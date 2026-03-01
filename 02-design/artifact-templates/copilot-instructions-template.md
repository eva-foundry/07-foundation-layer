# GitHub Copilot Instructions -- {PROJECT_NAME}

**Template Version**: 3.5.0
**Last Updated**: 2026-03-01 ET
**Project**: {PROJECT_NAME} -- {PROJECT_ONE_LINE_DESCRIPTION}
**Path**: `C:\AICOE\eva-foundation\{PROJECT_FOLDER}\`
**Stack**: {PROJECT_STACK}

> This file is the Copilot operating manual for this repository.
> PART 1 is universal -- identical across all EVA Foundation projects.
> PART 2 is project-specific -- customise the placeholders before use.

---

## PART 1 -- UNIVERSAL RULES
> Applies to every EVA Foundation project. Do not modify.

---

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Establish $base** (ACA primary -- run the bootstrap block in Section 3.1 first):
   - ACA (24x7, Cosmos-backed, no auth): `https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io`
   - Local dev fallback only: `http://localhost:8010`
   - `$base` must be set before any model query in this session.

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
   Invoke-RestMethod "$base/model/projects/{PROJECT_FOLDER}" | Select-Object id, maturity, notes
   ```

5. **Produce a Session Brief** -- one paragraph: active phase, last test count, next task, open blockers.
   Do not skip this. Do not start implementing before the brief is written.

---

### 2. DPDCA Execution Loop

> **See workspace copilot-instructions** section "The EVA Factory Architecture" for the complete DPDCA loop explanation.
> This is data-driven AI-enabled Software Engineering, not code vibes.

Every session runs this cycle. Do not skip steps.

```
Discover  --> Query data model (WBS, services, endpoints) + veritas audit (MTI, gaps)
Plan      --> gen-sprint-manifest.py: filter undone stories, size, generate manifest
Do        --> Agent writes code using data model context (exact schemas, routes, locations)
Check     --> pytest (exit 0) + veritas MTI gate (>= 30 Sprint 2, >= 70 Sprint 3+)
Act       --> PUT status=done to WBS, reseed veritas-plan.json, reflect-ids.py updates PLAN.md
Loop      --> return to Discover for next sprint
```

**Execution Rule**: Make the change. Do not propose, narrate, or ask for permission on a step you can determine yourself. If uncertain about scope, ask one clarifying question then proceed.

**Why Deterministic**: Data model provides EXACT route paths, auth requirements, request/response schemas, file locations. Zero hallucination. One HTTP call beats 10 file reads.

---

### 2.1. Azure Best Practices Reference

When working on Azure infrastructure, always consult the workspace-level Azure best practices library before making design decisions or implementing Azure resources.

**Library**: `C:\AICOE\eva-foundry\18-azure-best\` (32 entries covering WAF, security, AI, resiliency, IaC, cost)
**Index**: `C:\AICOE\eva-foundry\18-azure-best\00-index.json`
**Usage**: See workspace copilot-instructions section "18-Azure-Best -- Azure Best Practices Library"

**Quick examples**:
- Designing Azure AI workload -> Read `04-ai-workloads/ai-security.md` + `02-well-architected/waf-ai-workload.md`
- RBAC design -> Read `12-security/rbac.md`
- Bicep IaC validation -> Read `07-iac/bicep.md` + `01-assessment-tools/psrule.md`
- Cost optimization -> Read `02-well-architected/cost-optimization.md` + `08-finops/finops-toolkit.md`

Each file has structured summaries, code snippets, and an Agent Checklist at the bottom for workload evaluation.

---

### 3. EVA Data Model API -- Mandatory Protocol

> **GOLDEN RULE**: The `model/*.json` files are an internal implementation detail of the API server.
> Agents must never read, grep, parse, or reference them directly -- not even to "check" something.
> The HTTP API is the only interface. One HTTP call beats ten file reads.
> The API self-documents: `GET /model/agent-guide` returns the complete operating protocol.

> **Full reference**: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md` (v2.5)
> The model is the single source of truth. One HTTP call beats 10 file reads.
> Never grep source files for something the model already knows.

#### 3.1  Bootstrap

```powershell
# Primary -- ACA (24x7 Cosmos-backed, no auth required, always up)
$base = "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io"
$h = Invoke-RestMethod "$base/health" -ErrorAction SilentlyContinue
# Local fallback -- only if ACA is in a rare maintenance window
if (-not $h) {
    $base = "http://localhost:8010"
    $h = Invoke-RestMethod "$base/health" -ErrorAction SilentlyContinue
    if (-not $h) {
        $env:PYTHONPATH = "C:\AICOE\eva-foundation\37-data-model"
        Start-Process "C:\AICOE\.venv\Scripts\python.exe" `
            "-m uvicorn api.server:app --port 8010 --reload" -WindowStyle Hidden
        Start-Sleep 4
    }
}
# Readiness check
$r = Invoke-RestMethod "$base/ready" -ErrorAction SilentlyContinue
if (-not $r.store_reachable) { Write-Warning "Cosmos unreachable -- check COSMOS_URL/KEY" }
# The API self-documents -- read the agent guide before doing anything
Invoke-RestMethod "$base/model/agent-guide"
# One-call state check -- all 27 layer counts + total objects
Invoke-RestMethod "$base/model/agent-summary"
```

**Azure APIM (CI / cloud agents):**
```powershell
$base = "https://marco-sandbox-apim.azure-api.net/data-model"
$hdrs = @{"Ocp-Apim-Subscription-Key" = $env:EVA_APIM_KEY}
Invoke-RestMethod "$base/model/agent-summary" -Headers $hdrs
```

#### 3.2  Query Decision Table

| You want to know... | One-turn API call | FORBIDDEN (costs 10 turns) |
|---|---|---|
| Browse all layers + objects visually | portal-face `/model` (requires `view:model` permission) | grep model/*.json |
| Report: overview / endpoint matrix / edge types | portal-face `/model/report` | build ad-hoc queries |
| All layer counts | `GET /model/agent-summary` | query each layer separately |
| Object by ID | `GET /model/{layer}/{id}` | grep, file_search |
| All objects in a layer | `GET /model/{layer}/` | read source files |
| All ready-to-call endpoints | `GET /model/endpoints/filter?status=implemented` | grep router files |
| All unimplemented stubs | `GET /model/endpoints/filter?status=stub` | grep router files |
| Filter ANY other layer | `GET /model/{layer}/` + `Where-Object` client-side | no server filter on non-endpoint layers |
| What a screen calls | `GET /model/screens/{id}` -> `.api_calls` | read screen source |
| Auth / feature flag for endpoint | `GET /model/endpoints/{id}` -> `.auth`, `.auth_mode`, `.feature_flag` | grep auth middleware |
| Where is the route handler | `GET /model/endpoints/{id}` -> `.implemented_in`, `.repo_line` | file_search |
| Cosmos container schema | `GET /model/containers/{id}` -> `.fields`, `.partition_key` | read Cosmos config |
| What breaks if container changes | `GET /model/impact/?container=X` | trace imports manually |
| Relationship graph | `GET /model/graph/?node_id=X&depth=2` | read config files |
| Services list | `GET /model/services/` -> `obj_id, status, is_active, notes` | services uses obj_id not id; no type/port |
| Is the process alive? | `GET /health` -> `.status`, `.store`, `.version` | check process list |
| Is Cosmos reachable? | `GET /health` -> `.store` == "cosmos" means Cosmos-backed | ping Cosmos directly |
| Browse all layers + objects visually | portal-face `/model` (requires `view:model` permission) | grep model/*.json |
| Report: overview stats / endpoint matrix / edge types | portal-face `/model/report` | build ad-hoc PowerShell queries |

#### 3.3  PUT Rules -- Read Before Every Write

**Rule 1 -- Capture `row_version` BEFORE mutating (not in USER-GUIDE)**
Store it before any field changes so the confirm assert can check `previous + 1`.
```powershell
$ep      = Invoke-RestMethod "$base/model/endpoints/GET /v1/tags"
$prev_rv = $ep.row_version   # capture BEFORE mutation
$ep.status         = "implemented"
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
`-Depth 5` silently truncates `request_schema` / `response_schema` objects. Always use `-Depth 10`.
```powershell
$body = Strip-Audit $ep | ConvertTo-Json -Depth 10
Invoke-RestMethod "$base/model/endpoints/GET /v1/tags" `
    -Method PUT -ContentType "application/json" -Body $body `
    -Headers @{"X-Actor"="agent:copilot"}
```

**Rule 4 -- PATCH is not supported** -- always PUT the full object (422 otherwise).

**Rule 5 -- Endpoint id = exact string "METHOD /path"** -- never construct; copy verbatim:
```powershell
Invoke-RestMethod "$base/model/endpoints/" |
    Where-Object { $_.path -like '*translations*' } | Select-Object id, path
```

**Rule 6 -- Never PUT inside a `pwsh -Command` inline string** -- JSON escaping is mangled by shell quoting.
Write a `.ps1` script file and run it with `pwsh -File`. This is the single most common cause of failed model
writes. If a PUT fails on the first attempt, the first diagnosis is: is the body in an inline string?

WRONG (JSON escaping breaks silently):
```
pwsh -NoLogo -NonInteractive -Command "& { $body=... | ConvertTo-Json; Invoke-RestMethod ... -Body $body }"
```

RIGHT -- write a temp script, run it with -File:
```powershell
$script = @'
$base = "https://marco-eva-data-model..."
$obj  = Invoke-RestMethod "$base/model/{layer}/{id}"
$obj.status = "implemented"
$body = $obj | Select-Object * -ExcludeProperty layer,modified_by,modified_at,created_by,created_at,row_version,source_file | ConvertTo-Json -Depth 10
Invoke-RestMethod "$base/model/{layer}/{id}" -Method PUT -ContentType "application/json" -Body $body -Headers @{"X-Actor"="agent:copilot"}
'@
$script | Set-Content "$env:TEMP\put-model.ps1" -Encoding UTF8
pwsh -NoProfile -File "$env:TEMP\put-model.ps1"
```

**Rule 7 -- `get_terminal_output` only accepts IDs from `run_in_terminal(isBackground=true)`**
Never pass `"1"`, `"last"`, `"pwsh"`, or any terminal name/label as the ID.
The only valid ID is the opaque string returned by `run_in_terminal` when `isBackground=true`.
For a foreground terminal the output is returned inline -- no follow-up call needed.

```powershell
# WRONG
get_terminal_output(id="1")
get_terminal_output(id="pwsh")

# CORRECT -- capture the id from a background run, then use it:
# result = run_in_terminal(command="...", isBackground=true)
# get_terminal_output(id=result.id)
```

**Rule 8 -- Never call `create_file` on a path that already exists**
`create_file` on an existing file returns a hard error and makes no change.
Before any `create_file`, use `Test-Path` to check, then use `replace_string_in_file` or
`multi_replace_string_in_file` for edits to existing files.

```powershell
# Pre-flight check
if (Test-Path "C:\AICOE\path\to\file.ps1") {
    # use replace_string_in_file -- do NOT call create_file
} else {
    # safe to call create_file
}
```

#### 3.4  Write Cycle -- Every Model Change

**Preferred -- 3-step (admin/commit = export + assemble + validate in one call):**
```powershell
# Step 1 -- PUT
Invoke-RestMethod "$base/model/endpoints/GET /v1/tags" `
    -Method PUT -ContentType "application/json" -Body $body `
    -Headers @{"X-Actor"="agent:copilot"}

# Step 2 -- Canonical confirm: assert all three
$w = Invoke-RestMethod "$base/model/endpoints/GET /v1/tags"
$w.row_version   # must equal $prev_rv + 1
$w.modified_by   # must equal "agent:copilot"
$w.status        # must equal the value you PUT

# Step 3 -- Close the cycle
$c = Invoke-RestMethod "$base/model/admin/commit" `
    -Method POST -Headers @{"Authorization"="Bearer dev-admin"}
$c.status          # "PASS" = done; "FAIL" = fix violations before merging
$c.violation_count # 0 = clean
# ACA note: commit returns status=FAIL with assemble.stderr="Script not found" -- EXPECTED on ACA.
# PASS conditions on ACA: violation_count=0 AND exported_total matches agent-summary.total AND export_errors.Count=0.
```

**Manual fallback (if admin/commit unavailable):**
```
POST /model/admin/export  ->  scripts/assemble-model.ps1  ->  scripts/validate-model.ps1
[FAIL] lines block; [WARN] repo_line lines (38+) are pre-existing noise -- ignore
```

**Validate only (distinguishes new violations from pre-existing noise):**
```powershell
$v = Invoke-RestMethod "$base/model/admin/validate" `
       -Headers @{"Authorization"="Bearer dev-admin"}
$v.count       # 0 = clean; >0 = new violations to fix NOW
$v.violations  # the cross-reference FAILs -- fix these before commit
```

#### 3.5  Fix a Validation FAIL

```
Pattern: "screen 'X' api_calls references unknown endpoint 'Y'"
Root cause: api_calls used a wrong or constructed id.
```
```powershell
# Find the exact id  (never construct)
Invoke-RestMethod "$base/model/endpoints/" |
    Where-Object { $_.path -like '*conversation*' } | Select-Object id, path
# Fetch screen, replace bad id, PUT + Strip-Audit + ConvertTo-Json -Depth 10 + commit
```

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
- Markdown docs (README, STATUS, PLAN, ACCEPTANCE, copilot-instructions): ASCII-only -- no emoji anywhere

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

### 8. Sandbox AI Services -- marco-sandbox (EsDAICoE-Sandbox)

> Tested and confirmed 2026-02-27. Use these for all EVA AI workloads in sandbox/dev.
> All resources are in resource group `EsDAICoE-Sandbox`, region `canadaeast`.

#### Resources

| Resource | Kind | Endpoint |
|---|---|---|
| `marco-sandbox-foundry` | Azure AI Services (AIServices) | `https://marco-sandbox-foundry.cognitiveservices.azure.com/` |
| `marco-sandbox-openai-v2` | Azure OpenAI | `https://marco-sandbox-openai-v2.openai.azure.com/` |
| `marco-sandbox-aisvc` | CognitiveServices (multi) | `https://marco-sandbox-aisvc.cognitiveservices.azure.com/` |
| `marco-sandbox-docint` | Form Recognizer / Doc Intelligence | `https://marco-sandbox-docint.cognitiveservices.azure.com/` |

#### Confirmed Deployed Models (marco-sandbox-foundry)

| Deployment | Model | Version | TPM | Unit | Tool Calling | Status |
|---|---|---|---|---|---|---|
| `gpt-4o` | gpt-4o | 2024-11-20 | 20K | Standard | [PASS] | [PASS] BYOK-ready |
| `gpt-4o-mini` | gpt-4o-mini | 2024-07-18 | 50K | GlobalStandard | [PASS] | [PASS] BYOK-ready |
| `gpt-5.1-chat` | gpt-5.1-chat | 2025-11-13 | 100K | GlobalStandard | [PASS] | [PASS] BYOK-ready |
| `gpt-5-nano` | gpt-5-nano | 2025-08-07 | 250K | GlobalStandard | not tested | [PASS] chat-ready |
| `text-embedding-ada-002` | text-embedding-ada-002 | 2 | 100K | Standard | n/a | [PASS] embeddings |
| `gpt-5.1-codex` | gpt-5.1-codex | 2025-11-13 | 1K | GlobalStandard | n/a | [WARN] responses-API-only, 1K TPM cap |

#### Confirmed Deployed Models (marco-sandbox-openai-v2)

| Deployment | Model | Version | TPM | Unit | Status |
|---|---|---|---|---|---|
| `gpt-5.1-chat` | gpt-5.1-chat | 2025-11-13 | 100K | GlobalStandard | [PASS] chat + tool calling |

#### API Notes (gpt-5.x / gpt-5-nano)

These models have breaking changes vs. gpt-4 family -- always apply when calling directly:
- Use `max_completion_tokens` not `max_tokens`
- Omit `temperature` (only default value `1` is supported)
- API version: `2025-04-01-preview` minimum; do NOT use `2025-05-01-preview` (404 in canadaeast)
- `gpt-5.1-codex` requires the `/openai/responses` endpoint, not `/chat/completions`

#### Retrieve API Key (PowerShell)

```powershell
# marco-sandbox-foundry (preferred -- most deployments)
$key  = (az cognitiveservices account keys list `
             --name marco-sandbox-foundry `
             --resource-group EsDAICoE-Sandbox `
             --query "key1" -o tsv).Trim()
$base = "https://marco-sandbox-foundry.cognitiveservices.azure.com"
```

#### Use-Case Recommendations

**GitHub Copilot Chat (VS Code BYOK)**
- Primary:   `marco-sandbox-foundry` / `gpt-4o` -- most reliable tool calling; [PASS] agent mode
- Secondary: `marco-sandbox-foundry` / `gpt-5.1-chat` -- best quality, 100K TPM
- Budget:    `marco-sandbox-foundry` / `gpt-4o-mini` -- fast/cheap, 50K TPM, agent mode [PASS]
- To configure: VS Code model picker -> Manage Models -> Add Models -> Azure OpenAI
  - Endpoint: `https://marco-sandbox-foundry.cognitiveservices.azure.com/`
  - API key: retrieve with command above

**RAG Data Pipeline (embeddings + retrieval + generation)**
- Embeddings: `marco-sandbox-foundry` / `text-embedding-ada-002` -- 100K TPM Standard
- Chunk reranking / summarization: `marco-sandbox-foundry` / `gpt-4o-mini` -- highest TPM/cost ratio
- Answer synthesis: `marco-sandbox-foundry` / `gpt-4o` -- best accuracy for legal/policy content
- Document extraction: `marco-sandbox-docint` -- Form Recognizer for PDFs, tables, forms
- Search: `marco-sandbox-aisvc` -- Azure AI Search (vector + hybrid) via this multi-service key
- Pattern for EVA RAG (see `29-foundry/tools/rag.py`):
```python
AZURE_OPENAI_ENDPOINT   = "https://marco-sandbox-foundry.cognitiveservices.azure.com/"
EMBEDDING_DEPLOYMENT    = "text-embedding-ada-002"
COMPLETION_DEPLOYMENT   = "gpt-4o"
```

**Chat Apps (user-facing conversation, eva-brain, eva-jp-spark)**
- Default conversation model: `marco-sandbox-foundry` / `gpt-5.1-chat`
  - 100K TPM GlobalStandard -- highest throughput for multi-user chat
  - Use `max_completion_tokens`; omit `temperature`
- Fallback / low-cost: `marco-sandbox-foundry` / `gpt-4o-mini` -- 50K TPM
- High-context sessions: `marco-sandbox-foundry` / `gpt-4o` -- most stable context window
- Streaming note: all three support streaming via `stream=True` / SSE

**Cloud Coding (agentic code fix, devbench, brain-v2 code generation)**
- Primary: `marco-sandbox-openai-v2` / `gpt-5.1-chat`
  - Dedicated endpoint, 100K TPM GlobalStandard, no shared quota with chat apps
  - Confirmed tool-calling [PASS] -- required for agentic code-fix loops
- Secondary: `marco-sandbox-foundry` / `gpt-5.1-codex`
  - [WARN] 1K TPM cap + responses-API-only -- use only for single-shot completions, not loops
- Inline suggestions: NOT via BYOK (VS Code inline completions require separate provider extension)

---

## PART 2 -- PROJECT-SPECIFIC
> Replace all `{PLACEHOLDER}` values before use. Delete unused sections.

---

### Project Lock

This file is the copilot-instructions for **{PROJECT_FOLDER}** ({PROJECT_NAME}).

The workspace-level bootstrap rule "Step 1 -- Identify the active project from the currently open file path"
applies **only at the initial load of this file** (first read at session start).
Once this file has been loaded, the active project is locked to **{PROJECT_FOLDER}** for the entire session.
Do NOT re-evaluate project identity from editorContext or terminal CWD on each subsequent request.
Work state and sprint context are read from `STATUS.md` and `PLAN.md` at bootstrap -- not from this file.

---

### Project Identity

**Name**: {PROJECT_NAME}
**Folder**: `C:\AICOE\eva-foundation\{PROJECT_FOLDER}`
**ADO Epic**: #{ADO_EPIC_ID} -- `{ADO_BOARD_URL}`
**37-data-model record**: `GET /model/projects/{PROJECT_FOLDER}`
**Maturity**: {PROJECT_MATURITY}   <!-- empty | poc | active | retired -->
**Phase**: {CURRENT_PHASE}

**Depends on**:
- {DEPENDENCY_1} -- {WHY}

**Consumed by**:
- {CONSUMER_1} -- {HOW}

---

### Stack and Conventions

```
{LANGUAGE} {VERSION}
{FRAMEWORK} {VERSION}
{KEY_LIB_1}
```

---

### Test Command

```powershell
{TEST_COMMAND}       # must exit 0 before any commit
{SMOKE_TEST_COMMAND} # quick smoke test
```

**Current test count**: {TEST_COUNT} tests -- {COVERAGE}% coverage (as of {DATE})

---

### Key Commands

```powershell
{START_COMMAND}   # start dev server / app
{BUILD_COMMAND}   # build
{LINT_COMMAND}    # lint / type check
```

---

### Critical Code Patterns

{DESCRIBE_1_3_PATTERNS_SPECIFIC_TO_THIS_PROJECT}

---

### Known Anti-Patterns

| Do NOT | Do instead |
|---|---|
| {ANTI_PATTERN_1} | {CORRECT_APPROACH_1} |

---

### Skills in This Project

> If `.github/copilot-skills/` exists:
> ```powershell
> Get-ChildItem ".github/copilot-skills" -Filter "*.skill.md" | Select-Object Name
> ```

| Skill file | Trigger phrases | Purpose |
|---|---|---|
| {SKILL_FILE} | {TRIGGERS} | {PURPOSE} |

---

### 37-data-model -- This Project's Entities

```powershell
# Screens owned by this app
Invoke-RestMethod "$base/model/screens/" | Where-Object { $_.app -eq '{APP_NAME}' }

# Endpoints implemented by this project
Invoke-RestMethod "$base/model/endpoints/" | Where-Object { $_.implemented_in -like '*{PROJECT_FOLDER}*' }

# Feature flags gating this project
Invoke-RestMethod "$base/model/feature_flags/" | Where-Object { $_.id -like '*{FEATURE_PREFIX}*' }
```

---

### Deployment

**Environment**: {DEV_ENV_URL} / {PROD_ENV_URL}
**Deploy**: `{DEPLOY_COMMAND}`
**CI**: `{CI_PIPELINE_URL}`

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

*Source template*: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md` v3.3.3
*Project 07 README*: `C:\AICOE\eva-foundry\07-foundation-layer\README.md`
*EVA Data Model USER-GUIDE*: `C:\AICOE\eva-foundry\37-data-model\USER-GUIDE.md`
