# Copilot Instructions — EVA Faces

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
- Always use `@eva/ui` component wrappers for production code — do not import Fluent UI directly.
- Wrap app root with `GCThemeProvider` from `@eva/gc-design-system`.
- Use translation keys via `t()` for all user-facing text — zero hardcoded strings.
- New UI components require Vitest unit tests and a11y checks (jest-axe). Target coverage: statements >= 80%.

Agent Fleet rules
- Agent output target paths: write generated screens to `admin-face/src/pages/` and clients/hooks to `admin-face/src/api/`.
- Agent quality gates: TypeScript compile (no errors), vitest tests, jest-axe a11y (0 violations), GC compliance >=95%.
- Config: `agent-fleet/.env` contains AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_KEY, AZURE_OPENAI_DEPLOYMENT.

Auth & backend rules
- `DEV_AUTH_BYPASS=true` and `x-ms-client-principal-id` header are dev-only workarounds — do not use in production artifacts.
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
> containers, personas, and types. `grep` and `file_search` are the last resort —
> they cost 10 turns; the model costs 1.
>
> Full guide: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`

### Bootstrap — Start Every Session Here

#### Step 1 — Check the API
```powershell
Invoke-RestMethod http://localhost:8010/health
# Expected: {"status":"ok","store":"MemoryStore","layers":27}
```

#### Step 2A — API is up → proceed with HTTP queries below

```powershell
# Spot-check layer population
Invoke-RestMethod "http://localhost:8010/model/screens/"   | Measure-Object | Select-Object Count
Invoke-RestMethod "http://localhost:8010/model/endpoints/" | Measure-Object | Select-Object Count
```

#### Step 2B — API is down → start it (~3 s)
```powershell
$env:PYTHONPATH = "C:\AICOE\eva-foundation\37-data-model"
C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload
# Interactive docs: http://localhost:8010/docs
```

#### Step 2C — Offline / CI fallback
```powershell
$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json
# Use $m.screens, $m.endpoints, $m.literals, $m.containers, etc.
```

> **Layer status rule:** if a layer is listed as NOT STARTED in STATUS.md, fall back to source reads for that layer only.
> If COMPLETE, the model is authoritative — do not re-read source files.

---

### 27 layers (L0–L26)
`services` · `personas` · `feature_flags` · `containers` · `endpoints` · `schemas` · `screens` · `literals` · `agents` · `infrastructure` · `requirements` · `planes` · `connections` · `environments` · `cp_skills` · `cp_agents` · `runbooks` · `cp_workflows` · `cp_policies` · `components` · `hooks` · `ts_types` · `mcp_servers` · `prompts` · `security_controls` · `projects` · `wbs`

---

### Before You Implement — Gather Context First

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

# Jump directly to source — never grep (saves 9 turns)
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"
```

---

### 7-Step Implementation Sequence

Follow this every time. Skipping steps creates model drift.

```
1  Bootstrap (Step 1→2A/2B above)
2  Query: does this object already exist in the model?
3  Query: Cosmos container schema, persona, feature flag
4  Navigate to source via code --goto (never grep)
5  Implement the code
6  Update the model via PUT (write cycle below)
7  Close: export → assemble → validate
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

### Refactoring — Blast Radius First

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

# i18n coverage — literals missing French
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

# Cross-layer impact — what breaks if container changes?
Invoke-RestMethod "http://localhost:8010/model/impact/?container=translations"

# Graph traversal — N hops from a node
$g = Invoke-RestMethod "http://localhost:8010/model/graph/?node_id=TranslationsPage&depth=2"
$g.edges | Select-Object from_id, from_layer, to_id, to_layer, edge_type | Format-Table

# Filter graph edges by type and/or layer
Invoke-RestMethod "http://localhost:8010/model/graph/?edge_type=calls&from_layer=screens" |
  ForEach-Object { $_.edges } | Format-Table from_id, to_id

# List all edge types
Invoke-RestMethod "http://localhost:8010/model/graph/edge-types"

# Provenance — jump to source line in VS Code
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"

# Audit trail
Invoke-RestMethod "http://localhost:8010/model/admin/audit"

# Validate all cross-refs
Invoke-RestMethod "http://localhost:8010/model/admin/validate"

# Coverage gaps — run from 37-data-model root
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

### Anti-Patterns — These Cost 10 Turns Instead of 1

| Do NOT | Do instead |
|---|---|
| `grep` source files for endpoint names | `GET /model/endpoints/` |
| `file_search` to find a React component's path | `GET /model/components/{id}` → `.repo_path` |
| Read all route files to understand the API surface | `GET /model/endpoints/` |
| Ask "what depends on X" by reading config files | `GET /model/graph?node_id=X&depth=1` |
| Edit `model/*.json` files directly | `PUT /model/{layer}/{id}` → export → assemble |
| Defer the model update to a later session | Update in the same commit as the source change |
| Mark an endpoint `implemented` before it is wired | Use `stub` until the route is complete and tested |

---

### Correct 4-Step Write Cycle

**Never edit `model/*.json` files directly.** Direct edits bypass the audit trail —
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

The model is updated **in the same PR** that changes the source — never deferred.

| Change type | Layers to update |
|---|---|
| New backend endpoint | `endpoints` + `schemas` for the response shape |
| Endpoint promoted stub → implemented | `endpoints` — set `status`, `implemented_in`, `repo_line` |
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
| `validate-model.ps1` | Before every commit — must exit 0 |
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
