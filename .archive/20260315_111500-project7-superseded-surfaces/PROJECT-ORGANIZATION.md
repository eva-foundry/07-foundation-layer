<!-- eva-primed-organization -->

# 07-foundation-layer - Organization Standards

**Version**: v5.0.0 (Session 44 - Comprehensive Cleanup)
**Primed**: 2026-03-10 by agent:copilot (Session 44)
**Status**: Canonical scaffold for folder structure and file placement

---

## Root-Level Rules

Keep root minimal. Use root for governance and entry-point files only:
- `README.md`, `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`, `CHANGELOG.md`
- `.gitignore`, `requirements.txt`
- `.github/`, `docs/`, `scripts/`, `tests/`, `templates/`, `.archive/`

Move operational outputs out of root:
- Session artifacts MUST go to `docs/sessions/` (not root)
- Temporary logs → `.archive/logs/`
- Historical backups → `.archive/backups/`

---

## Target Folder Structure

```text
07-foundation-layer/
├── .github/
│   ├── copilot-instructions.md     # Project-level agent guidance (v5.0.0)
│   ├── copilot-skills/             # 6 workspace skills
│   └── workflows/                   # GitHub Actions (future)
│
├── scripts/
│   ├── deployment/                  # Invoke-PrimeWorkspace.ps1, Apply-Project07-Artifacts.ps1
│   ├── utilities/                   # Add-ProjectLock.ps1, Fix-Project07-Paths.ps1
│   ├── testing/                     # Test-PrimingCompatibility.ps1
│   ├── planning/                    # Sprint automation scripts
│   └── data-seeding/                # Data model seeding scripts
│
├── templates/
│   ├── copilot-instructions-template.md  # v5.0.0 project template
│   ├── governance/                       # 5 governance templates (PLAN, STATUS, ACCEPTANCE, README-header, PROJECT-ORGANIZATION)
│   ├── professional-runner-template.py   # Python scaffold
│   ├── supported-folder-structure-rag.json
│   └── docs/                             # Template usage guides
│
├── docs/
│   ├── sessions/                    # Session notes and reports (from .github cleanup)
│   ├── architecture-decisions/      # ADRs (future)
│   └── patterns/                    # Design patterns (future)
│
├── .archive/
│   ├── session-37/                  # Session 37 completion docs
│   ├── session-38/                  # Session 38 reorganization docs
│   ├── planning/                    # Historical proposals
│   ├── prototypes/                  # mcp-server (deprecated)
│   ├── old-backups/                 # Version backups
│   ├── diagnostics/                 # Diagnostic reports
│   └── testing-2026-01/             # Old test results
│
├── tests/
│   └── test-bootstrap-api.py        # Bootstrap API validation
│
├── .venv/                            # Python virtual environment (gitignored)
├── github-discussion-agent/          # Active: Discussion-based agent prototype
├── patterns/                         # APIM analysis pattern (under validation)
│
├── README.md                         # Project overview
├── PLAN.md                           # Sprint plan (v5.0.0 format)
├── STATUS.md                         # Progress tracking (v5.0.0 format)
├── ACCEPTANCE.md                     # Quality gates (v5.0.0 format)
├── CHANGELOG.md                      # Version history
└── PROJECT-ORGANIZATION.md           # This file
```

---

## Fractal DPDCA For Reorganization

Project 07 applied Fractal DPDCA across 4 major sweeps (Session 44):

### Sweep #1: Workspace .github Cleanup
- **DISCOVER**: Found 16 files (13 session artifacts + 3 design docs)
- **PLAN**: Move to 97-workspace-notes/docs/sessions/ and docs/
- **DO**: Executed moves with git mv
- **CHECK**: Verified .github clean (7 items remain)
- **ACT**: Updated workspace instructions

### Sweep #2: Project 07 .github Cleanup  
- **DISCOVER**: Found 8 files (6 session artifacts + 2 reference docs)
- **PLAN**: Move to docs/sessions/
- **DO**: Executed moves
- **CHECK**: Verified .github clean (4 items: copilot-instructions.md + copilot-skills/)
- **ACT**: Updated skill index to v2.0.0

### Sweep #3: Pre-Priming Audit & Remediation
- **DISCOVER**: Audited 15 templates + 20 scripts
- **PLAN**: Identified 8 issues (3 critical + 5 moderate + 2 minor)
- **DO**: Fixed version refs (4.2.0→5.0.0), removed invalid paths, added best practices
- **CHECK**: Verified all scripts production-ready
- **ACT**: Updated all templates to v5.0.0

### Sweep #4: Comprehensive Directory Cleanup
- **DISCOVER**: Analyzed 1,358 files across 11 directories
- **PLAN**: Archive 25 files in 3 locations
- **DO**: Created .archive/session-38/, planning/, prototypes/
- **CHECK**: Verified root has only 5 governance files
- **ACT**: Updated .archive/MANIFEST.md, persisted to memory

---

## Hybrid Paperless Governance (REQUIRED)

This project uses **mandatory hybrid governance** with Data Model API:

**Pre-Flight Requirement**:
- Priming requires EVA Data Model API to be available
- Pre-flight check: `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/health`
- Priming fails if API unavailable (10-second timeout)

**File-Based (Backward Compatible)**:
- Local PLAN.md, STATUS.md, ACCEPTANCE.md files maintained
- Traditional git-based workflow preserved
- Works offline after initial prime

**API-First (Single Source of Truth)**:
- All governance queries prefer Data Model API
- Live layer count: 91 operational (87 base + 4 execution)
- 6 category runbooks: session_tracking, sprint_tracking, evidence_tracking, governance_events, infra_observability, ontology_domains
- API endpoint: https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io

**Write-Back Pattern** (Paperless DPDCA):
- Project 48 (EVA Veritas) writes MTI scores to project_work layer (L46)
- Verification records persist to verification_records layer (L45)
- Quality gates evaluation to quality_gates layer (L34)

---

## Key Architecture Decisions

### 1. Template Version Evolution
- v3.4.0 (Session 37): Bootstrap checkpoint implementation
- v4.2.0 → v4.3.0 (Session 42-43): Paperless DPDCA integration
- v5.0.0 (Session 44): Bootstrap enforcement + template consolidation

**Rationale**: Synchronized versioning prevents CHECK phase failures during workspace-wide priming.

### 2. Scripts Organization by Purpose
- `deployment/`: Workspace-level operations (Invoke-PrimeWorkspace.ps1, Apply-Project07-Artifacts.ps1)
- `utilities/`: Supporting tools (Add-ProjectLock.ps1, Fix-Project07-Paths.ps1)
- `testing/`: Quality validation (Test-PrimingCompatibility.ps1)
- `planning/`: Sprint automation (future)
- `data-seeding/`: Data model initialization (future)

**Rationale**: Semantic organization enables agent discovery and role-based navigation.

### 3. Two-Tier Template System
- **Workspace Template**: `templates/copilot-instructions-template.md` (line 1 bootstrap checkpoint)
- **Project Templates**: `templates/governance/` (5 files: PLAN, STATUS, ACCEPTANCE, README-header, PROJECT-ORGANIZATION)

**Rationale**: Separates universal patterns (PART 1) from project-specific content (PART 2).

### 4. PROJECT-ORGANIZATION Template Enhancement (Session 44)
**Evolution**: 149 lines → 290 lines (comprehensive scaffold)

**Additions**:
- **Fractal DPDCA For Project Implementation**: Multi-phase examples (Foundation → Core → Enhancement → Production)
- **Key Architecture Decisions**: Template with examples (technology stack, patterns)
- **Integration Patterns**: Template with code examples (pipelines, event-driven, queries)
- **Standards Compliance**: Project-specific variables (language, cloud, security)
- **Lessons Learned**: Structured format for capturing insights

**Rationale**: Every project deserves comprehensive organization guidance, not just folder structure. Template now provides actionable patterns that projects can customize rather than creating from scratch.

**Impact**: Future priming operations will scaffold complete PROJECT-ORGANIZATION.md with all sections pre-populated with examples and placeholders.

### 5. Archive Strategy
Session artifacts moved immediately after completion (not accumulated at root).

**Structure**:
- `session-XX/`: Time-bound session deliverables
- `planning/`: Strategic proposals and designs
- `prototypes/`: Experimental code (superseded)
- `old-backups/`, `diagnostics/`, `testing-YYYY-MM/`: Historical references

**Rationale**: Clean root directory focuses attention on active governance documentation.

### 6. Bootstrap Enforcement (Triple-Defense)
Checkpoint at line 1 of **all** instruction files:
1. Workspace `.github/copilot-instructions.md`
2. Project `.github/copilot-instructions.md` 
3. Template `copilot-instructions-template.md`

**Rationale**: Prevents agent sessions from skipping mandatory API bootstrap sequence.

---

## Integration Patterns

### Pattern 1: Workspace Priming
```powershell
# Single project (dry-run)
.\scripts\deployment\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\14-az-finops" -DryRun

# All 57 projects
.\scripts\deployment\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry"
```

**Outputs**:
- `.github/copilot-instructions.md` (PART 1 + PART 2)
- `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md` (v5.0.0 format)
- `PROJECT-ORGANIZATION.md` (scaffold)
- `.eva/fractal-dpdca-evidence.json` (audit trail)

### Pattern 2: Data Model Seeding
```powershell
# Placeholder for future seeding patterns
# Will document seed-from-plan.py generalization
```

### Pattern 3: Governance Consistency Audits
```powershell
# Placeholder for Test-GovernanceConsistency.ps1
# Will validate version alignment across workspace
```

---

## Standards Compliance

**Template Versions**: All governance templates at v5.0.0
**Script Versions**: Invoke-PrimeWorkspace.ps1 v2.0.0, Apply-Project07-Artifacts.ps1 (enhanced with Fractal DPDCA)
**Bootstrap Protocol**: Mandatory API-first with fail-closed semantics
**Path References**: No eva-foundation\ or 29-foundry references
**Documentation**: Session artifacts in docs/sessions/, not root

---

## Lessons Learned (Session 44)

1. **Version Fragmentation is Cascading**: Scripts referencing v4.2.0 while templates at v5.0.0 would cause CHECK phase failures across all 57 primed projects.

2. **Template Content Propagates**: Broken paths in templates (29-foundry) would infect every newly primed project.

3. **Bootstrap Enforcement Must Be Hard-Stop**: Optional guidance gets ignored. Line 1 checkpoint with fail-closed is required.

4. **Session Artifacts Must Move Immediately**: Accumulating 25+ files at root obscures governance documentation.

5. **Fractal DPDCA Prevents Batch Failures**: Per-file, per-component validation catches issues before they propagate.

---

*Template v5.0.0 (Session 44 - Bootstrap Enforcement & Governance Consolidation)*
