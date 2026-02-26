# EVA Data Model — GitHub Copilot Instructions

<!--
  AUTO-LOADED by VS Code Copilot at every session start for this workspace.
  These rules apply to any agent reading or writing the EVA Data Model.
  Model declared GA: 2026-02-20T05:01:00-05:00  |  Last updated: 2026-02-23T12:00:00-05:00
  27/27 layers complete (L0–L26) · E-09/E-10/E-11 provenance + graph features in Sprint 8
  Counts grow each sprint — always query the live API for current totals:
    Invoke-RestMethod http://localhost:8010/health
  As of 2026-02-23 last recorded: 27 layers · 123 endpoints · 27 screens · 232 literals · 19 projects
-->

> **Model is complete: 27/27 layers · PASS 0 violations**  
> **Object counts grow each sprint — always query the live API for current totals.**  
> **API is running on port 8010 — use HTTP queries, not PowerShell file reads.**  
> See [USER-GUIDE.md](../USER-GUIDE.md) for query examples and agent skill patterns.  
> See [ANNOUNCEMENT.md](../ANNOUNCEMENT.md) for accuracy boundaries.

---

## What This Repository Is

`37-data-model` is the **semantic object model for the entire EVA ecosystem** —
every significant object (service, persona, container, endpoint, screen, literal,
agent, requirement) is a typed node with explicit FK-style cross-references,
automatically audited on every write.

**Read `eva-model.json` before reading any source file.**

---

## Bootstrap (every session)

> **Prefer HTTP over PowerShell.** If the model API is reachable on port 8010, use
> `Invoke-RestMethod` instead of loading the JSON file. PowerShell fallback is for
> offline / CI scenarios only.

```powershell
# Option A — HTTP (preferred, no file I/O)
Invoke-RestMethod http://localhost:8010/health          # confirms API is up
Invoke-RestMethod http://localhost:8010/model/services/ # list all services
Invoke-RestMethod http://localhost:8010/model/screens/  # list all screens

# Option B — file fallback (offline / CI)
$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json
$m.meta | Select-Object last_updated, layers_complete, total_layers

# Validate before any work
pwsh C:\AICOE\eva-foundation\37-data-model\scripts\validate-model.ps1
```

If `validate-model.ps1` reports violations → **fix them before doing any other work**.
A model with dangling references is worse than no model.

---

## Model API (HTTP service — port 8010)

The EVA Model API offers every read/write operation over HTTP, with structured
audit columns (`created_*`, `modified_*`, `row_version`, `is_active`), a Redis-backed cache, and cross-layer impact analysis.  
No PowerShell, no file I/O — any language can consume the model.

### Start (local dev / MemoryStore)

```powershell
cd C:\AICOE\eva-foundation\37-data-model
$env:PYTHONPATH = $PWD
C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload
```

Interactive docs: **http://localhost:8010/docs**

### Key API patterns

```powershell
# Health check
Invoke-RestMethod http://localhost:8010/health

# List a layer (cached 60 s)
Invoke-RestMethod "http://localhost:8010/model/services/"
Invoke-RestMethod "http://localhost:8010/model/endpoints/"

# Get one object by id
Invoke-RestMethod "http://localhost:8010/model/services/eva-brain-api"

# Create or update an object (audit fields are server-stamped — never send them)
Invoke-RestMethod "http://localhost:8010/model/services/my-new-svc" `
  -Method PUT -ContentType "application/json" `
  -Body '{"name":"My New Service","type":"internal_api","status":"planned"}'

# Soft-delete (sets is_active=false, increments row_version)
Invoke-RestMethod "http://localhost:8010/model/services/old-svc" -Method DELETE

# Filter endpoints by any combination of fields
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?status=stub"
Invoke-RestMethod "http://localhost:8010/model/endpoints/filter?cosmos_writes=jobs&auth=admin"

# Cross-layer impact analysis (equivalent to impact-analysis.ps1)
Invoke-RestMethod "http://localhost:8010/model/impact/?container=jobs"
Invoke-RestMethod "http://localhost:8010/model/impact/?container=config&field=key"

# Admin — export store to enriched JSON (completes write cycle, materialises audit trail)
Invoke-RestMethod "http://localhost:8010/model/admin/export" `
  -Method POST -Headers @{"Authorization"="Bearer dev-admin"}

# Admin — seed store from disk (idempotent; run after first start with Cosmos)
Invoke-RestMethod "http://localhost:8010/model/admin/seed" `
  -Method POST -Headers @{"Authorization"="Bearer dev-admin"}

# Admin — audit trail (last 50 writes across all layers)
Invoke-RestMethod "http://localhost:8010/model/admin/audit" `
  -Headers @{"Authorization"="Bearer dev-admin"}

# Admin — in-process validation (same checks as validate-model.ps1)
Invoke-RestMethod "http://localhost:8010/model/admin/validate" `
  -Headers @{"Authorization"="Bearer dev-admin"}

# Admin — flush cache
Invoke-RestMethod "http://localhost:8010/model/admin/cache/flush" `
  -Method POST -Headers @{"Authorization"="Bearer dev-admin"}
```

### Audit columns on every stored object

Every object returned by the API carries:

| Field | Type | Meaning |
|-------|------|---------|
| `created_by` | string | Actor who first created the object |
| `created_at` | ISO-8601 | Timestamp of first upsert |
| `modified_by` | string | Actor of last write |
| `modified_at` | ISO-8601 | Timestamp of last write |
| `row_version` | int | Monotonically increasing counter — +1 on every write |
| `is_active` | bool | False = soft-deleted; GET one returns 404, list skips it |
| `source_file` | string | Origin JSON file, e.g. `"model/endpoints.json"` — stamped on seed, survives export |
| `repo_line` | int \| null | **[E-10 Sprint 8]** 1-based line of primary definition in `implemented_in` / `repo_path` |
| `obj_id` | string | Business key (matches the URL `{id}` segment) |
| `layer` | string | Layer name (services, endpoints, etc.) |

Pass `X-Actor: your-name` header to tag writes with a meaningful identity.

### Store / cache mode selection

| Env vars set | Store | Cache |
|-------------|-------|-------|
| _(none)_ | MemoryStore — auto-seeds from disk JSON on startup | MemoryCache |
| `COSMOS_URL` + `COSMOS_KEY` | CosmosStore — partition key `/layer` | MemoryCache |
| `REDIS_URL` | (same as above) | RedisCache |

> **Note:** With MemoryStore the model is ephemeral — data resets on every restart.
> Run `POST /model/admin/seed` once after connecting Cosmos to load disk JSON into Cosmos.

### Use the API instead of PowerShell when…

| Task | Use instead of |
|------|---------------|
| Any agent reading model objects | `$m.endpoints \| …` in PowerShell |
| CI needs impact report | `impact-analysis.ps1` |
| Audit who changed what | Reading layer JSON files |
| Any non-Windows runtime | PowerShell scripts |

---

## Graph API — Object Relationships (DER/ERD over HTTP) [E-11 · Sprint 8]

```powershell
# All edge types (20 types across 27 layers)
Invoke-RestMethod "http://localhost:8010/model/graph/edge-types" | Format-Table

# Full graph — all nodes and edges
$g = Invoke-RestMethod "http://localhost:8010/model/graph"
Write-Host "$($g.meta.node_count) nodes · $($g.meta.edge_count) edges"

# Filter to one edge type
Invoke-RestMethod "http://localhost:8010/model/graph?edge_type=calls"   # screen → endpoint
Invoke-RestMethod "http://localhost:8010/model/graph?edge_type=reads"   # endpoint → container
Invoke-RestMethod "http://localhost:8010/model/graph?edge_type=depends_on"  # service → service

# Traverse from one node, N hops deep
$g = Invoke-RestMethod "http://localhost:8010/model/graph?node_id=TranslationsPage&depth=2"
$g.edges | Format-Table from, to, type

# What screens write to the translations container? (2-hop)
$writers = (Invoke-RestMethod "http://localhost:8010/model/graph?edge_type=writes").edges |
    Where-Object { $_.to -eq "translations" }
$callers = (Invoke-RestMethod "http://localhost:8010/model/graph?edge_type=calls").edges |
    Where-Object { $_.to -in $writers.from }
$callers | Select-Object from, to
```

> **Rule:** Use `GET /model/graph` for all relationship questions. Never grep source files for
> cross-references when the graph can answer it in one HTTP call.

---

## Provenance Queries [E-09 / E-10 · Sprint 8]

```powershell
# Provenance: who created this object and when?
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
"Created: $($ep.created_at) by $($ep.created_by)  v$($ep.row_version)  source: $($ep.source_file)"

# Navigation: jump directly to route decorator in VS Code (E-10 repo_line)
$ep = Invoke-RestMethod "http://localhost:8010/model/endpoints/GET /v1/health"
code --goto "C:\AICOE\eva-foundation\$($ep.implemented_in):$($ep.repo_line)"

# Same for a React hook or component:
$h = Invoke-RestMethod "http://localhost:8010/model/hooks/useTranslations"
code --goto "C:\AICOE\eva-foundation\$($h.repo_path):$($h.repo_line)"
```

```powershell
# What services exist?
$m.services | Select-Object id, type, port, status

# What can persona 'admin' access?
$m.personas | Where-Object { $_.id -eq 'admin' } | Select-Object -ExpandProperty feature_flags

# What does GET /v1/translations return?
$m.endpoints | Where-Object { $_.id -eq 'GET /v1/translations' } |
  Select-Object response_schema, cosmos_reads, auth

# What screens call GET /v1/translations?
$m.screens | Where-Object { $_.api_calls -contains 'GET /v1/translations' } |
  Select-Object id, route, status

# What literals does TranslationsPage use?
$m.literals | Where-Object { $_.screens -contains 'TranslationsPage' } |
  Select-Object key, default_en, default_fr

# Field rename impact: what breaks if 'key' renamed in translations container?
$affected_eps = $m.endpoints | Where-Object { $_.cosmos_reads -contains 'translations' -or $_.cosmos_writes -contains 'translations' }
$affected_sc  = $m.screens   | Where-Object { ($_.api_calls | ForEach-Object { $_ -in $affected_eps.id }) -contains $true }
"Endpoints: $($affected_eps.Count)  Screens: $($affected_sc.Count)"
```

---

## Writing Rules

### When to update the model

The model is updated **in the same commit that changes the source**. Never defer.

| Source change | Model update |
|---------------|-------------|
| New endpoint | `endpoints.json` + `schemas.json` for new response shape |
| New Pydantic model | `schemas.json` |
| New Cosmos container | `containers.json` |
| New React screen | `screens.json` + `literals.json` for all new string keys |
| New persona | `personas.json` + `feature_flags.json` |
| New feature flag | `feature_flags.json` |
| New agent | `agents.json` |
| New Azure resource | `infrastructure.json` |

### Validation gate

Before marking any layer complete:
```powershell
scripts/validate-model.ps1
```
Must exit 0. Zero dangling references. Zero schema violations.

### Assemble after every update

After editing any layer file:
```powershell
scripts/assemble-model.ps1
```
This regenerates `model/eva-model.json`. Never hand-edit `eva-model.json` directly.

---

## Schema Discipline

Every object in every layer file must conform to its JSON Schema in `schema/`.

Required fields that can NEVER be null:
- All objects: `id`, `status`
- endpoints: `method`, `path`, `auth`, `feature_flag`, `cosmos_reads`, `cosmos_writes`
- screens: `app`, `route`, `api_calls`, `components`
- literals: `key`, `default_en`, `default_fr`, `screens`
- containers: `partition_key`, `fields`

Optional fields that must be `null` (never omitted):
- `endpoint.request_schema` — null if no request body
- `screen.notes` — null if no caveats

---

## Cross-Reference Integrity Rules

1. Every `endpoint.cosmos_reads[]` value must be an `id` in `containers.json`
2. Every `endpoint.cosmos_writes[]` value must be an `id` in `containers.json`
3. Every `endpoint.feature_flag` must be an `id` in `feature_flags.json`
4. Every `endpoint.auth[]` value must be an `id` in `personas.json`
5. Every `screen.api_calls[]` value must be an `id` in `endpoints.json`
6. Every `literal.screens[]` value must be an `id` in `screens.json`
7. Every `requirement.satisfied_by[]` value must resolve to endpoint or screen id
8. Every `agent.output_screens[]` value must be an `id` in `screens.json`

Violations are reported by `scripts/validate-model.ps1`.

---

## Anti-Patterns

| Do NOT do this | Do this instead |
|----------------|-----------------|
| Run file_search to find all endpoints | `$m.endpoints \| Select-Object id, path` |
| grep source files for Cosmos container names | `$m.containers \| Select-Object id` |
| Read all route files to build impact analysis | `scripts/impact-analysis.ps1 -field <name>` |
| Ask "what calls what" by reading source | `GET /model/graph?edge_type=calls` |
| Ask "what depends on X" by scanning service configs | `GET /model/graph?node_id=X&depth=1` |
| Find a component's file by reading the repo tree | `GET /model/components/{id}` → `.repo_path` + `.repo_line` |
| Hand-edit `eva-model.json` | Edit the layer file, then run `assemble-model.ps1` |
| Edit JSON files directly to update model objects | `PUT /model/{layer}/{id}` → `POST /model/admin/export` → `assemble-model.ps1` |
| Defer model update to next session | Update in same commit as source change |

---

## Layer Status Reference

Check `STATUS.md` for current layer completeness before any query.
If a layer is NOT STARTED, fall back to reading source files for that layer.
If a layer is COMPLETE, the model is authoritative — do not re-read source.

---

## Relationship to Other repositories

- `33-eva-brain-v2/docs/artifacts.json` — file registry (one service) → cross-ref `endpoint.implemented_in`
- `31-eva-faces/EVA-FACES-MASTER-TRACKER.md` — implementation status cross-ref `screen.status`
- `33-eva-brain-v2/.github/copilot-instructions.md` — service-level coding rules (still apply)
- This file governs model reads/writes only; coding conventions remain in service repos
