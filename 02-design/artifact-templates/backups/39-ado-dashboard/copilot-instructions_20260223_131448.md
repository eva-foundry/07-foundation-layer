```instructions
# Copilot Instructions — 39-ado-dashboard

## Role of this package

`39-ado-dashboard` is the **spec author and reference implementation** for the EVA Portal pages.
It is **not a runtime app**. It exports React components and a YAML interface contract that
`31-eva-faces` reads to build the pages that actually ship.

**No-import architecture:**
`31-eva-faces` does **not** `npm install` this package.
It reads `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` and reimplements the pages independently.
This package is the living reference — keep it honest; keep the YAML in sync.

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
  - `marco-sandbox-apim` — API Management gateway (all APIM calls route through here)
  - `marco-sandbox-cosmos` — Cosmos DB (scrum-cache container; brain-v2 owns this)
  - `marco-eva-brain-api` — Container App serving `/v1/scrum/*` routes
  - `marco-sandbox-search` — Azure AI Search (read-only reference)
  - `marcosandkv20260203` — Key Vault (production secrets)

ADO org: `dev.azure.com/marcopresta/eva-poc`
ADO Epic: id=4 `EVA Platform` · Feature: `EVA ADO Dashboard`

---

## API rules — APIM only, never direct ADO

All browser-side API calls **must** go through `marco-sandbox-apim`. Never call ADO APIs directly from the browser.

```
GET  https://marco-sandbox-apim.azure-api.net/v1/scrum/dashboard?project={slug}&sprint={name}
GET  https://marco-sandbox-apim.azure-api.net/v1/scrum/summary
```

Subscription key header: `Ocp-Apim-Subscription-Key`

Environment variables (Vite convention — inject at build time):
```
VITE_APIM_BASE_URL=https://marco-sandbox-apim.azure-api.net
VITE_APIM_SUBSCRIPTION_KEY=<never hardcode — use .env>
```

Follow the pattern already established in `src/api/scrumApi.ts`:
- Build URL with `new URL(...)` — do not concatenate strings
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

Key types — do not duplicate or redefine:
```
WorkItem, WIState, Feature, Epic, ScrumDashboardResponse
SprintSummary, SprintBadgeState
Product, ProductCategory
VelocityPoint
```

---

## Design system

This package uses **`@gcweb-suite/react`** (Government of Canada Web Suite).
- Do **not** import from `@eva/ui` or `@fluentui/react-components` — those belong to `31-eva-faces`.
- Use GC Design System tokens for colours, spacing, and typography.
- All components must meet **WCAG 2.1 AA**: colour contrast ≥ 4.5:1, keyboard nav, skip links on pages.

---

## Bilingual rules

All user-facing text must be bilingual (English / French).

- `Product.name` is a `[string, string]` tuple — index 0 = EN, index 1 = FR. Always populate both.
- Page titles, badge labels, filter chips, drawer headers — every string needs an FR equivalent.
- Components accept a `lang: 'en' | 'fr'` prop or derive language from React context.
- Do not hardcode a single language string. If you cannot provide FR immediately, use `[enText, enText]` as a placeholder and add a `// TODO: translate` comment.

---

## Component rules

Output paths:
```
src/components/   ← reusable components (NavHeader, ProductTile, SprintBadge, etc.)
src/pages/        ← page-level components (EVAHomePage, SprintBoardPage)
src/types/        ← shared types (scrum.ts is the only file here)
src/api/          ← APIM client (scrumApi.ts is the only file here)
src/index.ts      ← barrel export; must export every public component + type
```

Component checklist (every component):
- [ ] Props typed with a named `interface XXXProps` in the component file or `scrum.ts`
- [ ] Default export + named export for the component
- [ ] Bilingual `lang` prop or context-driven language
- [ ] GC Design System tokens only — zero `#hex` or `px` magic numbers
- [ ] WCAG 2.1 AA verified (keyboard nav, colour contrast, aria labels)
- [ ] Exported from `src/index.ts`

Page checklist (EVAHomePage, SprintBoardPage):
- [ ] Accepts mock data when `VITE_APIM_BASE_URL` is empty (graceful degradation)
- [ ] Route path documented in component JSDoc (`// Route: /`)
- [ ] All API calls wrapped in try/catch — surface error state to UI, never crash silently

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
After updating the YAML, add a commit note: `chore(spec): update eva-ado-dashboard.epic.yaml — <reason>`.

---

## Work items (ADO)

ADO WIs for this package follow the pattern in `ADO-WORK-ITEMS.md`.

Work items that `31-eva-faces` must deliver for this package to function are named `FACES-WI-*`:
- `FACES-WI-A` — EVAHomePage (route /, static tiles phase)
- `FACES-WI-B` — SprintBoardPage (route /devops/sprint, static shell phase)
- `FACES-WI-C` — auth context exposed (user.role, language) to pages

Do not rename these — `31-eva-faces` PLAN.md references them by this ID.

---

## Product list integrity

`EVAHomePage.tsx` must render all 23 products across exactly 5 categories:
- User Products · AI Intelligence · Platform · Developer · Moonshot

Do not add, remove, or rename categories without updating:
1. The `ProductCategory` type in `scrum.ts`
2. `31-eva-faces/docs/epics/eva-ado-dashboard.epic.yaml` `screens[0].components.ProductTileGrid.categories`
3. `ADO-WORK-ITEMS.md` acceptance criteria for FACES-WI-A

---

## Mock data rules

Until `33-eva-brain-v2/routes/scrum.py` is deployed and APIM routes are registered:
- Pages must render from **mock data** — pre-declared `const MOCK_*` constants in the page file
- `scrumApi.ts` may add a `USE_MOCK` guard matching the `VITE_APIM_BASE_URL` empty check
- Mock shapes must exactly match the TypeScript types in `scrum.ts` — no `as any`, no type casting
- Each mock must include at least: 1 active sprint, 2 features, 3–5 work items, 3 SprintSummary entries

---

## Safety & secrets

- NEVER commit `VITE_APIM_SUBSCRIPTION_KEY` value to source control.
- `.env` is gitignored — copy from `.env.example` and fill locally.
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
