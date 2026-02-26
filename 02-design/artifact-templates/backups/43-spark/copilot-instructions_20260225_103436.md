# GitHub Copilot Instructions " EVA JP Spark

**Template Version**: 3.0.0
**Last Updated**: February 24, 2026 10:33 PM ET
**Project**: EVA JP Spark " Jurisprudence assistant (older)
**Path**: `C:\AICOE\eva-foundation\43-spark\`
**Stack**: Python, FastAPI, React

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

# EVA Spark " Copilot Instructions

> These instructions apply to **every Copilot session** in this workspace (agent mode, chat mode, inline completions).  
> They encode the non-negotiable rules for all EVA UI/UX frontend work.

---

## Project Identity

You are working on **EVA-JP v1.2**, a bilingual (English / French) AI assistant web application for the Government of Canada. The frontend is built with React 18, TypeScript strict mode, Vite, and Fluent UI React v9. It must meet WCAG 2.1 AA accessibility and comply with the Treasury Board of Canada Secretariat Official Languages Act requirements.

This app lives at `C:\AICOE\eva-foundation\31-eva-faces\eva-jp\` as a workspace in the **eva-faces monorepo**. It consumes `@eva/gc-design-system` and `@eva/ui` from sibling packages in `shared/` " no install or publish needed, npm workspaces symlinks them automatically.

The source of truth for API shapes and business logic is: https://github.com/microsoft/PubSec-Info-Assistant/tree/main/app/frontend

---

## Non-Negotiable Rules

### 1. UI Library
- Import shared components from **`@eva/ui`** first -- use the `EvaXxx` wrapper, not the raw Fluent primitive
  - `EvaButton`, `EvaInput`, `EvaTextArea`, `EvaSelect`, `EvaDialog`, `EvaDrawer`, `EvaBadge`,
    `EvaDataGrid`, `EvaSpinner`, `EvaIcon`, `EvaTabs`, `EvaToast`, `EvaDateRangePicker`, `EvaJsonViewer`
- For primitives **not yet wrapped** by `@eva/ui`, import from `@fluentui/react-components` only
- **Zero** imports from `@fluentui/react` (v8) -- treat this as a build-breaking error
- Theme is provided by **`GCThemeProvider`** from `@eva/gc-design-system` -- do **not** instantiate a bare `FluentProvider`
- Add `@eva/ui` and `@eva/gc-design-system` as peer/dev dependencies; in the monorepo they are symlinked automatically via npm workspaces

### 2. Styling
- Use `makeStyles` and `mergeClasses` from `@fluentui/react-components` for all styles
- All colours -> GC design tokens exported from `@eva/gc-design-system` (which extends `tokens.colorNeutral*` / `tokens.colorBrand*` / `tokens.colorStatus*`)
- All spacing ' `tokens.spacingHorizontal*` / `tokens.spacingVertical*`
- All typography ' `tokens.typographyStyles.*` (Body1, Subtitle1, Title1, etc.)
- **Zero** hardcoded hex values, pixel values, or `em` values in style objects
- Every `makeStyles` call that sets `color`, `background`, or `border` **must** include:
  ```ts
  '@media (forced-colors: active)': {
    // Use only: Canvas, CanvasText, Highlight, HighlightText, ButtonFace, ButtonText
  }
  ```

### 3. Internationalisation
- **Every** user-visible string uses `const { t } = useTranslation()` and `t("key")`
- Zero string literals in JSX " no exceptions, not even punctuation that appears in UI
- i18n keys follow the human-readable English string convention (`"Send question"`, not `"sendQuestion"`)
- `document.documentElement.lang` must always reflect the active i18next locale

### 4. Accessibility (WCAG 2.1 AA)
- Every interactive element has a visible focus ring: `outline: 3px solid tokens.colorStrokeFocus2; outlineOffset: 2px`
- Every `<Dialog>` and `<Drawer>` traps focus; Escape closes it; focus returns to the trigger `ref`
- Every icon-only button has an explicit `aria-label`
- Every form control has a `<label>` or `aria-label` " no placeholder-only labelling
- The chat message list uses `role="log" aria-live="polite"`
- Async state changes call `useAnnouncer()` " never rely on visual-only feedback
- `<header role="banner">` - `<main id="mainContent" role="main" tabIndex={-1}>` - `<nav aria-label="...">` - `<footer role="contentinfo">`
- One `<h1>` per page (in the header); page screens use `<h2>` as their first heading
- On route change: (1) `document.title` update, (2) `useAnnouncer()` call, (3) `setTimeout 150ms ' #mainContent h2 focus`
- Toggle button groups: `div role="radiogroup"` wrapping `ToggleButton` components with `role="radio"` and `aria-checked`

### 5. TypeScript
- Strict mode always on (`"strict": true` in tsconfig)
- Explicit return types on all exported components and functions
- No `any` types " use `unknown` and narrow, or define an interface

### 6. Out of Scope
- Do not modify backend API code, authentication logic, or Azure infrastructure
- Do not add dark theme (Phase 4+ stretch goal)
- Do not add languages beyond English and French

---

## Skills Available

When working on specific domains, reference these skill files for detailed guidance:

| Skill | Path | When to use |
|-------|------|-------------|
| `@eva/ui` + GC design system | `.copilot/skills/eva-ui.md` | Any component implementation |
| Accessibility / WCAG | `.copilot/skills/a11y-wcag.md` | Any ARIA, focus, or contrast work |
| i18n EN/FR | `.copilot/skills/i18n-enfr.md` | Any string or locale work |
| Spark workflow | `.copilot/skills/spark-workflow.md` | Structuring or refining Spark prompts |

---

## File Structure

```
src/
""" index.tsx                     GCThemeProvider + AnnouncerProvider + HashRouter
""" theme.ts                      re-exported GC design tokens from @eva/gc-design-system
""" App.tsx                       Route definitions
""" i18n/
"   """ i18n.tsx                  i18next init (navigator.language detection)
"   """" locales/
"       """ en/resources_en.json
"       """" fr/resources_fr.json
""" components/
"   """ Annoucement/              AnnouncerProvider + useAnnouncer
"   """ WarningBanner/
"   """ QuestionInput/
"   """ Answer/
"   """ CharacterStreamer/
"   """ AnalysisPanel/
"   """ ChatHistory/
"   """ Example/
"   """ FolderPicker/
"   """ TagPicker/
"   """ filepicker/
"   """ FileStatus/
"   """ InfoButton/
"   """ ResponseLengthButtonGroup/
"   """ ResponseTempButtonGroup/
"   """ ChatModeButtonGroup/
"   """ RAIPanel/
"   """ SupportingContent/
"   """ SettingsButton/
"   """ SettingsIconButton/
"   """" Title/
"""" pages/
    """ layout/Layout.tsx
    """ chat/Chat.tsx
    """ content/Content.tsx
    """ translator/Translator.tsx
    """ urlscrapper/Urlscrapper.tsx
    """ tda/Tda.tsx
    """ tutor/Tutor.tsx
    """" NoPage.tsx
```

---

## API Endpoints (do not invent new ones)

| Endpoint | Used by |
|----------|---------|
| `GET /api/userGroupInfo` | Layout " user RBAC info |
| `GET /api/featureFlags` | Layout " TDA and Math Tutor flags |
| `GET /api/applicationtitle` | LoadTitle component |
| `POST /api/conversation` | Chat " main streaming endpoint |
| `POST /api/feedback` | Answer " thumbs feedback |
| `GET /api/chathistory/sessions` | ChatHistory " list sessions |
| `POST /api/chathistory/session` | Chat " create new session |
| `DELETE /api/chathistory/session/{id}` | ChatHistory " delete session |
| `GET /api/uploadstatus` | FileStatus " list files |
| `POST /api/upload` | FilePicker " upload file |
| `GET /api/getfolders` | FolderPicker / Translator |
| `POST /api/createfolder` | FolderPicker |
| `GET /api/gettags` | TagPicker |
| `POST /api/translatefile` | Translator |
| `POST /api/urlscrape/preview` | URL Scraper " preview links |
| `POST /api/urlscrape/submit` | URL Scraper " submit selected |
| `POST /api/tda/analyse` | TDA " EventSource stream |
| `GET /api/tda/maxcsvfilesize` | TDA |
| `GET /api/tda/images` | TDA " chart images |
| `GET /api/math/hint` | Math Tutor " getHint |
| `POST /api/math/stream` | Math Tutor " streamData SSE |
| `POST /api/math/answer` | Math Tutor " processAgentResponse |

---

## Acceptance Criteria Summary

All 15 ACs in `ACCEPTANCE.md` must pass before any branch is merged. Quick reference:

| AC | One-line summary |
|----|-----------------|
| AC-01 | Zero v8 imports + no raw Fluent wrapper bypasses |
| AC-02 | axe-core 0 critical/serious per screen |
| AC-03 | All strings via `t()` |
| AC-04 | Language toggle -- no reload |
| AC-05 | `document.lang` = active locale |
| AC-06 | `document.title` updates on route change |
| AC-07 | Focus -> `<h2>` after navigation |
| AC-08 | Dialog/Drawer: focus trap + Escape + return |
| AC-09 | Icon-only buttons have `aria-label` |
| AC-10 | `aria-live` announces async changes |
| AC-11 | High-contrast mode operable |
| AC-12 | Pagination works correctly |
| AC-13 | Upload flow + FileStatus update |
| AC-14 | Translation flow + download link |
| AC-15 | URL Scraper dialog focus return |
| AC-16 | `EvaXxx` wrappers used; `GCThemeProvider` at root |

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
