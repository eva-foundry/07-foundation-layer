# EVA-JP v1.2 — Copilot Instructions

> Applies to every Copilot session (agent mode, chat, inline completions) in this repository.  
> Encode the non-negotiable rules for all EVA-JP frontend work.  
> Full context: https://github.com/eva-foundry/44-eva-jp-spark

---

## Project Identity

**EVA-JP v1.2** — bilingual (EN/FR) AI assistant web app for the Government of Canada.  
Stack: React 18 · TypeScript strict · Vite 5 · Fluent UI React v9 · WCAG 2.1 AA · i18next.

Backend API contract: https://github.com/microsoft/PubSec-Info-Assistant/tree/main/app/frontend  
Architecture reference: `ARCHITECTURE.md` in this repo.

---

## Non-Negotiable Rules

### 1. UI Library
- Import **only** from `@fluentui/react-components` and `@fluentui/react-icons`
- **ZERO** imports from `@fluentui/react` (v8) — treat as a **build-breaking error**

### 2. Styling
- All styles via `makeStyles()` + `mergeClasses()` from `@fluentui/react-components`
- All colours → `tokens.colorNeutral*` / `tokens.colorBrand*` / `tokens.colorStatus*`
- All spacing → `tokens.spacingHorizontal*` / `tokens.spacingVertical*`
- All typography → `tokens.typographyStyles.*`
- **ZERO** hardcoded hex values, pixel values, or `em` values
- Every `makeStyles` with `color`, `background`, or `border` **must** include:
  ```ts
  '@media (forced-colors: active)': { /* Canvas, CanvasText only */ }
  ```

### 3. Internationalisation
- Every user-visible string: `const { t } = useTranslation()` + `t("key")`
- Key format: human-readable English — `t("Send question")` not `t("sendQuestion")`
- **ZERO** string literals in JSX — no exceptions
- `document.documentElement.lang` always reflects the active locale

### 4. Accessibility (WCAG 2.1 AA)
- Focus ring on every interactive element: `outline: 3px solid tokens.colorStrokeFocus2; outlineOffset: 2px`
- All Dialogs and Drawers: trap focus, Escape closes, focus returns to trigger `ref`
- Every icon-only button has explicit `aria-label`
- Every form control has `<label>` or `aria-label`
- Chat message list: `role="log" aria-live="polite"`
- Async state changes call `useAnnouncer()` — never visual-only
- Landmarks: `<header role="banner">`, `<main id="mainContent" role="main" tabIndex={-1}>`, `<nav aria-label="...">`, `<footer role="contentinfo">`
- One `<h1>` per page (header); screens use `<h2>` inside `#mainContent`
- Route change: (1) `document.title`, (2) `useAnnouncer()`, (3) `setTimeout 150ms → #mainContent h2 focus`
- Toggle groups: `div role="radiogroup"` with `ToggleButton role="radio"` + `aria-checked`

### 5. TypeScript
- `"strict": true` always
- Explicit return types on all exported components and functions
- No `any` — use `unknown` + narrowing or a typed interface

### 6. Out of Scope
- Do not modify backend API code, auth logic, or Azure infrastructure
- Do not add dark theme (Phase 4+ stretch)
- Do not add languages beyond EN/FR

---

## Lesson Learned: API-First Write Protocol for Data Model Objects

> Updated Feb 23, 2026. Lessons from eva-faces + eva-jp-spark agent sessions.  
> Full agent user guide: `C:\AICOE\eva-foundation\37-data-model\USER-GUIDE.md`

**Never edit `model/*.json` files directly** to update data model objects.
Always go through the application layer (`PUT /model/{layer}/{id}`).

Direct edits bypass the audit trail: `modified_by` stays `"system:autoload"`, `row_version`
stays `1` for everything, and `GET /model/admin/audit` is blind to those changes.

### Correct 5-step write cycle
```
1. PUT /model/{layer}/{id}        # API stamps modified_at, modified_by, row_version
2. GET /model/{layer}/{id}        # verify — assert row_version incremented + modified_by matches actor
3. POST /model/admin/export       # write store back to model/*.json
4. assemble-model.ps1             # rebuild eva-model.json
5. validate-model.ps1             # MUST exit 0 — zero violations before commit
```

This applies to **all** API-backed stores in the EVA stack. Mock at the service/store layer
in tests, not by editing JSON on disk and restarting the server.

### Agent Gotchas — recorded Feb 23, 2026

**1. PUT requires the full object — strip audit columns first.**  
`Invoke-RestMethod` returns a `PSCustomObject`. Mutating it and round-tripping back works,  
but audit columns (`obj_id`, `layer`, `is_active`, `modified_*`, `created_*`, `row_version`)  
must be excluded from the PUT body or the API rejects / silently misbehaves.  
Build `[ordered]@{}` from scratch using only domain fields.

**2. PATCH is not supported — always PUT the full object.**  
PATCH returns 422. Never attempt partial-field updates via PATCH.

**3. Endpoint IDs include the exact parameter name — never construct, always GET.**  
The `id` of every endpoint record is `"METHOD /path/{exact_param}"` (e.g. `"GET /v1/sessions/{session_id}"`,  
not `"GET /v1/sessions/{id}"`). Wrong param names cause `validate-model.ps1` FAILs.  
Always query `GET /model/endpoints/` and use the `.id` field verbatim.

**4. Fix a validation FAIL: look up the correct endpoint ID, then re-PUT the screen.**  
If `validate-model.ps1` reports `screen 'X' api_calls references unknown endpoint 'Y'`:  
```powershell
# 1. Find the actual id
Invoke-RestMethod "http://localhost:8010/model/endpoints/" |
  Where-Object { $_.path -like '*your-path*' } | Select-Object id, method, path
# 2. Re-PUT the screen with the corrected api_calls array
# 3. Re-run export → assemble → validate
```

**5. Use a `.ps1` script for any PUT with more than 3 fields.**  
Inline PowerShell one-liners with multi-property `ConvertTo-Json` are silently truncated  
in the terminal — the PUT lands but Write-Host output is cut off.  
Write a temp script, run it, delete it. Use `(Invoke-WebRequest ...).Content` for reads.

**6. Validate WARNs about `repo_line` are pre-existing and not your fault.**  
`validate-model.ps1` always emits ~60 `[WARN]` lines about missing `repo_line` values.  
These are chronic gaps tracked via `scripts/backfill-repo-lines.py`. Ignore them in your  
validation check — only `[FAIL]` lines block a commit.

**7. The canonical write-confirm step is a GET asserting `row_version`.**  
```powershell
$v = (Invoke-WebRequest "http://localhost:8010/model/screens/MyScreen").Content | ConvertFrom-Json
if ($v.row_version -lt 2 -or $v.modified_by -ne 'agent:copilot') { throw 'PUT did not land' }
```

---

## API Endpoints (do not invent new ones)

See `ARCHITECTURE.md` Section 4 for the full endpoint table.

Key endpoints:
- `GET /api/userGroupInfo` — RBAC
- `GET /api/featureFlags` — TDA / Tutor visibility
- `POST /api/conversation` — SSE streaming chat
- `GET /api/chathistory/sessions` + `POST/DELETE /api/chathistory/session` — history
- `POST /api/upload` + `GET /api/uploadstatus` — file management

---

## EVA Data Model (37-data-model) — How to Use

The **EVA Data Model** (`C:\AICOE\eva-foundation\37-data-model`) is the single source of truth for
every significant object in the EVA ecosystem: screens, components, hooks, TypeScript types,
endpoints, literals, feature flags, and their cross-references.

> **Rule: query the model API first. Never grep source files when the model has the answer.**

### Start the API (port 8010)

```powershell
# Check if already up
Invoke-RestMethod http://localhost:8010/health
# {"status":"ok","store":"MemoryStore","layers":27}

# Start if not running (~3 s)
$env:PYTHONPATH = "C:\AICOE\eva-foundation\37-data-model"
C:\AICOE\.venv\Scripts\python -m uvicorn api.server:app --port 8010 --reload
# Interactive docs: http://localhost:8010/docs
```

### Layers Relevant to EVA-JP

| Layer name | What it holds |
|------------|---------------|
| `screens` (L5) | Every route: route path, min role, api_calls, components, hooks, status |
| `endpoints` (L4) | Every HTTP endpoint: method, path, auth, request/response shape |
| `feature_flags` (L2) | TDA / Tutor visibility guards + all other persona gates |
| `literals` (L6) | Every i18n key: `default_en`, `default_fr`, which screens use it |
| `components` (L18) | React component catalog — Fluent UI v9, WCAG notes, file path |
| `hooks` (L19) | Custom hooks: `useAnnouncer`, `useFeatureFlags`, `useRBAC` |
| `ts_types` (L20) | TypeScript interfaces and enums from `src/types/index.ts` |

### Common Queries

```powershell
# All EVA-JP screens and their status
Invoke-RestMethod "http://localhost:8010/model/screens/" |
  Where-Object { $_.app -eq 'eva-jp-spark' } |
  Select-Object id, route, status, min_role

# What API calls does the Chat screen make?
(Invoke-RestMethod "http://localhost:8010/model/screens/Chat").api_calls

# What components does the Chat screen use?
(Invoke-RestMethod "http://localhost:8010/model/screens/Chat").components

# Get the full definition of a component
Invoke-RestMethod "http://localhost:8010/model/components/QuestionInput"

# Get a hook definition (path + line for code --goto)
$h = Invoke-RestMethod "http://localhost:8010/model/hooks/useAnnouncer"
code --goto "C:\AICOE\eva-foundation\$($h.repo_path):$($h.repo_line)"

# All i18n literals used on the Chat screen
Invoke-RestMethod "http://localhost:8010/model/literals/" |
  Where-Object { $_.screens -contains 'Chat' }

# Check which feature flags gate TDA and Tutor
Invoke-RestMethod "http://localhost:8010/model/feature_flags/" |
  Where-Object { $_.id -match 'ENABLE_TABULAR|ENABLE_MATH' }

# Is an endpoint auth-gated? What role is required?
(Invoke-RestMethod "http://localhost:8010/model/endpoints/POST /api/conversation").auth

# Cross-layer impact: what screens/components break if an endpoint changes?
Invoke-RestMethod "http://localhost:8010/model/graph/?node_id=POST /api/conversation&depth=2" |
  ForEach-Object { $_.edges } | Select-Object from_id, from_layer, to_id, to_layer, edge_type

# Navigate directly to a component's source line
$c = Invoke-RestMethod "http://localhost:8010/model/components/AnswerPanel"
code --goto "C:\AICOE\eva-foundation\$($c.repo_path):$($c.repo_line)"
```

### Offline Fallback (CI / no API running)

```powershell
$m = Get-Content C:\AICOE\eva-foundation\37-data-model\model\eva-model.json | ConvertFrom-Json
$m.screens    | Where-Object { $_.app -eq 'eva-jp-spark' }
$m.endpoints  | Where-Object { $_.path -eq '/api/conversation' }
$m.literals   | Where-Object { $_.screens -contains 'Chat' }
$m.components | Where-Object { $_.id -eq 'QuestionInput' }
```

### Write Protocol — Update Model Objects

**Never edit `model/*.json` files directly.** Always use the API so the audit trail is preserved.

```
1. PUT /model/{layer}/{id}        # API stamps modified_at, modified_by, row_version
2. GET /model/{layer}/{id}        # verify — assert row_version incremented
3. POST /model/admin/export       # materialise store back to model/*.json
4. assemble-model.ps1             # rebuild eva-model.json
5. validate-model.ps1             # must exit 0 — [WARN] repo_line lines are pre-existing noise, ignore
```

```powershell
# Example: update the Chat screen's components list
# Rule: fetch first, build [ordered]@{} from domain fields only — strip audit columns
$s = (Invoke-WebRequest "http://localhost:8010/model/screens/Chat").Content | ConvertFrom-Json
$body = [ordered]@{
  id         = $s.id
  app        = $s.app
  route      = $s.route
  status     = $s.status
  min_role   = $s.min_role
  rbac       = $s.rbac
  api_calls  = $s.api_calls
  hooks      = $s.hooks
  components = @("QuestionInput", "Answer", "CharacterStreamer", "ChatHistory", "AnalysisPanel")
  notes      = $s.notes
} | ConvertTo-Json
Invoke-RestMethod "http://localhost:8010/model/screens/Chat" -Method PUT -Body $body -ContentType "application/json" -Headers @{"X-Actor"="agent:copilot"}
# Confirm
$v = (Invoke-WebRequest "http://localhost:8010/model/screens/Chat").Content | ConvertFrom-Json
"rv=$($v.row_version) by=$($v.modified_by)"
```

### Update Discipline

Model updates are **in the same PR as the source change** — never deferred.

| EVA-JP change | Model update required |
|---------------|----------------------|
| New component added to a screen | `PUT /model/screens/{id}` — add to `components[]` |
| New hook used | `PUT /model/screens/{id}` — add to `hooks[]`; `PUT /model/hooks/{id}` if new |
| New i18n key added | `PUT /model/literals/{key}` with `default_en`, `default_fr`, `screens[]` |
| New API call wired to a screen | `PUT /model/screens/{id}` — add endpoint to `api_calls[]` |
| New TypeScript interface exported | `PUT /model/ts_types/{id}` |

### Quick Decision Table

| You want to… | Use |
|---|---|
| Find a screen, component, hook, or type | `GET /model/{layer}/{id}` |
| List all objects in a layer | `GET /model/{layer}/` |
| What API calls does screen X make? | `GET /model/screens/X` → `.api_calls` |
| What breaks if endpoint Y changes? | `GET /model/graph?node_id=Y&depth=2` |
| Jump to source line in VS Code | `GET /model/{layer}/{id}` → `code --goto repo_path:repo_line` |
| Audit who changed what | `GET /model/admin/audit` |
| Validate all cross-refs | `GET /model/admin/validate` |

