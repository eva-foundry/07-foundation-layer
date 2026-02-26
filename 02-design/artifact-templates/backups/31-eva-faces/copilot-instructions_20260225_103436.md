# GitHub Copilot Instructions " EVA Faces

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA Faces " Admin + chat + portal frontend
**Path**: `C:\AICOE\eva-foundation\31-eva-faces\`
**Stack**: React, TypeScript, Fluent UI v9

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

# Copilot Instructions " EVA Faces

General rules
- Use plain ASCII only in scripts, JSON, YAML, Terraform, Bicep, or other configuration files. Avoid emojis in code or configs.
- When suggesting Azure resource names, use `marco-sandbox*` or `marcosand*` naming patterns.

Sandbox & subscription
- Subscription: EsDAICoESub (d2d4e571-e0f2-4f6c-901a-f88f7669bcba)
- Resource group: EsDAICoE-Sandbox
- Key sandbox resources (use these rather than inventing new names):
  - marco-sandbox-search (Azure AI Search)
  - marco-sandbox-cosmos (Cosmos DB)
  - marco-sandbox-openai, marco-sandbox-openai-v2 (Azure OpenAI)
  - marcosandkv20260203 (Key Vault)
  - marcosand20260203 (Storage)
  - marcosandacr20260203 (ACR)
  - marco-sandbox-apim (API Management)
  - marco-eva-roles-api (Container App)
  - marco-eva-brain-api (Container App)

OpenAI guidance
- Prefer `gpt-5.1-chat` (deployment set in `agent-fleet/.env`) for generation tasks.
- For lightweight tasks use `gpt-4o-mini` only when cost is a concern.

Monorepo / coding conventions
- Always use `@eva/ui` component wrappers for production code " do not import Fluent UI directly.
- Wrap app root with `GCThemeProvider` from `@eva/gc-design-system`.
- Use translation keys via `t()` for all user-facing text " zero hardcoded strings.
- New UI components require Vitest unit tests and a11y checks (jest-axe). Target coverage: statements >= 80%.

Agent Fleet rules
- Agent output target paths: write generated screens to `admin-face/src/pages/` and clients/hooks to `admin-face/src/api/`.
- Agent quality gates: TypeScript compile (no errors), vitest tests, jest-axe a11y (0 violations), GC compliance >=95%.
- Config: `agent-fleet/.env` contains AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_KEY, AZURE_OPENAI_DEPLOYMENT.

Auth & backend rules
- `DEV_AUTH_BYPASS=true` and `x-ms-client-principal-id` header are dev-only workarounds " do not use in production artifacts.
- Keep `MockBackendService.ts` until all 29 admin endpoints pass smoke tests with real backend.
- Cosmos DB usage: prefer `DefaultAzureCredential`/RBAC; secret-less auth in code for DevBox.

Safety & secrets
- NEVER commit production keys or secrets. Use Key Vault `marcosandkv20260203` for production secrets.

Where to find authoritative project info
- Single source of truth: `EVA-FACES-MASTER-TRACKER.md`
- Implementation plan: `PLAN.md`
- Status snapshot: `STATUS.md`
- **Acceptance gates (phase + DoD)**: `ACCEPTANCE.md`
- Audits & quality: `docs/QUALITY-DASHBOARD.md`, `docs/CONSOLIDATED-AUDIT-REPORT.md`
- 37-data-model agent guide: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`

## Data Model

> **You are talking to an AI agent. This section is your operating manual.**
>
> Every task on the EVA Faces project must **begin with a model query, not a source file read**.
> The model is the single source of truth for all endpoints, screens, literals, components, hooks,
> containers, personas, and types. `grep` and `file_search` are the last resort "
> they cost 10 turns; the model costs 1.
>
> Full guide: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`

### Bootstrap " Start Every Session Here

#### Step 1 " Check the API
```powershell
Invoke-RestMethod http://localhost:8010/health
# Expected: {"status":"ok","store":"MemoryStore","layers":27}
```

#### Step 2A " API is up ' proceed with HTTP queries below

```powershell
# Spot-check layer population
Invoke-RestMethod "http://localhost:8010/model/screens/"   | Measure-Object | Select-Object Count
Invoke-RestMethod "http://localhost:8010/model/endpoints/" | Measure-Object | Select-Object Count
```

#### Step 2B " API is down ' start it (~3 s)
```powershell
$env:PYTHONPATH = "C:\AICOE\eva-foundation\37-data-model"
C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload
# Interactive docs: http://localhost:8010/docs
```

#### Step 2C " Offline / CI fallback
```powershell
$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json
# Use $m.screens, $m.endpoints, $m.literals, $m.containers, etc.
```

> **Layer status rule:** if a layer is listed as NOT STARTED in STATUS.md, fall back to source reads for that layer only.
> If COMPLETE, the model is authoritative " do not re-read source files.

---

### 27 layers (L0"L26)
`services` - `personas` - `feature_flags` - `containers` - `endpoints` - `schemas` - `screens` - `literals` - `agents` - `infrastructure` - `requirements` - `planes` - `connections` - `environments` - `cp_skills` - `cp_agents` - `runbooks` - `cp_workflows` - `cp_policies` - `components` - `hooks` - `ts_types` - `mcp_servers` - `prompts` - `security_controls` - `projects` - `wbs`

---

### Before You Implement " Gather Context First

```powershell
# What does screen X do? (API calls, components, hooks, RBAC)
$s = Invoke-RestMethod "http://localhost:8010/model/screens/TranslationsPage"
$s.api_calls; $s.components; $s.hooks; $s.min_role

# Does the endpoint already exist?
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.path -like '*translations*' } | Select-Object id, status

# Cosmos container schema
$c = Invoke-RestMethod "http://localhost:8010/model/containers/translations"
$c.partition_key; $c.fields | Format-Table

# Auth and feature flag requirements
Invoke-RestMethod "http://localhost:8010/model/feature_flags/" |
  Where-Object { $_.id -like '*translation*' } |
  Select-Object id, status, personas, description

# Jump directly to source " never grep (saves 9 turns)
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"
```

---

### 7-Step Implementation Sequence

Follow this every time. Skipping steps creates model drift.

```
1  Bootstrap (Step 1'2A/2B above)
2  Query: does this object already exist in the model?
3  Query: Cosmos container schema, persona, feature flag
4  Navigate to source via code --goto (never grep)
5  Implement the code
6  Update the model via PUT (write cycle below)
7  Close: export ' assemble ' validate
```

---

### Debugging a Screen or Endpoint

```powershell
# Step 1: what does the broken screen call?
$calls = (Invoke-RestMethod "http://localhost:8010/model/screens/TranslationsPage").api_calls

# Step 2: are any not yet implemented?
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.id -in $calls -and $_.status -ne 'implemented' } | Select-Object id, status

# Step 3: what auth/feature flags do they require?
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.id -in $calls } | Select-Object id, auth, feature_flag, status

# Step 4: what Cosmos containers do they touch?
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.id -in $calls } | Select-Object id, cosmos_reads, cosmos_writes | Format-List

# Step 5: navigate to the implementation
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/$($calls[0])"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"
```

---

### Refactoring " Blast Radius First

Never rename or restructure code without mapping the blast radius.

```powershell
# Impact of changing a Cosmos container (or a specific field)
Invoke-RestMethod "http://localhost:8010/model/impact/?container=translations"
Invoke-RestMethod "http://localhost:8010/model/impact/?container=translations&field=key"

# Graph traversal: all objects that depend on an endpoint (2 hops)
$g = Invoke-RestMethod "http://localhost:8010/model/graph/?node_id=GET /v1/config/translations/{language}&depth=2"
$g.edges | Select-Object from_id, from_layer, to_id, to_layer, edge_type | Format-Table

# All services that depend on eva-roles-api
(Invoke-RestMethod "http://localhost:8010/model/graph/?edge_type=depends_on").edges |
    Where-Object { $_.to_id -eq "eva-roles-api" } | Select-Object from_id
```

> **Rule:** if the blast radius spans more than 2 layers, document it in the ADO work item before committing.

---

### Sprint Planning Queries

```powershell
# Endpoints not yet implemented
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=stub"    | Select-Object id | Sort-Object id
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=planned" | Select-Object id

# Screens with no components wired in model
Invoke-RestMethod "http://localhost:8010/model/screens/" |
  Where-Object { $_.components.Count -eq 0 } | Select-Object id, app, status

# i18n coverage " literals missing French
Invoke-RestMethod "http://localhost:8010/model/literals/" |
  Where-Object { -not $_.default_fr -or $_.default_fr -eq '' } | Select-Object key, default_en

# All EVA-Faces (admin/chat/portal) screens and their status
Invoke-RestMethod "http://localhost:8010/model/screens/" |
  Where-Object { $_.app -in @('admin-face','chat-face','portal-face') } |
  Select-Object id, app, route, status | Sort-Object app | Format-Table
```

---

### Core Query Patterns

```powershell
# List all objects in a layer
Invoke-RestMethod "http://localhost:8010/model/screens/"

# Get one object by ID
Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"

# Filter endpoints (status / auth / cosmos_writes)
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=stub&cosmos_writes=jobs"

# Cross-layer impact " what breaks if container changes?
Invoke-RestMethod "http://localhost:8010/model/impact/?container=translations"

# Graph traversal " N hops from a node
$g = Invoke-RestMethod "http://localhost:8010/model/graph/?node_id=TranslationsPage&depth=2"
$g.edges | Select-Object from_id, from_layer, to_id, to_layer, edge_type | Format-Table

# Filter graph edges by type and/or layer
Invoke-RestMethod "http://localhost:8010/model/graph/?edge_type=calls&from_layer=screens" |
  ForEach-Object { $_.edges } | Format-Table from_id, to_id

# List all edge types
Invoke-RestMethod "http://localhost:8010/model/graph/edge-types"

# Provenance " jump to source line in VS Code
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"

# Audit trail
Invoke-RestMethod "http://localhost:8010/model/admin/audit"

# Validate all cross-refs
Invoke-RestMethod "http://localhost:8010/model/admin/validate"

# Coverage gaps " run from 37-data-model root
./scripts/coverage-gaps.ps1
./scripts/coverage-gaps.ps1 -Json
./scripts/coverage-gaps.ps1 -Layer screens
```

---

### Decision Table

| You want to... | Use |
|---|---|
| Find an endpoint, screen, container, or persona | `GET /model/{layer}/{id}` |
| List all objects in a layer | `GET /model/{layer}/` |
| Filter endpoints by status / auth / cosmos_writes | `GET /model/endpoints/filter?...` |
| Know what breaks if a container field changes | `GET /model/impact/?container=X` |
| Traverse object relationships (live graph) | `GET /model/graph` |
| Traverse N hops from a specific node | `GET /model/graph?node_id=X&depth=2` |
| Navigate to exact source line (`code --goto`) | `.repo_path` + `.repo_line` on the object |
| Update a model object (registers audit stamp) | `PUT /model/{layer}/{id}` |
| Persist store back to disk JSON | `POST /model/admin/export` then `assemble-model.ps1` |
| Full audit trail | `GET /model/admin/audit` |
| Validate all cross-references | `GET /model/admin/validate` |

---

### Anti-Patterns " These Cost 10 Turns Instead of 1

| Do NOT | Do instead |
|---|---|
| `grep` source files for endpoint names | `GET /model/endpoints/` |
| `file_search` to find a React component's path | `GET /model/components/{id}` ' `.repo_path` |
| Read all route files to understand the API surface | `GET /model/endpoints/` |
| Ask "what depends on X" by reading config files | `GET /model/graph?node_id=X&depth=1` |
| Edit `model/*.json` files directly | `PUT /model/{layer}/{id}` ' export ' assemble |
| Defer the model update to a later session | Update in the same commit as the source change |
| Mark an endpoint `implemented` before it is wired | Use `stub` until the route is complete and tested |

---

### Correct 4-Step Write Cycle

**Never edit `model/*.json` files directly.** Direct edits bypass the audit trail "
`modified_by` stays `"system:autoload"`, `row_version` stays `1`, and `GET /model/admin/audit` is blind.

```powershell
# 1. Write via API (stamps modified_at, modified_by, row_version)
Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}" `
  -Method PUT -ContentType "application/json" `
  -Body ($body | ConvertTo-Json -Depth 10) `
  -Headers @{"X-Actor"="agent:copilot"}
# 2. Verify
Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}"
# 3. Export store to disk
Invoke-RestMethod "http://localhost:8010/model/admin/export" -Method POST
# 4. Rebuild eva-model.json + validate
& "C:\AICOE\eva-foundation\37-data-model\scripts\assemble-model.ps1"
& "C:\AICOE\eva-foundation\37-data-model\scripts\validate-model.ps1"  # must exit 0
```

---

### Update Discipline

The model is updated **in the same PR** that changes the source " never deferred.

| Change type | Layers to update |
|---|---|
| New backend endpoint | `endpoints` + `schemas` for the response shape |
| Endpoint promoted stub ' implemented | `endpoints` " set `status`, `implemented_in`, `repo_line` |
| New Cosmos container or field | `containers` |
| New React screen | `screens` + `literals` (every new string key) |
| New i18n key | `literals` |
| New custom hook | `hooks` |
| New React component | `components` |
| New persona or feature flag | `personas` + `feature_flags` + `endpoints` auth arrays |
| New Azure resource | `infrastructure` |
| New agent-fleet agent | `agents` |

---

### Scripts Reference

| Script | When to run |
|---|---|
| `assemble-model.ps1` | After every layer file edit |
| `validate-model.ps1` | Before every commit " must exit 0 |
| `impact-analysis.ps1 -container X` | Before any refactor |
| `coverage-gaps.ps1` | Sprint review |
| `sync-from-source.ps1` | Sprint close audit |
| `backfill-repo-lines.py` | After new endpoints are wired |
| `31-eva-faces/scripts/sync-to-model.py` | After eva-faces UI changes (run from eva-faces root) |
| `ado-generate-artifacts.ps1` | Sprint planning |

---

## Execution Rule
Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: findings docs (Discover), status updates (Act), test evidence (Check).
Not allowed: a document whose sole content is "here is what I will change in file X."

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
