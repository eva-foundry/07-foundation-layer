# GitHub Copilot Instructions " EVA Azure Best

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA Azure Best " Azure best practices (11 modules)
**Path**: `C:\AICOE\eva-foundation\18-azure-best\`
**Stack**: Markdown, Python

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

## PART 2 " PROJECT-SPECIFIC
> Replace all `{PLACEHOLDER}` values before use. Delete unused sections.

---

### Project Identity

**Name**: EVA Azure Best
**Folder**: `C:\AICOE\eva-foundation\18-azure-best`
**ADO Epic**: #{ADO_EPIC_ID} -- `{ADO_BOARD_URL}`
**37-data-model record**: `GET /model/projects/18-azure-best`
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

### 37-data-model " This Project's Entities

```powershell
# Screens owned by this app
Invoke-RestMethod "http://localhost:8010/model/screens/" | Where-Object { $_.app -eq '{APP_NAME}' }

# Endpoints implemented by this project
Invoke-RestMethod "http://localhost:8010/model/endpoints/" | Where-Object { $_.implemented_in -like '*18-azure-best*' }

# Feature flags gating this project
Invoke-RestMethod "http://localhost:8010/model/feature_flags/" | Where-Object { $_.id -like '*{FEATURE_PREFIX}*' }
```

---

### Deployment

**Environment**: {DEV_ENV_URL} / {PROD_ENV_URL}
**Deploy**: `{DEPLOY_COMMAND}`
**CI**: `{CI_PIPELINE_URL}`

---

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
