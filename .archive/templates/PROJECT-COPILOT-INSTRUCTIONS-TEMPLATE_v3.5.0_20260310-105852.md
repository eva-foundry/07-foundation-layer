# GitHub Copilot Instructions -- [PROJECT_NAME]

**Template Version**: 3.5.0 (Session 41 - CHECK Phase Hardening)  
**Last Updated**: March 8, 2026 @ 8:45 PM ET  
**Project**: [XX-PROJECT-ID] -- [PROJECT_FULL_NAME]  
**Path**: `C:\AICOE\eva-foundry\[XX-PROJECT-ID]\`  
**Stack**: [TECH_STACK]  

> This file is the Copilot operating manual for this repository.
> PART 1 is universal -- identical across all EVA Foundation projects.
> PART 2 is project-specific -- customise the placeholders before use.

---

## PART 1 -- UNIVERSAL RULES (Session 37 Edition)
> Applies to every EVA Foundation project. Do not modify.

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Establish $base** (Central EVA data model on port 8010 -- managed by project 37):
   - Central EVA data model: `http://localhost:8010` (all workspace projects, unified data store)
   - All projects share Project 37 data model (Cosmos DB)
   - Depends on: Project 37 (`C:\AICOE\eva-foundry\37-data-model\`) running on port 8010
   - `$base` must be set before any model query in this session.
   - **Session 37 Status**: ✅ All 51 layers operational (50 base + 1 metadata)

2. **Read this project's governance docs** (in order):
   - `README.md` -- identity, stack, quick start
   - `PLAN.md` -- phases, current phase, next tasks
   - `STATUS.md` -- last session snapshot, open blockers
   - `ACCEPTANCE.md` -- DoD checklist, quality gates (if exists)
   - Latest `docs/YYYYMMDD-plan.md` and `docs/YYYYMMDD-findings.md` (if exists)

3. **Read the skills index** (if `.github/copilot-skills/` exists):
   - List files: `Get-ChildItem .github/copilot-skills/ -Filter "*.skill.md" | Select-Object Name`
   - Read `00-skill-index.skill.md` or the first skill matching the current task's trigger phrase
   - Each skill has a `triggers:` YAML block -- match it to the user's intent

4. **Query the data model** for this project's record:
   ```powershell
   Invoke-RestMethod "$base/model/projects/[XX-PROJECT-ID]" | Select-Object id, maturity, notes
   ```

5. **Produce a Session Brief** -- one paragraph: active phase, last test count, next task, open blockers.
   Do not skip this. Do not start implementing before the brief is written.

---

### 2. DPDCA Execution Loop

Every session runs this cycle. Do not skip steps.

```
Discover  --> synthesise current sprint from plan + findings docs
Plan      --> pick next unchecked task from yyyymmdd-plan.md checklist
Do        --> implement -- make the change, do not just describe it
Check     --> run verification checklist (see 2.1); ALL must pass
Act       --> update STATUS.md, PLAN.md, yyyymmdd-plan.md, findings doc
Loop      --> return to Discover if tasks remain
```

**Execution Rule**: Make the change. Do not propose, narrate, or ask for permission on a step you can determine yourself. If uncertain about scope, ask one clarifying question then proceed.

#### 2.1 CHECK Phase -- Mandatory Verification

**CRITICAL**: Session 41 proved that skipping CHECK results in production bugs. This checklist is MANDATORY before any commit.

**Python Projects**:
```powershell
# 1. Static Analysis (catches undefined variables, syntax errors)
pylint {changed_files}  # Must show no E errors (C/R/W acceptable)
flake8 {changed_files}  # Must show no F/E errors

# 2. Test Suite
pytest tests/ -v  # Must exit 0

# 3. Manual Verification (if applicable)
# - For HTTP APIs: Test modified endpoints manually
# - For CLIs: Run smoke test with sample inputs
# - For libraries: Import and call modified functions
```

**PowerShell/Bash Scripts**:
```powershell
# 1. Syntax Check
PowerShell -NoProfile -Command "& '{script.ps1}' -WhatIf" 2>&1

# 2. Dry Run
.\{script.ps1} -DryRun  # if script supports it

# 3. Test Suite (if exists)
Invoke-Pester tests/  # Must exit 0
```

**All Projects**:
- [ ] Run project test command (see PART 2) → must exit 0
- [ ] If modified HTTP endpoint: Manual curl/Invoke-RestMethod test
- [ ] If modified function: Import and call with sample data
- [ ] No syntax errors, no undefined variables, no import failures
- [ ] Verify behavior matches intended change

**Session 41 Anti-Pattern** (Documented for Prevention):
```python
# ❌ WRONG: JavaScript boolean syntax in Python dict
return {"data_available": true}  # NameError: name 'true' is not defined

# ✅ CORRECT: Python boolean syntax
return {"data_available": True}  # Capitalized
```

**Why CHECK Failed in Session 41**:
- ❌ No pylint/flake8 run → Would have caught `E0602: undefined variable 'true'`
- ❌ No manual endpoint test → Would have shown 500 error immediately
- ❌ No pytest run → Would have failed if test existed
- ✅ py_compile passed → But only catches syntax errors, not semantic errors

**Detection Methods by Error Type**:
| Error Type | pylint | flake8 | pytest | Manual Test |
|------------|--------|--------|--------|-------------|
| Undefined variable | ✅ E0602 | ✅ F821 | ✅ Runtime | ✅ 500 error |
| Syntax error | ✅ | ✅ | ✅ | ✅ |
| Logic error | ❌ | ❌ | ✅ | ✅ |
| Missing import | ✅ | ✅ | ✅ | ✅ |

**Minimum Acceptable CHECK** (before ANY commit):
1. Static analysis (pylint OR flake8) → no E/F errors
2. Test suite (if exists) → exit 0
3. Manual verification (if HTTP API/CLI) → expected behavior confirmed

---

### 3. EVA Data Model API -- Mandatory Protocol

> **GOLDEN RULE**: The `model/*.json` files are an internal implementation detail of the API server.
> Agents must never read, grep, parse, or reference them directly -- not even to "check" something.
> The HTTP API is the only interface. One HTTP call beats ten file reads.
> The API self-documents: `GET /model/agent-guide` returns the complete operating protocol.

#### 3.1 Bootstrap

```powershell
# Central EVA data model (port 8010) -- managed by project 37-data-model
# Do NOT start local data model; rely on project 37 exclusively
$base = "http://localhost:8010"
$h = Invoke-RestMethod "$base/health" -ErrorAction SilentlyContinue
if (-not $h) { Write-Warning "[WARN] port 8010 not responding -- ensure project 37 is running" }
# The API self-documents -- read the agent guide before doing anything
Invoke-RestMethod "$base/model/agent-guide"
# One-call state check -- all layer counts + total objects
Invoke-RestMethod "$base/model/agent-summary"
```

**Cloud Agents (Azure APIM)**:
```powershell
# Cloud agents: use APIM gateway (delegates to project 37 backend in Cosmos)
$base = "https://marco-sandbox-apim.azure-api.net/data-model"
$hdrs = @{"Ocp-Apim-Subscription-Key" = $env:EVA_APIM_KEY}
Invoke-RestMethod "$base/model/agent-summary" -Headers $hdrs
```

---

## PART 2 -- PROJECT-SPECIFIC RULES

### 2.1 Project Identity
**Project ID**: [XX-PROJECT-ID]  
**Full Name**: [PROJECT_FULL_NAME]  
**Short Description**: [ONE_SENTENCE_DESCRIPTION]  
**Maturity**: [ALPHA|BETA|STABLE|SUNSET]  

### 2.2 Tech Stack
[FILL_IN_TECH_STACK]

### 2.3 Quick Start
[FILL_IN_HOW_TO_START_PROJECT]

### 2.4 Test Command
```bash
[FILL_IN_TEST_COMMAND]
```
**Expected output**: [EXIT_CODE_AND_RESULT_DESCRIPTION]

---

## Navigation

- **Workspace**: `C:\AICOE\.github\copilot-instructions.md` (workspace-level skills and status)
- **This Project**: Governance docs in root (`README.md`, `PLAN.md`, `STATUS.md`)
- **Central Data Model**: Project 37 @ http://localhost:8010
- **Workspace PM**: Project 07 (Foundation Layer) @ `07-foundation-layer/`

---

**Generated**: 2026-03-08 @ 8:45 PM ET (Session 41 - CHECK Phase Hardening)  
**For project re-priming**: Use `@foundation-expert prime [XX-PROJECT-ID]`  
