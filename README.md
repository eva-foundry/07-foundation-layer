# 07-foundation-layer -- EVA Foundation Layer

<!-- eva-primed -->
<!-- foundation-primer: 2026-03-03 by agent:copilot -->

## EVA Ecosystem Integration

| Tool | Purpose | How to Use |
|------|---------|------------|
| 37-data-model | Single source of truth for all project entities | GET http://localhost:8010/model/projects/07-foundation-layer |
| 29-foundry | Agentic capabilities (search, RAG, eval, observability) | C:\AICOE\eva-foundation\29-foundry |
| 48-eva-veritas | Trust score and coverage audit | MCP tool: audit_repo / get_trust_score |
| 07-foundation-layer | Copilot instructions primer + governance templates | MCP tool: apply_primer / audit_project |

**Agent rule**: Query the data model API before reading source files.
```powershell
Invoke-RestMethod "http://localhost:8010/model/agent-guide"   # complete protocol
Invoke-RestMethod "http://localhost:8010/model/agent-summary" # all layer counts
```

---


**Owner**: Marco Presta / EVA AI COE
**Status**: Active -- Workspace PM/Scrum Master -- Governance Toolchain Owner
**Last Updated**: 2026-03-01 08:31 ET
**Plan**: [PLAN.md](PLAN.md)
**History**: [docs/history/](docs/history/) (archived 2026-02-18 artefacts)

---

## Purpose

**07-Foundation-Layer is the Workspace PM/Scrum Master** -- the first touch on all new EVA projects.

### Core Responsibilities

1. **Project Scaffolding** (initial setup for any new EVA project):
   - README, PLAN, STATUS, ACCEPTANCE, CHANGELOG
   - Copilot instructions template (PART 1/PART 2/PART 3 structure)
   - Skills integration (from 29-foundry + proven project patterns)
   - Data model registration (37-data-model WBS layer seeding)
   - Veritas readiness (48-eva-veritas MTI gating setup)

2. **Governance Toolchain Ownership** (infrastructure serving all projects):
   - **36-red-teaming** -- Promptfoo adversarial testing harness
   - **37-data-model** -- Single source of truth API (Cosmos-backed, 27+ layers)
   - **38-ado-poc** -- ADO Command Center (scrum orchestration hub)
   - **39-ado-dashboard** -- EVA Home + sprint visualization
   - **40-eva-control-plane** (partial) -- Runtime evidence spine
   - **48-eva-veritas** -- Requirements traceability + MTI gating

3. **Pattern Propagation** (capturing and distributing proven patterns):
   - Template v3.4.0 with 18-azure-best integration
   - Seeder scripts (Reseed-Projects.ps1 deploys to 12 active projects)
   - Workspace management tools (scaffold, capture, housekeeping)
   - Pattern library: encoding safety, professional components, evidence collection

### The EVA Factory Architecture

**Process**: DPDCA (Discover, Plan, Do, Check, Act) -- deterministic execution loop  
**Data**: 37-data-model -- single source of truth (27+ layers describing ANY software project)  
**Actors**: Agent Skills (sprint-advance, gap-report, veritas-expert, progress-report, sprint-report)  
**Result**: Predictable, traceable, auditable software delivery at scale

**This is not code vibes. This is data-driven AI-enabled Software Engineering and Software Factories.**

---

## Key Artefacts

| Artefact | Path | Version | Notes |
|---|---|---|---|
| Copilot instructions template | 02-design/artifact-templates/copilot-instructions-template.md | v3.2.0 | ACA-first, lean PART 1/2/3 |
| Seeder script | scripts/Reseed-Projects.ps1 | v1.0.0 | -Scope active reseeds 12 projects |
| Apply primer | 02-design/artifact-templates/Apply-Project07-Artifacts.ps1 | v1.4.0 | project-type detection, backup, DryRun |
| Test suite | 02-design/artifact-templates/Test-Project07-Deployment.ps1 | v1.0.0 | 60+ Pester 5.x cases |
| Push script | scripts/Push-CopilotInstructions.ps1 | -- | targeted single-project push |
| MCP server | mcp-server/ | -- | foundation-primer; auto-starts via VS Code |
| Workspace scaffold | 02-design/artifact-templates/Initialize-ProjectStructure.ps1 | v1.0.0 | JSON-driven |
| Workspace capture | 02-design/artifact-templates/Capture-ProjectStructure.ps1 | v1.0.1 | snapshot generator |
| Housekeeping | 02-design/artifact-templates/Invoke-WorkspaceHousekeeping.ps1 | v1.0.0 | compliance + auto-organise |

---

## Quickstart

### Deploy template to a project

```powershell
# Preview first (no writes)
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
     -TargetPath "C:\AICOE\eva-foundry\<project-folder>" -DryRun

# Apply
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
     -TargetPath "C:\AICOE\eva-foundry\<project-folder>"
```

### Reseed all active projects (PART 1 + PART 3 only -- PART 2 preserved)

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\scripts\Reseed-Projects.ps1" -Scope active
```

Expected: PASS=12 FAIL=0 for the current active project set.

### Scaffold a new project

```powershell
# Step 1 -- create folder structure from template
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Initialize-ProjectStructure.ps1" `
     -ProjectRoot "C:\AICOE\eva-foundry\<new-project>" `
     -TemplateFile "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\supported-folder-structure-rag.json"

# Step 2 -- deploy copilot instructions
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
     -TargetPath "C:\AICOE\eva-foundry\<new-project>"
```

---

## Template Structure (v3.2.0)

```
PART 1: Universal rules (encoding, data model API, Python env, Azure account)
PART 2: Project-specific placeholder (filled per project; preserved on reseed)
PART 3: Quality gates checklist
```

PART 1 is managed here and pushed by the seeder.
PART 2 belongs to each individual project and is never overwritten.

---

## Phase Status

| Phase | Status | Notes |
|---|---|---|
| 1 -- Discovery | [~] Formally open | Project 06 patterns extracted; broader ecosystem survey deferred |
| 2 -- Design | [x] Complete | Template v3.2.0 (428 lines); ADRs and usage guide in 02-design/ |
| 3 -- Development | [x] Complete | Apply primer (1,200+ lines) + Pester test suite (650+ lines) |
| 4 -- Testing | [~] Ready | Test suite written; full Pester 5.x run pending |
| 5 -- Workspace Mgmt | [x] Tested | Init / Capture / Housekeeping validated on Project 01 |
| 6 -- Propagation | [x] Running | Reseed-Projects.ps1 active; 12 projects reseeded last run |

---

## Open Items

- Propagate v3.2.0 PART 2 corrections to 29-foundry and 44-eva-jp-spark
  (PART 2 blocks still contain bare localhost:8010 references -- pre-date base pattern)
- Run full Pester 5.x test suite (Install-Module Pester -MinimumVersion 5.0)
- Add workspace management integration to Apply-Project07-Artifacts.ps1 (v1.6.0 target)
- Create additional project-type templates: automation, api, infrastructure

---

## Encoding Rule

ASCII only. No emoji. No Unicode above U+007F. Applies to every file in this project.
Output tokens: [PASS] / [FAIL] / [WARN] / [INFO]

---

## Change Log

| Date | Change |
|---|---|
| 2026-02-26 | README rewritten: ASCII-compliant, paths corrected to C:\AICOE, status synced to STATUS.md (v3.2.0, reseed PASS=12) |
| 2026-02-25 | Template synced to v3.2.0 -- ACA-first throughout. Reseed PASS=12 FAIL=0. STATUS.md created. |
| 2026-02-24 | Workspace copilot-instructions.md updated to v1.1.0 (ACA URL, Endpoint Lifecycle, Veritas MCP). |
| 2026-02-23 | Template rewritten to v3.0.0 (lean 428 lines). Reseed-Projects.ps1 run on 12 active projects. |
| 2026-01-30 | Workspace management scripts tested on Project 01. Phase 5 complete. |
| 2026-01-29 | Phase 3 complete. Apply primer + test suite created. Self-referential copilot-instructions added. |
| 2026-01-22 | Project initiated. |

---

## Priming 51-ACA

- **Purpose**: bootstrap the ACA integration project used for local dev and ACA-connected tests.
- **What to create**: repository folder `51-ACA` with a minimal README, `.gitkeep`, and optional start scripts.
- **Quick actions**:

```powershell
mkdir C:\AICOE\eva-foundry\51-ACA
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
     -TargetPath "C:\AICOE\eva-foundry\51-ACA" -DryRun
```

- **Next steps**: Run the readiness probe from this layer before wiring other projects to ACA. After verification, deploy PART 1 and PART 3 to `51-ACA` via the seeder scripts.

---

## Notes

- This README follows the ASCII-only encoding rule used across EVA projects.

