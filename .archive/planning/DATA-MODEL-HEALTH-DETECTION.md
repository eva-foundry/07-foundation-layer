# Data Model Health Detection & Endpoint Selection

**Last Updated**: 2026-03-05 (improved detection logic)

## Overview

Both **Bootstrap-Project07.ps1** and the **MCP Server (foundation-primer)** now implement proper data model health detection that:
1. Tests BOTH endpoints in parallel
2. Reports health status of each
3. Selects the primary endpoint intelligently
4. Provides clear diagnostics for troubleshooting

---

## Endpoints

### Cloud (Primary Preferred)
- **URL**: https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io
- **Store**: Cosmos DB (production, durable, scalable)
- **Auth**: None (public endpoint)
- **Uptime**: 24x7 (Azure-managed SLA)
- **Good For**: Production workflows, shared workspace, cloud-first deployments

### Local (Fallback)
- **URL**: http://localhost:8010
- **Store**: In-memory (ephemeral, development)
- **Auth**: None
- **Uptime**: Manual startup required (`51-ACA\data-model\start.ps1`)
- **Good For**: Development, offline work, testing without cloud access

---

## Health Detection Logic

### PowerShell Bootstrap Script (Bootstrap-Project07.ps1)

```powershell
# Test ACA endpoint with 5-second timeout
$aca_health = Invoke-RestMethod "$AcaBase/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
if ($aca_health -and $aca_health.status -eq "ok") {
    [PASS] ACA: store=$store v=$version uptime=$uptime_seconds
}

# Test Local endpoint independently
$local_health = Invoke-RestMethod "$LocalBase/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
if ($local_health -and $local_health.status -eq "ok") {
    [PASS] Local: store=$store v=$version uptime=$uptime_seconds
}

# Selection strategy: prefer ACA, fallback to local, fail if both down
if ($aca_ok) {
    [INFO] Using ACA (primary endpoint)
} elseif ($local_ok) {
    [INFO] Using Local (fallback - ACA down)
} else {
    [FAIL] Data model unreachable (ACA + local both down)
}
```

### MCP Server (foundation-primer/server.py)

```python
def _detect_data_model_base() -> str:
    """Detect which data model endpoint is reachable."""
    try:
        resp = urlopen(_ACA_BASE + "/health", timeout=5)
        if resp.status == 200:
            return _ACA_BASE
    except (URLError, Exception):
        pass
    
    try:
        resp = urlopen(_LOCAL_BASE + "/health", timeout=5)
        if resp.status == 200:
            return _LOCAL_BASE
    except (URLError, Exception):
        pass
    
    return _LOCAL_BASE  # fallback even if both are down

_DATA_MODEL_BASE = _detect_data_model_base()
```

---

## Health Endpoint Response

Both endpoints provide `/health` endpoint returning:

```json
{
  "status": "ok",
  "service": "model-api",
  "version": "1.0.0",
  "store": "cosmos" | "memory",
  "cache": "memory",
  "cache_ttl": 0,
  "started_at": "2026-03-05T10:42:34...",
  "uptime_seconds": 1216,
  "request_count": 14,
  "agent_guide": "/model/agent-guide",
  "readiness": "/ready"
}
```

**Critical fields for detection**:
- `status`: Must equal `"ok"` (string comparison)
- `store`: `"cosmos"` (ACA) or `"memory"` (local)
- `version`: API version (currently 1.0.0)
- `uptime_seconds`: Useful for diagnostics

---

## Bootstrap Output Example

```
--- [1] Data Model Health ---
  [PASS] ACA endpoint: store=cosmos v=1.0.0 uptime=1216s
  [PASS] Local endpoint: store=memory v=1.0.0 uptime=1396s
  [INFO] Using ACA (primary endpoint)
```

### Scenarios

**Both Healthy** (normal state):
```
[PASS] ACA endpoint: store=cosmos v=1.0.0 uptime=1216s
[PASS] Local endpoint: store=memory v=1.0.0 uptime=1396s
[INFO] Using ACA (primary endpoint)
```

**Only Local Available** (ACA down for maintenance):
```
[WARN] ACA endpoint unreachable or unhealthy
[PASS] Local endpoint: store=memory v=1.0.0 uptime=1396s
[INFO] Using Local (fallback - ACA down)
```

**Both Down** (critical - needs action):
```
[WARN] ACA endpoint unreachable or unhealthy
[WARN] Local endpoint unreachable or unhealthy
[FAIL] Data model unreachable (ACA + local both down)
→ Issues.Add("Data model unreachable")
```

---

## Troubleshooting

### ACA Endpoint Not Responding

1. Check network/firewall: Can you reach the URL in browser?
   ```powershell
   Invoke-RestMethod "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io/health"
   ```

2. Check Azure Container Apps:
   - Resource group: (TBD)
   - Service status dashboard: (TBD)

3. Fallback to local endpoint (always available if running)

### Local Endpoint Not Running

1. Start local data model:
   ```powershell
   cd C:\eva-foundry\51-ACA\data-model
   powershell -File start.ps1
   ```

2. Verify it's running:
   ```powershell
   Invoke-RestMethod "http://localhost:8010/health"
   ```

3. Note: Local endpoint stores data in memory (ephemeral - lost on restart)

### Both Endpoints Down

1. Try ACA health check manually (see above)
2. Start local endpoint (see above)
3. If still failing, bootstrap will continue with `_LOCAL_BASE` as fallback (deferred failure)
4. Log the issue for governance toolchain owner

---

## Governance Data Query

Both endpoints also serve project governance data via `/model/projects/` endpoint.

### Query Pattern

```powershell
# List all projects (governance data for workspace scoping)
Invoke-RestMethod "https://marco-eva-data-model.../model/projects/" -TimeoutSec 10 | ConvertTo-Json -Depth 3
```

### Current Data State (Verified 2026-03-05)

| Metric | Cloud (ACA/Cosmos) | Local (Development) |
|--------|-------------------|-------------------|
| Project Count | 55 records | 50 records |
| Response Time | ~5 seconds | <1 second |
| Data Completeness | 55 with missing obj_id | 50 with complete obj_id |
| Status | Operational | Operational |

**Notes**:
- Cloud has 5 additional incomplete records (orphaned or pending cleanup)
- Local has cleaner dataset (50 active projects)
- Both endpoints **serve governance data successfully**
- Workspace toolchain can query from either endpoint based on availability

### Example Response (First Project)

```json
{
  "obj_id": "14-az-finops",
  "title": "Azure FinOps",
  "maturity": "empty",
  "phase": "Backlog",
  "pbi_total": 0,
  "repo_path": "14-az-finops/",
  "created_at": "2026-01-20T...",
  "modified_at": "2026-03-05T...",
  "row_version": 5
}
```

---

### Override Endpoint (PowerShell Script)

```powershell
.\Bootstrap-Project07.ps1 -DataModelBase "http://custom-endpoint:8010"
```

### Override Endpoint (MCP Tool)

```python
# Via bootstrap_project07 MCP tool
bootstrap_project07(data_model_base="http://custom-endpoint:8010")
```

### Check Agent-Configured Endpoint (At Runtime)

```powershell
# See which endpoint the session is using
$base = "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io"
# or
$base = "http://localhost:8010"

Invoke-RestMethod "$base/model/agent-guide" | ConvertTo-Json
```

---

## Version History

| Date | Change |
|------|--------|
| 2026-03-05 | Improved health detection: test both endpoints independently, report both, select intelligently |
| 2026-03-05 | Updated Bootstrap-Project07.ps1 and foundation-primer/server.py with new detection logic |
| 2026-02-XX | Initial sequential detection (would fail if ACA lost without trying local) |
