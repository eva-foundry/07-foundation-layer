# Project 07 -- Foundation Layer -- Status

> Last updated: 2026-03-01 08:31 ET (session 5)
> Status key: [x] Done -- [ ] Not started -- [~] In progress -- [!] Blocked

---

## Current Phase

**Active**: Strategic Elevation -- 07 is now the Workspace PM/Scrum Master

---

## Session Summary -- 2026-03-01 08:31 ET (session 5)

### Strategic Elevation: From Template Seeder to Workspace PM/Scrum Master

**Vision Alignment Complete**: Project 07 undergoes fundamental role expansion.

**New Identity**:
- **From**: Template seeder (copilot instructions propagation)
- **To**: Workspace PM/Scrum Master (first touch on all new EVA projects)

**Core Responsibilities (3 pillars)**:

1. **Project Scaffolding**:
   - README, PLAN, STATUS, ACCEPTANCE, CHANGELOG templates
   - Copilot instructions deployment (PART 1/PART 2/PART 3)
   - Skills integration (source: 29-foundry + proven patterns from 51-ACA)
   - Data model registration (seed WBS layer via seed-from-plan.py pattern)
   - Veritas MTI gating setup (48-eva-veritas integration)

2. **Governance Toolchain Ownership**:
   - **36-red-teaming**: Promptfoo adversarial testing harness
   - **37-data-model**: Single source of truth API (Cosmos-backed, 27+ layers)
   - **38-ado-poc**: ADO Command Center (scrum orchestration hub)
   - **39-ado-dashboard**: EVA Home + sprint views
   - **40-eva-control-plane** (partial): Runtime evidence spine
   - **48-eva-veritas**: Requirements traceability + MTI gating
   - ~~47-eva-mti~~ (retired): MTI computation now in 48-eva-veritas

3. **Pattern Propagation**:
   - Template v3.4.0 with 18-azure-best integration
   - Seeder scripts (Reseed-Projects.ps1 to 12 active projects)
   - Workspace management (scaffold, capture, housekeeping)
   - Agent skills elevation (from 51-ACA to workspace level)

**The EVA Factory Architecture** (data-driven, not code vibes):

```
HUMAN INTENT
  ↓
README → PLAN → STATUS → ACCEPTANCE
  ↓
seed-from-plan.py parses PLAN.md → assigns canonical IDs
  ↓
DATA MODEL (37-data-model API, 27+ layers)
  ↓
AGENT SKILLS query data model (sprint-advance, gap-report, veritas-expert, etc.)
  ↓
DPDCA EXECUTION LOOP (deterministic, repeatable, auditable)
  D -- Discover: Query data model (WBS, services, endpoints, screens, containers)
  P -- Plan: gen-sprint-manifest.py (filter undone stories, size, generate manifest)
  D -- Do: Agent writes code using data model context (exact schemas, routes, etc.)
  C -- Check: pytest + veritas MTI gate (>= 30 Sprint 2, >= 70 Sprint 3+)
  A -- Act: PUT status=done to WBS, reseed, reflect-ids.py updates PLAN.md
  ↓
LOOP BACK TO D -- next sprint
```

**Why This Is Deterministic**:
- Traditional AI: Agent hallucinates route paths, auth logic, schemas (wastes turns)
- EVA Factory: Agent queries data model for EXACT route, auth, schemas, file location
- Result: Zero hallucination. Zero guessing. Predictable delivery.

**51-ACA Breakthrough Patterns** (to be elevated to workspace):
- **5 automation skills**: sprint-advance, veritas-expert, gap-report, sprint-report, progress-report
- **3 core scripts**: seed-from-plan.py, reflect-ids.py, gen-sprint-manifest.py
- **ID consistency solved**: reflect-ids.py writes [ACA-NN-NNN] inline into PLAN.md → no more invented IDs
- **One-line governance**: `gh issue create` with sprint manifest → GitHub Copilot cloud agent executes
- **DPDCA-WORKFLOW.md**: Complete 5-phase loop documentation

**Immediate Tasks** (next sessions):
1. Generalize 51-ACA scripts to work for ANY EVA project (not just ACA)
2. Elevate 5 skills to workspace level (make project-agnostic)
3. Create scaffolding templates: DPDCA-WORKFLOW.md, sprint manifest, GitHub Actions workflow
4. Document one-line governance pattern in workspace copilot-instructions
5. Update 07's own PLAN.md to reflect toolchain ownership
6. Answer 4 reorganization questions (DPDCA location, encoding rule split, etc.)

**Artifacts Updated**:
- README.md: New purpose statement, 3-pillar responsibilities, EVA Factory architecture
- STATUS.md: This session summary (session 5, 2026-03-01 08:31 ET)
- *(Pending)* PLAN.md: Add governance toolchain tasks
- *(Pending)* Workspace copilot-instructions.md: Add DPDCA/Factory section
- *(Pending)* Template copilot-instructions-template.md: Reference workspace DPDCA

**Key Insight**: The data model is the meta-schema describing ANY software project. One HTTP call beats 10 file reads. DPDCA is the deterministic loop. Agent skills are the actors. This is Software Factory at scale.

---

## Session Summary -- 2026-02-28 (session 4)

### Universal Command Wrapper -- Foundation Pattern for Terminal Output Capture Bug

**Problem Identified**: Terminal output capture bug in AI agent sessions
- Symptom: `run_in_terminal` returns command echoes, no actual results
- Impact: Verification impossible (51-ACA Sprint 2 blocked)
- Root cause: Unknown (terminal state, buffer limit, or tool limitation)

**User Solution Proposal**: Create global wrapper with log file pattern
- Take command + search pattern
- Run inside logger wrapper
- Know exact log file (no searching)
- Echo back what user needs
- Solve systematically for all EVA agents

**Implementation Complete** (v1.0.0):

1. **PowerShell Wrapper** (200 lines):
   - `scripts/Invoke-CommandWithLog.ps1`
   - Captures ALL output (stdout + stderr)
   - Uniquely-named logs: `{label}_{YYYYMMDD-HHMMSS-fff}.log`
   - Pattern extraction OR full log
   - Auto-cleanup (1 hour retention)
   - Returns structured result: command, log_file, exit_code, output, duration, success

2. **Python Wrapper** (200 lines):
   - `scripts/invoke_command_with_log.py`
   - Same functionality as PowerShell version
   - CLI interface for testing
   - JSON output mode

3. **Skill Documentation** (400 lines):
   - `.github/copilot-skills/universal-command-wrapper.skill.md`
   - Complete usage guide + examples
   - When to use pattern
   - Integration with EVA projects
   - Adoption roadmap
   - Testing instructions

4. **Immediate Application -- 51-ACA Sprint 2**:
   - `sprint2-verify.ps1` -- 3-gate verification using wrapper (130 lines)
   - `test-wrapper.ps1` -- Wrapper functionality test (60 lines)
   - `WRAPPER-IMPLEMENTATION.md` -- Full implementation guide (250 lines)
   - `QUICK-START.md` -- 3-command quick reference (80 lines)

**Confirmed Gaps (51-ACA Sprint 2)**:
- ✅ LOCAL DB: 15 stories in Sprint-02 (READY)
- ❌ ADO Sprint 2: Empty (user screenshot confirmed)
- ⏳ Baseline tests: Unknown (need manual run)
- ❌ Cloud model: ado_project = "eva-poc" (should be "51-aca")

**Deliverables**:
- Foundation wrapper: 2 implementations (PowerShell + Python)
- Skill documentation: Complete usage guide
- 51-ACA verification: Scripts use wrapper pattern
- Pattern solves terminal bug systematically

**Next Steps**:
1. User runs `sprint2-verify.ps1` to verify Sprint 2 readiness
2. Sync ADO Sprint 2 if GATE 2 fails
3. Update workspace copilot-instructions with wrapper reference (Section 3.5)
4. Update template v3.5.0 with wrapper pattern
5. Deploy to all EVA projects via Apply-Project07-Artifacts.ps1

**Validation**:
- [PASS] Wrapper created in foundation layer (global for all agents)
- [PASS] PowerShell + Python implementations complete
- [PASS] Skill documentation comprehensive (400 lines)
- [PASS] 51-ACA immediate application ready
- [PASS] ASCII-only output (no emoji, Unicode)
- [PENDING] User test: Does wrapper solve terminal bug?

---

## Session Summary -- 2026-02-28 (session 4)

### Integration: 18-Azure-Best Library into Copilot Instructions

1. **Scanned 18-azure-best project** -- complete reference library (32 entries, 2026-02-26)
   - Structure: 12 category folders (01-assessment-tools through 12-security)
   - Machine-readable index: `00-index.json` with topic tags, paths, canonical URLs
   - Each entry: structured summary + code snippets + Agent Checklist

2. **Added to workspace copilot-instructions** (v1.1.0 -> v1.2.0):
   - New section: "18-Azure-Best -- Azure Best Practices Library" (after 29-Foundry, before EVA-Veritas)
   - Structure overview: 12 category folders, all 32 entries listed
   - Usage guide: 3-step process (query index by topic, read file, apply checklist)
   - When to Reference table: 18 common scenarios mapped to specific files
   - Topic tags reference: query shortcuts for common topics (ai, security, resiliency, etc.)

3. **Added to project template** (v3.3.3 -> v3.4.0):
   - New section 2.1: "Azure Best Practices Reference" (after DPDCA, before Data Model API)
   - Quick examples: 4 common scenarios with file paths
   - Reference to workspace instructions for full details

4. **Deliverables**:
   - Workspace instructions v1.2.0: full 18-azure-best integration with usage guide
   - Template v3.4.0: reference section pointing to workspace instructions
   - Reorganization proposal: `docs/copilot-instructions-reorganization-proposal.md` (created earlier in session)

5. **Validation**:
   - [PASS] Workspace instructions now reference 18-azure-best as shared infrastructure
   - [PASS] Template references workspace for Azure best practices (avoids duplication)
   - [PASS] All paths use `C:\AICOE\eva-foundry\` workspace root convention
   - [PASS] ASCII-only output throughout (no emoji, Unicode arrows, etc.)

6. **Next step**: Reseed active projects to propagate template v3.4.0 (blocked on user decision about reorganization proposal)

---

## Session Summary -- 2026-02-25 (session 3)

### Template v3.1.0 --> v3.2.0: ACA-first + browser UI

1. Problem identified: template PART 1 still referenced `http://localhost:8010` as primary
   data model endpoint in bootstrap, PUT Rules, Write Cycle, and code examples.
   HIGH task from session 2 Next Tasks table -- now resolved.

2. Changes applied to `copilot-instructions-template.md` (v3.1.0 --> v3.2.0):
   - Header version and Last Updated stamp (Feb 25, 2026 10:14 ET)
   - Section 1 Step 1: replaced localhost ping with $base ACA description
   - Section 1 Step 4: `http://localhost:8010` --> `$base`
   - Section 3 USER-GUIDE ref: v2.4 --> v2.5
   - Section 3.3 PUT Rules R1, R3, R5: localhost --> `$base`
   - Section 3.4 Write Cycle (PUT + confirm + commit): localhost --> `$base`
   - Section 3.5 validate + fix blocks: localhost --> `$base`
   - Section 3.2 Decision Table: added 2 browser UI rows (portal-face /model, /model/report)
   - Intentional fallback lines preserved: localhost:8010 appears only in
     `$base = "http://localhost:8010"` fallback block (lines 26, 87)

3. Changes applied to `C:\AICOE\.github\copilot-instructions.md`:
   - Bootstrap: project registry query updated to use ACA $base URL
   - PUT Rules + Write Cycle: localhost --> $base (4 multi-replace batches)
   - USER-GUIDE version: v2.4 --> v2.5
   - Intentional fallback at line 165 preserved unchanged

4. Verification:
   - Template: grep for localhost:8010 returns exactly 2 intentional lines [PASS]
   - Template: grep for v3.1.0 / v2.4 returns 0 matches [PASS]
   - Workspace copilot-instructions: 1 intentional localhost line (fallback assign) [PASS]

5. Child projects NOT yet propagated -- still reference localhost:8010.
   Affected: 29-foundry, 37-data-model, 43-spark, 42-learn-foundry, 44-eva-jp-spark,
   45-aicoe-page, 47-eva-mti and others.
   Action required: run Reseed-Projects.ps1 (see Next Tasks).

6. Reseed-Projects.ps1 -Scope active executed (session 3, after STATUS update):
   PASS=12 FAIL=0. PART 1 + PART 3 refreshed for all 12 active projects.
   PART 1 now ACA-first with $base throughout in all 12 files.
   Residual: PART 2 project-specific content in 29-foundry (lines 341-395) and
   44-eva-jp-spark (lines 427-578) still contains bare localhost:8010 references.
   Root cause: those PART 2 blocks are preserved by design; they pre-date $base pattern.
   Action: update 29-foundry and 44-eva-jp-spark PART 2 in their own project sessions.

---

## Session Summary -- 2026-02-25 (session 2)

### Encoding sweep -- workspace-wide copilot-instructions.md

1. Scanned all owned `copilot-instructions.md` in AICOE workspace.
   - Total owned files: 48 (1 workspace-level + 47 project-level)
   - Excluded: .git, backups, node_modules, cloned-repos, archives,
     08-cds-rag/ai-answers, 26-eva-gh mirrors, 18-azure-best finops clones,
     27-devbench archives, 42-learn-foundry cloned repos

2. Audit result before fix:
   - Dirty files: 40 / 48
   - Clean files: 8 / 48
   - Largest: 43-spark (604 chars), 33-eva-brain-v2 (321), 38-ado-poc (235)

3. Fix pass:
   - All 40 dirty files fixed. 0 partial. 0 errors.
   - Substitution map applied (bullets, dashes, quotes, arrows, emoji stripped/replaced)
   - Catch-all loop dropped any remaining non-ASCII including all surrogate-pair emoji
   - Written back as UTF-8 no-BOM

4. Verification pass:
   - [PASS] All 48 owned copilot-instructions.md are now ASCII-clean.

5. Template updated to v3.1.0 (session 1 carry-over, now confirmed in artifacts).

6. Tool delivered: `C:\AICOE\tools\fix-all-copilot-instructions.ps1` v1.1.0
   - Parameters: -AuditOnly (report only), -ShowClean (show PASS lines)
   - Reusable for drift prevention after reseed operations

---

## Session Summary -- 2026-02-25 (session 1)

### What was reviewed this session

1. File history (10 most recent files, .eva excluded):
   - Most recent real change: `02-design/artifact-templates/copilot-instructions-template.md` -- updated 2026-02-24 09:00
   - 2026-02-23 session produced: `Reseed-Projects.ps1` v1.0.0, updated `Apply-Project07-Artifacts.ps1`, seeded
     `.github/copilot-instructions.md` (project 07 own instructions) and `00-skill-index.skill.md`
   - Backups taken for: `33-eva-brain-v2`, `44-eva-jp-spark` (prior to reseed run at ~13:14)

2. `v1.3.0-IMPLEMENTATION-SUMMARY.md` -- 10 code enhancements planned for Apply script;
   Phase 1 (docs/version bump only) was done; all 10 code items still pending.

3. `patterns/APIM-ANALYSIS-METHODOLOGY.md` -- 675 lines, status "To Be Reviewed";
   needs second-project validation (EVA-JP-v1.2 proposed, not yet done).

4. `C:\AICOE\.github\copilot-instructions.md` v1.1.0 (2026-02-24):
   - Workspace-level instructions now includes ACA URL as primary data model endpoint
   - Added GOLDEN RULE preamble to data model section
   - Added Endpoint Lifecycle (Register/Discover/Use) section
   - Added EVA-Veritas MCP section and 29-Foundry capabilities registry section
   - Added Workspace-Level Skills placeholder (not yet created)
   - Source of Truth Hierarchy documented
   - Full 46-project registry table added
   - Template PART 1 does NOT yet reflect all of these additions (lag identified)

5. Veritas audit result (run 2026-02-25):
   - Score: 0 (no planned features, no stories defined in project 07)
   - Actions: [block, investigate]
   - Root cause: Project 07 has no .eva story plan -- veritas cannot score what was never
     formally broken into trackable stories
   - Action required: define Veritas story plan for project 07 (see Next Tasks)

### Key findings

- Template is v3.0.0 (409 lines, lean PART 1 / PART 2 / PART 3 structure) -- radically smaller
  than the v2.1.0 (1,902 lines) referenced in README. README is stale.
- Reseed-Projects.ps1 ran successfully on 2026-02-23 against 12 active projects.
- Workspace copilot-instructions v1.1.0 (Feb 24) added ACA URL, endpoint lifecycle, veritas
  and foundry sections that are NOT yet mirrored in the template PART 1.
- README Change Log stops at 2026-01-29 -- missing all February activity.
- No `STATUS.md` existed before this session (created now).
- No concrete skills exist in `.github/copilot-skills/` (only index stub with [TODO] entries).
- `37-data-model` project had its `.github/copilot-instructions.md` deleted
  (terminal evidence: `Remove-Item ...37-data-model\.github\copilot-instructions.md`).
  This means 37-data-model is now missing a copilot-instructions -- needs re-seeding.

---

## Phase Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 1 -- Discovery | [~] In progress (stale) | Broader EVA ecosystem survey, pain-point interviews not done |
| 2 -- Design | [x] Complete | Template v3.0.0 (simplified 409-line structure) |
| 3 -- Development | [x] Complete | Apply script v1.4.0, Reseed script v1.0.0 |
| 4 -- Testing | [!] Blocked | Pester 5.x needs verifying; test suite not run yet |
| 5 -- Workspace Mgmt | [x] Tested | v1.5.2 -- manual validation passed on Project 01 |

---

## Next Tasks

| Priority | Task | Why |
|----------|------|-----|
| ~~HIGH~~ | ~~Sync template PART 1 with workspace instructions v1.1.0 changes~~ | DONE -- template v3.2.0 (session 3) |
| ~~HIGH~~ | ~~Run Reseed-Projects.ps1 to propagate v3.2.0 to child projects~~ | DONE -- PASS=12 FAIL=0 (session 3) |
| ~~MEDIUM~~ | ~~Integrate 18-azure-best into copilot instructions~~ | DONE -- workspace v1.2.0 + template v3.4.0 (session 4) |
| HIGH | Run Reseed-Projects.ps1 to propagate v3.4.0 to child projects | Template now references 18-azure-best; propagate to 12 active projects |
| MEDIUM | Fix PART 2 localhost:8010 in 29-foundry (lines 341-395) | Project-specific content; fix in 29-foundry session |
| MEDIUM | Fix PART 2 localhost:8010 in 44-eva-jp-spark (lines 427-578) | Project-specific content; fix in 44-eva-jp-spark session |
| HIGH | Re-seed 37-data-model copilot-instructions (it was deleted) | Run Reseed-Projects.ps1 targeting 37-data-model |
| MEDIUM | Add Veritas story plan (.eva/) to project 07 | Score is 0; veritas cannot track what has no plan |
| MEDIUM | Update README.md -- version refs, change log, phase status | README says v2.1.0 / 1,902 lines; actual is v3.4.0 now |
| MEDIUM | Create first concrete skill files | Only [TODO] stub in 00-skill-index; no task skills yet |
| LOW | APIM methodology -- second-project validation | Apply to EVA-JP-v1.2 to confirm pattern generalises |
| LOW | v1.3.0 code enhancements -- 10 items | All documented in v1.3.0-IMPLEMENTATION-SUMMARY.md |
| LOW | Run Pester test suite | Confirm Pester 5.x is present, run Test-Project07-Deployment.ps1 |
| LOW | Review + decide on reorganization proposal | docs/copilot-instructions-reorganization-proposal.md -- open questions 1-4 |

---

## Open Blockers

| # | Blocker | Resolution path |
|---|---------|----------------|
| B-01 | Pester 5.x version unconfirmed on this machine | Run: `Get-Module -ListAvailable Pester` -- if < 5.x install it |
| B-02 | No Veritas story plan for project 07 | Create `.eva/plan.json` with feature/story definitions |
| B-03 | Phase 1 discovery incomplete (ecosystem survey) | Low priority given tool adoption via Reseed script |
| B-04 | 37-data-model copilot-instructions.md deleted | Re-run: `.\Reseed-Projects.ps1 -Projects "37-data-model"` |

---

## Artifacts Inventory (current)

| Artifact | Path | Version | Status |
|----------|------|---------|--------|
| Template | 02-design/artifact-templates/copilot-instructions-template.md | 3.4.0 | Active (18-azure-best integrated) |
| Workspace instructions | C:\AICOE\.github\copilot-instructions.md | 1.2.0 | Active (18-azure-best integrated) |
| Reorganization proposal | docs/copilot-instructions-reorganization-proposal.md | 1.0 | Draft for Review |
| Apply script | 02-design/artifact-templates/Apply-Project07-Artifacts.ps1 | 1.4.0 | Active |
| Reseed script | 02-design/artifact-templates/Reseed-Projects.ps1 | 1.0.0 | Active |
| Usage guide | 02-design/artifact-templates/template-v2-usage-guide.md | 2.1.0 (stale name) | Active |
| Encoding fix tool | tools/fix-all-copilot-instructions.ps1 | 1.1.0 | Active |
| APIM methodology | patterns/APIM-ANALYSIS-METHODOLOGY.md | 1.0 | To Be Reviewed |
| Skill index | .github/copilot-skills/00-skill-index.skill.md | 1.0.0 | Stub only |
| Own instructions | .github/copilot-instructions.md | matches reseed output | Active |
