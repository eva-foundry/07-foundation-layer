# GitHub Copilot Instructions -- {PROJECT_NAME}

**Template Version**: 4.0.0 (Session 38 - GitHub Best Practices Aligned)
**Last Updated**: 2026-03-07 ET
**Project**: {PROJECT_NAME}
**Path**: `C:\AICOE\eva-foundry\{PROJECT_FOLDER}\`
**Stack**: {PROJECT_STACK}

---

## PART 1 -- UNIVERSAL RULES (EVA Foundation)

Applies to every EVA Foundation project. All project templates share these rules; see workspace copilot-instructions for details.

### Essential References (Read in Order)

1. **Workspace Context**: `C:\AICOE\.github\copilot-instructions.md`
   - Skills available, architecture overview, key projects
2. **Best Practices**: `C:\AICOE\.github\best-practices-reference.md`
   - Encoding safety, patterns, evidence collection
3. **Data Model API**: `C:\AICOE\eva-foundry\37-data-model\USER-GUIDE.md`
   - Query patterns, PUT rules, model layer reference
4. **This Project**: README.md → PLAN.md → STATUS.md → ACCEPTANCE.md

### Session Bootstrap (Checklist)

This sequence runs ONCE per agent session and establishes `$session` with API guidance.

```powershell
# Step 1: Set base URL
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

# Step 2: Create session object
$session = @{ base = $base; initialized_at = Get-Date }

# Step 3: Bootstrap from API (← KEY STEP)
try {
    $session.guide = Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10
    [INFO] "Bootstrap complete. $(($session.guide.layers_available | Measure-Object).Count) layers online."
} catch {
    [FAIL] "Cannot contact MSub API at $base. Exiting."
    exit 1
}

# Step 4: Verify 51 layers are available (50 base + 1 metadata)
$layerCount = ($session.guide.layers_available | Measure-Object).Count
if ($layerCount -ne 51) {
    [WARN] "Expected 51 layers; API reports $layerCount. Some features may be unavailable."
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
- [ ] `$session.guide` contains expected sections (identity, query_patterns, write_cycle, etc.)
- [ ] Layer count verified (warning acceptable, but must be reported)
- [ ] All project artifacts detected (or explained why missing)

### Encoding & Output

**Windows cp1252 RULE**: No emoji, no unicode in output. Use `[PASS]` / `[FAIL]` / `[WARN]` / `[INFO]` only.

### Python Environment

```powershell
# DON'T use bare python; use venv executable
C:\AICOE\.venv\Scripts\python.exe
```

### Azure Sandbox (marco-sandbox)

- **Foundry**: `https://marco-sandbox-foundry.cognitiveservices.azure.com/`
- **Models**: gpt-4o (20K TPM), gpt-4o-mini (50K TPM), gpt-5.1-chat (100K TPM)
- **Key retrieval**: `az cognitiveservices account keys list --name marco-sandbox-foundry --resource-group EsDAICoE-Sandbox --query "key1" -o tsv`

### Azure Best Practices

Consult `C:\AICOE\eva-foundry\18-azure-best/` (32 entries: WAF, security, AI, IaC, cost) before design decisions.

---

## PART 2 -- PROJECT-SPECIFIC

Replace all `{PLACEHOLDER}` values before use. Delete unused sections.

### Project Lock

This file governs **{PROJECT_FOLDER}** ({PROJECT_NAME}) for the active session only. Once loaded, the project is locked to prevent context drift.

### Project Identity

**Name**: {PROJECT_NAME}
**Folder**: `C:\AICOE\eva-foundry\{PROJECT_FOLDER}`
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

**For All Available Query Patterns**: See `$session.guide.query_patterns` after bootstrap, or `C:\AICOE\eva-foundry\37-data-model\USER-GUIDE.md`

### Deployment

**Environment**: {DEV_URL} | {PROD_URL}
**Deploy**: `{DEPLOY_COMMAND}`
**CI Pipeline**: {CI_URL}

---

## PART 3 -- QUALITY GATES

All must pass before PR merge:

- [ ] Test command exits 0
- [ ] `validate-model.ps1` exits 0 (if model layer changed)
- [ ] No [FORBIDDEN] encoding patterns
- [ ] STATUS.md updated with session summary
- [ ] PLAN.md reflects actual remaining work
- [ ] If new model entity added: PUT + write cycle closed

---

*Template v4.0.0 (Session 38 - GitHub best practices aligned)* | [Workspace instructions](../../../.github/copilot-instructions.md) | [EVA Data Model](../../../37-data-model/USER-GUIDE.md) | [Best Practices](../../../.github/best-practices-reference.md)
