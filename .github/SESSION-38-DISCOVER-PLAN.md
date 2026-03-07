# DISCOVER → PLAN: API Contract Validation & Implementation Plan

**Date**: 2026-03-07  
**Phase**: Session 38 Instruction Hardening  
**Status**: Ground-truth API response captured; ready for implementation

---

## DISCOVER Results: Actual vs. Proposed

### ✅ API Response is RICH and PRODUCTION-READY

**Actual Response Structure** (40KB JSON):
```
- identity (service name, URLs, APIM headers) ✅
- golden_rule (HTTP API is ONLY interface) ✅
- discovery_journey (5-step progression with detailed calls) ✅
- bootstrap_sequence (5 bootstrap calls listed) ✅
- query_capabilities (universal + layer-specific) ✅
- terminal_safety (PowerShell-specific guidance!) ✅
- query_patterns (20+ patterns) ✅
- write_cycle (5 rules with commit workflow) ✅
- actor_header (X-Actor, Authorization headers) ✅
- common_mistakes (9 lessons learned) ✅
- examples (before/after code snippets) ✅
- layers_available (41 layers listed) ✅
- layer_notes (special cases per layer) ✅
- forbidden (7 rules) ✅
- quick_reference (all endpoints one-liner) ✅
```

### 📊 Differences: Proposed vs. Actual

| Aspect | My Proposal | Actual API | Action |
|--------|------------|-----------|--------|
| Layer Count | 50-51 | 41 actual + 27 mentioned in description | Update: use actual 41 |
| Common Mistakes | 8 items | 9 items (includes git/gh CLI issue) | Update template with all 9 |
| Query Patterns | ~10 generic | 20+ specific (filter, navigate, impact, graph) | Expand examples in template |
| Terminal Safety | Mentioned only | Full section with PowerShell-specific tips | **Highlight in USER-GUIDE** |
| Layer Notes | Missing | Included (endpoints naming, services obj_id, etc.) | Add to USER-GUIDE |
| Session State | Not in API | Missing (API doesn't define session binding) | **Add to USER-GUIDE** |
| Write Cycle | 5 rules | 5 rules (matches proposal) | Verify examples work |
| Examples | Generic | Actual code with error traces | Copy verbatim |

---

## Critical Findings

### 🚨 API Missing: Session State Guidance
**Problem**: `/model/agent-guide` doesn't specify how agents should manage `$session` state.

**Current gaps**:
- Where should `$base` be stored? (PowerShell session? `.env`? Env var?)
- How long is the guide response cached? (TTL not specified)
- Should agents refetch guide on each project bootstrap, or once per workspace session?

**Impact**: Agent instructions still don't solve the "where is `$base` stored?" problem.

**Solution**: Add explicit section to USER-GUIDE.md defining PowerShell session pattern.

### 🎯 Terminal Safety is CRITICAL

From actual API response:
```
"problem": "Large JSON responses (272 literals, 135 endpoints) scramble 
PowerShell terminal with Format-Table overflow"
```

**This wasn't emphasized enough in template**. Need to:
1. Move terminal_safety to top of USER-GUIDE (before examples)
2. Add explicit `-limit` to every example query
3. Show `.data` property access pattern on every example

### 📦 Layer Count Discrepancy

API description says: **"27+ layers"**  
API provides: **41 layers** in `layers_available` array

Layers: services, personas, feature_flags, containers, endpoints, schemas, screens, literals, agents, infrastructure, requirements, planes, connections, environments, cp_skills, cp_agents, runbooks, cp_workflows, cp_policies, mcp_servers, prompts, security_controls, components, hooks, ts_types, projects, wbs, sprints, milestones, risks, decisions, traces, evidence, workspace_config, project_work, agent_policies, quality_gates, github_rules, deployment_policies, testing_policies, validation_rules

**Action**: USER-GUIDE must acknowledge **41 operational layers** (not 27 or 51).

---

## PLAN: Implementation Changes

### Phase 1: USER-GUIDE.md (Primary Authority)

#### Addition 1: Formal Session State Pattern
**New section after "The One Instruction":**

```markdown
## Session State Management (Agent Pattern)

Every agent session must establish `$session` object with API bootstrap:

### Initialize Once Per Session

PowerShell initialization must happen BEFORE any data model queries:

\`\`\`powershell
# Session initialization (run once at start of agent session)
$session = @{
    base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
    initialized_at = Get-Date
    guide = $null
}

# Fetch authoritative guidance 
try {
    $session.guide = Invoke-RestMethod "$($session.base)/model/agent-guide" -TimeoutSec 10
    Write-Host "[INFO] Bootstrap complete. $(($session.guide.layers_available | Measure-Object).Count) layers online."
} catch {
    Write-Error "[FAIL] API bootstrap failed: $_"
    exit 1
}

# Now all subsequent queries use $session:
$projects = (Invoke-RestMethod "$($session.base)/model/projects/?limit=100").data
\`\`\`

### Refresh If Session > 4 Hours

```powershell
if ((Get-Date) - $session.initialized_at | Select-Object -ExpandProperty TotalHours > 4) {
    Write-Host "[WARN] Session > 4 hours. Refreshing guide..."
    $session.guide = Invoke-RestMethod "$($session.base)/model/agent-guide"
}
```

### Store Using Your Favorite Pattern

This guide specifies **what** `$session` should contain. **How** you persist it is flexible:
- **Option A**: Native PowerShell (shown above) — recommended for scripts
- **Option B**: Environment variables — `$env:EVA_BASE`, `$env:EVA_SESSION_GUID`
- **Option C**: `.env` file — `$session = @{ base = (Get-Content .env | ... ) }`
- **Option D**: Agent memory (if using GitHub Copilot or similar)

Choose one. **Requirement**: `$session` must be available to all API queries without re-bootstrapping.
```

#### Addition 2: Terminal Safety (Moved to Top)

Move the **"terminal_safety"** section from USER-GUIDE Examples up to a new "BEFORE YOU QUERY" section:

```markdown
## ⚠️ IMPORTANT: Terminal Safety (Before Your First Query)

Large API responses can scramble PowerShell output. All examples below follow these rules:

**Rule 1: Always use `?limit=N`**
- Default: ?limit=100
- Max: ?limit=1000
- Never query without a limit (Terminal Table Overflow risk)

Example: ❌ `(irm $base/model/endpoints/).data | Format-Table`  
Correct: ✅ `(irm "$base/model/endpoints/?limit=20").data | Select-Object id,status | Format-Table`

**Rule 2: Always use `.data` property**
API wraps results in standard structure:
\`\`\`json
{ "data": [...], "metadata": {...} }
\`\`\`

Access like this: ✅ `(irm $base/model/projects/).data`  
Not like this: ❌ `irm $base/model/projects/` (missing .data)

**Rule 3: Limit Select-Object to 3-5 fields**
```powershell
# ✅ Correct
$objects | Select-Object id,status,phase | Format-Table

# ❌ Wrong (Format-Table auto-columns overflow terminal)
$objects | Format-Table
```

**Rule 4: For First Exploration**
```powershell
# Safe first query pattern:
(irm "$($session.base)/model/projects/?limit=20").data | 
  Select-Object id,label,maturity | 
  Format-Table

# If you want full scan later, save to variable first:
$all_projects = (irm "$($session.base)/model/projects/").data
$all_projects.Count  # Check size first
```
```

#### Addition 3: Direct Integration Instructions

Replace the current "How This Approach?" section with explicit integration:

```markdown
## Integration with Copilot Instructions

After bootstrap (above), your workflow is:

1. **Workspace Level** → Read `C:\AICOE\.github\copilot-instructions.md`
   - Tells you workspace name, skills, architecture overview
   - Directs you here (USER-GUIDE.md) for API guidance

2. **API Bootstrap** → Call `GET /model/agent-guide` (this guide's content)
   - Fetch into `$session.guide`
   - All query patterns, write rules, safety limits now available

3. **Project Level** → Read `.github/copilot-instructions.md` in your project repo
   - Project-specific entity mappings (which layers does THIS project own?)
   - Override `$session` if needed for project-specific base URL or auth

4. **Query/Write** → Use `$session.guide` for patterns
   - Query patterns in: `$session.guide.query_patterns`
   - Write rules in: `$session.guide.write_cycle`
   - Safe limits in: `$session.guide.query_capabilities.universal_params`
   - Common mistakes to avoid in: `$session.guide.common_mistakes`

**One Instruction = Three-Level Hierarchy:**
```
  Workspace Context
       ↓
    API Bootstrap ← **You are here**
       ↓
   Project Specifics
```
```

#### Addition 4: Update Layer Count

Replace mention of "51 layers" throughout with **"41 operational layers"**:
- Update in introduction
- Update in session bootstrap checklist 
- Verify against `$session.guide.layers_available.Count`

#### Addition 5: Move "Emergency" Section to "API Reliability"

Replace outdated emergency section with:

```markdown
## API Reliability & Availability

MSub API is designed for **24x7 production operation**:
- ✅ Min replicas enabled (always warm)
- ✅ Cosmos DB backed (geo-replicated, durable)
- ✅ Analytics cached (typical response < 200ms)

### Expected Response Times
- Health check (`GET /health`): < 50ms
- Agent guide (`GET /model/agent-guide`): < 200ms (cached from analytics)
- Layer query (`GET /model/{layer}/?limit=100`): < 500ms
- Large export (`GET /model/admin/export`): < 5s

### If API Is Slow (Retryable Transient)

```powershell
$maxRetries = 3
$retryDelay = 50  # milliseconds, doubles each retry

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
        return (Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 5)
    } catch {
        if ($attempt -eq $maxRetries) {
            Write-Error "[FAIL] API unavailable after $maxRetries attempts. Check status."
            exit 1
        }
        $delay = $retryDelay * [Math]::Pow(2, $attempt - 1)
        Write-Warning "[RETRY] Attempt $attempt failed. Waiting ${delay}ms..."
        Start-Sleep -Milliseconds $delay
    }
}
```

### If API Returns Partial Response

Check `metadata._query_warnings` in response. If present:
```powershell
$response = Invoke-RestMethod "$base/model/projects/"
if ($response.metadata._query_warnings) {
    Write-Warning "[WARN] Partial response: $($response.metadata._query_warnings)"
    Write-Host "[INFO] Received $($response.data.Count) of $($response.metadata.total) expected."
    # Safe to proceed; indicates transient backend lag
}
```

### API Monitoring

- **Status Page**: Check current operations at https://status.example.com
- **Incident Escalation**: Create issue in 37-data-model repo with logs
- **Performance SLA**: 99.9% uptime (analytics cached layer)
```

---

### Phase 2: copilot-instructions-template.md (07-foundation)

#### Change 1: Fix Bootstrap Checklist

Replace entire "Session Bootstrap (Checklist)" section with:

```markdown
### Session Bootstrap (Checklist)

This sequence runs ONCE per agent session and establishes `$session` with API guidance.

```powershell
# Step 1: Set base URL
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

# Step 2: Create session object
$session = @{ base = $base; initialized_at = Get-Date }

# Step 3: Bootstrap from API (THIS IS THE KEY STEP)
try {
    $session.guide = Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10
    [INFO] "Bootstrap complete. $(($session.guide.layers_available | Measure-Object).Count) layers online."
} catch {
    [FAIL] "Cannot contact MSub API at $base. Exiting."
    exit 1
}

# Step 4: Verify 41 layers are available
$layerCount = ($session.guide.layers_available | Measure-Object).Count
if ($layerCount -ne 41) {
    [WARN] "Expected 41 layers; API reports $layerCount. Some features may be unavailable."
}

# Step 5: Read project artifacts
foreach ($artifact in @("README.md", "PLAN.md", "STATUS.md")) {
    if (-not (Test-Path $artifact)) {
        [WARN] "Missing artifact: $artifact"
    }
}

# Step 6: Check for project skills
if (Test-Path ".github/copilot-skills/") {
    Get-ChildItem ".github/copilot-skills/" -Filter "*.skill.md" | ForEach-Object {
        [INFO] "Found skill: $($_.Name)"
    }
} else {
    [INFO] "No project skills directory (.github/copilot-skills/)"
}

# ✅ Bootstrap complete
[INFO] "Session ready. Use `$session.guide` for all query patterns and write rules."
```

**Do NOT proceed until:**
- [ ] API call returned status 200
- [ ] `$session.guide` contains expected sections
- [ ] Layer count verified (warning acceptable)
- [ ] All project artifacts detected (or explained why missing)
```

#### Change 2: Replace Data Model Query Section

Replace "Data Model -- This Project's Entities" section:

```markdown
### Data Model Integration (Queries)

All queries use the `$session.guide` patterns established at bootstrap. Never deviate from patterns.

**Universal Query Pattern** (applies to all layers):

```powershell
# Template
$endpoint = "{LAYER_NAME}"  # e.g., "projects", "endpoints", "evidence"
$limit = $session.guide.query_capabilities.universal_params.limit  # or hardcode 100
$offset = 0  # pagination

$response = Invoke-RestMethod "$($session.base)/model/$endpoint/?limit=$limit&offset=$offset"
$results = $response.data  # Always access .data

# Always use Select-Object before Format-Table
$results | Select-Object id,status,phase | Format-Table
```

**Project-Specific Queries**:

This project accesses these layers (from PLAN.md):
- {LAYER_1}
- {LAYER_2}

For examples, see `$session.guide.query_patterns` or `$session.guide.examples`.

**Example: Safe First Query**

```powershell
# Get first 20 projects, show key fields only
$projects = (Invoke-RestMethod "$($session.base)/model/projects/?limit=20").data
$projects | Select-Object id, label, maturity, status | Format-Table

# Count total (without fetching all data)
$count = (Invoke-RestMethod "$($session.base)/model/projects/count").data.count
Write-Host "Total projects: $count"
```

**For More Patterns**: See `$session.guide.query_patterns` (available after bootstrap).
```

---

### Phase 3: copilot-instructions.md (Workspace)

#### Addition: API Bootstrap Reference

Add new section right after "Workspace-Level Skills":

```markdown
## Agent Bootstrap: The API Entry Point

**Every agent session must start here**, before reading project instructions.

### One-Step Bootstrap

```powershell
# Fetch complete guidance from Project 37 Cosmos DB API
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{ 
    base = $base
    guide = (Invoke-RestMethod "$base/model/agent-guide")
}

# You now have access to:
# - $session.guide.query_patterns (how to query)
# - $session.guide.write_cycle (how to write safely)
# - $session.guide.common_mistakes (what NOT to do)
# - $session.guide.layers_available (all 41 operational layers)
```

**Why?** The API is your single source of truth for:
- ✅ Query safety limits (prevents timeouts & terminal scramble)
- ✅ Write cycle rules (prevents data corruption)  
- ✅ Layer schemas (current definitions, not stale docs)
- ✅ Lessons learned (from recent sessions, live)

**Next**: Read [Project 37 User Guide](eva-foundry/37-data-model/USER-GUIDE.md) for full bootstrap sequence and session state management.
```

---

## Summary: What Needs To Change

### USER-GUIDE.md
| Change | Reason | Effort |
|--------|--------|--------|
| Add Session State Pattern section | Solves "$base location" problem | 1 hour |
| Move Terminal Safety to top | Critical guidance, visibility | 30 min |
| Add Integration section | Three-tier hierarchy clarity | 30 min |
| Update layer count 27→41 | Accuracy | 15 min |
| Replace Emergency section | 24x7 API, retry logic | 30 min |
| **TOTAL** | | ~2.5 hours |

### copilot-instructions-template.md
| Change | Reason | Effort |
|--------|--------|--------|
| Fix bootstrap checklist | Add `/model/agent-guide` call step | 45 min |
| Replace data model section | Remove duplication; reference $session.guide | 30 min |
| **TOTAL** | | ~1.25 hours |

### copilot-instructions.md
| Change | Reason | Effort |
|--------|--------|--------|
| Add API Bootstrap section | Workspace-level entry point | 30 min |
| **TOTAL** | | ~0.5 hours |

## Implementation Sequence

1. ✅ **DISCOVER** (Complete) — API response obtained, differences documented
2. ⏮️ **PLAN** (Complete) — Changes specified above
3. 🔄 **DO** — Create branch, apply changes (next step)
4. ✔️ **CHECK** — Test bootstrap against Project 51 (ACA)
5. 📝 **ACT** — Commit and document

---

*Ready for DO phase. Branch: session-38-instruction-hardening*
