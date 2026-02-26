# Copilot Instructions - EVA Brain v2

<!-- Last Updated: 2026-02-23 08:16 ET — 37-data-model integration rules added; work state current -->

## Session Workflow (DPDCA Loop)

Every session follows: **Bootstrap → Discover → Plan → Do → Check → Act → Loop**

1. **Bootstrap** — Execute in this exact order:
   1. Ping the model API: `Invoke-RestMethod http://localhost:8010/health` — if it responds, use HTTP queries for all discovery below. If not, start it (`$env:PYTHONPATH = 'C:\AICOE\eva-foundation\37-data-model'; C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload`) or fall back to `Get-Content .../model/eva-model.json | ConvertFrom-Json`.
   2. Read `.github/copilot-skills/SESSION-STATE.md` (current WI, last test count, open blockers).
   3. Query active sprint state: `Invoke-RestMethod 'http://localhost:8010/model/projects/33-eva-brain-v2'` — confirms maturity, `pbi_done`, `sprint_context`.
   4. Read `docs/artifacts.json` (file-level artifact DB for this repo).
   5. Read `README.md`, `PLAN.md`, `STATUS.md`, this file, then the latest `docs/YYYYMMDD-plan.md` and `docs/YYYYMMDD-findings.md`.
   - **Rule:** Any question whose answer is a service, persona, feature flag, container, endpoint, screen, or literal — look it up in 37-data-model FIRST. Do not open source files to rediscover facts the model already has.
2. **Discover** — Synthesize current sprint, last test result, open questions from findings.
3. **Plan** — Pick the next unchecked task from the latest `yyyymmdd-plan.md` Part 6 checklist.
4. **Do** — Implement. **Execution Rule: make the change, do not describe it.**
5. **Check** — `pytest tests/ --tb=short -q` must exit 0. `uvicorn app.main:app` must start cleanly.
6. **Act** — Run `documentator.md` skill: update `STATUS.md`, `PLAN.md`, `yyyymmdd-plan.md`, this file, and the `31-eva-faces` dependency doc.
7. **Self-Improve** — At every sprint boundary (or when any test required >1 full-suite run to fix): run `self-improvement.md` to write lessons directly into `copilot-instructions.md` and sibling skill files.
8. **Loop** — Return to Discover if tasks remain.

Full orchestration: `.github/copilot-skills/SESSION-WORKFLOW.md`

## Context Health Protocol

Context drift is the #1 source of wasted turns in long sessions (40+ messages).
The agent cannot read a wall clock, but it can count its own Do steps and run a
self-consistency check. Apply this protocol unconditionally.

### Step Counter Rule

Maintain a mental count of Do steps completed in the current session.
A Do step is: any file edit, terminal command, or test run.

| Step milestone | Action required |
|---------------|-----------------|
| Step 5        | Run Context Health Check (below) |
| Step 10       | Run Context Health Check + re-read SESSION-STATE.md |
| Step 15       | Run Context Health Check + re-read SESSION-STATE.md + STATE full summary aloud |
| Every 5 after | Repeat: step 10 pattern |

### Context Health Check (run at each milestone)

Answer these four questions from memory, then verify against SESSION-STATE.md.
If any answer is wrong or "not sure", stop the Do phase and run Recovery.

    1. What is the active WI number and its one-line description?
    2. What was the last recorded test count and coverage %?
    3. What file am I currently editing or about to edit?
    4. Have I run any terminal command in this session that I cannot account for?

### Drift Signals (trigger immediate check outside milestones)

Stop and run the health check immediately if you notice:
- About to search for or read a file you already read this session
- About to run `pytest tests/` without having first isolated the failing test
- Narrating an exploratory step you already completed ("let me check if X exists")
- Proposing an approach that contradicts a decision already recorded in PLAN.md
- Uncertainty about which WI or sprint is active

### Recovery Procedure

    1. Re-read `.github/copilot-skills/SESSION-STATE.md` (not from memory -- from disk)
    2. Run baseline: Push-Location "...\eva-brain-api"; python -m pytest tests/ --tb=no -q 2>&1 | Select-String "passed|failed"
    3. Confirm count matches "Last Test Result" in SESSION-STATE.md
    4. Resume from the last verified good state -- do not re-implement anything

## 37-data-model — The Ecosystem Repository (MANDATORY — USE IT FIRST, EVERY SESSION)

> **READ THE USER GUIDE:** `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`  
> It is the authoritative reference — read it once per sprint boundary or whenever a query pattern is unfamiliar.

> **Why this matters:** Agents that do not use 37-data-model waste 6–10 turns per session on file-reading spirals that the model answers in one HTTP call. The model already contains brain-v2's 60 endpoints, 10 feature flags, 13 Cosmos containers, 22 personas, and the full WBS/project plane. Every fact you would `grep_search` for is already there, typed, cross-referenced, and queryable.

### Anti-patterns (10 wasted turns) vs. model queries (1 turn)

> **Any time you are about to do one of the left-column actions, stop and use the right column instead.**

| DO NOT | DO INSTEAD |
|--------|------------|
| `grep_search` source files for endpoint names or paths | `GET /model/endpoints/` or `GET /model/endpoints/{id}` |
| `file_search` to find a React component's file path | `GET /model/components/{id}` → `.repo_path` |
| `read_file` route files to understand the API surface | `GET /model/endpoints/` |
| Ask "what depends on X" by reading config files | `GET /model/graph?node_id=X&depth=1` |
| Edit `model/*.json` files directly | `PUT /model/{layer}/{id}` → export → assemble |
| Defer the model update to a later session | Update in the **same commit** as the source change |
| Mark an endpoint `implemented` before it is wired | Use `stub` status until route is complete and tested |
| `read_file` to find what line a route handler is on | `.implemented_in` + `.repo_line` → `code --goto` |

### What the model knows about brain-v2 right now

| Layer | Content | How to query |
|-------|---------|-------------|
| L0 services | `eva-brain-api` (port 8001), `eva-roles-api` (port 8002), full `depends_on` chain | `GET /model/services/eva-brain-api` |
| L1 personas | `admin`, `legal-researcher`, `legal-clerk`, `machine-agent`, `auditor` + feature_flags per persona | `GET /model/personas/` |
| L2 feature_flags | All 10 flags, which personas hold them, which endpoints they gate, which source file implements them | `GET /model/feature_flags/` |
| L3 containers | 13 Cosmos containers — fields, partition keys, TTL, which endpoints read/write each | `GET /model/containers/sessions` |
| L4 endpoints | All 60 endpoints — method, path, auth, feature_flag, cosmos_reads, cosmos_writes, status | `GET /model/endpoints/` |
| L9 infrastructure | All `marco-sandbox-*` Azure resources, APIM product tiers, Key Vault secrets | `GET /model/infrastructure/` |
| L25 projects | `33-eva-brain-v2` project record — maturity, ADO epic, pbi_done/total, sprint_context, blocked_by | `GET /model/projects/33-eva-brain-v2` |
| L26 wbs | WBS deliverable nodes for brain-v2 sprints — critical path, gate dependencies | `GET /model/wbs/` |

### Common questions answered in one query instead of ten grep turns

```powershell
# Which personas can POST /v1/ingest/upload?
(Invoke-RestMethod 'http://localhost:8010/model/endpoints/POST /v1/ingest/upload').auth

# What Cosmos containers does GET /v1/chat read and write?
$ep = Invoke-RestMethod 'http://localhost:8010/model/endpoints/POST /v1/chat'
$ep.cosmos_reads; $ep.cosmos_writes

# What breaks everywhere if I change the jobs container?
Invoke-RestMethod 'http://localhost:8010/model/impact/?container=jobs'

# Does action.programme exist yet? (Sprint 7 blocker check)
Invoke-RestMethod 'http://localhost:8010/model/feature_flags/action.programme'
# 404 = blocked. Must be PUT before @require_feature will work.

# Current project state — pbi_done, sprint, maturity
Invoke-RestMethod 'http://localhost:8010/model/projects/33-eva-brain-v2'

# What file and line implements GET /v1/health? Navigate there with one command.
$ep = Invoke-RestMethod 'http://localhost:8010/model/endpoints/GET /v1/health'
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"
```

### Endpoint ID format — copy `.id` verbatim, never construct

> **Recorded Feb 23, 2026 (USER-GUIDE v2.1). This error costs a full validate-model re-run every time.**

The `id` of every endpoint record is **`"METHOD /path/{exact_param_name}"`** — the exact placeholder name in the route declaration (e.g. `"GET /v1/sessions/{session_id}"`, NOT `"GET /v1/sessions/{id}"`).  
Wrong param names pass `PUT` silently but produce a `[FAIL]` in `validate-model.ps1` citing `unknown endpoint 'Y'`.

```powershell
# SAFE pattern: always query, never construct
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/"
$ep | Where-Object { $_.path -like '*sessions*' } | Select-Object id, method, path
# => id="GET /v1/sessions/{session_id}"  ← copy this verbatim into api_calls[]
```

### Add `MODEL_API_URL` to `.env`

```bash
# Add to services/eva-brain-api/.env and .env.example
MODEL_API_URL=http://localhost:8010
MODEL_OFFLINE_MODE=false   # set true only if 37-data-model is not running locally
```

The new `model_api_client.py` (Sprint 7, see README) reads this URL exactly as `roles_client.py` reads `ROLES_API_URL`.

### Sprint planning queries

> **`filter?status=` scope:** The `filter?status=` query parameter is **only available on the `endpoints` layer**.  
> For all other layers (`screens`, `components`, `hooks`, `feature_flags`, etc.) use `Where-Object` client-side.

```powershell
# Endpoints not yet implemented (stub = scaffolded, planned = not started)
# filter?status= works ONLY for endpoints layer:
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=stub"    | Select-Object id | Sort-Object id
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=planned" | Select-Object id

# Screens not yet wired (empty components[])
Invoke-RestMethod "http://localhost:8010/model/screens/" |
  Where-Object { $_.components.Count -eq 0 } | Select-Object id, app, status

# i18n coverage gaps (literals missing French)
Invoke-RestMethod "http://localhost:8010/model/literals/" |
  Where-Object { -not $_.default_fr -or $_.default_fr -eq '' } | Select-Object key, default_en

# Azure resources not yet provisioned
Invoke-RestMethod "http://localhost:8010/model/infrastructure/" |
  Where-Object { $_.status -eq 'planned' } | Select-Object id, type, azure_resource_name

# Which projects are blocked right now?
Invoke-RestMethod "http://localhost:8010/model/projects/" |
  Where-Object { $_.blocked_by.Count -gt 0 } | Select-Object id, maturity, blocked_by
```

### Blast radius (ALWAYS run before renaming, moving, or refactoring)

```powershell
# Full impact of changing a Cosmos container (or a specific field)
Invoke-RestMethod "http://localhost:8010/model/impact/?container=jobs"
Invoke-RestMethod "http://localhost:8010/model/impact/?container=sessions&field=actor_oid"

# Graph traversal: all objects that depend on an endpoint or container (2 hops)
$g = Invoke-RestMethod "http://localhost:8010/model/graph/?node_id=POST /v1/chat&depth=2"
$g.edges | Select-Object from_id, from_layer, to_id, to_layer, edge_type | Format-Table

# All services that depend on eva-roles-api
(Invoke-RestMethod "http://localhost:8010/model/graph/?edge_type=depends_on").edges |
  Where-Object { $_.to_id -eq "eva-roles-api" } | Select-Object from_id
```

> **Rule:** if the blast radius spans more than 2 layers, document it in the ADO work item before committing any code.

### Navigate to source -- never grep

```powershell
# Backend endpoint → route decorator
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"

# React component
$c = Invoke-RestMethod "http://localhost:8010/model/components/QuestionInput"
code --goto "C:\AICOE\eva-foundation\$($c.repo_path):$($c.repo_line)"

# Custom hook
$h = Invoke-RestMethod "http://localhost:8010/model/hooks/useAnnouncer"
code --goto "C:\AICOE\eva-foundation\$($h.repo_path):$($h.repo_line)"
```

### Sprint 7 hard blockers — must be PUT into 37-data-model before brain-v2 code can work

| Flag | Required by | Status today |
|------|-------------|-------------|
| `action.programme` | `@require_feature` on all `/v1/projects`, `/v1/wbs/*` routes | 🔲 Missing — PUT blocks Sprint 7 |
| `action.ado_sync` | `@require_feature` on `POST /v1/ado/sync` | 🔲 Missing — PUT blocks Sprint 7 |
| `action.ado_write` | `@require_feature` on `POST /v1/ado/wi` | 🔲 Missing — PUT blocks Sprint 8 |

Write cycle for each:
```powershell
# Step 1 — PUT the flag (X-Actor header mandatory on every write)
Invoke-RestMethod 'http://localhost:8010/model/feature_flags/action.programme' -Method PUT `
  -ContentType 'application/json' `
  -Headers @{"X-Actor"="agent:copilot"} `
  -Body '{"id":"action.programme","label":"Programme plane — read project and WBS data","personas":["pm_viewer","admin","auditor"],"status":"planned","endpoints":["GET /v1/projects","GET /v1/wbs","GET /v1/wbs/critical-path"]}'
# Step 2 — verify
Invoke-RestMethod 'http://localhost:8010/model/feature_flags/action.programme'
# Step 3 — export audit trail
Invoke-RestMethod 'http://localhost:8010/model/admin/export' -Method POST -Headers @{Authorization='Bearer dev-admin'}
# Step 4 — rebuild
pwsh C:\AICOE\eva-foundation\37-data-model\scripts\assemble-model.ps1
# Step 5 — validate (must exit 0; any violation = revert and fix before committing)
pwsh C:\AICOE\eva-foundation\37-data-model\scripts\validate-model.ps1
```

---

## Artifact Database

`docs/artifacts.json` is the single queryable record of every significant file in the project.
Read it at bootstrap instead of running file_search + grep_search + read_file discovery loops.
Update it in every Act phase for any file created, modified, or deleted.

### Schema per artifact
- `path` -- workspace-relative path
- `type` -- route | service | test | model | config | decorator | middleware | client | entrypoint | test-infra
- `purpose` -- one-line description
- `status` -- stable | wip | planned | stale | missing
- `sprint_created` / `sprint_last_modified`
- `test_file` -- path to the test file covering this artifact (null if none)
- `test_coverage_pct` -- last recorded coverage (null if unmeasured)
- `imports` -- key direct dependencies
- `imported_by` -- who depends on this file
- `notes` -- gotchas, warnings, known patterns

### PowerShell queries
```powershell
# Files with coverage below 70%
$a = Get-Content docs/artifacts.json | ConvertFrom-Json
$a.artifacts | Where-Object { $_.test_coverage_pct -ne $null -and $_.test_coverage_pct -lt 70 } | Select-Object path, test_coverage_pct

# All files with no test file yet
$a.artifacts | Where-Object { $_.test_file -eq $null -and $_.type -ne 'test' -and $_.type -ne 'test-infra' } | Select-Object path, type

# Everything that imports azure.cosmos (Cosmos mock pattern required)
$a.artifacts | Where-Object { $_.imports -contains 'azure.cosmos' } | Select-Object path, notes

# Planned artifacts for next sprint
$a.planned_artifacts | Select-Object path, sprint_planned, purpose
```

### Update rule
After every file creation or modification, update the corresponding artifact entry:
- Set `sprint_last_modified` to current sprint
- Set `status` to `stable` once tests pass
- Update `test_coverage_pct` after running coverage
- Move from `planned_artifacts` to `artifacts` when the file is created

## Session Planning Files

Session decisions and checklists live in `docs/` as dated files:
- `docs/YYYYMMDD-plan.md` — decisions (G1-Gn), sprint scope, Part 6 checklist, open questions
- `docs/YYYYMMDD-findings.md` — forensic findings, code archaeology, discoveries

Always read the **most recent** of each before starting work.

## Test Discipline Rules

These rules exist because repeated pytest runs and mock rabbit holes were the
main source of wasted time in Sprint 4. Enforce them strictly.

### Always isolate before you run the full suite
- NEVER start a diagnostic cycle with `pytest tests/ --tb=short -q`.
- ALWAYS run the single failing file first: `pytest tests/test_foo.py -v --tb=short`.
- Only run the full suite for the gate check at the end of a Do step.

### Read state files before touching code
- Session start order (non-negotiable):
  1. `SESSION-STATE.md` — current WI, last test result, open blockers
  2. `STATUS.md` — overall sprint state
  3. `PLAN.md` — DoD gate for current sprint
- Run the baseline check from SESSION-STATE.md before writing a single line.
- If baseline deviates from the recorded last test result, investigate FIRST.

### Diagnose mocks before writing test files
- Before creating a new test file that imports a service using azure.cosmos:
  1. Check if the service catches `CosmosResourceNotFoundError` or `CosmosHttpResponseError`.
  2. If yes, verify `sys.modules['azure.cosmos.exceptions']` is set in conftest.py.
  3. Check for lazy imports (`from azure.cosmos.aio import X` inside a function body).
     If present, use `patch.dict(sys.modules, ...)` not `patch("app.routes.foo.X")`.
- Full gotcha reference: `tests/conftest.py` — KNOWN MOCK GOTCHAS block at the top.

### Coverage exclude lifecycle
- When a module is excluded from coverage because its implementation is a stub, add a comment:
  `# TODO WI-N: remove this exclusion once the stub is implemented and tests are written`
- As soon as the stub is fully implemented: (1) remove the exclusion entry, (2) run
  `pytest tests/ --cov=app --cov-fail-under=70` and verify the threshold still passes.
- Stale exclusions silently inflate coverage pass rates and hide real gaps.

### Test fixture uniqueness — never rely on list position
- When test fixtures contain multiple records sharing a field value (e.g. two documents
  both with `type="jurisprudence"`), asserting by list index (`response.json()[0]`) is fragile.
- Fix at fixture time: give each record a unique stable `id`. In assertions, select by ID:
  ```python
  record = next(r for r in response.json() if r["id"] == "expected-id")
  assert record["field"] == "expected-value"
  ```

### Fix multiple test failures atomically
- When `pytest -v --tb=short` reveals failures across N different files simultaneously,
  collect ALL fixes into a single `multi_replace_string_in_file` call rather than iterating
  one file at a time.
- Iterative single-file fixes trigger N-1 unnecessary full-suite runs and waste context budget.
- Exception: if a fix in file A changes the interface that file B depends on, sequence them.

## General Rules
- Do not insert or use any non-ASCII Unicode characters or emojis in scripts, JSON, YAML, Terraform, Bicep, Python, or any configuration files; always use plain ASCII text only.
- When proposing resource names, tags, or identifiers for Azure resources, restrict to ASCII characters (letters, digits, `-`, `_`).
- This project uses TWO microservices: `eva-brain-api` (port 8001) and `eva-roles-api` (port 8002). Never conflate them.
- Before editing or referencing any Python file, verify it exists on disk. Sprint 0 (Feb 19, 2026) restored all 25 missing files -- eva-brain-api and eva-roles-api are fully present. The "Missing Files" section has been replaced with a completion note.

## Environment Variables

All required environment variables and their sandbox values/patterns are documented in two `.env.example` files:

| Service | File | Source of truth |
|---------|------|----------------|
| eva-brain-api | `services/eva-brain-api/.env.example` | `services/eva-brain-api/app/config.py` (Settings class) |
| eva-roles-api | `services/eva-roles-api/.env.example` | `services/eva-roles-api/app/main.py` (os.getenv calls) |

> **Naming inconsistency (scrum.py):** `app/routes/scrum.py` reads `COSMOS_ENDPOINT` / `COSMOS_KEY` / `COSMOS_DATABASE`
> (not the `AZURE_COSMOS_*` names used by `config.py`). Both sets must be set when running the full API.
> Both sets are included in `services/eva-brain-api/.env.example`.

---

## EsDAICoESub Inventory Reference
- Subscription name: `EsDAICoESub`
- Subscription ID: `d2d4e571-e0f2-4f6c-901a-f88f7669bcba`
- Primary sandbox resource group: `EsDAICoE-Sandbox`

### Azure Resources (marco-sandbox-* naming)
When working with code, infrastructure, or documentation, prefer reusing these existing resources instead of inventing new ones.

- Search: `marco-sandbox-search` (Microsoft.Search/searchServices)
- Cosmos DB: `marco-sandbox-cosmos` (Microsoft.DocumentDB/databaseAccounts)
- App Service plans: `marco-sandbox-asp-backend`, `marco-sandbox-asp-enrichment`, `marco-sandbox-asp-func`
- Web Apps / Functions: `marco-sandbox-backend`, `marco-sandbox-enrichment`, `marco-sandbox-func`
- Key Vault: `marcosandkv20260203`
- Storage Accounts: `marcosand20260203`, `marcosandboxfinopshub`
- Container Registry: `marcosandacr20260203`
- Application Insights: `marco-sandbox-appinsights`
- API Management: `marco-sandbox-apim`
- Cognitive Services:
  - `marco-sandbox-openai` (kind=OpenAI)
  - `marco-sandbox-foundry` (kind=AIServices) - Azure AI Foundry Hub
  - `marco-sandbox-aisvc` (kind=CognitiveServices)
  - `marco-sandbox-docint` (kind=FormRecognizer) - Azure Document Intelligence
- Data Factory: `marco-sandbox-finops-adf`

### Azure AI Foundry Models (marco-sandbox-foundry)
- **gpt-4o**: Primary model for complex reasoning (20K TPM)
- **gpt-4o-mini**: Cost-optimized model for simple queries (50K TPM)
- **text-embedding-ada-002**: Embeddings for RAG/search (100K TPM)
- Endpoint: https://marco-sandbox-foundry.cognitiveservices.azure.com/
- Foundry client: `app/clients/foundry_client.py` (uses `azure.ai.projects.AIProjectClient`)

## Project-Specific Coding Rules

### Lazy Azure Cosmos Imports
- `app/services/audit_logger.py` already uses a lazily evaluated import of `azure.cosmos.aio` to avoid spinning up the client at module import time. When referencing Cosmos APIs elsewhere, follow the same pattern (defer `from azure.cosmos.aio import CosmosClient` until inside a factory/async context manager).

## Lesson Learned: API-First Write Protocol for Data Model Objects

> Recorded Feb 22, 2026. Source: eva-faces agent self-correction during 37-data-model session.

### The Rule
Never edit `model/*.json` files directly to update data model objects.
Never `PUT` directly into the underlying database (Cosmos or any other store).
Always go through the application layer.

### Why
Direct JSON edits bypass the audit trail entirely:
- `modified_by` shows `"system:autoload"` (the seed actor) instead of a real actor
- `modified_at` reflects the last seed run, not when the change was actually made
- `row_version` stays at `1` for every object regardless of how many times it was changed
- `GET /model/admin/audit` is blind to those changes

The analogy (stated by the agent verbatim): editing a Siebel repository table with a raw
`UPDATE` statement instead of going through Siebel Tools UI. The application state is
corrupted from an audit perspective even though the data looks correct.

### Correct Write Cycle (5 steps)
```
1. PUT /model/{layer}/{id}        # stamps modified_at, modified_by, row_version; X-Actor header required
2. GET /model/{layer}/{id}        # verify the stored object
3. POST /model/admin/export       # write store back to model/*.json (preserves audit trail)
4. assemble-model.ps1             # rebuild eva-model.json
5. validate-model.ps1             # must exit 0; any violation = revert and fix before committing
```

### PUT Rules — non-negotiable (recorded Feb 23, 2026 USER-GUIDE v2.1)

**Rule 1 — PATCH is not supported. Always PUT the full object.**  
`PATCH` returns 422. Never attempt partial-field updates. Build the full object for every write.

**Rule 2 — Strip audit columns before PUT.**  
Audit columns (`obj_id`, `layer`, `is_active`, `modified_*`, `created_*`, `row_version`) must be excluded from the PUT body or the API rejects / silently misbehaves.

```powershell
# Strip-Audit helper — use this for every PUT
function Strip-Audit($obj) {
    $keep = $obj.PSObject.Properties |
        Where-Object { $_.Name -notmatch '^(obj_id|layer|is_active|modified_|created_|row_version)' }
    $out = [ordered]@{}
    foreach ($p in $keep) { $out[$p.Name] = $p.Value }
    $out
}

$raw = (Invoke-WebRequest "http://localhost:8010/model/screens/Chat").Content | ConvertFrom-Json
$body = Strip-Audit $raw
$body.components = @("QuestionInput", "Answer", "ChatHistory")   # mutate domain fields
$json = $body | ConvertTo-Json -Depth 10
Invoke-RestMethod "http://localhost:8010/model/screens/Chat" `
  -Method PUT -Body $json -ContentType "application/json" `
  -Headers @{"X-Actor"="agent:copilot"}
```

**Rule 3 — Use a `.ps1` script for any PUT with more than 3 fields.**  
Inline PowerShell one-liners with `ConvertTo-Json` are silently truncated in the terminal — the PUT lands but output is cut off and you cannot confirm success. Write a temp script, run it, delete it.

### Canonical write confirmation — assert, never trust terminal output

After every PUT, run a GET and assert all three properties:

```powershell
$v = (Invoke-WebRequest "http://localhost:8010/model/screens/Chat").Content | ConvertFrom-Json
if ($v.row_version -lt 2 -or $v.modified_by -ne 'agent:copilot') {
    throw "PUT did not land — row_version=$($v.row_version) modified_by=$($v.modified_by)"
}
# Also assert the domain field you changed:
if ($v.components -notcontains 'QuestionInput') { throw 'components update missing' }
```

**Three assertions required:** `row_version` (must be previous+1), `modified_by` (must equal X-Actor), and at least one domain field confirming the change reached storage.

### `repo_line` WARNs are chronic pre-existing noise — ignore them

`validate-model.ps1` always emits ~38+ `[WARN]` lines about objects with no `repo_line` value.  
These are tracked in `scripts/backfill-repo-lines.py` and are not your responsibility.

**Ignore every `[WARN]` — only `[FAIL]` lines block a commit.**

To check without the WARN noise:
```powershell
# API validator (preferred over PS script for cross-reference checks)
$v = Invoke-RestMethod "http://localhost:8010/model/admin/validate"
if ($v.count -gt 0) { $v.violations | Format-Table; throw "Model has violations" }
Write-Host "PASS -- 0 violations"
```

### Fix a validation FAIL — step-by-step

If `validate-model.ps1` or `GET /model/admin/validate` reports `screen 'X' api_calls references unknown endpoint 'Y'`:

```powershell
# Step 1: find the ACTUAL endpoint id (never construct -- see Endpoint ID format section)
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.path -like '*your-path*' } | Select-Object id, method, path

# Step 2: fetch the offending screen, strip audit, correct api_calls
$raw = (Invoke-WebRequest "http://localhost:8010/model/screens/X").Content | ConvertFrom-Json
$body = Strip-Audit $raw
$body.api_calls = @("GET /v1/correct/{exact_param}")   # use the correct id from Step 1
$json = $body | ConvertTo-Json -Depth 10
Invoke-RestMethod "http://localhost:8010/model/screens/X" `
  -Method PUT -Body $json -ContentType "application/json" `
  -Headers @{"X-Actor"="agent:copilot"}

# Step 3: confirm write landed
$v2 = (Invoke-WebRequest "http://localhost:8010/model/screens/X").Content | ConvertFrom-Json
if ($v2.row_version -le $raw.row_version) { throw 'PUT did not land' }

# Step 4: export → assemble → re-validate (must be 0 violations)
Invoke-RestMethod 'http://localhost:8010/model/admin/export' -Method POST -Headers @{Authorization='Bearer dev-admin'}
pwsh C:\AICOE\eva-foundation\37-data-model\scripts\assemble-model.ps1
$v = Invoke-RestMethod "http://localhost:8010/model/admin/validate"
if ($v.count -gt 0) { throw "Still failing" }
```

### Applies Equally To
- Any API-backed store (37-data-model, eva-brain-api cosmos_service, eva-roles-api sessions)
- Mocks in tests: mock at the SERVICE or STORE layer, not by editing fixture JSON files
  and restarting the server
- Any feature flag, persona, endpoint, or screen in the data model

### Headers (mandatory on every protected endpoint)
Every FastAPI route handler that calls `@require_feature` MUST accept these headers:
```python
x_actor_oid: Annotated[str, Header(alias="X-Actor-OID")]
x_correlation_id: Annotated[str, Header(alias="X-Correlation-ID")]
x_acting_session: Annotated[str, Header(alias="X-Acting-Session")]
x_caller_app: Annotated[str, Header(alias="X-Caller-App")] = "unknown"
x_environment: Annotated[str, Header(alias="X-Environment")] = "dev"
```

### RBAC Decorator
All protected endpoints use `@require_feature` from `app.decorators.feature_guard`.
```python
from app.decorators import require_feature
from app.models.features import FeatureID

@router.post("/v1/chat")
@require_feature(FeatureID.ACTION_CHAT)
async def chat(...):
    ...
```
Public endpoints (config, health, translations) do NOT use `@require_feature`.

### Settings / Config
`app.config.settings` is the ONLY source for all Azure credentials and service URLs. Never hardcode endpoints, keys, or URLs in route files or service files. Settings object reads from environment variables defined in `.env` and the full variable list in `tests/conftest.py`.

Key settings attributes used across the codebase:
- `settings.azure_cosmos_endpoint`, `settings.azure_cosmos_database`, `settings.azure_cosmos_key`
- `settings.azure_openai_endpoint`, `settings.azure_openai_deployment`, `settings.azure_openai_api_key`
- `settings.azure_search_endpoint`, `settings.azure_search_index`, `settings.azure_search_api_key`
- `settings.azure_storage_account_name`, `settings.azure_storage_account_key`, `settings.azure_storage_container`
- `settings.azure_tenant_id`, `settings.azure_client_id`, `settings.azure_client_secret`
- `settings.roles_api_url` (default: http://localhost:8002)
- `settings.environment`, `settings.log_level`

`app/config.py` is PRESENT. It provides a `Settings(BaseSettings)` singleton at `app.config.settings`.

### Lane A / Logging Compliance
- NEVER store raw content (prompts, responses, document text) in logs or audit records.
- Use `hash_content(text)` (SHA-256, 16-char hex) from `app.models.agent` for all content references.
- Use `create_safe_result_summary(result)` from `app.models.agent` for tool output records.
- All tool invocations produce a `ToolInvocation` model with `result_summary` (metadata only), not raw results.
- Lane B (break-glass) logging requires `ticket_id`, `approver`, `reason`, `expires_at` fields.

### Cost Attribution (mandatory)
Every agent invocation must include cost tags:
```python
from app.models.cost import CostTags  # file may need reconstruction
cost_tags = CostTags(
    phase=resolved_session["phase"],
    task=resolved_session["task"],
    project=resolved_session["project"],
    costcenter=resolved_session["costcenter"],
    persona_id=resolved_session["persona_id"],
    actor_oid=x_actor_oid
)
```

### Personas
Persona constraints are defined ONLY in `services/eva-brain-api/config/personas.yml`.
Do NOT hardcode persona rules (tool whitelists, index access, token budgets) in Python files.
Use `PersonaConstraintsService.get_constraints(persona_id)` to load them at runtime.

Current personas: `legal-researcher`, `legal-clerk`, `admin`.

### Eva-Roles-API
The companion service runs on port 8002 (configurable via `ROLES_API_URL`).
`app/services/roles_client.py` is the HTTP client for the roles API.
`app/clients/roles_client.py` is the persistent httpx.AsyncClient wrapper with `resolve_session()` and `close()`.
All eva-roles-api source files were restored in Sprint 0 (Feb 19, 2026).

## Sprint 0 Completion (Feb 19, 2026 @ 3:10 PM ET)

All 25 previously-missing files have been created. The service boots cleanly. **72/72 tests pass.**

### eva-brain-api -- Restored Files
```
app/config.py                              -- Settings(BaseSettings) singleton
app/main.py                                -- FastAPI app, port 8001, optional router mounting
app/utils/__init__.py
app/utils/retry.py                         -- with_retry() async decorator
app/models/__init__.py
app/models/cost.py                         -- CostTags model
app/models/features.py                     -- FeatureID enum
app/decorators/__init__.py
app/decorators/feature_guard.py            -- @require_feature, G6 rule
app/middleware/__init__.py
app/middleware/rbac.py                     -- RBACMiddleware, X-Actor-OID, public prefixes
app/services/__init__.py
app/services/audit_logger.py              -- Lane A/B, lazy cosmos.aio import
app/services/azure_openai_service.py
app/services/azure_search_service.py
app/services/roles_client.py
app/services/rag_orchestrator.py           -- 7 approaches
app/clients/__init__.py
app/clients/roles_client.py                -- persistent httpx.AsyncClient
app/routes/__init__.py
app/routes/health.py
app/routes/chat.py                         -- 7 approach endpoints + /v1/chat/approaches
app/routes/retrieve.py
app/routes/documents.py                    -- 8 endpoints
tests/test_rbac.py                         -- 22 tests
tests/test_rag_orchestrator.py             -- 16 tests
```

### eva-roles-api -- Restored Files
```
app/__init__.py
app/main.py                                -- FastAPI app, port 8002
app/routes/__init__.py
app/routes/health.py
app/routes/roles.py                        -- 6 RBAC endpoints
app/services/__init__.py
app/services/rbac_service.py
app/services/cost_policy_service.py
app/services/session_service.py            -- in-process sessions, TTL 4h
```

### Modified Existing Files
- `eva-roles-api/app/exceptions.py`: Fixed SWA leak -- `x-ms-client-principal-id` -> `X-Actor-OID` (G5)
- `eva-brain-api/app/middleware/rbac.py`: Added `/v1/chat/approaches` to `_PUBLIC_PREFIXES`
- `eva-brain-api/app/main.py`: Optional router mounting (try/except) for pre-existing broken deps

### Sprint 2 Backlog (not yet implemented)
- Cosmos DB persistence for eva-roles-api sessions (currently in-process dict)
- OTel tracing integration in RBACMiddleware
- `utils/__init__.py` re-exports for convenience helpers

## Files Present on Disk (Safe to Reference)

### eva-brain-api
```
app/agents/conversation_agent.py     -- ConversationAgent class
app/agents/tools.py                  -- AgentTools class (7 tools)
app/agents/persona_constraints.py    -- PersonaConstraintsService
app/clients/foundry_client.py        -- FoundryClient (Azure AI Projects SDK)
app/exceptions.py                    -- EVAException hierarchy
app/models/agent.py                  -- All agent Pydantic models (540 lines)
app/routes/admin.py                  -- POST /v1/users, GET /v1/groups
app/routes/config.py                 -- GET /v1/config/info|features|translations (public)
app/routes/ingest.py                 -- POST /v1/ingest/* (6 endpoints)
app/routes/search.py                 -- Saved search management
app/routes/sessions.py               -- POST/GET/PATCH/DELETE /v1/sessions/*
app/routes/tags.py                   -- GET /v1/tags, /v1/tags/{tag}/documents
app/services/chunking_service.py
app/services/config_service.py
app/services/conversation_store.py   -- InMemoryConversationStore
app/services/cosmos_service.py       -- CosmosService, JobStatus enum
app/services/document_service.py
app/services/embedding_service.py
app/services/enrichment/entity_extraction_service.py
app/services/enrichment/pii_redaction_service.py
app/services/enrichment/translation_service.py
app/services/group_service.py
app/services/indexing_service.py
app/services/metrics_service.py      -- AgentMetricsService (OpenTelemetry)
app/services/pipeline_orchestrator.py
app/services/processors/docx_processor.py
app/services/processors/image_processor.py
app/services/processors/pdf_processor.py
app/services/processors/txt_processor.py
app/services/processors/xlsx_processor.py
app/services/queue_service.py        -- QueueService, QueueName enum
app/services/rag_context_builder.py  -- RAGContextBuilder
app/services/rag_orchestrator_old.py -- OLD version, do not use
app/services/search_management_service.py
app/services/session_service.py
app/services/storage_service.py
app/services/tag_service.py
app/services/user_service.py
tests/conftest.py
tests/test_agent_framework.py
tests/test_chat_endpoints.py
tests/test_exceptions.py
tests/test_roles_client.py
tests/test_rbac.py                   -- 22 RBAC tests (Sprint 0)
tests/test_rag_orchestrator.py       -- 16 RAG orchestration tests (Sprint 0)
config/personas.yml
openapi/agent-schemas.yaml
-- Sprint 0 restored (Feb 19, 2026):
app/config.py
app/main.py
app/utils/__init__.py
app/utils/retry.py
app/models/__init__.py
app/models/cost.py
app/models/features.py
app/decorators/__init__.py
app/decorators/feature_guard.py
app/middleware/__init__.py
app/middleware/rbac.py
app/services/__init__.py
app/services/audit_logger.py
app/services/azure_openai_service.py
app/services/azure_search_service.py
app/services/roles_client.py
app/services/rag_orchestrator.py
app/clients/__init__.py
app/clients/roles_client.py
app/routes/__init__.py
app/routes/health.py
app/routes/chat.py
app/routes/retrieve.py
app/routes/documents.py
-- Sprint 4 restored + added (Feb 20, 2026):
tests/test_cosmos_service.py
tests/test_document_service.py
tests/test_embedding_service.py
tests/test_enrichment_services.py
tests/test_failure_modes.py
tests/test_indexing_service.py
tests/test_pipeline_orchestrator.py
tests/test_processors.py
tests/test_rag_context_builder.py
tests/test_routes_tags_and_storage.py
tests/test_search_and_embedding_services.py
tests/test_sessions.py
tests/test_tag_service.py
-- Sprint 5 WI-5 (Feb 20, 2026):
app/services/translation_store_service.py  -- Cosmos translations container CRUD
app/services/settings_service.py           -- Cosmos settings container CRUD
app/services/math_assistant.py             -- SymPy evaluate/solve/plot (run_in_executor)
app/services/tabular_assistant.py          -- Pandas parse/query/summarize/export
app/services/audit_log_service.py          -- Cosmos audit_logs (90d TTL) read-only
app/services/content_log_service.py        -- Cosmos content_logs (24h TTL) read-only
app/routes/translations.py                 -- GET/PUT/PATCH/DELETE /v1/config/translations/{lang}
app/routes/settings.py                     -- GET/PATCH /v1/settings
app/routes/assistants.py                   -- 7 math+tabular endpoints
app/routes/logs.py                         -- 8 audit+content log endpoints
tests/test_translations.py
tests/test_settings.py
tests/test_assistants.py
tests/test_logs.py
-- Sprint 5 WI-6 (Feb 20, 2026):
app/services/apps_service.py               -- Cosmos apps container CRUD (UUID partition key)
app/routes/apps.py                         -- 7 apps registry endpoints (admin only)
tests/test_apps.py                         -- 23 tests (route + service unit)
```

### eva-roles-api
```
app/__init__.py
app/main.py
app/exceptions.py
app/routes/__init__.py
app/routes/health.py
app/routes/roles.py
app/services/__init__.py
app/services/rbac_service.py
app/services/cost_policy_service.py
app/services/session_service.py
tests/test_exceptions.py
```

## Contract Schemas
JSON schemas in `contracts/schemas/` define the API contract:
- `chat-request.json` -- required: messages[]; optional: max_tokens, temperature, rag_top_k, rag_indexes, cost_tags
- `chat-response.json` -- required: choices[], usage; optional: citations[]
- `cost-tags.json` -- required: phase, task, project, costcenter
- `persona-context.json`
- `session.json`
- `audit-event.json`

OpenAPI component schemas are in `services/eva-brain-api/openapi/agent-schemas.yaml`.




## Work State — February 23, 2026 @ 8:16 AM ET

| Metric | Value |
|--------|-------|
| Active sprint | Sprint 6 — Deployment to Azure |
| Tests | 577/577 passing · 72% coverage |
| Endpoints | 60/60 implemented |
| eva-roles-api | Running (port 8002) — fully present on disk |
| Dockerfile (brain-api) | Present |
| Dockerfile (roles-api) | Needs creation (Sprint 6 step 1) |
| ACR push | Pending (Sprint 6 step 2) |
| Container App deploy | Pending (Sprint 6 steps 3–4) |
| APIM policies | Pending (Sprint 6 step 5) |
| action.programme flag in 37-data-model | 🔲 Missing — blocker for Sprint 7 |
| action.ado_sync flag in 37-data-model | 🔲 Missing — blocker for Sprint 7 |
| model_api_client.py | 🔲 Planned Sprint 7 |
| services.json notes (stale) | Says "453 tests, Phase 1-4" — update to 577/60/60 after Sprint 6 deploy via `PUT /model/services/eva-brain-api` |

---

## Definition of Done (MI-8)

Every WI that adds, modifies, or removes API routes MUST satisfy ALL of the following
before the task is marked done in the sprint checklist.

### Route Change Checklist

| # | Gate | How to verify |
|---|------|--------------|
| 1 | `pytest tests/ --tb=short -q` exits 0 | Test suite passes |
| 2 | `uvicorn app.main:app` starts cleanly (no ERROR in lifespan output) | Manual startup check |
| 3 | `37-data-model/model/endpoints.json` reflects the change | Grep for the route id |
| 4 | `scripts/assemble-model.ps1` succeeds (25/25 layers populated) | Run the script |
| 5 | `scripts/validate-model.ps1` reports PASS -- 0 violations | Run the script |
| 6 | `docs/artifacts.json` updated for any new/modified file | Review artifact DB |
| 7 | `STATUS.md` sprint section updated | Review STATUS.md |

### Data Model Write Protocol (API-First)

NEVER edit `model/*.json` files directly to create or update data model objects.
Direct edits bypass the audit trail (`modified_by` stays `"system:autoload"`, `row_version` stays `1`).

Correct 5-step write cycle:
```
1. PUT /model/{layer}/{id}        # API stamps modified_at, modified_by, row_version; include X-Actor header
2. GET /model/{layer}/{id}        # verify the write round-tripped correctly
3. POST /model/admin/export       # write store back to model/*.json on disk
4. scripts/assemble-model.ps1     # rebuild eva-model.json
5. scripts/validate-model.ps1     # must exit 0 — ANY violation = revert and fix before committing
```

> **`X-Actor` header is mandatory on every PUT:**
> ```powershell
> Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/tags" `
>   -Method PUT -ContentType "application/json" `
>   -Headers @{"X-Actor"="agent:copilot"} `
>   -Body ($payload | ConvertTo-Json -Depth 5)
> ```

> **Same-PR rule:** every source change that affects a model object must update the model in the same commit. Never defer. A stale model is worse than no model.

Run `scripts/validate-model.ps1` after step 4. Target is always 0 violations.

Exception: bulk structural adds (new layers, schema fields) may be done via direct
JSON edit during the same session that introduces the schema, followed immediately by
the full write cycle (steps 3-4) and a validate run.

### Model Offline Mode

`MODEL_OFFLINE_MODE=true` suppresses the startup validation call to 37-data-model.
Use it only in local dev when 37-data-model is not running.
NEVER commit `.env` with `MODEL_OFFLINE_MODE=true`.

---

## Execution Rule

Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: findings docs (Discover), status updates (Act), test evidence (Check).
Not allowed: a document whose sole content is "here is what I will change in file X."
