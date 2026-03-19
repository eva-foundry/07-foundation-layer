# Project 07 Reorganization - EXECUTION PLAN (Corrected)

**Date**: March 7, 2026  
**Status**: DPDCA DO Phase - Ready to Execute

---

## CORRECTED INVENTORY

### Already in scripts/ (JUST ORGANIZE INTO SUBFOLDERS)
All 8 files already correctly located:
- `Add-ProjectLock.ps1`
- `gen-sprint-manifest.py`
- `invoke_command_with_log.py`
- `Invoke-CommandWithLog.ps1`
- `Push-CopilotInstructions.ps1`
- `reflect-ids.py`
- `run-push.bat`
- `seed-from-plan.py`

### In 02-design/artifact-templates/ (MOVE TO TOP-LEVEL OR ARCHIVE)

#### Production Automation (→ scripts/deployment/)
- Invoke-PrimeWorkspace.ps1
- Apply-Project07-Artifacts.ps1
- Apply-Project07-Artifacts-v1.4.1.ps1 (older version)
- Bootstrap-Project07.ps1
- Reseed-Projects.ps1

#### Utility Scripts (→ scripts/utilities/ or general)
- Capture-ProjectStructure.ps1
- Initialize-ProjectStructure.ps1
- Invoke-WorkspaceHousekeeping.ps1
- Fix-Project07-Paths.ps1

#### Testing (→ scripts/testing/)
- Test-Project07-Deployment.ps1

#### Templates (→ templates/)
- copilot-instructions-template.md
- copilot-instructions-workspace-template.md
- professional-runner-template.py
- data-model-seed-template.py
- supported-folder-structure-rag.json
- build-sprint-agent.yml.template
- Dockerfile.template

#### Reference/Guides (→ docs/ or templates/docs/)
- template-v2-usage-guide.md
- WORKSPACE-TEMPLATE-GUIDE.md
- PATH-FIX-IMPLEMENTATION-SUMMARY.md
- enhanced-find-function.txt

#### Archive (→ .archive/old-backups/)
- Apply-Project07-Artifacts.ps1.backup_20260202_115209
- Test-Project07-Deployment.ps1.backup_20260202_115209

---

## PHASE 1: Create Folder Structure

**Target**: Create organized subfolder hierarchy

```powershell
scripts/
  deployment/
  utilities/
  testing/
  planning/
  data-seeding/

templates/
  docker/

docs/
  architecture-decisions/
  discovery-reference/
  templates-guides/
  patterns/

.archive/
  session-37/
  diagnostics/
  testing-2026-01/
  empty-scaffolds/
  old-backups/
```

## PHASE 2: Move Active Scripts

Since most scripts are already in scripts/, just organize:

```
scripts/
├── deployment/
│   ├── Invoke-PrimeWorkspace.ps1                 (from 02-design)
│   ├── Apply-Project07-Artifacts.ps1             (from 02-design)
│   ├── Bootstrap-Project07.ps1                   (from 02-design)
│   ├── Push-CopilotInstructions.ps1              (keep)
│   └── run-push.bat                              (keep)
├── utilities/
│   ├── Add-ProjectLock.ps1                       (keep)
│   ├── Invoke-CommandWithLog.ps1                 (keep)
│   ├── invoke_command_with_log.py                (keep)
│   ├── reflect-ids.py                            (keep)
│   ├── Capture-ProjectStructure.ps1              (from 02-design)
│   ├── Initialize-ProjectStructure.ps1           (from 02-design)
│   ├── Invoke-WorkspaceHousekeeping.ps1          (from 02-design)
│   ├── Fix-Project07-Paths.ps1                   (from 02-design)
│   └── Reseed-Projects.ps1                       (from 02-design)
├── data-seeding/
│   └── seed-from-plan.py                         (keep)
├── planning/
│   └── gen-sprint-manifest.py                    (keep)
└── testing/
    └── Test-Project07-Deployment.ps1             (from 02-design)
```

## PHASE 2b: Move Templates

```
templates/
├── copilot-instructions-template.md
├── copilot-instructions-workspace-template.md
├── professional-runner-template.py
├── data-model-seed-template.py
├── supported-folder-structure-rag.json
├── build-sprint-agent.yml.template
├── docker/
│   └── Dockerfile.template
└── docs/
    ├── template-v2-usage-guide.md
    ├── WORKSPACE-TEMPLATE-GUIDE.md
    └── PATH-FIX-IMPLEMENTATION-SUMMARY.md
```

## PHASE 3: Archive

```
.archive/
├── session-37/
│   ├── SESSION-37-COMPLETION-STATUS.md
│   ├── SESSION-37-REPRIMING-GUIDE.md
│   ├── SESSION-37-UPDATE-SUMMARY.md
│   ├── INSTRUCTION-QUALITY-ASSESSMENT.md
│   └── PROPOSED-INSTRUCTION-CHANGES.md
├── diagnostics/
│   ├── CLOUD-ENDPOINT-TIMEOUT-INVESTIGATION.md
│   ├── ENDPOINT-VERIFICATION-COMPLETE.md
│   ├── analyze_endpoints.ps1
│   └── verify_endpoints.ps1
├── testing-2026-01/
│   └── (all files from 04-testing/results/)
├── empty-scaffolds/
│   ├── 03-development/
│   └── 05-implementation/
└── old-backups/
    ├── Apply-Project07-Artifacts.ps1.backup_20260202_115209
    ├── Test-Project07-Deployment.ps1.backup_20260202_115209
    └── Apply-Project07-Artifacts-v1.4.1.ps1
```

## PHASE 4: Move Docs (from DPDCA folders)

```
docs/
├── architecture-decisions/
│   ├── ADR-004-Professional-Transformation-Methodology.md
│   └── ADR-005-Dependency-Management-Strategy.md
├── discovery-reference/
│   ├── artifacts-inventory.md
│   ├── current-state-assessment.md
│   ├── gap-analysis.md
│   ├── assessment-framework.md
│   ├── pattern-application-methodology.md
│   ├── PYTHON-DEPENDENCY-MANAGEMENT.md
│   └── discovery-summary.md
└── patterns/
    (from patterns/ folder if non-empty)
```

---

## Files Summary for Execution

**Phase 1**: Create 10 new folders
**Phase 2**: Move ~35 files from 02-design/ and reorganize scripts/
**Phase 3**: Move ~20 files to .archive/
**Phase 4**: Move discovery + ADR docs
**CHECK**: Verify Git history preserved
**ACT**: Update README, fix broken links

---

## Ready to Execute?

✅ **DISCOVER**: Complete - All 55 items inventoried  
✅ **PLAN**: Documented above  
?  **DO**: Ready to start if approved  
?  **CHECK**: Will verify structure & no broken links  
?  **ACT**: Will update entry points  

**Confirm to proceed with DO phase?**
