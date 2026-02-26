# GitHub Copilot Instructions " EVA ADO Dashboard

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: EVA ADO Dashboard " Sprint views and metrics
**Path**: `C:\AICOE\eva-foundation\39-ado-dashboard\`
**Stack**: React, TypeScript

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
# Copilot Instructions " 39-ado-dashboard

## Role of this package

`39-ado-dashboard` is the **spec author and reference implementation** for the EVA Portal pages.
It is **not a runtime app**. It exports React components and a YAML interface contract that
`31-eva-faces` reads to build the pages that actually ship.

**No-import architecture:**
`31-eva-faces` does **not** `npm install` this package.
It reads `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` and reimplements the pages independently.
This package is the living reference " keep it honest; keep the YAML in sync.

Summary of ownership:
- **39-ado-dashboard** owns: types, reference components, api client, epic YAML interface contract
- **31-eva-faces** owns: routing, auth, actual deployed pages, build pipeline, SWA

---

## General rules

- Use plain ASCII only in scripts, JSON, YAML, and config files. No emojis in code.
- When suggesting Azure resource names, use `marco-sandbox*` or `marcosand*` naming patterns.
- Never commit secrets or APIM subscription keys. Use `.env` (gitignored) locally.

---

## Sandbox & subscription

- Subscription: EsDAICoESub (`d2d4e571-e0f2-4f6c-901a-f88f7669bcba`)
- Resource group: `EsDAICoE-Sandbox`
- Key resources:
  - `marco-sandbox-apim` " API Management gateway (all APIM calls route through here)
  - `marco-sandbox-cosmos` " Cosmos DB (scrum-cache container; brain-v2 owns this)
  - `marco-eva-brain-api` " Container App serving `/v1/scrum/*` routes
  - `marco-sandbox-search` " Azure AI Search (read-only reference)
  - `marcosandkv20260203` " Key Vault (production secrets)

ADO org: `dev.azure.com/marcopresta/eva-poc`
ADO Epic: id=4 `EVA Platform` - Feature: `EVA ADO Dashboard`

---

## API rules " APIM only, never direct ADO

All browser-side API calls **must** go through `marco-sandbox-apim`. Never call ADO APIs directly from the browser.

```
GET  https://marco-sandbox-apim.azure-api.net/v1/scrum/dashboard?project={slug}&sprint={name}
GET  https://marco-sandbox-apim.azure-api.net/v1/scrum/summary
```

Subscription key header: `Ocp-Apim-Subscription-Key`

Environment variables (Vite convention " inject at build time):
```
VITE_APIM_BASE_URL=https://marco-sandbox-apim.azure-api.net
VITE_APIM_SUBSCRIPTION_KEY=<never hardcode " use .env>
```

Follow the pattern already established in `src/api/scrumApi.ts`:
- Build URL with `new URL(...)` " do not concatenate strings
- Add `apimHeaders()` to every fetch call
- On 404/5xx: throw a typed error with `[scrumApi]` prefix
- On summary endpoint failure: degrade gracefully (return `[]`, log `console.warn`)

---

## Type discipline

`src/types/scrum.ts` is the **canonical source of truth** for all data types in this package.

Rules:
- **Never define a data type outside `scrum.ts`**. Component props that describe an ADO entity belong here.
- All 39-ado-dashboard types must match the response shape of `marco-eva-brain-api /v1/scrum/*`.
- When a type is added or changed here, update `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` to reflect it.
- Component-local props (e.g., `WICardProps`) may be defined in the component file, but must reference types from `scrum.ts`.

Key types " do not duplicate or redefine:
```
WorkItem, WIState, Feature, Epic, ScrumDashboardResponse
SprintSummary, SprintBadgeState
Product, ProductCategory
VelocityPoint
```

---

## Design system

This package uses **`@gcweb-suite/react`** (Government of Canada Web Suite).
- Do **not** import from `@eva/ui` or `@fluentui/react-components` " those belong to `31-eva-faces`.
- Use GC Design System tokens for colours, spacing, and typography.
- All components must meet **WCAG 2.1 AA**: colour contrast  4.5:1, keyboard nav, skip links on pages.

---

## Bilingual rules

All user-facing text must be bilingual (English / French).

- `Product.name` is a `[string, string]` tuple " index 0 = EN, index 1 = FR. Always populate both.
- Page titles, badge labels, filter chips, drawer headers " every string needs an FR equivalent.
- Components accept a `lang: 'en' | 'fr'` prop or derive language from React context.
- Do not hardcode a single language string. If you cannot provide FR immediately, use `[enText, enText]` as a placeholder and add a `// TODO: translate` comment.

---

## Component rules

Output paths:
```
src/components/    reusable components (NavHeader, ProductTile, SprintBadge, etc.)
src/pages/         page-level components (EVAHomePage, SprintBoardPage)
src/types/         shared types (scrum.ts is the only file here)
src/api/           APIM client (scrumApi.ts is the only file here)
src/index.ts       barrel export; must export every public component + type
```

Component checklist (every component):
- [ ] Props typed with a named `interface XXXProps` in the component file or `scrum.ts`
- [ ] Default export + named export for the component
- [ ] Bilingual `lang` prop or context-driven language
- [ ] GC Design System tokens only " zero `#hex` or `px` magic numbers
- [ ] WCAG 2.1 AA verified (keyboard nav, colour contrast, aria labels)
- [ ] Exported from `src/index.ts`

Page checklist (EVAHomePage, SprintBoardPage):
- [ ] Accepts mock data when `VITE_APIM_BASE_URL` is empty (graceful degradation)
- [ ] Route path documented in component JSDoc (`// Route: /`)
- [ ] All API calls wrapped in try/catch " surface error state to UI, never crash silently

---

## Epic YAML interface contract

`31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` is the **interface contract** between this package
(spec author) and `31-eva-faces` (implementer).

**When to update the epic YAML:**
- A new component is added to `src/components/` or `src/pages/`
- A type in `scrum.ts` is added, renamed, or removed
- An API endpoint path or query param changes
- A new env variable is required
- A new ADO work item (FACES-WI-*) is needed from `31-eva-faces`

The YAML lives in `31-eva-faces` (not here), because `31-eva-faces` owns the contract enforcement.
After updating the YAML, add a commit note: `chore(spec): update eva-ado-dashboard.epic.yaml " <reason>`.

---

## Work items (ADO)

ADO WIs for this package follow the pattern in `ADO-WORK-ITEMS.md`.

Work items that `31-eva-faces` must deliver for this package to function are named `FACES-WI-*`:
- `FACES-WI-A` " EVAHomePage (route /, static tiles phase)
- `FACES-WI-B` " SprintBoardPage (route /devops/sprint, static shell phase)
- `FACES-WI-C` " auth context exposed (user.role, language) to pages

Do not rename these " `31-eva-faces` PLAN.md references them by this ID.

---

## Product list integrity

`EVAHomePage.tsx` must render all 23 products across exactly 5 categories:
- User Products - AI Intelligence - Platform - Developer - Moonshot

Do not add, remove, or rename categories without updating:
1. The `ProductCategory` type in `scrum.ts`
2. `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` `screens[0].components.ProductTileGrid.categories`
3. `ADO-WORK-ITEMS.md` acceptance criteria for FACES-WI-A

---

## Mock data rules

Until `33-eva-brain-v2/routes/scrum.py` is deployed and APIM routes are registered:
- Pages must render from **mock data** " pre-declared `const MOCK_*` constants in the page file
- `scrumApi.ts` may add a `USE_MOCK` guard matching the `VITE_APIM_BASE_URL` empty check
- Mock shapes must exactly match the TypeScript types in `scrum.ts` " no `as any`, no type casting
- Each mock must include at least: 1 active sprint, 2 features, 3"5 work items, 3 SprintSummary entries

---

## Safety & secrets

- NEVER commit `VITE_APIM_SUBSCRIPTION_KEY` value to source control.
- `.env` is gitignored " copy from `.env.example` and fill locally.
- Production key lives in Key Vault `marcosandkv20260203`; retrieve via az keyvault secret show.

---

## Where to find authoritative project info

| What | Where |
|------|-------|
| Work item backlog | `ADO-WORK-ITEMS.md` |
| Cross-project dependencies | `DEPENDENCIES.md` |
| Interface contract (YAML) | `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` |
| Data model | `src/types/scrum.ts` |
| API client | `src/api/scrumApi.ts` |
| Reference pages | `src/pages/EVAHomePage.tsx`, `src/pages/SprintBoardPage.tsx` |
| Sprint board braindump | `38-ado-poc/STATUS.md` |

---

## Execution rule

Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: reference implementation files, type updates, YAML spec updates, api client updates.
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
