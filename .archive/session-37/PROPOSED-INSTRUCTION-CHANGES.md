# Proposed Changes to Instructions Architecture

**Context**: MSub API is 24x7 available (min replicas + analytics enabled). Agent bootstrap should fetch detailed guidance from Cosmos DB via `/model/agent-guide` endpoint.

**Assessment Date**: 2026-03-07  
**Current State**: Three-tier instruction system with discovered gaps

---

## Problem Statement

### Current Architecture Gaps

1. **USER-GUIDE.md delegates to API but API contract is vague**
   - File says "call `/model/agent-guide`" but doesn't specify response structure
   - Response sections listed (identity, golden_rule, etc.) but not documented
   - Agent doesn't know: cache strategy, TTL, how to handle partial responses

2. **copilot-instructions-template.md conflicts with USER-GUIDE.md**
   - Template: "Set `$base = ...` [undefined location]"
   - Template: Query `/model/projects/`, `/model/screens/`, `/model/endpoints/`
   - USER-GUIDE.md: Call `/model/agent-guide` for complete guidance
   - **Unclear**: Should agent use pre-computed guide or query individual layers?

3. **No integration spec between workspace + project + API guidelines**
   - Workspace instructions say "read workspace context"
   - Template says "read workspace context, then project README/PLAN"
   - USER-GUIDE says "call API for everything"
   - **Unclear**: Precedence and integration order

4. **Session bootstrap state is undefined**
   - `$base` variable location not specified
   - No cache invalidation strategy
   - No recovery if API call fails mid-session
   - No signal that bootstrap is complete

5. **24x7 API availability not fully leveraged**
   - "Emergency: If API Is Down" section is outdated
   - Should be: "API is authoritative, always call it; includes analytics"
   - No telemetry strategy for agent requests

---

## Proposed Solution Architecture

```
┌─────────────────────────────────────────────────────┐
│  Agent Session Lifecycle                            │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 1. WORKSPACE CONTEXT          │
        │ - Read copilot-instructions   │
        │ - Identify caller context     │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 2. API BOOTSTRAP (← NEW)       │
        │ - Call GET /model/agent-guide  │
        │ - Cache in $session            │
        │ - Verify 51 layers active      │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 3. PROJECT-SPECIFIC           │
        │ - Read project copilot-*      │
        │ - Override from $session      │
        │ - Set query filters           │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 4. WORK                       │
        │ - Query API using $session    │
        │ - Apply patterns from guide   │
        └───────────────────────────────┘
```

---

## Changes Required

### 1. USER-GUIDE.md: Restructure Around API Contract

**Current Issues:**
- Promises API returns complete guide but doesn't detail structure
- "Emergency" section outdated (API is now 24x7)
- No integration path with copilot-instructions.md

**Proposed Changes:**

#### 1a. Clearly Define API Contract
Add a formal section after "What You'll Get":

```markdown
## Agent Guide API Contract

**Endpoint**: `GET /model/agent-guide`  
**Availability**: 24x7 (min replicas enabled)  
**Response Time**: <200ms (analytics cached)  
**Cache Strategy**: Call once per agent session; store in `$session.guide`  
**Freshness**: Call again if session > 4 hours old  

### Response Structure

```json
{
  "service": { "name", "version", "endpoints": {...} },
  "bootstrap": {
    "steps": [{step, description, query_template}],
    "expected_counts": {"projects": 56, "layers": 51, ...}
  },
  "query": {
    "universal_params": [...],
    "layer_schemas": {...},
    "safe_limits": {"max_results": 10000, "recommended": 100}
  },
  "write": {
    "rules": [{rule, example_before, example_after}],
    "actor_header": "X-Actor",
    "validation": {...}
  },
  "patterns": {
    "query_examples": [...],
    "common_mistakes": [{error, cause, fix}]
  },
  "forbidden": [...]
}
```

**What This Means for Agents:**
- After calling `/model/agent-guide`, store full response in `$session.guide`
- All query guidance is in `$session.guide.query` (not scattered docs)
- All write rules are in `$session.guide.write` (centralized)
- Pattern examples are in `$session.guide.patterns` (authoritative)
```

#### 1b. Integration Section
Add after bootstrap:

```markdown
## How This Guide Integrates with copilot-instructions

The agent bootstrap sequence is:

1. **Workspace Level** (`C:\AICOE\.github\copilot-instructions.md`)
   - Identifies workspace, skills, references
   - Sets `$base` variable (API endpoint)

2. **API Bootstrap** (← This guide)
   - Calls `GET /model/agent-guide`
   - Stores response in `$session.guide` (in-memory)
   - Validates 51 layers are operational

3. **Project Level** (`.github/copilot-instructions.md` in project repo)
   - Reads project README/PLAN/STATUS
   - Overrides `$session.guide` with project-specific rules if needed
   - Inherits all API query patterns from step 2

**Key Point:** If copilot-instructions.md says "call `/model/projects/`", that query is defined in `$session.guide.query.safe_limits` and patterns in`$session.guide.patterns.query_examples`.
```

#### 1c. Session State Binding
Add formal section:

```markdown
## Session State Management

Agents MUST follow this pattern for session lifecycle:

**Initialization (per-session, once):**

```powershell
# 1. Set base API endpoint (from workspace instructions)
$session = @{
    base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
    initialized_at = Get-Date
}

# 2. Fetch authoritative guide from API
try {
    $session.guide = Invoke-RestMethod "$($session.base)/model/agent-guide"
    $session.guide_version = $session.guide.service.version
    $session.layers_available = $session.guide.bootstrap.expected_counts.layers
    [INFO] "Bootstrap complete. $($session.layers_available) layers online."
} catch {
    [FAIL] "API bootstrap failed: $_"
    exit 1
}

# 3. Verify prerequisites
if ($session.layers_available -ne 51) {
    [WARN] "Not all layers available ($($session.layers_available)/51)"
}
```

**Per-Operation (any query):**

```powershell
# Apply safe limits from $session
$limit = $session.guide.query.safe_limits.recommended  # Usually 100

# Query using established pattern
$results = (Invoke-RestMethod "$($session.base)/model/projects/?limit=$limit").data

# Access results
$results | Select-Object id, name, status
```

**Session Refresh (if > 4 hours):**

```powershell
if ((Get-Date) - $session.initialized_at | Select-Object -ExpandProperty TotalHours) {
    Write-Host "[INFO] Session > 4 hours; refreshing guide..."
    $session.guide = Invoke-RestMethod "$($session.base)/model/agent-guide"
}
```
```

#### 1d. Replace "Emergency: If API Is Down"

**Current (Outdated):**
```
If the API is unreachable, the backup guide is in your conversation history. 
But ALWAYS try the API first - it has the latest guidance including lessons 
learned from recent sessions.
```

**Proposed (24x7-Aware):**
```markdown
## API Availability & Reliability

The MSub API is **designed for 24x7 operation**:
- ✅ Min replicas enabled (always warm)
- ✅ Analytics cached (sub-200ms response)
- ✅ Cosmos DB backing (durable, geo-replicated)

**What If API Is Slow?**
- Retry with exponential backoff (50ms → 100ms → 200ms)
- If still unavailable after 3 retries: Fail fast with clear error
- Log to workspace analytics for investigation

**What If API Returns Partial Response?**
- Check `metadata._query_warnings` in response
- Partial data is safe to proceed with (indicates transient issue)
- Inform user: "[WARN] Received 95% of expected results due to transient API lag"

**Recovery Pattern:**
```powershell
$maxRetries = 3
$retryDelayMs = 50
for ($i = 0; $i -le $maxRetries; $i++) {
    try {
        $guide = Invoke-RestMethod "$($session.base)/model/agent-guide" -TimeoutSec 5
        return $guide
    } catch {
        if ($i -eq $maxRetries) {
            throw "[FAIL] API unavailable after $maxRetries retries. Check https://status.example.com"
        }
        Start-Sleep -Milliseconds ($retryDelayMs * [Math]::Pow(2, $i))
    }
}
```

This ensures agents respect the 24x7 guarantee while having sensible fallback logic.
```

---

### 2. copilot-instructions-template.md: Align with API-First Bootstrap

**Current Issues:**
- "Set `$base = ...`" is vague about location
- Session bootstrap checklist doesn't reference `/model/agent-guide`
- Data model queries section duplicates guidance (should reference guide)

**Proposed Changes:**

#### 2a. Clarify $base Variable Binding
**Replace this:**
```
- [ ] Set `$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"`
```

**With this:**
```
- [ ] Set `$base` in session (PowerShell script shown below)
```

#### 2b. Update Bootstrap Checklist
**Replace:** The entire "Session Bootstrap (Checklist)" section

**With:**
```markdown
### Session Bootstrap (Checklist)

Every agent session must run this sequence ONCE:

```powershell
# Step 1: Establish session with API endpoint
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{ base = $base; initialized_at = Get-Date }

# Step 2: Fetch authoritative guidance from Cosmos DB
try {
    $session.guide = Invoke-RestMethod "$base/model/agent-guide"
} catch {
    Write-Error "[FAIL] Bootstrap failed: cannot reach API at $base"
    exit 1
}

# Step 3: Verify expected state
$layers = $session.guide.bootstrap.expected_counts.layers
if ($layers -ne 51) {
    Write-Warning "[WARN] Expected 51 layers; API reports $layers. Some features may be unavailable."
}

# Step 4: Read project artifacts (README → PLAN → STATUS)
Get-Content "README.md", "PLAN.md", "STATUS.md" | Select-String "^#"  # Quick scan

# Step 5: Check project skills  
if (Test-Path ".github/copilot-skills/") {
    Get-ChildItem ".github/copilot-skills/" -Filter "*.skill.md" | Select-Object Name
}

# ✅ Bootstrap complete. $session is now ready for all operations.
Write-Host "[INFO] Session bootstrap complete. Use `$session.guide` for all query patterns."
```

**DO NOT proceed until:**
- [ ] API call succeeded (status 200)
- [ ] `$session.guide` contains >= 50 properties
- [ ] Layer count is verified (warning OK, but must be reported)
- [ ] Project README is present
```

#### 2c. Replace "Data Model -- This Project's Entities" with Integration Reference

**Replace:** The existing section with query templates

**With:**
```markdown
### Data Model Integration

This project's queries are defined in `$session.guide.query.safe_limits` and patterned in `$session.guide.patterns.query_examples`.

**To query any layer:**

All layer queries follow this pattern (defined at bootstrap):

```powershell
# Query pattern from $session.guide
$endpoint = "{LAYER_NAME}"  # e.g., "projects", "endpoints", "screens"
$limit = $session.guide.query.safe_limits.recommended  # Default: 100
$response = Invoke-RestMethod "$($session.base)/model/$endpoint/?limit=$limit"
$results = $response.data  # Always access .data property
```

**Project-Specific Entities:**

This project owns these data model layers:
- {LAYER_1}: Described in PLAN.md section "Data Model"
- {LAYER_2}: Described in STATUS.md

For complete layer definitions, see `$session.guide.bootstrap.expected_counts` after bootstrap.

**Example: Query this project's endpoints**

```powershell
$myEndpoints = (Invoke-RestMethod `
  "$($session.base)/model/endpoints/?service={SERVICE_NAME}&limit=100").data
$myEndpoints | Select-Object id, method, path, status | Format-Table
```

(This query is safe because `limit=100` respects `$session.guide.query.safe_limits.recommended`)
```
```

---

### 3. copilot-instructions.md (Workspace): Add API Bootstrap Reference

**Current Issue:** Doesn't mention the API endpoint or bootstrap process.

**Proposed Addition:**

After the "Key Architecture References" section, add:

```markdown
## Agent Bootstrap: The One Essential First Step

Every agent session must initialize with Project 37's authoritative API:

```powershell
# Public endpoint (prod & dev)
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

# Fetch complete guidance from Cosmos DB
$session = @{ base = $base }
$session.guide = Invoke-RestMethod "$base/model/agent-guide"

# All query patterns, write rules, and safety limits are now in $session.guide
```

See [Project 37 User Guide](37-data-model/USER-GUIDE.md) for complete bootstrap sequence.

**Why?** The API is your authoritative source for:
- ✅ Query safety limits (prevents timeouts)
- ✅ Write cycle rules (prevents corruption)
- ✅ Common mistakes to avoid (prevents rework)
- ✅ Live layer availability (prevents stale docs)
```

---

## Summary of Changes

| File | Change | Impact | Priority |
|------|--------|--------|----------|
| `USER-GUIDE.md` | Add formal API contract definition | Agents know exactly what to expect from `/model/agent-guide` | 🔴 Critical |
| `USER-GUIDE.md` | Add session state binding pattern | Eliminates `$base` ambiguity; enables recovery | 🔴 Critical |
| `USER-GUIDE.md` | Add integration section (copilot-instructions alignment) | Three-tier instruction system is now coherent | 🔴 Critical |
| `USER-GUIDE.md` | Replace "Emergency" section | Reflects 24x7 API; adds retry logic | 🟠 High |
| `copilot-instructions-template.md` | Fix bootstrap checklist | Agents know to call `/model/agent-guide` first | 🔴 Critical |
| `copilot-instructions-template.md` | Replace data model section | Eliminates query duplication; points to authoritative guide | 🔴 Critical |
| `copilot-instructions.md` | Add API bootstrap ref section | Workspace-level instructions now include API entry point | 🟠 High |

---

## Implementation Roadmap

### Phase 1: Core Fixes (Session 38)
1. ✅ Update `USER-GUIDE.md` with API contract + session binding
2. ✅ Update `copilot-instructions-template.md` bootstrap section
3. ✅ Add workspace-level API reference

**Result:** Instruction system is coherent; agents can bootstrap reliably

### Phase 2: Validation (Session 38)
1. Test bootstrap sequence with Project 05, 07, 51 (reference projects)
2. Verify `$session.guide` contains expected 50+ properties
3. Verify query patterns work with real layer endpoints

**Result:** Instructions validated against actual API

### Phase 3: Rollout (Session 38)
1. Apply to missing 6 projects (08, 17, 20, 34-eva-agents, 54, 99)
2. Update existing 54 projects' copilot-instructions with Phase 1 template
3. Run automation: `Invoke-PrimeWorkspace.ps1`

**Result:** All 57 projects aligned

---

## Test Cases for Implementation

Once changes are made, validate:

```powershell
# Test 1: API contract validation
$guide = Invoke-RestMethod "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/agent-guide"
$guide | Get-Member -MemberType NoteProperty | Measure-Object
# Expected: >= 10 properties (service, bootstrap, query, write, patterns, forbidden, etc.)

# Test 2: Session binding works
$session = @{}
$session.guide = $guide
$session.guide.bootstrap.expected_counts.layers
# Expected: 51

# Test 3: Query pattern from guide works
$limit = $session.guide.query.safe_limits.recommended
$projects = (Invoke-RestMethod "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/?limit=$limit").data
$projects.Count -le $limit
# Expected: $true

# Test 4: Bootstrap section references are correct
"README.md", "PLAN.md", "STATUS.md" | % { Test-Path $_ }
# Expected: $true for each (project artifacts are present)
```

---

*Comprehensive change proposal for Session 38 instruction hardening. Ready for implementation.*
