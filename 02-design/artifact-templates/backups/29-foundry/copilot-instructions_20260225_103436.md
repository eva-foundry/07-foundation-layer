<!-- EVA-STORY: F29-00-001 -->
<!-- EVA-FEATURE: F29-00 -->
# GitHub Copilot Instructions -- EVA Foundry Library

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA Foundry Library -- Agentic capabilities hub (MCP, RAG, eval)
**Path**: `C:\AICOE\eva-foundation\29-foundry\`
**Stack**: Python, FastAPI

> This file is the Copilot operating manual for this repository.
> PART 1 is universal -- identical across all EVA Foundation projects.
> PART 2 is project-specific -- customise the placeholders before use.

---

## PART 1 -- UNIVERSAL RULES
> Applies to every EVA Foundation project. Do not modify.

---

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Ping 37-data-model API**: `Invoke-RestMethod http://localhost:8010/health`
   - If `{"status":"ok"}` ' use HTTP queries for all discovery (fastest)
   - If down ' start it: `$env:PYTHONPATH="C:\AICOE\eva-foundation\37-data-model"; C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload`
   - If no venv ' fall back: `$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json`

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
   Invoke-RestMethod "http://localhost:8010/model/projects/{PROJECT_FOLDER}" | Select-Object id, maturity, notes
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

1. **Strip audit columns from PUT body** -- exclude `obj_id`, `layer`, `modified_by`, `modified_at`, `created_by`, `created_at`, `row_version`, `source_file`. `is_active` is a domain field -- KEEP IT.
2. **PATCH is not supported** -- always PUT the full object (422 otherwise).
3. **Endpoint IDs include the exact param name** -- never construct; use `GET /model/endpoints/` and copy `.id` verbatim (e.g. `"GET /v1/sessions/{session_id}"` not `"GET /v1/sessions/{id}"`).
4. **Fix a FAIL** -- look up the correct endpoint ID from the model, re-PUT the offending screen with the corrected api_calls, re-run write cycle.
5. **Use `-Depth 10` in `ConvertTo-Json`** -- `-Depth 5` silently truncates `request_schema` / `response_schema` nested objects. Always assign to `$body` before piping.
6. **Capture `row_version` BEFORE mutating** -- store it so the canonical confirm can assert `previous + 1`.
7. **[WARN] repo_line lines are pre-existing noise (38+ items)** -- only [FAIL] cross-reference lines block a commit; use `GET /model/admin/validate` to separate new FAILs from noise.
8. **Canonical confirm -- assert all three after every PUT**:
   ```powershell
   $prev_rv = (Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}").row_version
   # ... mutate fields, strip audit, PUT ...
   $w = Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}"
   $w.row_version   # must equal $prev_rv + 1
   $w.modified_by   # must equal "agent:copilot"
   $w.status        # must equal the value you PUT
   ```

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

## PART 2 -- PROJECT-SPECIFIC (29-foundry)

**Project:** EVA Foundry Library
**Version:** 0.1.0-beta
**Path:** `C:\AICOE\eva-foundation\29-foundry`
**Stack:** Python 3.11, FastAPI, Microsoft Agent Framework, Azure AI Foundry, MCP
**Purpose:** Single source of truth for reusable EVA agent skills, Python utilities, MCP servers, and agent patterns consumed by `31-eva-faces` and `33-eva-brain-v2`.
**37-data-model record:** `GET /model/projects/29-foundry` (maturity: active)

---

### 2a. Test Command

```powershell
Set-Location "C:\AICOE\eva-foundation\29-foundry"
C:\AICOE\.venv\Scripts\python.exe -m pytest tests/ -x -q
# Must exit 0 before any commit.
```

---

### 2b. Data Model Usage -- 29-foundry Rules

#### Query this project's record

```powershell
Invoke-RestMethod "http://localhost:8010/model/projects/29-foundry" | Select-Object id, maturity, notes
```

#### Services layer quirk -- use obj_id, not id

The services layer returns `obj_id` (not `id`). Fields `type` and `port` are not present.

```powershell
Invoke-RestMethod "http://localhost:8010/model/services/" |
  Select-Object obj_id, status, is_active, notes | Format-Table
```

#### Filter is ONLY available on the endpoints layer

`GET /model/endpoints/filter?status=stub` works.
For all other layers use `Where-Object` client-side:
```powershell
Invoke-RestMethod "http://localhost:8010/model/screens/" |
  Where-Object { $_.status -eq 'planned' } | Select-Object id, app, status
```

#### APIM cloud endpoint (CI / GitHub Actions / any non-localhost context)

```powershell
$apimBase = "https://marco-sandbox-apim.azure-api.net/data-model"
# $env:EVA_APIM_KEY = "<key from Azure Portal -> marco-sandbox-apim -> Subscriptions>"
$h = @{"Ocp-Apim-Subscription-Key" = $env:EVA_APIM_KEY}
Invoke-RestMethod "$apimBase/model/agent-summary" -Headers $h
Invoke-RestMethod "$apimBase/model/projects/29-foundry" -Headers $h
```

#### Write cycle for this project (preferred -- commit shortcut)

```powershell
# Step 1: capture row_version BEFORE any mutation
$prev_rv = (Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}").row_version

# Step 2: PUT (strip audit columns; keep is_active; use -Depth 10)
function Strip-Audit ($obj) {
    $obj | Select-Object * -ExcludeProperty `
        obj_id, layer, modified_by, modified_at, created_by, created_at, row_version, source_file
}
$body = Strip-Audit $ep | ConvertTo-Json -Depth 10
Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}" `
    -Method PUT -ContentType "application/json" -Body $body `
    -Headers @{"X-Actor"="agent:copilot"}

# Step 3: canonical confirm
$w = Invoke-RestMethod "http://localhost:8010/model/{layer}/{id}"
$w.row_version   # must equal $prev_rv + 1
$w.modified_by   # must equal "agent:copilot"
$w.status        # must equal what you PUT

# Step 4: close the cycle
$c = Invoke-RestMethod "http://localhost:8010/model/admin/commit" `
    -Method POST -Headers @{"Authorization"="Bearer dev-admin"}
$c.status          # "PASS" = done
$c.violation_count # 0 = clean
```

> Never edit `model/*.json` files directly -- direct edits bypass the audit trail.

---

### 2c. Project Structure

```
29-foundry/
  copilot-skills/          6 Copilot agent skills ([PASS] Complete)
  agent-framework/         Microsoft Agent Framework patterns
  mcp-servers/             3 MCP server implementations (azure-ai-search, cosmos-db, blob-storage)
  tools/                   Python utilities (search, rag, evaluation, observability, auth)
  prompts/                 Prompty-format prompt templates
  agents/                  Agent plane sub-packages (github, azure, ado planes)
  server/                  FastAPI server (session-workflow-agent -- pending impl)
  notebooks/               Jupyter exploration notebooks
  docs/                    Architecture, MCP, skills, migration guides
  audit/                   Portable certification audit tools
  skill-catalog.json       Machine-readable 72-skill registry (stale -- needs refresh)
```

---

### 2d. Cross-Project Import Pattern

When any EVA project imports foundry tools, use this canonical path:

```python
import sys
from pathlib import Path

foundry_path = Path(__file__).parent.parent.parent / "29-foundry"
sys.path.insert(0, str(foundry_path))

from tools.search import EVASearchClient
from tools.rag import RAGPipeline, DocumentChunker, CitationBuilder
from tools.evaluation import EVAEvaluator
from tools.observability import TracedOperation, setup_foundry_tracing
from tools.auth import get_azure_credential
```

| Consuming project | Relative path to foundry |
|---|---|
| 33-eva-brain-v2 | `../../29-foundry/` |
| 31-eva-faces | `../../../29-foundry/` |

---

### 2e. Authority Hierarchy for Code Generation

1. Domain skills in the consuming project (`31-eva-faces`, `33-eva-brain-v2` `.github/copilot-skills/`)
2. Foundry library skills (`29-foundry/copilot-skills/`) -- 6 available
3. Cloned Microsoft samples (`29-foundry/cloned-repos/`) -- reference implementations
4. Microsoft documentation

---

### 2f. Open Blockers (as of 2026-02-24)

- `skill-catalog.json` declares 30 skills but `skill_id` / `project_id` fields are unpopulated
- `33-eva-brain-v2` skills are in free-form markdown, not `.skill.md` format -- not consumable
- `agent-framework/` exists but has no imported agent implementations
- `session-workflow-agent` FastAPI endpoint not yet built -- `sprint-execute.yml` in `38-ado-poc` is blocked
- `STATUS.md` and `PLAN.md` need to exist (session governance gap)

---

### 2g. Important Runtime Rules

- **Never hardcode credentials** -- always use `.env` or Azure Key Vault
- **Enable tracing** -- call `setup_foundry_tracing()` in all agents
- **Evaluate responses** -- run evaluation tools on all production agent code
- **Pin dependencies** -- all packages must have pinned versions in `requirements.txt`
- **Always check `tools/`** before creating new utilities -- de-duplicate first

---

## Execution Rule

Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: findings docs (Discover), status updates (Act), test evidence (Check).
Not allowed: a document whose sole content is "here is what I will change in file X."

---

## Code Quality Standards (Python)

- **Type hints required** -- all public functions and classes (PEP 484)
- **Error handling** -- specific exceptions with context in log messages
- **Async patterns** -- async/await for all I/O (Azure SDK calls, OpenAI API)
- **Logging** -- Python `logging` module; levels: DEBUG, INFO, WARNING, ERROR
- **Docstrings** -- Google style for all public functions and classes
- **No emojis in code** -- use `[PASS]` / `[FAIL]` / `[WARN]` / `[INFO]` tokens instead
- **ASCII only in machine-readable output** -- JSON, YAML, evidence files, CLI output parsed by scripts

### Naming Conventions

| Entity | Convention | Example |
|---|---|---|
| Class | PascalCase | `EVASearchClient`, `RAGPipeline` |
| Function/method | snake_case | `hybrid_search`, `build_context` |
| Constant | UPPER_SNAKE_CASE | `DEFAULT_CHUNK_SIZE` |
| Private method | underscore prefix | `_init_client` |
| Environment variable | UPPER_SNAKE_CASE with namespace | `AZURE_OPENAI_ENDPOINT` |

---



## PART 3 -- QUALITY GATES

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
