# Project 07 - Reorganization & Streamlining Proposal

**Prepared**: March 7, 2026  
**Analysis Scope**: scripts/, .github/, 01-05 DPDCA folders  
**Objective**: Clarity, maintainability, value extraction

---

## Current State Analysis

### SCRIPTS/ (Active, Production-Critical)

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| `seed-from-plan.py` | 311 | Data model seeding from PLAN.md | ✅ ACTIVE |
| `Invoke-CommandWithLog.ps1` | 173 | Logged command execution | ✅ ACTIVE |
| `invoke_command_with_log.py` | 194 | Python variant | ✅ ACTIVE |
| `gen-sprint-manifest.py` | 210 | Sprint planning automation | ✅ ACTIVE |
| `reflect-ids.py` | 187 | Story/task ID reflection | ✅ ACTIVE |
| `Add-ProjectLock.ps1` | 100 | Lock file management | ✅ ACTIVE |
| `Push-CopilotInstructions.ps1` | 72 | Template sync utility | ✅ ACTIVE |
| `run-push.bat` | 3 | Batch wrapper | ⚠️ LOW-VALUE |

**Verdict**: ALL KEEP (current structure is fine, maybe organize by function)

---

### .GITHUB/ (Complex Mix)

#### Tier 1: ACTIVE Core Files (KEEP)
- `copilot-instructions.md` - Session 37, authoritative
- `PROJECT-COPILOT-INSTRUCTIONS-TEMPLATE.md` - v3.4.0, production template
- `BOOTSTRAP-API-FIRST.md` - Reference for API-first bootstrap pattern
- `copilot-skills/` - 3 production skills (foundation-expert, universal-command-wrapper, skill-index)
- `workflows/discussion-bot-agent.yml` - GitHub Actions, active sprint agent
- `discussion_templates/sprint-planning.yml` - Sprint discussion template

#### Tier 2: ARCHIVAL Candidates (.archive/)
These are Session 37 completion docs—valuable history but not operational:

| File | Purpose | Archive? |
|------|---------|----------|
| `SESSION-37-COMPLETION-STATUS.md` | Validation checklist | YES - Completion artifact |
| `SESSION-37-REPRIMING-GUIDE.md` | Automation scripts reference | YES - Reference guide (for one-time use) |
| `SESSION-37-UPDATE-SUMMARY.md` | What changed in S37 | YES - Historical summary |
| `SESSION-38-DISCOVER-PLAN.md` | Discovering S38 work | MAYBE - If S38 is underway |
| `INSTRUCTION-QUALITY-ASSESSMENT.md` | Assessment report | YES - Diagnostic report |
| `PROPOSED-INSTRUCTION-CHANGES.md` | Proposal document | YES - After decision made |

**Verdict**: Move all Tier 2 to `.archive/session-37/` for historical record-keeping

---

### DPDCA FOLDERS (Scaffolding + Reference)

#### 01-DISCOVERY (8 files, 0.2 MB)

| File | Purpose | Audience | Keep? |
|------|---------|----------|-------|
| `artifacts-inventory.md` | What artifacts exist | Internal reference | ✅ YES |
| `current-state-assessment.md` | Starting baseline | Historical | ✅ YES |
| `gap-analysis.md` | What's missing | Strategic planning | ✅ YES |
| `assessment-framework.md` | How to evaluate | Methodology | ✅ YES |
| `pattern-application-methodology.md` | Application process | Operational | ✅ YES |
| `PYTHON-DEPENDENCY-MANAGEMENT.md` | Python setup | Reference | ✅ YES |
| `discovery-summary.md` | Executive summary | Historical | ✅ YES |
| `README.md` | Navigation | **KEEP** |

**Verdict**: All valuable as reference. Keep but move to `docs/01-discovery-reference/`

---

#### 02-DESIGN (103 files, 0.88 MB)

**CRITICAL OBSERVATION**: This folder contains production templates!

##### Subfolder: `artifact-templates/` (30+ files)

| Category | Files | Status | Verdict |
|----------|-------|--------|---------|
| **Core Automation** | Invoke-PrimeWorkspace.ps1, Apply-Project07-Artifacts.ps1 | ✅ PRODUCTION | MOVE TO scripts/ |
| **Templates** | copilot-instructions-template.md, professional-runner-template.py | ✅ PRODUCTION | MOVE TO scripts/ or docs/templates/ |
| **Configuration** | eva-factory.config.yaml (if here), supported-folder-structure-rag.json | ✅ PRODUCTION | MOVE TO scripts/ or root config/ |
| **Backup/Testing** | *.backup, Test-Project07-Deployment.ps1 | ⚠️ TRANSIENT | CONSIDER ARCHIVING |

##### Subfolder: `architecture-decision-records/` (2 files)

| File | Purpose | Status |
|------|---------|--------|
| ADR-004-Professional-Transformation-Methodology.md | Architecture decision | ✅ KEEP |
| ADR-005-Dependency-Management-Strategy.md | Architecture decision | ✅ KEEP |

**Verdict**: 
- Move `artifact-templates/` → `templates/` (top-level or docs/)
- Archive old backups and test results
- Keep ADRs in `docs/architecture-decisions/`

---

#### 03-DEVELOPMENT (1 file)
- `README.md` — Only content
- **Verdict**: Empty scaffold. Archive entirely or delete.

---

#### 04-TESTING (4 files, 0.03 MB)

| File | Purpose | Age | Keep? |
|------|---------|-----|-------|
| `manual-test-workspace-mgmt.ps1` | Test script | Current | ✅ YES |
| `test-results-workspace-mgmt-v1.0.0.md` | Results summary | Historical | ✅ YES |
| `results/` folder (4 old dry-runs) | Test artifacts | 1/30/2026 | ⚠️ ARCHIVE |

**Verdict**: 
- Keep test scripts in `tests/`
- Archive old `results/` folder
- Move results to `.archive/testing-2026-01/`

---

#### 05-IMPLEMENTATION (2 items)

| Item | Purpose | Keep? |
|------|---------|-------|
| `README.md` | Navigation | ✅ YES |
| `archive/` | Contains 1 old file (copilot-instructions-ORIGINAL) | ARCHIVE |

**Verdict**: Entire folder is scaffold. Archive or consolidate.

---

## Proposed New Structure

```
07-foundation-layer/
├── .github/
│   ├── copilot-instructions.md              [ACTIVE]
│   ├── copilot-skills/
│   │   ├── 00-skill-index.skill.md
│   │   ├── foundation-expert.skill.md
│   │   └── universal-command-wrapper.skill.md
│   ├── workflows/
│   │   └── discussion-bot-agent.yml
│   ├── discussion_templates/
│   │   └── sprint-planning.yml
│   ├── .archive/session-37/                 [SESSION 37 DOCS]
│   │   ├── SESSION-37-COMPLETION-STATUS.md
│   │   ├── SESSION-37-REPRIMING-GUIDE.md
│   │   ├── SESSION-37-UPDATE-SUMMARY.md
│   │   ├── INSTRUCTION-QUALITY-ASSESSMENT.md
│   │   ├── PROPOSED-INSTRUCTION-CHANGES.md
│   │   └── BOOTSTRAP-API-FIRST.md (reference copy)
│   └── reference/                           [REFERENCE DOCS]
│       ├── PROJECT-COPILOT-INSTRUCTIONS-TEMPLATE.md
│       └── BOOTSTRAP-API-FIRST.md
│
├── scripts/                                 [PRODUCTION AUTOMATION]
│   ├── deployment/
│   │   ├── Invoke-PrimeWorkspace.ps1
│   │   ├── Apply-Project07-Artifacts.ps1
│   │   ├── Bootstrap-Project07.ps1
│   │   └── Push-CopilotInstructions.ps1
│   ├── data-seeding/
│   │   └── seed-from-plan.py
│   ├── utilities/
│   │   ├── Invoke-CommandWithLog.ps1
│   │   ├── invoke_command_with_log.py
│   │   ├── Add-ProjectLock.ps1
│   │   └── reflect-ids.py
│   └── planning/
│       └── gen-sprint-manifest.py
│
├── templates/                               [PRODUCTION TEMPLATES - NEW]
│   ├── copilot-instructions-template.md
│   ├── professional-runner-template.py
│   ├── supported-folder-structure-rag.json
│   └── docker/
│       └── Dockerfile.template
│
├── docs/                                    [REFERENCE & DISCOVERY]
│   ├── architecture-decisions/
│   │   ├── ADR-004-Professional-Transformation-Methodology.md
│   │   └── ADR-005-Dependency-Management-Strategy.md
│   ├── discovery-reference/                [FROM 01-DISCOVERY]
│   │   ├── artifacts-inventory.md
│   │   ├── current-state-assessment.md
│   │   ├── gap-analysis.md
│   │   └── [... others ...]
│   ├── patterns/                           [FROM patterns/ - if not empty]
│   └── README.md
│
├── tests/                                   [TESTING]
│   ├── manual-test-workspace-mgmt.ps1
│   ├── test-results-workspace-mgmt-v1.0.0.md
│   └── README.md
│
├── .archive/                                [ARCHIVED ITEMS]
│   ├── session-37/                          [Session 37 docs]
│   ├── diagnostics/                         [Old endpoint investigations]
│   ├── testing-2026-01/                     [Old test results]
│   ├── 05-implementation/                   [Empty scaffold]
│   ├── 03-development/                      [Empty scaffold]
│   ├── 15-cdc/                              [Misplaced]
│   └── MANIFEST.md
│
├── github-discussion-agent/                 [REVIEW NEEDED]
│   ├── agent.py
│   ├── README.md
│   └── QUICKSTART.md
│
├── ACCEPTANCE.md                            [GOVERNANCE]
├── PLAN.md                                  [GOVERNANCE]
├── STATUS.md                                [GOVERNANCE]
├── CHANGELOG.md                             [GOVERNANCE]
└── README.md                                [ENTRY POINT]
```

---

## Action Items (Priority Order)

### Phase 1: Immediate Cleanup (< 30 min)

- [ ] Create `scripts/deployment/`, `scripts/data-seeding/`, `scripts/utilities/`, `scripts/planning/`
- [ ] Create `templates/docker/`
- [ ] Create `docs/architecture-decisions/`, `docs/discovery-reference/`
- [ ] Create `.archive/session-37/`, `.archive/diagnostics/`, `.archive/testing-2026-01/`

### Phase 2: Move Active Content (< 10 min)

**Scripts** (from 02-design/artifact-templates/ → scripts/):
- `Invoke-PrimeWorkspace.ps1` → scripts/deployment/
- `Apply-Project07-Artifacts.ps1` → scripts/deployment/
- `Bootstrap-Project07.ps1` → scripts/deployment/
- `seed-from-plan.py` → scripts/data-seeding/
- `Invoke-CommandWithLog.ps1` → scripts/utilities/
- `invoke_command_with_log.py` → scripts/utilities/
- `Add-ProjectLock.ps1` → scripts/utilities/
- `reflect-ids.py` → scripts/utilities/
- `gen-sprint-manifest.py` → scripts/planning/

**Templates** (from 02-design/artifact-templates/ → templates/):
- `copilot-instructions-template.md`
- `professional-runner-template.py`
- `supported-folder-structure-rag.json`
- `Dockerfile.template` → templates/docker/

**Docs** (from 01-discovery/ → docs/discovery-reference/):
- All .md files except README.md

**ADRs** (from 02-design/architecture-decision-records/ → docs/architecture-decisions/):
- Both ADR files

### Phase 3: Archive Obsolete Content (< 5 min)

**To .archive/session-37/:**
- SESSION-37-COMPLETION-STATUS.md
- SESSION-37-REPRIMING-GUIDE.md
- SESSION-37-UPDATE-SUMMARY.md
- INSTRUCTION-QUALITY-ASSESSMENT.md
- PROPOSED-INSTRUCTION-CHANGES.md

**To .archive/diagnostics/:**
- CLOUD-ENDPOINT-TIMEOUT-INVESTIGATION.md
- ENDPOINT-VERIFICATION-COMPLETE.md
- analyze_endpoints.ps1
- verify_endpoints.ps1

**To .archive/testing-2026-01/:**
- 04-testing/results/ (all old dry-runs)

**To .archive/empty-scaffolds/:**
- 03-development/
- 05-implementation/

### Phase 4: Decision Points

- [ ] **github-discussion-agent/** — Keep or relocate to own project (40-github-discussion-agent)?
- [ ] **run-push.bat** — Delete or keep for legacy shell access?
- [ ] **mcp-server/** folder — Functionality status? (Not examined yet)
- [ ] **patterns/** folder — Content status? (Not examined yet)

---

## Benefits of Proposed Reorganization

| Benefit | Current | Proposed |
|---------|---------|----------|
| **Script findability** | Mixed in 02-design/artifact-templates/ | Organized by function in scripts/ |
| **Template access** | Buried in 02-design/ | Visible in top-level templates/ |
| **Docs clarity** | Scattered across DPDCA folders | Consolidated in docs/ |
| **Archive policy** | Unclear | Explicit .archive structure |
| **Onboarding time** | 15+ min to find things | < 5 min |
| **Maintenance overhead** | High (unclear structure) | Low (clear intent) |

---

## Implementation Notes

- All moves preserve git history (use `git mv` for version control)
- Keep 02-design/ as reference folder (or delete entirely after migration)
- Update README.md entry points for new structure
- Update any internal doc links (scripts, templates) that reference old paths

---

## Low-Value Items Recommended for Archive

**Already archived** (this session):
- v1.3.0-IMPLEMENTATION-SUMMARY.md
- IMPLEMENTATION-COMPLETE-v1.5.2.md
- PHASE-3-IMPLEMENTATION-COMPLETE.md
- PREVIEW-Project14.md
- 15-cdc/ folder

**Recommend archiving** (Phase 3):
- All files in SESSION-37-* (completion artifacts)
- All diagnostic investigation files
- Empty DPDCA scaffold folders (03-dev, 05-impl)
- Old test dry-runs
- Old backup files (*.backup_*)

---

## Decision Required

**Ready to proceed with Phase 1-3?** (Low-risk reorganization)

OR

**Hold for Phase 4 review first?** (Verify github-discussion-agent, mcp-server, patterns use)
