# EVA Spark — Copilot Instructions

> These instructions apply to **every Copilot session** in this workspace (agent mode, chat mode, inline completions).  
> They encode the non-negotiable rules for all EVA UI/UX frontend work.

---

## Project Identity

You are working on **EVA-JP v1.2**, a bilingual (English / French) AI assistant web application for the Government of Canada. The frontend is built with React 18, TypeScript strict mode, Vite, and Fluent UI React v9. It must meet WCAG 2.1 AA accessibility and comply with the Treasury Board of Canada Secretariat Official Languages Act requirements.

This app lives at `C:\AICOE\eva-foundation\31-eva-faces\eva-jp\` as a workspace in the **eva-faces monorepo**. It consumes `@eva/gc-design-system` and `@eva/ui` from sibling packages in `shared/` — no install or publish needed, npm workspaces symlinks them automatically.

The source of truth for API shapes and business logic is: https://github.com/microsoft/PubSec-Info-Assistant/tree/main/app/frontend

---

## Non-Negotiable Rules

### 1. UI Library
- Import components **only** from `@fluentui/react-components` and `@fluentui/react-icons`
- **Zero** imports from `@fluentui/react` (v8) — treat this as a build-breaking error
- If you need a component not in v9, build it from primitives; do not reach for v8

### 2. Styling
- Use `makeStyles` and `mergeClasses` from `@fluentui/react-components` for all styles
- All colours → `tokens.colorNeutral*` / `tokens.colorBrand*` / `tokens.colorStatus*` etc.
- All spacing → `tokens.spacingHorizontal*` / `tokens.spacingVertical*`
- All typography → `tokens.typographyStyles.*` (Body1, Subtitle1, Title1, etc.)
- **Zero** hardcoded hex values, pixel values, or `em` values in style objects
- Every `makeStyles` call that sets `color`, `background`, or `border` **must** include:
  ```ts
  '@media (forced-colors: active)': {
    // Use only: Canvas, CanvasText, Highlight, HighlightText, ButtonFace, ButtonText
  }
  ```

### 3. Internationalisation
- **Every** user-visible string uses `const { t } = useTranslation()` and `t("key")`
- Zero string literals in JSX — no exceptions, not even punctuation that appears in UI
- i18n keys follow the human-readable English string convention (`"Send question"`, not `"sendQuestion"`)
- `document.documentElement.lang` must always reflect the active i18next locale

### 4. Accessibility (WCAG 2.1 AA)
- Every interactive element has a visible focus ring: `outline: 3px solid tokens.colorStrokeFocus2; outlineOffset: 2px`
- Every `<Dialog>` and `<Drawer>` traps focus; Escape closes it; focus returns to the trigger `ref`
- Every icon-only button has an explicit `aria-label`
- Every form control has a `<label>` or `aria-label` — no placeholder-only labelling
- The chat message list uses `role="log" aria-live="polite"`
- Async state changes call `useAnnouncer()` — never rely on visual-only feedback
- `<header role="banner">` · `<main id="mainContent" role="main" tabIndex={-1}>` · `<nav aria-label="...">` · `<footer role="contentinfo">`
- One `<h1>` per page (in the header); page screens use `<h2>` as their first heading
- On route change: (1) `document.title` update, (2) `useAnnouncer()` call, (3) `setTimeout 150ms → #mainContent h2 focus`
- Toggle button groups: `div role="radiogroup"` wrapping `ToggleButton` components with `role="radio"` and `aria-checked`

### 5. TypeScript
- Strict mode always on (`"strict": true` in tsconfig)
- Explicit return types on all exported components and functions
- No `any` types — use `unknown` and narrow, or define an interface

### 6. Out of Scope
- Do not modify backend API code, authentication logic, or Azure infrastructure
- Do not add dark theme (Phase 4+ stretch goal)
- Do not add languages beyond English and French

---

## Skills Available

When working on specific domains, reference these skill files for detailed guidance:

| Skill | Path | When to use |
|-------|------|-------------|
| Fluent UI v9 | `.copilot/skills/fluent-v9.md` | Any component implementation |
| Accessibility / WCAG | `.copilot/skills/a11y-wcag.md` | Any ARIA, focus, or contrast work |
| i18n EN/FR | `.copilot/skills/i18n-enfr.md` | Any string or locale work |
| Spark workflow | `.copilot/skills/spark-workflow.md` | Structuring or refining Spark prompts |

---

## File Structure

```
src/
├── index.tsx                    ← FluentProvider + AnnouncerProvider + HashRouter
├── theme.ts                     ← webLightTheme export
├── App.tsx                      ← Route definitions
├── i18n/
│   ├── i18n.tsx                 ← i18next init (navigator.language detection)
│   └── locales/
│       ├── en/resources_en.json
│       └── fr/resources_fr.json
├── components/
│   ├── Annoucement/             ← AnnouncerProvider + useAnnouncer
│   ├── WarningBanner/
│   ├── QuestionInput/
│   ├── Answer/
│   ├── CharacterStreamer/
│   ├── AnalysisPanel/
│   ├── ChatHistory/
│   ├── Example/
│   ├── FolderPicker/
│   ├── TagPicker/
│   ├── filepicker/
│   ├── FileStatus/
│   ├── InfoButton/
│   ├── ResponseLengthButtonGroup/
│   ├── ResponseTempButtonGroup/
│   ├── ChatModeButtonGroup/
│   ├── RAIPanel/
│   ├── SupportingContent/
│   ├── SettingsButton/
│   ├── SettingsIconButton/
│   └── Title/
└── pages/
    ├── layout/Layout.tsx
    ├── chat/Chat.tsx
    ├── content/Content.tsx
    ├── translator/Translator.tsx
    ├── urlscrapper/Urlscrapper.tsx
    ├── tda/Tda.tsx
    ├── tutor/Tutor.tsx
    └── NoPage.tsx
```

---

## API Endpoints (do not invent new ones)

| Endpoint | Used by |
|----------|---------|
| `GET /api/userGroupInfo` | Layout — user RBAC info |
| `GET /api/featureFlags` | Layout — TDA and Math Tutor flags |
| `GET /api/applicationtitle` | LoadTitle component |
| `POST /api/conversation` | Chat — main streaming endpoint |
| `POST /api/feedback` | Answer — thumbs feedback |
| `GET /api/chathistory/sessions` | ChatHistory — list sessions |
| `POST /api/chathistory/session` | Chat — create new session |
| `DELETE /api/chathistory/session/{id}` | ChatHistory — delete session |
| `GET /api/uploadstatus` | FileStatus — list files |
| `POST /api/upload` | FilePicker — upload file |
| `GET /api/getfolders` | FolderPicker / Translator |
| `POST /api/createfolder` | FolderPicker |
| `GET /api/gettags` | TagPicker |
| `POST /api/translatefile` | Translator |
| `POST /api/urlscrape/preview` | URL Scraper — preview links |
| `POST /api/urlscrape/submit` | URL Scraper — submit selected |
| `POST /api/tda/analyse` | TDA — EventSource stream |
| `GET /api/tda/maxcsvfilesize` | TDA |
| `GET /api/tda/images` | TDA — chart images |
| `GET /api/math/hint` | Math Tutor — getHint |
| `POST /api/math/stream` | Math Tutor — streamData SSE |
| `POST /api/math/answer` | Math Tutor — processAgentResponse |

---

## Acceptance Criteria Summary

All 15 ACs in `ACCEPTANCE.md` must pass before any branch is merged. Quick reference:

| AC | One-line summary |
|----|-----------------|
| AC-01 | Zero v8 imports |
| AC-02 | axe-core 0 critical/serious per screen |
| AC-03 | All strings via `t()` |
| AC-04 | Language toggle — no reload |
| AC-05 | `document.lang` = active locale |
| AC-06 | `document.title` updates on route change |
| AC-07 | Focus → `<h2>` after navigation |
| AC-08 | Dialog/Drawer: focus trap + Escape + return |
| AC-09 | Icon-only buttons have `aria-label` |
| AC-10 | `aria-live` announces async changes |
| AC-11 | High-contrast mode operable |
| AC-12 | Pagination works correctly |
| AC-13 | Upload flow + FileStatus update |
| AC-14 | Translation flow + download link |
| AC-15 | URL Scraper dialog focus return |
