````instructions
# GitHub Copilot Instructions -- EVA Machine Trust Index

**Template Version**: 3.0.0
**Last Updated**: 2026-02-23 16:33 ET
**Project**: EVA Machine Trust Index (MTI) -- Trust Service specification and runtime
**Path**: `C:\AICOE\eva-foundation\47-eva-mti\`
**Stack**: Python (Trust Service runtime), Markdown (specs), YAML/JSON (computation spec, OpenAPI)

> This file is the Copilot operating manual for this repository.
> PART 1 is universal -- identical across all EVA Foundation projects.
> PART 2 is project-specific -- tailored for 47-eva-mti.

---

## PART 1 -- UNIVERSAL RULES
> Applies to every EVA Foundation project. Do not modify.

---

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Ping 37-data-model API**: `Invoke-RestMethod http://localhost:8010/health`
   - If `{"status":"ok"}` --> use HTTP queries for all discovery (fastest)
   - If down --> start it: `$env:PYTHONPATH="C:\AICOE\eva-foundation\37-data-model"; C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload`
   - If no venv --> fall back: `$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json`

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
   Invoke-RestMethod "http://localhost:8010/model/projects/47-eva-mti" | Select-Object id, maturity, notes
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
Check     --> run the project test command (see PART 2); must exit 0
Act       --> update STATUS.md, PLAN.md, yyyymmdd-plan.md, findings doc
Loop      --> return to Discover if tasks remain
```

**Execution Rule**: Make the change. Do not propose, narrate, or ask for permission on a step you can determine yourself. If uncertain about scope, ask one clarifying question then proceed.

---

### 3. EVA Data Model API -- Mandatory Protocol

**Full reference**: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
Read it at every sprint boundary or when a query pattern is unfamiliar.

#### Rule: query the model first -- never grep when the model has the answer

| You want to know... | Use (1 turn) | Do NOT (10 turns) |
|---|---|---|
| All endpoints for a service | `GET /model/endpoints/` filtered | grep router files |
| What a screen calls | `GET /model/screens/{id}` -> `.api_calls` | read screen source |
| Auth/feature flag for an endpoint | `GET /model/endpoints/{id}` | grep auth middleware |
| What breaks if X changes | `GET /model/impact/?container=X` | trace imports manually |
| Navigate to source line | `.repo_path` + `.repo_line` -> `code --goto` | file_search |

#### 5-step write cycle (mandatory -- every model change)

```
1. PUT /model/{layer}/{id}           -- X-Actor: agent:copilot header required
2. GET /model/{layer}/{id}           -- assert row_version incremented + modified_by matches
3. POST /model/admin/export          -- Authorization: Bearer dev-admin
4. scripts/assemble-model.ps1        -- must report 27/27 layers OK
5. scripts/validate-model.ps1        -- must exit 0; [FAIL] lines block commit; [WARN] are noise
```

#### 7 agent gotchas (recorded Feb 23, 2026)

1. **Strip audit columns from PUT body** -- exclude `obj_id`, `layer`, `is_active`, `modified_*`, `created_*`, `row_version`. Build `[ordered]@{}` from domain fields only.
2. **PATCH is not supported** -- always PUT the full object.
3. **Endpoint IDs include the exact param name** -- never construct; use `GET /model/endpoints/` and copy `.id` verbatim (e.g. `"GET /v1/sessions/{session_id}"` not `"GET /v1/sessions/{id}"`).
4. **Fix a FAIL** -- look up correct endpoint ID, re-PUT the screen, re-run write cycle.
5. **Use a .ps1 script for PUTs with more than 3 fields** -- inline one-liners truncate silently.
6. **[WARN] repo_line lines are pre-existing noise** -- only [FAIL] lines block a commit.
7. **Canonical confirm**: `(Invoke-WebRequest ".../{id}").Content | ConvertFrom-Json | Select-Object row_version, modified_by`

---

### 4. Encoding and Output Safety

**Windows Enterprise Encoding (cp1252) -- ABSOLUTE RULE**

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

- **Personal**: sandbox experiments
- **Professional**: `marco.presta@...` -- Government of Canada / production resources

If `az` fails with "subscription doesn't exist":
```powershell
az account show --query user.name
az logout; az login --use-device-code
```

---

## PART 2 -- PROJECT-SPECIFIC

---

### Project Identity

**Name**: EVA Machine Trust Index
**Folder**: `C:\AICOE\eva-foundation\47-eva-mti`
**ADO Epic**: To be created (see 19-ai-gov ADO artifacts for governance epics)
**37-data-model record**: `GET /model/projects/47-eva-mti`
**Maturity**: poc
**Phase**: Design complete (inherited from 19-ai-gov). Implementation not started (Phase 5 in PLAN.md).

**Depends on**:
- `37-data-model` (port 8010) -- `actor_trust_scores` container schema; use PUT write cycle for any schema change
- `19-ai-gov` -- governance policy layer; Decision Engine step 5 calls this project's Trust Service
- `28-rbac` -- role assignment data feeds ITI subscore
- `33-eva-brain-v2` -- emits BTI and ARI signals via `POST /trust/signal`
- `36-red-teaming` -- red team evaluation results feed ARI subscore
- `17-apim` -- injects STI signals (prompt injection, anomaly headers)
- `40-eva-control-plane` -- emits ETI signals when evidence packs are validated

**Consumed by**:
- `19-ai-gov` Decision Engine -- calls `POST /trust/evaluateTrust` at pipeline step 5
- `33-eva-brain-v2` -- reads MTI trust band before executing high-risk intents
- `31-eva-faces` -- reads trust band for Trust Indicator UI component

---

### Stack and Conventions (Target -- Implementation Phase)

```
Python 3.11+ / C:\AICOE\.venv\Scripts\python.exe
FastAPI (Trust Service HTTP surface)
Azure Cosmos DB (actor_trust_scores container)
Azure Entra ID (bearer auth on all endpoints)
```

Current state: **specification only** -- no runnable code yet. Reference specs are in `19-ai-gov` (source copies).

**Spec quality warning**: YAML blocks in `eva-mti-compute-specs.md` and `eva-mti-trust-service-api.md` (in 19-ai-gov) contain `&nbsp;` HTML entities -- they are NOT parse-ready YAML. Strip entities before using in code (M-09 task in PLAN.md).

---

### Test Command

```powershell
# No tests yet -- implementation not started
# When Trust Service is implemented:
# C:\AICOE\.venv\Scripts\python -m pytest tests/ -v --tb=short
```

**Current test count**: 0 -- implementation not started (as of 2026-02-23)

---

### Key Commands

```powershell
# Query project record
Invoke-RestMethod "http://localhost:8010/model/projects/47-eva-mti"

# When implementation begins -- start Trust Service locally:
# Set-Location "C:\AICOE\eva-foundation\47-eva-mti"
# C:\AICOE\.venv\Scripts\python -m uvicorn trust_service.main:app --port 8030 --reload

# Reference specs (in 19-ai-gov):
# C:\AICOE\eva-foundation\19-ai-gov\eva-mti-compute-specs.md
# C:\AICOE\eva-foundation\19-ai-gov\eva-mti-trust-service-api.md
# C:\AICOE\eva-foundation\19-ai-gov\eva-mti-scope.md
# C:\AICOE\eva-foundation\19-ai-gov\eva-mti-actions-matrix.md
```

---

### Critical Patterns

1. **Trust Service is stateless per request, stateful via Cosmos** -- each `/evaluateTrust` call reads signals from live data sources, computes all 6 subscores, writes result to `actor_trust_scores`, and returns synchronously. No in-memory actor state.

2. **Hard fail safe on missing signals** -- if a required signal source is unavailable, apply the configured `unknown_signal_penalty` (default -5 per missing signal). Never silently default to 0 (trust inflation risk).

3. **Signal ingestion is async** -- `POST /trust/signal` returns 202 immediately and queues a recompute job. The recompute must complete within 60 seconds (AC-T04). Use a background task or queue (e.g., Azure Service Bus or asyncio task).

4. **Exponential decay on BTI negatives** -- violation events must be timestamped and decayed at compute time: `weight(t) = exp(-ln(2) * t / 14)`. Never store decayed scores -- always recompute from raw events.

5. **Actor type determines weight table** -- HUMAN, AGENT, SERVICE, SYSTEM each have distinct subscore weights. ARI weight is 0 for SERVICE/SYSTEM actors. Always look up the actor type before applying the formula.

---

### Known Anti-Patterns

| Do NOT | Do instead |
|---|---|
| Store pre-decayed BTI scores in Cosmos | Store raw violation events with timestamps; decay at compute time |
| Default missing signals to 0 (zero = perfect) | Apply `unknown_signal_penalty` per missing required signal |
| Use the same weight table for HUMAN and AGENT | Look up actor type; use actor-type-specific weight table |
| Return HTTP 404 for unknown actorId on `/evaluateTrust` | Compute score with defaults/penalties; always return 200 with score |
| Use `&nbsp;` YAML blocks from spec files as-is | Strip HTML entities before using in code (M-09) |
| Expose raw numeric MTI scores in API logs | Log trust band label; raw scores only in Cosmos and secure audit trail |

---

### Skills in This Project

| Skill file | Trigger phrases | Purpose |
|---|---|---|
| `00-skill-index.skill.md` | list skills, what can you do, skill menu | Skill index (additional skills to be added during implementation) |

---

### 37-data-model -- This Project's Entities

```powershell
# Project record
Invoke-RestMethod "http://localhost:8010/model/projects/47-eva-mti"

# actor_trust_scores container (to be registered when implementation begins)
# Invoke-RestMethod "http://localhost:8010/model/containers/actor_trust_scores"

# Trust Service endpoints (to be registered when API is built):
# POST /trust/evaluateTrust
# GET  /trust/getActorTrust/{actorId}
# POST /trust/getDecision
# POST /trust/signal
```

---

### Trust Service API Quick Reference

| Endpoint | Method | Purpose | Key inputs | Key outputs |
|---|---|---|---|---|
| `/trust/evaluateTrust` | POST | Compute 6 subscores + composite MTI | Context envelope (actorId, actorType, ...) | iti, bti, cti, eti, sti, ari, compositeMti, trustBand |
| `/trust/getActorTrust/{actorId}` | GET | Current + historical scores for actor | actorId, ?history=true | Latest scores + time series |
| `/trust/getDecision` | POST | Full governance decision (chains to 19-ai-gov) | Context envelope | decision, obligations[], reasons[] |
| `/trust/signal` | POST | Ingest trust signal event | signalType, actorId, value, timestamp | 202 Accepted |

**Trust Bands:**

| Band | Score | Decision Engine allows |
|---|---|---|
| HIGH TRUST | 85-100 | Fully autonomous |
| TRUSTED | 70-84 | Allowed with monitoring |
| GUARDED | 50-69 | Human approval for sensitive |
| LOW TRUST | 30-49 | Heavily restricted |
| UNTRUSTED | 0-29 | Blocked |

---

## PART 3 -- QUALITY GATES

All must pass before merging a PR:

- [ ] Test command exits 0
- [ ] `validate-model.ps1` exits 0 (if any model layer was changed)
- [ ] No [FORBIDDEN] encoding patterns in new code
- [ ] STATUS.md updated with session summary
- [ ] PLAN.md reflects actual remaining work
- [ ] If new endpoint added: model PUT + write cycle closed
- [ ] If `actor_trust_scores` schema changed: Cosmos schema doc updated in `eva-api-n-cosmos-container.md` (19-ai-gov) and 47-eva-mti
- [ ] All 6 subscores returned in every `/evaluateTrust` response (AC-T01-1)
- [ ] No missing signal defaults to 0 -- penalty applied (AC-T01-6)

---

*Source template*: `C:\AICOE\eva-foundation\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md` v3.0.0
*Reference specs*: `C:\AICOE\eva-foundation\19-ai-gov\` (eva-mti-*.md files)
*EVA Data Model USER-GUIDE*: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
*Governance boundary*: `C:\AICOE\eva-foundation\19-ai-gov\` (policy layer; Decision Engine spec)

````
