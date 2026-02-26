# GitHub Copilot Instructions -- AICOE Public Page

**Template Version**: 3.0.0
**Last Updated**: February 23, 2026
**Project**: AICOE Public Page -- React 19 + Fluent UI public-facing AICOE page built from a GitHub Spark template.
**Path**: `C:\AICOE\eva-foundation\45-aicoe-page\`
**Stack**: React 19 + TypeScript 5 strict + Vite 7 + Fluent UI v9 + @eva/gc-design-system + i18next EN/FR
**Category**: User Products
**Maturity**: poc
**WBS**: WBS-045

> This file is the Copilot operating manual for this repository.
> PART 1 is universal -- identical across all EVA Foundation projects.
> PART 2 is project-specific -- fill all [TODO] placeholders during first active session.

---

## PART 1 -- UNIVERSAL RULES
> Applies to every EVA Foundation project. Do not modify.

---

### 1. Session Bootstrap (run in this order, every session)

Before answering any question or writing any code:

1. **Ping 37-data-model API**: `Invoke-RestMethod http://localhost:8010/health`
   - If `{"status":"ok"}` use HTTP queries for all discovery (fastest)
   - If down: `env:PYTHONPATH="C:\AICOE\eva-foundation\37-data-model"; C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload`
   - If no venv: `m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json`

2. **Read this project's governance docs** (in order):
   - `README.md` -- identity, stack, quick start
   - `PLAN.md` -- phases, current phase, next tasks
   - `STATUS.md` -- last session snapshot, open blockers
   - `ACCEPTANCE.md` -- DoD checklist, quality gates (if exists)
   - Latest `docs/YYYYMMDD-plan.md` and `docs/YYYYMMDD-findings.md` (if exists)

3. **Read the skills index** (if `.github/copilot-skills/` exists):
   `powershell
   Get-ChildItem ".github/copilot-skills" -Filter "*.skill.md" | Select-Object Name
   `
   - Read `00-skill-index.skill.md` for the skill menu
   - Match the trigger phrase in `triggers:` YAML block to the user's current intent
   - Read the matched skill file in full before doing any work

4. **Query the data model** for this project's record:
   `powershell
   Invoke-RestMethod "http://localhost:8010/model/projects/45-aicoe-page" | Select-Object id, maturity, notes
   `

5. **Produce a Session Brief** -- one paragraph: active phase, last test count, next task, open blockers.
   Do not skip this. Do not start implementing before the brief is written.

---

### 2. DPDCA Execution Loop

Every session runs this cycle. Do not skip steps.

`
Discover  --> synthesise current sprint from plan + findings docs
Plan      --> pick next unchecked task from YYYYMMDD-plan.md checklist
Do        --> implement -- make the change, do not just describe it
Check     --> run the project test command (see PART 2); must exit 0
Act       --> update STATUS.md, PLAN.md, YYYYMMDD-plan.md, findings doc
Loop      --> return to Discover if tasks remain
`

**Execution Rule**: Make the change. Do not propose, narrate, or ask for permission
on a step you can determine yourself. If uncertain about scope, ask one clarifying
question then proceed.

---

### 3. EVA Data Model API -- Mandatory Protocol

**Full reference**: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
Read it at every sprint boundary or when a query pattern is unfamiliar.

**Rule: query the model first -- never grep when the model has the answer**

| You want to know... | Use (1 turn) | Do NOT (10 turns) |
|---|---|---|
| All endpoints for a service | `GET /model/endpoints/` filtered | grep router files |
| What a screen calls | `GET /model/screens/{id}` -> `.api_calls` | read screen source |
| Auth/feature flag for an endpoint | `GET /model/endpoints/{id}` | grep auth middleware |
| What breaks if X changes | `GET /model/impact/?container=X` | trace imports manually |
| Navigate to source line | `.repo_path` + `.repo_line` -> `code --goto` | file_search |

**5-step write cycle (mandatory -- every model change)**

`
1. PUT /model/{layer}/{id}          -- X-Actor: agent:copilot header required
2. GET /model/{layer}/{id}          -- assert row_version incremented + modified_by matches
3. POST /model/admin/export         -- Authorization: Bearer dev-admin
4. scripts/assemble-model.ps1       -- must report 27/27 layers OK
5. scripts/validate-model.ps1       -- must exit 0; [FAIL] lines block; [WARN] are noise
`

---

### 4. Encoding and Output Safety

- All Python scripts: `PYTHONIOENCODING=utf-8` in any .bat wrapper
- All PowerShell output: `[PASS]` / `[FAIL]` / `[WARN]` / `[INFO]` -- never emoji
- Machine-readable outputs (JSON, YAML, evidence files): ASCII-only always
- Markdown human-facing docs: emoji allowed for readability only

---

### 5. Python Environment

`
venv exec: C:\AICOE\.venv\Scripts\python.exe
activate:  C:\AICOE\.venv\Scripts\Activate.ps1
`

Never use bare `python` or `python3`. Always use the full venv path.

---

## PART 2 -- PROJECT-SPECIFIC
> Fill all [TODO] values during the first active session on this project.

---

### Project Identity

**Name**: AICOE Public Page
**Folder**: `C:\AICOE\eva-foundation\45-aicoe-page`
**ADO Epic**: [TODO]
**37-data-model record**: `GET /model/projects/45-aicoe-page`
**Maturity**: poc
**Phase**: Phase 1 -- Scaffolded

**Depends on**:
- 31-eva-faces/shared/gc-design-system -- GC design tokens + GCThemeProvider
- 31-eva-faces/shared/eva-ui -- shared EvaXxx component wrappers

**Consumed by**:
- Public web users (GC public-facing landing page)
- 31-eva-faces may embed or link to this page

---

### Stack and Conventions

`
[TODO: runtime / language + version]
[TODO: framework + version]
[TODO: key libraries]
`

---

### Test Command

`powershell
# Type-check + build (must exit 0 before any commit)
npm run build
# Lint
npm run lint
`

**Current test count**: 0 (Vitest not yet added -- Phase 3)

---

### Key Commands

`powershell
npm run dev          # Vite dev server
npm run build        # tsc --noEmit + vite build (must pass before commit)
npm run typecheck    # tsc --noEmit only
npm run lint         # eslint src
npm install --legacy-peer-deps  # required due to @eva/* file: deps
`

---

### Critical Patterns

1. **GCThemeProvider is mandatory** -- Never use bare `FluentProvider`. Always wrap with `<GCThemeProvider>` from `@eva/gc-design-system`; it applies GC design tokens to Fluent\'s token system.
2. **All visible strings via `t("key")`** -- No hardcoded English/French in JSX. Every string lives in `src/i18n/locales/en/` and `src/i18n/locales/fr/`.
3. **WCAG skip-link + announcer** -- Every new page must be reachable via skip-link; route changes must call `announce()` via `useAnnouncer()`.

---

### Known Anti-Patterns

| Do NOT | Do instead |
|---|---|
| `import { FluentProvider, webLightTheme }` | `import { GCThemeProvider } from "@eva/gc-design-system"` |
| Hardcode `px` or hex colours in `makeStyles` | Use `tokens.*` from `@fluentui/react-components` |
| Put English/French text in JSX | Use `t("key")` and add key to both locale files |
| Add `@github/spark` back | Spark runtime removed intentionally in Phase 2 |

---

### Skills in This Project

`powershell
Get-ChildItem ".github/copilot-skills" -Filter "*.skill.md" | Select-Object Name
`

| Skill file | Trigger phrases | Purpose |
|---|---|---|
| 00-skill-index.skill.md | list skills, what can you do | Skill menu + index |
| [TODO: add skills as they are created] | | |

---

### 37-data-model -- This Project's Entities

`powershell
# Endpoints implemented by this project
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.implemented_in -like '*45-aicoe-page*' } |
  Select-Object id, status

# Feature flags gating this project
Invoke-RestMethod "http://localhost:8010/model/feature_flags/" |
  Where-Object { $_.id -like '*[TODO:feature-prefix]*' }
`

---

### Deployment

**Environment**: local: `http://localhost:5173` / prod: TBD (GitHub Pages or Azure SWA)
**Deploy**: `npm run build` -> deploy `dist/` folder

---

## PART 3 -- QUALITY GATES

All must pass before merging a PR:

- [ ] Test command exits 0
- [ ] `validate-model.ps1` exits 0 (if any model layer was changed)
- [ ] No encoding violations in new code
- [ ] STATUS.md updated with session summary
- [ ] PLAN.md reflects actual remaining work
- [ ] If new screen / endpoint / component added: model PUT + write cycle closed

---

*Source template*: `C:\AICOE\eva-foundation\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md` v3.0.0
*EVA Data Model USER-GUIDE*: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`
