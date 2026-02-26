# GitHub Copilot Instructions " EVA AI Governance

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA AI Governance " AI Governance frameworks
**Path**: `C:\AICOE\eva-foundation\19-ai-gov\`
**Stack**: Python, Markdown

> This file is the Copilot operating manual for this repository.
> PART 1 is universal " identical across all EVA Foundation projects.
> PART 2 is project-specific " customise the placeholders before use.

---

## PART 1 " UNIVERSAL RULES
> Applies to every EVA Foundation project. Do not modify.

---

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Ping 37-data-model API**: `Invoke-RestMethod http://localhost:8010/health`
   - If `{"status":"ok"}` ' use HTTP queries for all discovery (fastest)
   - If down ' start it: `$env:PYTHONPATH="C:\AICOE\eva-foundation\37-data-model"; C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload`
   - If no venv ' fall back: `$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json`

2. **Read this project's governance docs** (in order):
   - `README.md` " identity, stack, quick start
   - `PLAN.md` " phases, current phase, next tasks
   - `STATUS.md` " last session snapshot, open blockers
   - `ACCEPTANCE.md` " DoD checklist, quality gates (if exists)
   - Latest `docs/YYYYMMDD-plan.md` and `docs/YYYYMMDD-findings.md` (if exists)

3. **Read the skills index** (if `.github/copilot-skills/` exists):
   - List files: `Get-ChildItem .github/copilot-skills/ -Filter "*.skill.md" | Select-Object Name`
   - Read `00-skill-index.skill.md` or the first skill matching the current task's trigger phrase
   - Each skill has a `triggers:` YAML block " match it to the user's intent

4. **Query the data model** for this project's record:
   ```powershell
   Invoke-RestMethod "http://localhost:8010/model/projects/{PROJECT_FOLDER}" | Select-Object id, maturity, notes
   ```

5. **Produce a Session Brief** " one paragraph: active phase, last test count, next task, open blockers.
   Do not skip this. Do not start implementing before the brief is written.

---

### 2. DPDCA Execution Loop

Every session runs this cycle. Do not skip steps.

```
Discover  --> synthesise current sprint from plan + findings docs
Plan      --> pick next unchecked task from yyyymmdd-plan.md checklist
Do        --> implement -- make the change, do not just describe it
Check     --> run the project test command (see PART 2); must exit 0
Act       --> update STATUS.md, PLAN.md, yyyymmdd-plan.md, findings doc
Loop      --> return to Discover if tasks remain
```

**Execution Rule**: Make the change. Do not propose, narrate, or ask for permission on a step you can determine yourself. If uncertain about scope, ask one clarifying question then proceed.

---

### 3. EVA Data Model API -- Mandatory Protocol

> **Full reference**: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md` (v2.4)
> The model is the single source of truth. One HTTP call beats 10 file reads.
> Never grep source files for something the model already knows.

---

#### 3.1  Bootstrap

```powershell
# Health check -- -ErrorAction SilentlyContinue prevents red errors when API is down
$h = Invoke-RestMethod http://localhost:8010/health -ErrorAction SilentlyContinue
if (-not $h) {
    # Start the API (~3 s)
    $env:PYTHONPATH = "C:\AICOE\eva-foundation\37-data-model"
    Start-Process "C:\AICOE\.venv\Scripts\python.exe" `
        "-m uvicorn api.server:app --port 8010 --reload" -WindowStyle Hidden
    Start-Sleep 4
}

# One-call state check -- all 27 layer counts + total objects
Invoke-RestMethod "http://localhost:8010/model/agent-summary"
# { layers: { services:22, endpoints:136, screens:28, ... }, total:866 }
# Use this instead of querying each layer separately.
```

**Azure APIM (CI / cloud agents):**
```powershell
$base = "https://marco-sandbox-apim.azure-api.net/data-model"
$hdrs = @{"Ocp-Apim-Subscription-Key" = $env:EVA_APIM_KEY}
Invoke-RestMethod "$base/model/agent-summary" -Headers $hdrs
```

---

#### 3.2  Query Decision Table

| You want to know... | One-turn API call | FORBIDDEN (costs 10 turns) |
|---|---|---|
| All layer counts | `GET /model/agent-summary` | query each layer separately |
| Object by ID | `GET /model/{layer}/{id}` | grep, file_search |
| All objects in a layer | `GET /model/{layer}/` | read source files |
| Filter endpoints by status | `GET /model/endpoints/filter?status=stub` | grep router files |
| Filter ANY other layer | `GET /model/{layer}/` + `Where-Object` client-side | no server filter on non-endpoint layers |
| What a screen calls | `GET /model/screens/{id}` -> `.api_calls` | read screen source |
| Auth / feature flag | `GET /model/endpoints/{id}` -> `.auth`, `.feature_flag` | grep auth middleware |
| Cosmos container schema | `GET /model/containers/{id}` -> `.fields`, `.partition_key` | read Cosmos config |
| Navigate to source line | `.repo_path` + `.repo_line` -> `code --goto` | file_search |
| What breaks if X changes | `GET /model/impact/?container=X` | trace imports manually |
| Relationship graph | `GET /model/graph/?node_id=X&depth=2` | read config files |
| Services list | `GET /model/services/` -> `obj_id, status, is_active, notes` | services uses obj_id not id; no type/port |

---

#### 3.3  PUT Rules -- Read Before Every Write

**Rule 1 -- Capture `row_version` BEFORE mutating (not in USER-GUIDE)**
`Invoke-RestMethod` returns a live object; mutating it overwrites the original value.
Store it first so the confirm assert can check `previous + 1`.
```powershell
$ep      = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/tags"
$prev_rv = $ep.row_version        # capture BEFORE any mutation
$ep.status         = "implemented"
$ep.implemented_in = "33-eva-brain-v2/app/routers/tags.py"
$ep.repo_line      = 14
```

**Rule 2 -- Strip audit columns, keep domain fields**
Exclude: `obj_id`, `layer`, `modified_by`, `modified_at`, `created_by`, `created_at`, `row_version`, `source_file`.
`is_active` is a domain field -- keep it.
```powershell
function Strip-Audit ($obj) {
    $obj | Select-Object * -ExcludeProperty `
        obj_id, layer, modified_by, modified_at, created_by, created_at, row_version, source_file
}
```

**Rule 3 -- Assign ConvertTo-Json before piping; use -Depth 10 for nested schemas**
Inline pipelines truncate silently. Objects with `request_schema` / `response_schema` need
`-Depth 10`, not the USER-GUIDE default of 5.
```powershell
$body = Strip-Audit $ep | ConvertTo-Json -Depth 10
Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/tags" `
    -Method PUT -ContentType "application/json" -Body $body `
    -Headers @{"X-Actor"="agent:copilot"}
```

**Rule 4 -- PATCH is not supported** -- always PUT the full object (422 otherwise).

**Rule 5 -- Endpoint id = exact string "METHOD /path"**
Never construct it. Copy verbatim from the model:
```powershell
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
    Where-Object { $_.path -like '*translations*' } | Select-Object id, path
# Use the returned .id -- never retype it (wrong param name passes PUT but fails validate)
```

---

#### 3.4  Write Cycle -- Every Model Change

**Preferred -- 3-step (admin/commit = export + assemble + validate in one call):**
```powershell
# Step 1 -- PUT (see Rules above)
Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/tags" `
    -Method PUT -ContentType "application/json" -Body $body `
    -Headers @{"X-Actor"="agent:copilot"}

# Step 2 -- Canonical confirm: assert all three
$w = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/tags"
$w.row_version   # must equal $prev_rv + 1
$w.modified_by   # must equal "agent:copilot"
$w.status        # must equal the value you PUT

# Step 3 -- Close the cycle
$c = Invoke-RestMethod "http://localhost:8010/model/admin/commit" `
    -Method POST -Headers @{"Authorization"="Bearer dev-admin"}
$c.status          # "PASS" = done; "FAIL" = fix violations before merging
$c.violation_count # 0 = clean
$c.exported_total  # e.g. 866
```

**Manual fallback (if admin/commit is unavailable):**
```
POST /model/admin/export       -- Authorization: Bearer dev-admin
scripts/assemble-model.ps1     -- must report 27/27 layers OK
scripts/validate-model.ps1     -- [FAIL] lines block; [WARN] repo_line lines are pre-existing noise (38+)
```

**API validator -- preferred over the PS script (distinguishes new violations from noise):**
```powershell
$v = Invoke-RestMethod "http://localhost:8010/model/admin/validate" `
       -Headers @{"Authorization"="Bearer dev-admin"}
$v.count       # 0 = clean; >0 = new violations to fix NOW
$v.violations  # the cross-reference FAILs -- fix these before commit
```

---

#### 3.5  Fix a Validation FAIL

```
Pattern: "screen 'X' api_calls references unknown endpoint 'Y'"
Root cause: api_calls used a wrong or constructed id.
```
```powershell
# Step 1 -- find the exact id (never construct)
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
    Where-Object { $_.path -like '*conversation*' } | Select-Object id, path

# Step 2 -- fetch the offending screen, fix api_calls with the exact id
$s = Invoke-RestMethod "http://localhost:8010/model/screens/JpSparkChatPage"
$s.api_calls = @("POST /api/conversation")   # exact .id from step 1

# Step 3 -- PUT + confirm + commit
$body = Strip-Audit $s | ConvertTo-Json -Depth 10
Invoke-RestMethod "http://localhost:8010/model/screens/JpSparkChatPage" `
    -Method PUT -ContentType "application/json" -Body $body
$v = Invoke-RestMethod "http://localhost:8010/model/admin/validate" `
       -Headers @{"Authorization"="Bearer dev-admin"}
$v.count   # must drop to 0
```

---

#### 3.6  What to Update for Each Source Change

| Source change | Model layers to update |
|---|---|
| New FastAPI endpoint | `endpoints` + `schemas` |
| Stub -> implemented | `endpoints` -- set `status`, `implemented_in`, `repo_line` |
| New Cosmos container/field | `containers` |
| New React screen | `screens` + `literals` |
| New i18n key | `literals` |
| New hook / component | `hooks` / `components` |
| New persona / feature flag | `personas` + `feature_flags` |
| New Azure resource | `infrastructure` |
| New agent | `agents` |

> **Same-PR rule**: every source change that affects a model object must update the model
> in the same commit. Never defer. A stale model is worse than no model.

---

### 4. Encoding and Output Safety

**Windows Enterprise Encoding (cp1252) " ABSOLUTE RULE**

```python
# [FORBIDDEN] -- causes UnicodeEncodeError in enterprise Windows
print("success")   # with any emoji or unicode

# [REQUIRED] -- ASCII only
print("[PASS] Done")   print("[FAIL] Failed")   print("[INFO] Wait...")
```

- All Python scripts: `PYTHONIOENCODING=utf-8` in any .bat wrapper
- All PowerShell output: `[PASS]` / `[FAIL]` / `[WARN]` / `[INFO]` -- never emoji
- Machine-readable outputs (JSON, YAML, evidence files): ASCII-only always
- Markdown human-facing docs: emoji allowed for readability only

---

### 5. Context Health Protocol

Maintain a mental count of Do steps (file edits, terminal commands, test runs) this session.

| Milestone | Action |
|---|---|
| Step 5  | Context health check -- answer 4 questions from memory, verify against state files |
| Step 10 | Health check + re-read SESSION-STATE.md or STATUS.md |
| Step 15 | Health check + re-read + state summary aloud |
| Every 5 after | Repeat step-10 pattern |

**4 health questions:**
1. What is the active task and its one-line description?
2. What was the last recorded test count?
3. What file am I currently editing or about to edit?
4. Have I run any terminal command I cannot account for?

**Drift signals** -- trigger immediate check:
- About to search for a file already read this session
- About to run the full test suite without isolating the failing test first
- Proposing an approach that contradicts a decision in PLAN.md
- Uncertainty about which task or sprint is active

**Recovery**: re-read STATUS.md from disk -> run baseline tests -> resume from last verified state.

---

### 6. Python Environment

```
venv exec: C:\AICOE\.venv\Scripts\python.exe
activate:  C:\AICOE\.venv\Scripts\Activate.ps1
```

Never use bare `python` or `python3`. Always use the full venv path.

---

### 7. Azure Account Pattern

- **Personal**: `{PERSONAL_SUBSCRIPTION_NAME}` -- sandbox experiments
- **Professional**: `{PROFESSIONAL_EMAIL}` -- Government of Canada / production resources
  - Dev subscription:  `{DEV_SUBSCRIPTION_ID}`
  - Prod subscription: `{PROD_SUBSCRIPTION_ID}`

If `az` fails with "subscription doesn't exist":
```powershell
az account show --query user.name
az logout; az login --use-device-code --tenant {TENANT_ID}
```

---

## PART 2 -- PROJECT-SPECIFIC

---

### Project Identity

**Name**: EVA AI Governance
**Folder**: `C:\AICOE\eva-foundation\19-ai-gov`
**ADO Epic**: See `ado-artifacts.json` -- run `ado-import.ps1` to create work items
**37-data-model record**: `GET /model/projects/19-ai-gov`
**Maturity**: active
**Phase**: All design phases complete. Phase 6 (MTI separation + quality remediation) complete Feb 23, 2026.

**Depends on**:
- `37-data-model` (port 8010) -- governance object schemas; use PUT write cycle for schema changes
- `47-eva-mti` -- Trust Service API contract; Decision Engine step 5 calls `POST /trust/evaluateTrust`

**Consumed by**:
- `17-apim` -- reads Decision Engine spec for governance header injection and `/getDecision` call
- `29-foundry` -- candidate runtime for Decision Engine and Trust Service
- `33-eva-brain-v2` -- reads actor contract model; registers service principal with declared contract
- `40-eva-control-plane` -- reads evidence artifact schema; obligation fulfillment runtime
- `31-eva-faces` -- reads trust band definitions for Trust Indicator UI and Governance Panel

---

### Stack and Conventions

```
Markdown (all spec documents)
YAML / JSON (machine-readable catalogs and inline YAML spec blocks)
PowerShell (ADO import, tooling)
Python / C:\AICOE\.venv\Scripts\python.exe (utility scripts only)
```

No runnable application -- this is a specification and design project.

---

### Test Command

```powershell
# No automated test suite -- spec-only project
# Validate governance domain catalog JSON:
C:\AICOE\.venv\Scripts\python -c "import json; json.load(open('eva-governance-domain-catalog.json')); print('[PASS] JSON valid')"
```

**Current test count**: 0 automated tests -- specification project (as of 2026-02-23)

---

### Key Commands

```powershell
# Import ADO work items
Set-Location "C:\AICOE\eva-foundation\19-ai-gov"; .\ado-import.ps1

# Query project record
Invoke-RestMethod "http://localhost:8010/model/projects/19-ai-gov"

# Validate governance domain catalog
C:\AICOE\.venv\Scripts\python -c "import json; json.load(open('eva-governance-domain-catalog.json')); print('[PASS] JSON valid')"
```

---

### Critical Patterns

1. **Decision Engine step 5 calls Trust Service** -- never inline MTI computation in the governance engine. The call is `POST /trust/evaluateTrust` (contract in 47-eva-mti). This is the architectural boundary.

2. **Hard-stops before MTI** -- any implementation must evaluate step 4 (hard-stops) before step 5 (MTI). MTI=100 does not bypass a hard-stop.

3. **Context Envelope is the governance contract** -- any EVA surface calling the Decision Engine must supply the full envelope: actorId, actorType, roles, surface, environment, dataClassification, intent, correlationId.

---

### Known Anti-Patterns

| Do NOT | Do instead |
|---|---|
| Inline MTI computation in the Decision Engine | Call `POST /trust/evaluateTrust` from 47-eva-mti |
| Use raw MTI numeric scores in UI or logs | Use Trust Band label (UNTRUSTED / LOW / GUARDED / TRUSTED / HIGH TRUST) |
| Bypass hard-stops based on role or MTI | Hard-stops are unconditional -- no exemptions |
| Mutate or delete audit_events records | Audit log is append-only -- no UPDATE, no DELETE |
| Copy YAML spec blocks verbatim into code | Strip HTML entities (&amp;nbsp;) before use -- spec YAML is reference-only |

---

### Skills in This Project

| Skill file | Trigger phrases | Purpose |
|---|---|---|
| `00-skill-index.skill.md` | list skills, what can you do, skill menu | Skill index |

---

### 37-data-model -- This Project's Entities

```powershell
# Project record
Invoke-RestMethod "http://localhost:8010/model/projects/19-ai-gov"

# No screens, endpoints, or agents registered -- spec-only project
# Governance catalog: eva-governance-domain-catalog.json (local)
```

## PART 3 " QUALITY GATES

All must pass before merging a PR:

- [ ] Test command exits 0
- [ ] `validate-model.ps1` exits 0 (if any model layer was changed)
- [ ] No [FORBIDDEN] encoding patterns in new code
- [ ] STATUS.md updated with session summary
- [ ] PLAN.md reflects actual remaining work
- [ ] If new screen / endpoint / component added: model PUT + write cycle closed

---

*Source template*: `C:\AICOE\eva-foundation\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md` v3.0.0
*Project 07 README*: `C:\AICOE\eva-foundation\07-foundation-layer\README.md`
*EVA Data Model USER-GUIDE*: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
