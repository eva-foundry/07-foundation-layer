# [BOOTSTRAP CHECK] -- HAVE YOU BOOTSTRAPPED?

**Before reading this project's instructions, verify you completed the bootstrap sequence:**

1. **Did you bootstrap the workspace?** → Read `C:\eva-foundry\.github\copilot-instructions.md` FIRST
2. **Did you call the API?** → Must have `$session.guide` and `$session.userGuide` loaded
3. **Did you verify layer count?** → Must have 91+ operational layers available

**If you answered NO to any:** STOP. Go back to workspace instructions. Execute bootstrap FIRST.

**Quick Bootstrap Check:**
```powershell
# This should return data (not error)
$session.guide.layers_available.Count  # Expected: 91+
$session.userGuide.categories.Count    # Expected: 6
```

**If undefined or error:** You skipped bootstrap. This is a protocol violation. Go back to workspace instructions NOW.

---

# GitHub Copilot Instructions -- {PROJECT_NAME}

**Template Version**: 5.0.0 (Session 44 - Bootstrap Enforcement + Template Consolidation)
**Last Updated**: 2026-03-10
**Project**: {PROJECT_NAME}
**Path**: `C:\eva-foundry\{PROJECT_FOLDER}\`
**Stack**: {PROJECT_STACK}

---

## PART 1 -- UNIVERSAL RULES (EVA Foundation)

Applies to every EVA Foundation project. All project templates share these rules; see workspace copilot-instructions for details.

### Essential References (Read in Order)

1. **Workspace Context**: `C:\eva-foundry\.github\copilot-instructions.md`
   - Skills available, architecture overview, key projects
2. **Best Practices**: `C:\eva-foundry\.github\best-practices-reference.md`
   - Encoding safety, patterns, evidence collection
3. **Data Model API**: `C:\eva-foundry\37-data-model\USER-GUIDE.md`
   - Query patterns, PUT rules, live layer count via $session.guide.layers_available.Count
4. **Category Runbook Examples**: `C:\eva-foundry\37-data-model\docs\CATEGORY-RUNBOOK-EXAMPLES.md`
   - Real-world DPDCA workflows for 6 governance categories (session, sprint, evidence, governance, infrastructure, ontology)
5. **Paperless DPDCA Tutorial**: `C:\eva-foundry\37-data-model\docs\PAPERLESS-DPDCA-TUTORIAL.md`
   - Step-by-step guide to API-first governance (bootstrap → plan → execute → validate → close)
6. **This Project**: README.md -> PLAN.md -> STATUS.md -> ACCEPTANCE.md

### Session Bootstrap (Checklist)

This sequence runs ONCE per agent session and establishes `$session` with API guidance.

```powershell
# Step 1: Set base URL
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

# Step 2: Create session object
$session = @{ base = $base; initialized_at = Get-Date }

# Step 3: Bootstrap from API (<-- KEY STEP)
try {
    $session.guide = Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10
    $session.userGuide = Invoke-RestMethod "$base/model/user-guide" -TimeoutSec 10
    [INFO] "Bootstrap complete. $(($session.guide.layers_available | Measure-Object).Count) layers online."
} catch {
    [FAIL] "Cannot contact MSub API at $base. Exiting."
    exit 1
}

# Step 4: Verify layer count
$layerCount = ($session.guide.layers_available | Measure-Object).Count
if ($layerCount -lt 50) {
    [WARN] "Low layer count: $layerCount. Some features may be unavailable."
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

# Bootstrap complete
[INFO] "Session ready. Use `$session.guide` for all query patterns and write rules."
```

**Do NOT proceed until:**
- [ ] API call returned status 200
- [ ] `$session.guide` contains expected sections (identity, query_patterns, write_cycle, etc.)
- [ ] Layer count verified (warning acceptable, but must be reported)
- [ ] All project artifacts detected (or explained why missing)

---

### Category Runbooks (Use These Patterns)

The `/model/user-guide` endpoint provides deterministic workflows for 6 common scenarios. **ALWAYS query user-guide first** before writing to these layers.

**COMPREHENSIVE GUIDES AVAILABLE**:
- **Real-World Examples**: See [CATEGORY-RUNBOOK-EXAMPLES.md](../../37-data-model/docs/CATEGORY-RUNBOOK-EXAMPLES.md) for complete DPDCA workflows with PowerShell code
- **Tutorial Walkthrough**: See [PAPERLESS-DPDCA-TUTORIAL.md](../../37-data-model/docs/PAPERLESS-DPDCA-TUTORIAL.md) for step-by-step API-first governance guide

#### 1. Session Tracking (`session_tracking`)
**Layer**: `project_work` | **ID Format**: `{project_id}-{YYYY-MM-DD}`

```powershell
# 5-Step DPDCA Pattern (from $session.userGuide.category_instructions.session_tracking)
GET /model/projects/{project_id}              # DISCOVER: Verify project exists
GET /model/project_work/{id}                  # DISCOVER: Check if session exists (404 OK)
PUT /model/project_work/{id} -Headers @{      # DO: Create/update session
    'X-Actor' = 'agent:copilot'
} -Body @{ project_id, current_phase, session_summary, tasks, metrics }
GET /model/project_work/{id}                  # CHECK: Verify write (row_version++)
POST /model/admin/commit                      # ACT: Validate consistency
```

**Anti-Trash Rules**: No duplicate dates per project • session_summary must have completed_tasks + next_steps • tasks array non-empty • metrics include tests_passing, tests_added, files_changed • current_phase matches project

**Common Mistakes**: Using POST (not supported) • Forgetting X-Actor header • Not verifying project exists • Duplicate dates • Skipping admin/commit

#### 2-6. Other Categories
**Sprint Tracking**: `$session.userGuide.category_instructions.sprint_tracking` (sprints layer)  
**Evidence Tracking**: `$session.userGuide.category_instructions.evidence_tracking` (evidence layer - immutable)  
**Governance Events**: `$session.userGuide.category_instructions.governance_events` (verification_records, quality_gates, decisions, risks)  
**Infra Observability**: `$session.userGuide.category_instructions.infra_observability` (infrastructure_events, agent_execution_history, deployment_records)  
**Ontology Domains**: `$session.userGuide.category_instructions.ontology_domains` (12-domain reasoning - see [USER-GUIDE.md](../../37-data-model/USER-GUIDE.md))

**Workflow**: For ANY data model operation, query the relevant category in user-guide FIRST. This prevents "trash can" data and follows proven patterns.

---

### Encoding & Output

**ASCII-ONLY -- ABSOLUTE RULE -- NO EXCEPTIONS**

This applies to every file created or edited: .md, .ps1, .py, .ts, .json, .yaml, .txt, every string literal, log line, comment, commit message.

**Forbidden output:**
- Emoji (any Unicode codepoint above U+007F)
- Unicode arrows -- use ASCII `->` instead
- Unicode dashes -- use `--` instead
- Curly quotes -- use `"` or `'` instead
- Non-breaking spaces
- PowerShell backtick (`) line continuation -- see PUT Rule 7
- UTF-8 BOM in any text file

**Allowed output tokens**: `[PASS]` / `[FAIL]` / `[WARN]` / `[INFO]`

```python
# [FORBIDDEN] -- causes UnicodeEncodeError in enterprise Windows
print("success")   # with any emoji or unicode symbol

# [REQUIRED] -- ASCII only
print("[PASS] Done")
print("[FAIL] Failed")
print("[INFO] Wait...")
```

### Python Environment

```powershell
# DON'T use bare python; use venv executable
C:\eva-foundry\.venv\Scripts\python.exe
```

### Azure Sandbox (marco-sandbox)

- **Foundry**: `https://marco-sandbox-foundry.cognitiveservices.azure.com/`
- **Models**: gpt-4o (20K TPM), gpt-4o-mini (50K TPM), gpt-5.1-chat (100K TPM)
- **Key retrieval**: `az cognitiveservices account keys list --name marco-sandbox-foundry --resource-group EsDAICoE-Sandbox --query "key1" -o tsv`

### Azure Best Practices

Consult `C:\eva-foundry\18-azure-best/` (32 entries: WAF, security, AI, IaC, cost) before design decisions.

---

## PART 2 -- PROJECT-SPECIFIC

Replace all `{PLACEHOLDER}` values before use. Delete unused sections.

### Project Lock

This file governs **{PROJECT_FOLDER}** ({PROJECT_NAME}) for the active session only. Once loaded, the project is locked to prevent context drift.

### Project Identity

**Name**: {PROJECT_NAME}
**Folder**: `C:\eva-foundry\{PROJECT_FOLDER}`
**ADO Epic**: #{ADO_EPIC_ID}
**37-data-model record**: `GET /model/projects/{PROJECT_FOLDER}`
**Maturity**: {PROJECT_MATURITY} (empty | poc | active | retired)
**Current Phase**: {CURRENT_PHASE}

**Dependencies**: {DEPENDENCY_LIST}
**Consumed by**: {CONSUMER_LIST}

### Stack and Build

**Languages/Frameworks**: {LANGUAGE} {VERSION}, {FRAMEWORK} {VERSION}

```powershell
{BUILD_COMMAND}          # compile/setup
{TEST_COMMAND}           # must exit 0 before commit
{SMOKE_TEST_COMMAND}     # quick test
{START_COMMAND}          # dev server
{LINT_COMMAND}           # lint/type check
```

**Current state**: {TEST_COUNT} tests, {COVERAGE}% coverage (as of {DATE})

### Critical Patterns

{DESCRIBE_1_3_KEY_PATTERNS_SPECIFIC_TO_PROJECT}

| Pattern | Why |
|---------|-----|
| {PATTERN_1} | {RATIONALE} |

### Anti-Patterns (DO NOT)

**Project-Specific Anti-Patterns**:

| Anti-Pattern | Do Instead |
|---|---|
| {FORBIDDEN} | {CORRECT} |

**GitHub Actions Workflows** (if project has workflows):

See [37-data-model/docs/workflows/ANTI-PATTERNS-AND-BEST-PRACTICES.md](../../37-data-model/docs/workflows/ANTI-PATTERNS-AND-BEST-PRACTICES.md) for complete guide.

| Anti-Pattern | Do Instead |
|---|---|
| Check `$LASTEXITCODE` in separate step after script | Let GitHub Actions handle exit codes natively OR use `steps.<id>.outcome` |
| End PowerShell scripts without explicit exit code | Add `exit 0` on success, `exit 1` on failure |
| Single-step workflows without evidence | Generate correlation ID, create receipt, upload artifacts with `if: always()` |
| Fail fast without collecting issues | Use `continue-on-error: true`, collect all results, report comprehensive summary |
| No job-to-job communication | Use `outputs:` in jobs, access via `needs.<job>.outputs.<key>` |

**Critical**: Each workflow step = NEW shell session. Exit codes don't persist. Use job outputs or `steps.<id>.outcome`.

### Project Skills

```powershell
Get-ChildItem ".github/copilot-skills/" -Filter "*.skill.md" | Select-Object Name
```

| Skill | Triggers | Purpose |
|---|---|---|
| {SKILL_FILE} | {PHRASES} | {PURPOSE} |

### Data Model Integration (Queries)

All queries use the `$session.guide` patterns established at bootstrap. Never deviate from patterns.

**Universal Query Pattern** (applies to all layers):

```powershell
# Template
$endpoint = "{LAYER_NAME}"  # e.g., "projects", "endpoints", "evidence"
$limit = 100  # or $session.guide.query_capabilities.universal_params.limit
$offset = 0   # pagination

$response = Invoke-RestMethod "$($session.base)/model/$endpoint/?limit=$limit&offset=$offset"
$results = $response.data  # Always access .data

# Always use Select-Object before Format-Table
$results | Select-Object id,status,phase | Format-Table
```

**Project-Specific Queries**:

This project accesses these layers (from PLAN.md):
- {LAYER_1}
- {LAYER_2}

For complete patterns, see `$session.guide.query_patterns` or `$session.guide.examples` (available after bootstrap).

**Example: Safe First Query**

```powershell
# Get first 20 projects, show key fields only
$projects = (Invoke-RestMethod "$($session.base)/model/projects/?limit=20").data
$projects | Select-Object id, label, maturity, status | Format-Table

# Count total (without fetching all data)
$count = (Invoke-RestMethod "$($session.base)/model/projects/count").data.count
Write-Host "Total projects: $count"
```

**For All Available Query Patterns**: See `$session.guide.query_patterns` after bootstrap, or `C:\eva-foundry\37-data-model\USER-GUIDE.md`

### Data Model API Protocol (Advanced)

> **GOLDEN RULE**: The `model/*.json` files are internal implementation details of the API server.
> Agents must never read, grep, parse, or reference them directly -- not even to "check" something.
> The HTTP API is the only interface. One HTTP call beats ten file reads.
> The API self-documents: GET /model/agent-guide returns the complete operating protocol.

#### PUT Rules (Read Before Every Write)

**Rule 1 -- Capture `row_version` BEFORE mutating**:
```powershell
$ep = Invoke-RestMethod "$base/model/endpoints/GET /v1/tags"
$prev_rv = $ep.row_version   # capture BEFORE mutation
```

**Rule 2 -- Strip audit columns, keep domain fields**:
Exclude: `obj_id`, `layer`, `modified_by`, `modified_at`, `created_by`, `created_at`, `row_version`, `source_file`.
`is_active` is a domain field -- keep it.

**Rule 3 -- Use `-Depth 10` for nested schemas**:
```powershell
$body = $obj | ConvertTo-Json -Depth 10
```

**Rule 4 -- PATCH is not supported** -- always PUT the full object (422 otherwise).

**Rule 5 -- Endpoint id = exact string "METHOD /path"** -- never construct; copy verbatim.

**Rule 6 -- Never call create_file on existing paths**:
```powershell
if (Test-Path $filePath) {
    # use replace_string_in_file instead
} else {
    # safe to call create_file
}
```

**Rule 7 -- Never use PowerShell backtick (`) for line continuation**:
Use splatting or single line. Backticks break in terminals and cause JSON escaping failures.

#### Write Cycle Protocol

**Preferred 3-step cycle**:
```powershell
# Step 1: PUT (use splatting per Rule 7)
$params = @{
    Method = "PUT"
    ContentType = "application/json"
    Body = $body
    Headers = @{"X-Actor"="agent:copilot"}
}
Invoke-RestMethod "$base/model/{layer}/{id}" @params

# Step 2: Confirm (assert row_version incremented)
$updated = Invoke-RestMethod "$base/model/{layer}/{id}"
$updated.row_version  # must equal $prev_rv + 1

# Step 3: Close cycle (commit + validate)
$result = Invoke-RestMethod "$base/model/admin/commit" -Method POST -Headers @{"Authorization"="Bearer dev-admin"}
$result.status         # PASS = done; FAIL = fix violations
$result.violation_count # must be 0
```

#### Context Health Protocol

Maintain a mental count of Do steps (file edits, terminal commands, test runs) this session.

| Milestone | Action |
|---|---|
| Step 5  | Context health check -- answer 4 questions from memory |
| Step 10 | Health check + re-read STATUS.md |
| Step 15 | Health check + re-read + state summary aloud |
| Every 5 after | Repeat step-10 pattern |

**4 health questions:**
1. What is the active task and its one-line description?
2. What was the last recorded test count?
3. What file am I currently editing or about to edit?
4. Have I run any terminal command I cannot account for?

**Drift signals** -- trigger immediate check:
- About to search for a file already read this session
- About to run full test suite without isolating failing test first
- Proposing approach that contradicts decision in PLAN.md
- Uncertainty about which task or sprint is active

**Recovery**: re-read STATUS.md, run baseline tests, resume from last verified state.

### Tool Index Awareness

Before creating any new tool, check if it already exists:
- Read `docs/TOOL-INDEX.md` (if exists) -- comprehensive catalog of all scripts/ tools
- DO NOT recreate existing tools -- use what's already built
- If tool doesn't exist, add it to index after creation

---

## PART 2 -- PROJECT-SPECIFIC

Replace all `{PLACEHOLDER}` values before use. Delete unused sections.

### Project Lock

This file governs **{PROJECT_FOLDER}** ({PROJECT_NAME}) for the active session only. Once loaded, the project is locked to prevent context drift.

### Project Identity

**Name**: {PROJECT_NAME}
**Folder**: `C:\eva-foundry\{PROJECT_FOLDER}`
**ADO Epic**: #{ADO_EPIC_ID}
**37-data-model record**: `GET /model/projects/{PROJECT_FOLDER}`
**Maturity**: {PROJECT_MATURITY} (empty | poc | active | retired)
**Current Phase**: {CURRENT_PHASE}

**Dependencies**: {DEPENDENCY_LIST}
**Consumed by**: {CONSUMER_LIST}

### Stack and Build

**Languages/Frameworks**: {LANGUAGE} {VERSION}, {FRAMEWORK} {VERSION}

```powershell
{BUILD_COMMAND}          # compile/setup
{TEST_COMMAND}           # must exit 0 before commit
{SMOKE_TEST_COMMAND}     # quick test
{START_COMMAND}          # dev server
{LINT_COMMAND}           # lint/type check
```

**Current state**: {TEST_COUNT} tests, {COVERAGE}% coverage (as of {DATE})

### Critical Patterns

{DESCRIBE_1_3_KEY_PATTERNS_SPECIFIC_TO_PROJECT}

| Pattern | Why |
|---------|-----|
| {PATTERN_1} | {RATIONALE} |

**Same-Commit Rule**: Documentation and model updates happen in the same commit as source code changes. Never defer. A stale artifact is worse than no artifact.

### Anti-Patterns (DO NOT)

**Project-Specific Anti-Patterns**:

| Anti-Pattern | Do Instead |
|---|---|
| {FORBIDDEN} | {CORRECT} |

**GitHub Actions Workflows** (if project has workflows):

See [37-data-model/docs/workflows/ANTI-PATTERNS-AND-BEST-PRACTICES.md](../../37-data-model/docs/workflows/ANTI-PATTERNS-AND-BEST-PRACTICES.md) for complete guide.

| Anti-Pattern | Do Instead |
|---|---|
| Check `$LASTEXITCODE` in separate step after script | Let GitHub Actions handle exit codes natively OR use `steps.<id>.outcome` |
| End PowerShell scripts without explicit exit code | Add `exit 0` on success, `exit 1` on failure |
| Single-step workflows without evidence | Generate correlation ID, create receipt, upload artifacts with `if: always()` |
| Fail fast without collecting issues | Use `continue-on-error: true`, collect all results, report comprehensive summary |
| No job-to-job communication | Use `outputs:` in jobs, access via `needs.<job>.outputs.<key>` |

**Critical**: Each workflow step = NEW shell session. Exit codes don't persist. Use job outputs or `steps.<id>.outcome`.

### Project Skills

```powershell
Get-ChildItem ".github/copilot-skills/" -Filter "*.skill.md" | Select-Object Name
```

| Skill | Triggers | Purpose |
|---|---|---|
| {SKILL_FILE} | {PHRASES} | {PURPOSE} |

### Data Model Integration (Queries)

All queries use the `$session.guide` patterns established at bootstrap. Never deviate from patterns.

**Universal Query Pattern** (applies to all layers):

```powershell
# Template
$endpoint = "{LAYER_NAME}"  # e.g., "projects", "endpoints", "evidence"
$limit = 100  # or $session.guide.query_capabilities.universal_params.limit
$offset = 0   # pagination

$response = Invoke-RestMethod "$($session.base)/model/$endpoint/?limit=$limit&offset=$offset"
$results = $response.data  # Always access .data

# Always use Select-Object before Format-Table
$results | Select-Object id,status,phase | Format-Table
```

**Project-Specific Queries**:

This project accesses these layers (from PLAN.md):
- {LAYER_1}
- {LAYER_2}

For complete patterns, see `$session.guide.query_patterns` or `$session.guide.examples` (available after bootstrap).

**Example: Safe First Query**

```powershell
# Get first 20 projects, show key fields only
$projects = (Invoke-RestMethod "$($session.base)/model/projects/?limit=20").data
$projects | Select-Object id, label, maturity, status | Format-Table

# Count total (without fetching all data)
$count = (Invoke-RestMethod "$($session.base)/model/projects/count").data.count
Write-Host "Total projects: $count"
```

### Deployment

**Environment**: {DEV_URL} | {PROD_URL}
**Deploy**: `{DEPLOY_COMMAND}`
**CI Pipeline**: {CI_URL}

---

## PART 3 -- QUALITY GATES

**CHECK Phase Requirements** (before EVERY commit):

### 3.1 Static Analysis (Mandatory)

**Python Projects**:
```powershell
# Run both - each catches different issues
pylint {changed_files} --disable=C,R,W  # E errors only = blockers
flake8 {changed_files}                  # F/E errors only = blockers
```

**JavaScript/TypeScript**:
```powershell
eslint {changed_files}
tsc --noEmit  # type check without compile
```

**PowerShell**:
```powershell
Invoke-ScriptAnalyzer {changed_files} -Severity Error
```

### 3.2 Test Suite (Mandatory)

```powershell
{TEST_COMMAND}  # Must exit 0 before commit
```

**If no tests exist**: Create minimal test for modified code OR acknowledge gap in commit message.

### 3.3 Manual Verification (Context-Dependent)

**HTTP APIs** (FastAPI, Flask, Express, etc.):
```powershell
# Test modified endpoints manually
Invoke-RestMethod "http://localhost:{PORT}/{modified_endpoint}" -Method GET
# Verify: 200 status, expected response structure, no 500 errors
```

**CLIs**:
```powershell
# Run smoke test with sample inputs
.\{cli_command} {sample_args}
# Verify: Expected output, exit code 0, no exceptions
```

**Libraries/Modules**:
```python
# Import and call modified functions
import {module}
result = {module}.{modified_function}({test_data})
assert result == expected_output
```

### 3.4 Session 41 Anti-Pattern (Document for Prevention)

**Root Cause**: Lowercase boolean `true` (JavaScript syntax) used in Python dict

```python
# WRONG: JavaScript/JSON boolean in Python
response = {
    "data_available": true,   # NameError: name 'true' is not defined
    "ready": false            # NameError: name 'false' is not defined
}

# CORRECT: Python boolean (capitalized)
response = {
    "data_available": True,   # Python boolean
    "ready": False            # Python boolean
}
```

**Why py_compile Didn't Catch It**:
- `py_compile` only validates syntax (colons, brackets, indentation)
- Semantic errors (undefined variables) only appear at runtime
- Functions not called during import -> bug hidden until endpoint invoked

**Detection Method Effectiveness**:
| Tool | Detects This Bug? | Error Code |
|------|-------------------|------------|
| **pylint** | YES | E0602: Undefined variable 'true' |
| **flake8** | YES | F821: undefined name 'true' |
| **py_compile** | NO | Only syntax errors |
| **pytest** | YES | NameError at runtime (if test calls endpoint) |
| **Manual test** | YES | 500 Internal Server Error |

**Session 41 Timeline** (What Went Wrong):
1. Committed code with lowercase `true` in line 907
2. Skipped CHECK phase (no pylint, no flake8, no manual test)
3. Deployed to Azure -- 500 error in production
4. Required debug endpoint + DPDCA investigation to isolate
5. Bug was trivial but detection gap made it expensive

**Lesson**: Static analysis is NOT optional. Run pylint/flake8 BEFORE every commit.

### 3.5 Quality Gate Checklist (Before PR Merge)

All must pass:

- [ ] Static analysis exits 0 (pylint E errors, flake8 F/E errors)
- [ ] Test command exits 0: `{TEST_COMMAND}`
- [ ] Manual verification complete (if HTTP API/CLI/modified function)
- [ ] `validate-model.ps1` exits 0 (if model layer changed)
- [ ] No [FORBIDDEN] encoding patterns (Unicode, emoji, cp1252 violations)
- [ ] STATUS.md updated with session summary
- [ ] PLAN.md reflects actual remaining work
- [ ] If new model entity added: PUT + write cycle closed with evidence
- [ ] No undefined variables (pylint E0602, flake8 F821)
- [ ] All imports resolve (no ImportError at runtime)

---

*Template v5.0.0 (Session 44 - Bootstrap Enforcement & Governance Consolidation)* | [Workspace instructions](../../../.github/copilot-instructions.md) | [EVA Data Model](../../../37-data-model/USER-GUIDE.md) | [Best Practices](../../../.github/best-practices-reference.md)
