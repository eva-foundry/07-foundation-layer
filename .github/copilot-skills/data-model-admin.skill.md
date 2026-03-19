# Data Model Admin Skill

**Skill Name**: `@data-model-admin`  
**Domain**: Project 37 Governance & Operations  
**Audience**: Workspace administrators, project leads, agents performing data model operations  
**Last Updated**: Session 38 (March 7, 2026)  

---

## Overview

This skill provides operational guidance for administering Project 37 (EVA Data Model) across the workspace. It covers API safety patterns, data seeding, layer management, evidence submission, and validation rules.

### When to Use This Skill

**DO use when**:
- Querying Project 37 API (safe limits, pagination, filtering)
- Seeding project data from PLAN.md files
- Adding or updating data model layers
- Submitting agent/project evidence for auditing
- Validating data model schemas
- Troubleshooting API timeouts or connection failures
- Checking evidence correlation traces

**DO NOT use when**:
- Deploying Project 37 infrastructure (ACA, Cosmos DB) -- use DevOps runbooks
- Implementing Project 37 business logic -- use Project 37 developers
- Querying Azure resources directly -- use Azure skills
- Troubleshooting client app failures unrelated to data model

---

## 1. Bootstrap Pattern

Every agent session must bootstrap from Project 37 cloud API before performing operations.

### Mandatory Bootstrap Sequence

```python
# Step 1: Initialize session from cloud API (REQUIRED)
import requests
import time

base_url = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacontainerapps.io"
session_state = {
    "base": base_url,
    "initialized_at": time.time(),
    "refresh_ttl": 14400  # 4 hours in seconds
}

try:
    # Step 2: Fetch agent guide (complete protocol + safety rules)
    response = requests.get(f"{base_url}/model/agent-guide", timeout=5)
    response.raise_for_status()
    session_state["guide"] = response.json()
except requests.Timeout:
    print("⚠️  Cloud API timeout. Using file-based fallback.")
    session_state["guide"] = load_fallback_guide()  # Local JSON backup
except Exception as e:
    print(f"❌ Bootstrap failed: {e}. Stop and investigate.")
    exit(1)

# Step 3: Verify core fields before proceeding
assert "query_patterns" in session_state["guide"], "Missing query_patterns in API response"
assert "write_cycle" in session_state["guide"], "Missing write_cycle in API response"
assert "layers_available" in session_state["guide"], "Missing layers_available in API response"
```

### Bootstrap Refresh

Sessions are valid for **4 hours**. After, re-bootstrap:
```python
if (time.time() - session_state["initialized_at"]) > session_state["refresh_ttl"]:
    print("🔄 Session TTL expired. Refreshing...")
    session_state = bootstrap_session()  # Re-run bootstrap sequence
```

---

## 2. API Query Patterns (Safe Limits)

Project 37 enforces hard safety limits to prevent timeouts and resource exhaustion.

### Query Type: Layers (List All 41)

**Endpoint**: `GET /model/layers`  
**Safe Limit**: Always use (no pagination defaults to all layers)  
**Response**: Array of 41 layer metadata objects

```python
# SAFE: Fetch all layers
response = requests.get(
    f"{base_url}/model/layers",
    timeout=10
)
all_layers = response.json()
print(f"✅ Retrieved {len(all_layers)} layers")
```

### Query Type: Stories (Paginated)

**Endpoint**: `GET /model/stories?project_id={id}&limit={limit}&skip={skip}`  
**Default Limit**: 100 stories  
**Max Limit**: 500 stories  
**Pagination**: Use `skip` to fetch pages

```python
# SAFE: Fetch paginated stories for a project
project_id = "07"
stories_all = []
skip = 0

while True:
    response = requests.get(
        f"{base_url}/model/stories",
        params={
            "project_id": project_id,
            "limit": 100,
            "skip": skip
        },
        timeout=10
    )
    response.raise_for_status()
    page = response.json()
    
    if not page:
        break  # No more stories
    
    stories_all.extend(page)
    skip += 100

print(f"✅ Retrieved {len(stories_all)} total stories for project {project_id}")
```

### Query Type: Evidence (Time-Range Windowed)

**Endpoint**: `GET /model/evidence?project_id={id}&start_time={ts}&end_time={ts}`  
**Time Window**: Max 30 days per query  
**Response**: Immutable audit trail records

```python
# SAFE: Query evidence with time windowing
import datetime

project_id = "07"
end_time = datetime.datetime.utcnow()
start_time = end_time - datetime.timedelta(days=7)  # Last 7 days

response = requests.get(
    f"{base_url}/model/evidence",
    params={
        "project_id": project_id,
        "start_time": start_time.isoformat(),
        "end_time": end_time.isoformat()
    },
    timeout=15
)
evidence = response.json()
print(f"✅ Retrieved {len(evidence)} evidence records (7-day window)")
```

### ❌ UNSAFE Query Patterns

**DO NOT do**:
```python
# ❌ WRONG: Fetch ALL evidence across all projects without time windowing
requests.get(f"{base_url}/model/evidence")  # Will timeout and fail

# ❌ WRONG: Fetch stories without pagination
requests.get(f"{base_url}/model/stories?limit=10000")  # Exceeds max limit

# ❌ WRONG: Loop without checking response status
for i in range(0, 100000, 100):  # Spins forever without checking data
    requests.get(f"{base_url}/model/stories?skip={i}")
```

---

## 3. Data Seeding (Project → Data Model)

### Automated Seeding: seed-from-plan.py

Project 07 provides a **universal seeding script** that works for ANY project.

**Location**: `07-foundation-layer/scripts/data-seeding/seed-from-plan.py`  
**Language**: Python 3.10+  
**Purpose**: Parse PLAN.md → extract stories → sync to Project 37 API

### Usage

```bash
# Seed a specific project (auto-detects project ID from folder name)
python seed-from-plan.py --project-id "36"

# Reseed (overwrite existing entries)
python seed-from-plan.py --project-id "36" --reseed-model

# Seed current working directory's project
python seed-from-plan.py

# Dry-run (show what would be seeded, do not write)
python seed-from-plan.py --dry-run
```

### How It Works

1. **Project ID Detection** (4-tier fallback):
   - Explicit `--project-id` argument
   - Environment variable `EVA_PROJECT_ID`
   - Folder name inference (e.g., `36-red-teaming` → project ID `36`)
   - PLAN.md scan for `"project_id": "36"` field

2. **PLAN.md Parsing** (flexible format support):
   - Extracts epics, features, stories (no rigid format required)
   - Handles Markdown headers, JSON, YAML, plaintext list formats
   - Generates RFC-4122 UUID for each story if not provided
   - Associates stories with DPDCA phases

3. **Output Generation**:
   - `.eva/veritas-plan.json` -- Veritas story roster with traceability IDs
   - HTTP POST to `{base_url}/model/stories/batch` -- Project 37 ingestion
   - Evidence record with correlation ID to Evidence Layer (L31)
   - ASCII-only output (no Unicode >U+007F for Windows Enterprise safety)

4. **Idempotency**:
   - Detects existing stories (by UUID) and skips duplicates
   - `--reseed-model` flag forces overwrite for updates
   - Uses optimistic concurrency (timestamps prevent lost updates)

### Example: Seed Project 36 (Red-Teaming)

```bash
cd c:\eva-foundry\36-red-teaming
python ../07-foundation-layer/scripts/data-seeding/seed-from-plan.py

# Output:
# ✅ Project ID detected: 36
# ✅ PLAN.md parsed: 15 stories found
# ✅ Synced to API: 15 stories → Project 37 stories table
# ✅ Evidence created: Correlation ID evc_abc12356_20260307_093412
# ✅ Veritas roster: .eva/veritas-plan.json (15 entries)
```

---

## 4. Layer Management

Project 37 maintains 41 operational layers. Workspace managers can add custom layers following this protocol.

### Understanding the 41 Layers

| Layer Range | Purpose | Count |
|---|---|---|
| L0–L15 | Entity metadata (services, personas, features, containers, endpoints) | 16 |
| L16–L30 | DPDCA process tracking (requirements, plans, executions, tests, remediation) | 15 |
| L31 | **Evidence Layer** (immutable audit trails, correlation IDs, patent-filed) | 1 |
| L32–L40 | Governance (quality gates, MTI scoring, compliance, workspace registry) | 9 |

### Layer Validation Before Adding

Before proposing a new layer, verify:

```python
def validate_layer_proposal(layer_id, layer_name, schema):
    """
    Validate new layer before submission to Project 37.
    Returns: (is_valid: bool, errors: list[str])
    """
    errors = []
    
    # Check 1: Layer ID uniqueness
    response = requests.get(f"{base_url}/model/layers")
    existing_ids = [l["id"] for l in response.json()]
    if layer_id in existing_ids:
        errors.append(f"Layer ID {layer_id} already exists (duplicate)")
    
    # Check 2: Layer name uniqueness
    existing_names = [l["name"] for l in response.json()]
    if layer_name in existing_names:
        errors.append(f"Layer name '{layer_name}' already exists (duplicate)")
    
    # Check 3: Schema validation
    required_fields = ["id", "name", "description", "data_type", "owner_project"]
    for field in required_fields:
        if field not in schema:
            errors.append(f"Schema missing required field: {field}")
    
    # Check 4: Layer ID numeric bounds (0-40 reserved for core, 41+ for custom)
    if layer_id < 41 and layer_id >= 0:
        errors.append(f"Layer ID {layer_id} conflicts with core layers (0-40). Use ID >= 41.")
    
    is_valid = len(errors) == 0
    return is_valid, errors
```

### Layer Addition Workflow

1. **Propose in PLAN.md** (Project 07):
   ```markdown
   ## Feature F07-03-002: Elevate Workspace Patterns
   - Story 1: Add workspace-level caching layer (L42)
     - Owner: Project 07
     - Schema: { layer_id, project_id, cache_key, cache_value, ttl }
     - Rationale: Share cache across all projects
   ```

2. **Validate** (this skill):
   ```python
   is_valid, errors = validate_layer_proposal(42, "workspace_cache", schema)
   if not is_valid:
       print(f"❌ Validation failed: {errors}")
   else:
       print("✅ Ready for submission")
   ```

3. **Submit to Project 37**:
   ```python
   response = requests.post(
       f"{base_url}/admin/layers/add",
       json={
           "layer_id": 42,
           "layer_name": "workspace_cache",
           "schema": {...},
           "owner_project": "07",
           "rationale": "Share cache across all projects"
       },
       timeout=10
   )
   ```

4. **Track in Evidence Layer** (automatic upon success):
   - New layer registered with creation timestamp
   - Correlation ID links proposal → validation → addition

---

## 5. Evidence Submission (Project → Layer 31)

All projects submit evidence to the Evidence Layer (L31) for auditing, compliance, and traceability.

### Evidence Record Structure

```python
evidence_record = {
    "evidence_id": "evc_07_20260307_093412",  # UUID + project + timestamp
    "project_id": "07",
    "artifact_type": "test_run",  # or: acceptance_gate, deployment, remediation, etc.
    "artifact_key": "AC-4-bootstrap-api-tests",
    "status": "PASS",  # or: FAIL, WARN, SKIP
    "timestamp": "2026-03-07T09:34:12Z",
    "correlation_id": "corr_abc123def456",  # Links to other evidence records
    "metadata": {
        "test_count": 4,
        "pass_count": 2,
        "skip_count": 1,
        "warn_count": 1,
        "metrics": {"api_latency_ms": 234, "schema_checks": 23}
    },
    "evidence_url": "https://github.com/microsoft/eva-foundry/blob/main/07-foundation-layer/tests/test-bootstrap-api.py"
}
```

### Evidence Submission Pattern

```python
def submit_evidence(project_id, artifact_type, artifact_key, status, metadata):
    """Submit evidence to Project 37 Evidence Layer (L31)"""
    
    evidence_record = {
        "project_id": project_id,
        "artifact_type": artifact_type,
        "artifact_key": artifact_key,
        "status": status,
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        "metadata": metadata
    }
    
    response = requests.post(
        f"{base_url}/model/evidence",
        json=evidence_record,
        timeout=10
    )
    response.raise_for_status()
    
    result = response.json()
    print(f"✅ Evidence submitted: {result['evidence_id']}")
    return result['evidence_id']
```

### Evidence Artifact Types

| Type | Purpose | Examples |
|---|---|---|
| `test_run` | Unit/integration test execution | AC-4 bootstrap tests, acceptance gate verifications |
| `acceptance_gate` | Feature readiness checkpoint | AC-1 through AC-9 completions |
| `deployment` | Infrastructure or application deployment | ACA container pushes, Terraform applies |
| `remediation` | Bug fix or issue resolution | Test suite fixes, API patches |
| `audit_scan` | Compliance or security scan | DPDCA checkpoint, MTI validation |
| `performance_metric` | Operational performance data | API latency, request counts, error rates |

### Real Example: AC-4 Test Results

```python
# File: 07-foundation-layer/tests/test-bootstrap-api.py
result = run_test_ac4_bootstrap_api()

# Submit to Project 37
evidence_id = submit_evidence(
    project_id="07",
    artifact_type="acceptance_gate",
    artifact_key="AC-4-bootstrap-api-tests",
    status="PASS",  # 2 pass, 1 skip, 1 warn = PASS overall
    metadata={
        "test_count": 4,
        "pass_count": 2,
        "skip_count": 1,
        "warn_count": 1,
        "test_results": {
            "Test 1: Bootstrap Cloud": "PASS",
            "Test 2: Bootstrap Files": "PASS",
            "Test 3: Performance": "WARN (threshold near)",
            "Test 4: Fallback Resilience": "SKIP (future)"
        },
        "metrics": {
            "api_latency_ms": 234,
            "schema_assertions": 23,
            "validation_time_ms": 45
        }
    }
)

print(f"🎯 AC-4 evidence recorded: {evidence_id}")
```

---

## 6. Troubleshooting

### Symptom: "Cloud API timeout"

**Root Causes**:
- Network connectivity issue (check proxy, firewall)
- Project 37 ACA instance down (check DevOps status page)
- Query without pagination (using unsafe pattern)

**Resolution**:
```python
# Step 1: Check connectivity
import subprocess
result = subprocess.run(["ping", "-c", "1", "msub-eva-data-model.victoriousgrass..."], capture_output=True)

# Step 2: Use file-based fallback while investigating
session_state["guide"] = load_fallback_guide()

# Step 3: Retry with exponential backoff
for attempt in range(3):
    try:
        response = requests.get(f"{base_url}/model/layers", timeout=15)
        break
    except requests.Timeout:
        wait_time = 2 ** attempt
        print(f"⚠️  Timeout. Retrying in {wait_time}s...")
        time.sleep(wait_time)
```

### Symptom: "Validation error: Layer ID out of bounds"

**Root Cause**: Using layer ID `<0` or `>40` for new layers (core range)  
**Resolution**: Use layer ID `≥41` for custom layers

### Symptom: "Evidence not appearing in audit trail"

**Root Cause**: Evidence submission succeeded but correlation ID missing  
**Resolution**:
```python
# Ensure correlation_id is set when submitting related evidence
evidence_record = {
    "correlation_id": previous_evidence_id,  # Links to earlier evidence
    ...
}
```

---

## 7. Related Skills & Automation

| Skill | Purpose |
|---|---|
| `@red-teaming-integration` | Red-teaming evidence → Project 37 L31 |
| `@eva-factory-guide` | DPDCA cycle → seed-from-plan.py patterns |
| `seed-from-plan.py` | Universal orchestrator (read PLAN.md → sync to API) |
| `Invoke-PrimeWorkspace.ps1` | Workspace automation (includes data model seeding) |

---

## 8. Key Takeaways

✅ **Always bootstrap from cloud API first** -- enables all operations  
✅ **Use safe query limits** -- prevent timeouts (100 stories default, 500 max)  
✅ **Seed via seed-from-plan.py** -- universal pattern for ANY project  
✅ **Submit evidence via Evidence Layer (L31)** -- enables audit trails and traceability  
✅ **Validate layers before adding** -- prevent conflicts and duplicates  
✅ **Use 4-hour TTL refresh** -- keep sessions fresh for long-running processes  

---

## 9. Quick Reference

**Bootstrap**:
```python
session = bootstrap_from_cloud_api("https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io")
```

**Query Stories**:
```python
requests.get(f"{base_url}/model/stories", params={"project_id": "07", "limit": 100, "skip": 0})
```

**Seed Project**:
```bash
python 07-foundation-layer/scripts/data-seeding/seed-from-plan.py --project-id "36"
```

**Submit Evidence**:
```python
submit_evidence("07", "acceptance_gate", "AC-4-bootstrap-api-tests", "PASS", metadata)
```

---

**Revision**: 1.0.0 (March 7, 2026)  
**Maintainer**: Project 07 (Foundation Layer)  
**Last Validated**: Session 38
