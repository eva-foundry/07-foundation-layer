# GitHub Copilot Instructions " EVA ADO Command Center

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA ADO Command Center " Scrum orchestration hub
**Path**: `C:\AICOE\eva-foundation\38-ado-poc\`
**Stack**: Python, FastAPI, Azure DevOps

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

### 3. EVA Data Model API " Mandatory Protocol

**Full reference**: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
Read it at every sprint boundary or when a query pattern is unfamiliar.

#### Rule: query the model first " never grep when the model has the answer

| You want to know... | Use (1 turn) | Do NOT (10 turns) |
|---|---|---|
| All endpoints for a service | `GET /model/endpoints/` filtered | grep router files |
| What a screen calls | `GET /model/screens/{id}` -> `.api_calls` | read screen source |
| Auth/feature flag for an endpoint | `GET /model/endpoints/{id}` | grep auth middleware |
| What breaks if X changes | `GET /model/impact/?container=X` | trace imports manually |
| Navigate to source line | `.repo_path` + `.repo_line` -> `code --goto` | file_search |

#### 5-step write cycle (mandatory " every model change)

```
1. PUT /model/{layer}/{id}           -- X-Actor: agent:copilot header required
2. GET /model/{layer}/{id}           -- assert row_version incremented + modified_by matches
3. POST /model/admin/export          -- Authorization: Bearer dev-admin
4. scripts/assemble-model.ps1        -- must report 27/27 layers OK
5. scripts/validate-model.ps1        -- must exit 0; [FAIL] lines block commit; [WARN] are noise
```

#### 7 agent gotchas (recorded Feb 23, 2026)

1. **Strip audit columns from PUT body** " exclude `obj_id`, `layer`, `is_active`, `modified_*`, `created_*`, `row_version`. Build `[ordered]@{}` from domain fields only.
2. **PATCH is not supported** " always PUT the full object.
3. **Endpoint IDs include the exact param name** " never construct; use `GET /model/endpoints/` and copy `.id` verbatim (e.g. `"GET /v1/sessions/{session_id}"` not `"GET /v1/sessions/{id}"`).
4. **Fix a FAIL** " look up correct endpoint ID, re-PUT the screen, re-run write cycle.
5. **Use a .ps1 script for PUTs with more than 3 fields** " inline one-liners truncate silently.
6. **[WARN] repo_line lines are pre-existing noise** " only [FAIL] lines block a commit.
7. **Canonical confirm**: `(Invoke-WebRequest ".../{id}").Content | ConvertFrom-Json | Select-Object row_version, modified_by`

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

## PART 2 - PROJECT-SPECIFIC
> PRESERVED from previous copilot-instructions.md (no PART structure detected).
> Review and restructure into the PART 2 sections below as needed.

```instructions
# Copilot Instructions " 38-ado-poc (EVA ADO Command Center)

## Role of this repository

`38-ado-poc` is the **control plane** for scrum execution across the entire EVA Platform.
It reads the live backlog from Azure DevOps, identifies active work items, and dispatches
project-specific copilot-agent runners to execute their DPDCA lifecycle.

This is not a passive sprint history log. It is the orchestration hub:
- ADO is the **single source of truth** for what work is active, blocked, or done
- Each runner is dispatched from here " reads its WI from ADO, runs DPDCA, pushes state back
- Skills for all runners are mastered in `29-foundry` and sourced centrally
- APIM (`17-apim`) injects `x-eva-*` cost attribution headers on every API call
- Sprint data feeds `39-ado-dashboard` (EVA Home + ADO views in `31-eva-faces`) via APIM

---

## General rules

- Use plain ASCII only in scripts, JSON, YAML, and config files. No emojis in code.
- When suggesting Azure resource names, use `marco-sandbox*` or `marcosand*` naming patterns.
- Never commit secrets or PAT values to any file in any repo " see Security section.
- All PowerShell scripts must be idempotent (safe to re-run without creating duplicates).

---

## Sandbox & subscription

- Subscription: EsDAICoESub (`d2d4e571-e0f2-4f6c-901a-f88f7669bcba`)
- Resource group: `EsDAICoE-Sandbox`
- Key resources:
  - `marco-sandbox-apim` " API Management gateway (import scheduled Mar 29"30, 2026)
  - `marco-sandbox-cosmos` " Cosmos DB (`scrum-cache` container, brain-v2 owns this)
  - `marco-eva-brain-api` " Container App serving `/v1/scrum/*` routes
  - `marco-eva-roles-api` " Container App serving `/evaluate-cost-tags` ... deployed
  - `marcosandkv20260203` " Key Vault (production secrets)

---

## ADO project coordinates

```
ADO_ORG_URL    = https://dev.azure.com/marcopresta
ADO_PROJECT    = eva-poc
ADO_TEAM       = eva-poc Team
EPICS          = ids 15-32  (one per eva-foundation project folder; 18 total)
FEATURES       = ids 33-95  (2-3 per project)
PBIS           = ids 96-122 + pre-existing 7-14 (brain v2 history)
ADO_ACTIVE_WI  = WI-7    (brain v2 Sprint-6 sandbox deploy)
ADO_ACTIVE_SPRINT = Sprint-6
```

API version used throughout all scripts: `7.1`
Base URL: `https://dev.azure.com/marcopresta/eva-poc/_apis/`
Auth: `Authorization: Basic base64(:PAT)` " PAT from `$env:ADO_PAT` only.
Board (Epics view): `https://dev.azure.com/marcopresta/eva-poc/_boards/board/t/eva-poc%20Team/Epics`

---

## Security " PAT handling (CRITICAL)

- The PAT is **always** passed as `$env:ADO_PAT`. Never store it in any file.
- All scripts must throw immediately if `$env:ADO_PAT` is not set.
- `.env.ado` contains only IDs, URLs, and team names " zero credentials. Safe to commit.
- Production credentials live in Key Vault `marcosandkv20260203`. Use SP `sp-eva-foundry` for pipeline runs.
- Never substitute a hardcoded token or base64 string in place of `$env:ADO_PAT`.

---

## Script rules (scripts/)

Canonical script source: `38-ado-poc/scripts/` (all scripts live here).

| Script | Purpose | When to run |
|--------|---------|-------------|
| `ado-import-project.ps1` | Shared import engine " Epic+Features+PBIs+Sprints via ADO REST 7.1; idempotent | Per-project import / re-run |
| `ado-onboard-all.ps1` | Orchestrator " discovers all 18 project folders, calls import engine, logs everything | Batch import or re-sync all projects |
| `ado-generate-artifacts.ps1` | Idea intake parser " structured markdown ' `ado-artifacts.json` skeleton | Before a new project import |
| `ado-bootstrap-pull.ps1` | WIQL query ' markdown WI table for session context | Phase 0 of every DPDCA session |
| `ado-close-wi.ps1` | Transition PBI ' Done, post test count + coverage comment | Phase 5 / Act phase |
| `ado-create-bug.ps1` | Create Bug WI with Severity, Sprint, repro steps | Self-improvement P0/P1 findings |
| `<project>/ado-import.ps1` | Thin wrapper " sets paths and calls shared engine | Single-project import |

### Script discipline

- All `Ensure-Sprint` calls handle 409 conflict via GET fallback; use `.identifier` GUID (not `.id` integer) for team assignment.
- PS7 `ConvertTo-Json` unwraps single-element arrays " always use `ConvertTo-Json -InputObject $Body`.
- `[array](if ...)` is invalid PS7 syntax " use `$arr = @(); if (...) { $arr = [array]$x }`.
- Guard optional PSObject properties with `$obj.PSObject.Properties['field']` before access under `Set-StrictMode -Version Latest`.
- ADO WIQL does not support hierarchy subqueries (`IN (SELECT FROM WorkItemLinks...)`). Use title+type filter only.
- Scrum PBI state machine is sequential " never skip steps:
  ```
  New ' Approved ' Committed ' Done
  ```
  Each transition is a separate PATCH call. Setting State=Done on creation is rejected by ADO.
- `ado-close-wi.ps1` finds a PBI by tag (case-insensitive). Ensure the WI is at Committed before calling.
- Always print the work item URL at the end of `ado-close-wi.ps1` for the MANIFEST log.

---

## DPDCA session protocol (run from this Command Center)

**Phase 0 " Bootstrap (always):**
```powershell
$env:ADO_PAT = "<your-pat>"           # never stored in any file
.\scripts\ado-bootstrap-pull.ps1      # read board ' build WI queue
```
ADO is authoritative. If ADO state conflicts with `SESSION-STATE.md`, **ADO wins**.

**Phase 5 " Act (sprint close):**
```powershell
.\scripts\ado-close-wi.ps1 -WiTag "WI-7" -TestCount 600 -Coverage "73" -Notes "APIs deployed"
```

**Self-improvement escalation:**
```powershell
.\scripts\ado-create-bug.ps1 -Title "axe timeout in waitFor" -Severity "2 - High" -Sprint "Sprint-6"
```

---

## GitHub-ADO async bridge (.github/workflows/)

All 5 workflow files live in `.github/workflows/` " copy to each project repo before use:

| File | Trigger | Purpose |
|------|---------|--------|
| `ado-pr-bridge.yml` | PR open/close/review, CI check | PR lifecycle ' ADO WI state machine; `[WI-ID:N]` convention |
| `ado-idea-intake.yml` | Push to `docs/ADO/idea/` | Parse idea docs ' generate `ado-artifacts.json` ' import to ADO |
| `sprint-execute.yml` | `workflow_dispatch` from ADO | DPDCA execution, heartbeats, WI close, PR creation |
| `watchdog-poll.yml` | Cron every 15 min | Detect stall/crash on `SPRINT_HEARTBEAT` ' ADO alert + Teams |
| `morning-summary.yml` | Cron 12:00 UTC (07:00 ET) | Daily sprint digest ' ADO Feature comment |

Heartbeat format written to GitHub repo variable `SPRINT_HEARTBEAT`:
```
2026-02-20T14:35:00Z|WI-7|Do|eva-brain-v2|run_id=12345678
```

Stall thresholds:
- < 25 min old ' normal
- 25"45 min ' ADO WARNING comment on Feature
- > 45 min ' ADO ALERT + Teams message
- Action failed ' immediate Teams CRITICAL alert

ADO Pipeline (`PIPELINE-SPEC.md`) fires `workflow_dispatch` to GitHub; GitHub Actions calls
Foundry skill endpoints and posts progress back via ADO REST. Never the reverse.

---

## Cost attribution (`x-eva-*` headers)

`/evaluate-cost-tags` is already deployed on `marco-eva-roles-api`. It is the source of truth
for project, client, business unit, and sprint cost tags on every API call.

Headers injected by APIM inbound policy on every request:
```
x-eva-user-id        " JWT oid claim (Entra ID)
x-eva-role           " Roles API /context response
x-eva-business-unit  " persona ' business unit
x-eva-project-id     " subscription mapping
x-eva-client-id      " product subscription ' client
x-eva-sprint         " ADO active sprint from cache
x-eva-wi-tag         " WI tag on current sprint context (e.g. eva-brain;wi-7)
```

Live endpoint (dev-bypass mode until Entra app registration):
```
POST https://marco-eva-roles-api.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io/evaluate-cost-tags
Header: x-ms-client-principal-id: <user-id>
Body:   { "context": { "project": "eva-brain-v2", "sprint": "Sprint-6", "wi_tag": "eva-brain;wi-7" } }
```

---

## Skill versioning (29-foundry)

All runner skills originate from `29-foundry/.github/copilot-skills/`. Each project carries:
- A reference to the foundry `SKILL_VERSION` it is running on
- Its own `SESSION-STATE.md` (local cache " ADO is authoritative)

Format: `MAJOR.MINOR.PATCH`  
Current: `1.0.0`  
Project `.env.ado` fields:
```
FOUNDRY_SKILL_VERSION=1.0.0
FOUNDRY_PROJECT_ID=eva-brain-v2
FOUNDRY_HUB_ENDPOINT=https://eva-aicoe.api.azureml.ms
```

Do not update skills in individual project repos " update `29-foundry` and propagate.

---

## ADO WI tagging convention

- Tags format: `<project>;<wi-tag>` " e.g. `eva-brain;wi-7` (lowercase, semicolon-separated)
- Entity tags for `37-data-model` awareness: `entity:<name>` " e.g. `entity:assistant`
- Tags are the attribution dimension for APIM cost headers and `14-az-finops` FinOps pipeline

---

## Where to find authoritative project info

| What | Where |
|------|-------|
| Live board state | `STATUS.md` |
| Layered architecture | `PLAN.md` |
| Future milestones | `ROADMAP.md` |
| Definition of done | `ACCEPTANCE.md` |
| ADO REST endpoints | `APIS.md` |
| All board/WI URLs | `URLS.md` |
| Cross-project deps | `DEPENDENCIES.md` |
| Foundry hub design | `FOUNDRY-PLAN.md` |
| Observability stack | `OBSERVABILITY.md` |
| Pipeline YAML spec | `PIPELINE-SPEC.md` |
| Script reference + schema | `docs/ADO/ONBOARDING.md` |
| Three-system wiring + deploy | `docs/ADO/THREE-SYSTEM-WIRING.md` |
| Scripts (canonical) | `scripts/ado-import-project.ps1`, `scripts/ado-onboard-all.ps1` |
| Project-39 plan | `../39-ado-dashboard/PLAN.md` |
| ADO project | `https://dev.azure.com/marcopresta/eva-poc` |

---

## Execution rule

Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: script edits, `.env.ado` updates, STATUS.md updates, ACCEPTANCE.md checkbox updates.
Not allowed: a document whose sole content is "here is what I will change in file X."
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
