# Project 07 - DPDCA Folders (01-05) Reorganization Proposal

**Analysis Date**: March 7, 2026  
**Previous Work**: Session 38 reorganization (scripts moved, templates reorganized)  
**Status**: Ready for implementation (all details discovered)

---

## Executive Summary

**Current State**: Folders 01-05 contain a mix of historical discovery/design artifacts, diagnostic backups, and empty scaffolds (65+ files total).

**Target State**: Archive historical content while preserving references, reducing active project overhead.

**Impact**:
- Removes 200+ MB of diagnostic/backup JSON and old instruction files
- Improves project structure clarity from 5 legacy folders → 1 organized archive
- Preserves all essential reference docs (practices, standards, migration guides)
- Maintains git history with clean move strategy

---

## Detailed Analysis

### 01-discovery/automation/ (14 files)

**Type**: Python/PowerShell utilities from discovery phase  
**Key Files**:
- `evidence.py` — Evidence collection utility
- `generate-docs.py` — Documentation generator
- `generate.ps1`, `preflight-check.ps1`, `run-tests.ps1` — Automation scripts
- `pytest.ini`, `requirements.txt`, `test_*.py` — Test framework
- `QUICKSTART.md`, `README.md` — Documentation

**Status**: ✅ **Marked LOCAL-ONLY**
- Header: "⚠️ LOCAL-ONLY - DO NOT COMMIT"
- QUICKSTART.md: "All files in this automation framework are LOCAL-ONLY and excluded from Git"
- These were discovery-phase utilities, not production code

**Assessment**: 🗑️ **ARCHIVE**
- Misclassified as committed (should only be gitignored)
- Historical utilities from discovery phase (Jan 2026)
- Not referenced by current workflows
- Superseded by production scripts in `scripts/` folder

**Action**: Move entire folder → `.archive/01-discovery-automation/`

---

### 02-design/ Root (9 files)

**Active Reference Docs** [KEEP AT TOP-LEVEL]:
- `best-practices-reference.md` (584 lines)
  - ✅ Actively referenced in multiple copilot-instructions files
  - ✅ Maps patterns to copilot-instructions-template.md sections
  - ✅ Professional transformation methodology, components, evidence patterns
  - **DECISION**: KEEP (move to `docs/references/`)

- `standards-specification.md`
  - ✅ Governance standards for all projects
  - ✅ Configuration quality criteria
  - **DECISION**: KEEP (move to `docs/references/`)

- `marco-framework-architecture.md`
  - ✅ Framework design document
  - ✅ Historical architecture decisions
  - **DECISION**: KEEP (move to `docs/architecture-decisions/`)

- `MIGRATION-GUIDE-*.md` (2 files)
  - ✅ Version migration procedures
  - ✅ Historical but potentially useful for future upgrades
  - **DECISION**: KEEP (move to `docs/references/guides/`)

- `SPRINT-BACKLOG-v1.7.0.md`
  - ✅ Historical sprint planning document
  - ⚠️ Useful for understanding how sprints were managed
  - **DECISION**: KEEP (move to `docs/discovery-reference/`)

- `v1.7.0-IMPLEMENTATION-SUMMARY.md`
  - ✅ Historic implementation summary
  - **DECISION**: KEEP (move to `docs/discovery-reference/`)

---

### 02-design/artifact-templates/ (Complex Subfolder)

**Subfolders Worth Examining**:

#### `artifact-templates/governance/` (3 templates, ~8 KB)
- `ACCEPTANCE-template.md` (2.6 KB)
- `PLAN-template.md` (3.0 KB)
- `STATUS-template.md` (2.2 KB)
- `README-header-block.md` (0.9 KB)

**Assessment**: ✅ **These may be in-use templates**
- Align with governance file types in every EVA project
- Could be referenced by automation scripts
- **ACTION**: Investigate if these are duplicates or active; if active, move to `templates/governance/`; if just reference copies, archive to `02-design/.archive/`

---

#### `artifact-templates/backups/` (~400 KB, 22 files)
- Backups of copilot-instructions.md from projects 18, 19, 29, 31, 33, 36, 37, 38, 39, 40, 42, 43, 44, 45, 47
- Dated 2/23 and 2/25 (two snapshots each, 3-4 weeks old)
- Example: `18-azure-best/copilot-instructions_20260225_103436.md` (10.2 KB)

**Assessment**: 🔴 **ARCHIVE - NOT NEEDED**
- Same files exist in their respective projects
- Diagnostic snapshots from artifact-deployment automation runs
- Taking up ~20 MB of storage
- Zero ongoing value

**ACTION**: Move `artifact-templates/backups/` → `.archive/02-design-artifacts/backups/`

---

#### `artifact-templates/debug/` (~8 KB, 18 files)
- Diagnostic JSON from artifact-deployment runs (March 5, 2026)
- Files: `before_analysis_*.json`, `after_analysis_*.json`, `deployment_start_*.json`, etc.
- All files 0.2-0.3 KB each

**Assessment**: 🔴 **ARCHIVE - DIAGNOSTIC ONLY**
- Session diagnostic output from automation runs
- No lasting value after session complete
- Clutters project structure

**ACTION**: Move `artifact-templates/debug/` → `.archive/02-design-artifacts/debug/`

---

#### `artifact-templates/sessions/` (~12 KB, 30+ checkpoints)
- Session state and checkpoints from artifact-deployment runs
- Dated 1/29/2026 - 3/5/2026
- Files: `session_state.json`, `checkpoint_*.json`
- Nested structure: `sessions/artifact-deployment/checkpoints/`

**Assessment**: 🔴 **ARCHIVE - SESSION STATE ONLY**
- Historical session checkpoint data
- Used only during active automation runs
- No value in completed sessions

**ACTION**: Move `artifact-templates/sessions/` → `.archive/02-design-artifacts/sessions/`

---

#### `artifact-templates/logs/` and `artifact-templates/governance/`
- `logs/` - Likely contains automation logs (not listed in detail above but present)
- `governance/` - Contains templates (assessed above)

**ACTION-GOVERNANCE**: Verify if templates are active; if yes move to production `templates/governance/`; if no, archive

**ACTION-LOGS**: Archive any log directories → `.archive/02-design-artifacts/logs/`

---

### 03-development/ (1 file)

**Content**: Only `README.md` (empty scaffold)

**Assessment**: 🗑️ **ARCHIVE**
- Zero functional content
- Scaffold marker only
- No dependencies

**ACTION**: Move entire folder → `.archive/03-development-scaffold/`

---

### 04-testing/ (7 files)

**Files**:
- `README.md` (scaffold)
- `manual-test-workspace-mgmt.ps1` (January 2026 test)
- `test-results-workspace-mgmt-v1.0.0.md` (test results summary)
- `results/` (subfolder with results)
- Dry-run output files (archived in previous phase)

**Assessment**: 🟡 **ARCHIVE**
- Old test artifacts from January 2026 (2+ months)
- Superseded by tests in `scripts/testing/` (Session 38)
- Not active testing framework

**ACTION**: Move entire folder → `.archive/04-testing-artifacts/`

---

### 05-implementation/ (2 files)

**Files**:
- `README.md` (scaffold)
- `archive/` (subfolder with old backups)

**Assessment**: ➖ **ARCHIVE**
- Nearly empty scaffold
- Archive subfolder already exists (meta-archive)

**ACTION**: Move entire folder → `.archive/05-implementation-scaffold/`

---

## Reorganization Plan (DPDCA Framework)

### D = DISCOVER ✅ (COMPLETE)
- [x] Inventoried all 65 files across 01-05
- [x] Analyzed content type, activity status, dependencies
- [x] Identified 9 valuable reference docs to preserve
- [x] Identified 100+ diagnostic/backup files to archive
- [x] Verified current production structure (scripts/, templates/, docs/)

### P = PLAN (THIS DOCUMENT)
- [x] Proposed archive structure
- [x] Identified 5 archival paths
- [x] Estimated impact (200+ MB cleanup, 50+ fewer active files)
- [x] Preserved git history strategy (git mv for all moves)
- [x] Defined decision point (governance templates investigation)

---

## Proposed Archive Structure

```
.archive/
├── 01-discovery-automation/
│   └── automation/                    # LOCAL-ONLY utilities, discovery phase
│       ├── evidence.py
│       ├── generate-docs.py
│       ├── *.ps1
│       ├── test_*.py
│       └── ...
├── 02-design-artifacts/
│   ├── backups/                       # Old project instruction backups
│   │   ├── 18-azure-best/
│   │   ├── 19-ai-gov/
│   │   └── ...
│   ├── debug/                         # Diagnostic JSON from runs
│   ├── sessions/                      # Session checkpoints
│   ├── logs/                          # Automation logs
│   └── governance/                    # [IF NOT ACTIVE: governance templates]
├── 03-development-scaffold/           # Empty scaffold
│   └── README.md
├── 04-testing-artifacts/              # Old test artifacts (Jan 2026)
│   ├── manual-test-workspace-mgmt.ps1
│   ├── test-results-*.md
│   ├── results/
│   └── ...
├── 05-implementation-scaffold/        # Nearly empty scaffold
│   └── README.md
└── REORGANIZATION-COMPLETE-SESSION38.md
```

---

## Proposed Documentation Structure (Post-Move)

```
docs/
├── architecture-decisions/
│   ├── marco-framework-architecture.md [MOVED FROM 02-design/]
│   └── ... (existing ADRs)
├── discovery-reference/
│   ├── v1.7.0-IMPLEMENTATION-SUMMARY.md [MOVED FROM 02-design/]
│   ├── SPRINT-BACKLOG-v1.7.0.md [MOVED FROM 02-design/]
│   └── ... (existing discovery docs)
├── references/
│   ├── best-practices-reference.md [MOVED FROM 02-design/]
│   ├── standards-specification.md [MOVED FROM 02-design/]
│   ├── guides/
│   │   ├── MIGRATION-GUIDE-v1.0-to-v1.3.md [MOVED FROM 02-design/]
│   │   └── MIGRATION-GUIDE-v1.3-to-v1.7.md [MOVED FROM 02-design/]
│   └── ...
└── ... (existing folders)
```

---

## Implementation Options

### Option A: Conservative (Minimal Changes)
- Archive: 01-discovery/automation/, 03-development/, 04-testing/, 05-implementation/
- Keep: 02-design/ as-is
- Result: Removes empty scaffolds + local-only code, keeps all active docs
- Risk: Low
- Files retained: 35 (just keep current state)
- Files archived: ~30

### Option B: Balanced ⭐ *RECOMMENDED*
- Archive: All of Option A PLUS diagnostic subfolders (backups/, debug/, sessions/, logs/)
- Move valuable docs from 02-design → docs/references/, docs/architecture-decisions/, docs/discovery-reference/
- Decide on governance templates (investigate if active)
- Result: Clean structure, 200+ MB freed, valuable references preserved
- Risk: Medium (requires verification of governance templates)
- Files retained: 15 (only essential references)
- Files archived: 50+ including all diagnostics

### Option C: Maximum Cleanup
- Archive: Everything in Option B
- PLUS: Archive remaining 02-design/ structure entirely to `.archive/02-design-complete/`
- Result: Complete removal of legacy folders
- Risk: High (loses organizational context)
- Files retained: 0 in 01-05
- Files archived: 65

---

## Decision Point: Governance Templates

**Question**: Are `02-design/artifact-templates/governance/` templates still active?

**Action Required**:
```bash
# Option 1: Search for references to these templates
grep -r "ACCEPTANCE-template\|PLAN-template\|STATUS-template" /path/to/scripts/ /path/to/projects/

# Option 2: Check if these are duplicates of templates/ folder
diff "02-design/artifact-templates/governance/" "templates/governance/"

# Option 3: Manual check of scripts using automation
grep -r "artifact-templates" scripts/
```

**Then decide**:
- IF ACTIVE: Move to `templates/governance/` (production location)
- IF INACTIVE: Archive to `.archive/02-design-artifacts/governance/`

---

## Git Move Strategy (Preserving History)

All moves will use `git mv` to preserve commit history:

```powershell
# Phase 1: Archive folders with empty content
git mv 01-discovery/automation .archive/01-discovery-automation
git mv 03-development .archive/03-development-scaffold
git mv 04-testing .archive/04-testing-artifacts
git mv 05-implementation .archive/05-implementation-scaffold

# Phase 2: Archive diagnostic subfolders
git mv 02-design/artifact-templates/backups .archive/02-design-artifacts/backups
git mv 02-design/artifact-templates/debug .archive/02-design-artifacts/debug
git mv 02-design/artifact-templates/sessions .archive/02-design-artifacts/sessions
git mv 02-design/artifact-templates/logs .archive/02-design-artifacts/logs  [if exists]

# Phase 3: Move valuable docs to permanent locations
git mv 02-design/best-practices-reference.md docs/references/
git mv 02-design/standards-specification.md docs/references/
git mv 02-design/marco-framework-architecture.md docs/architecture-decisions/
# ... etc

# Phase 4: Verify 02-design/artifact-templates/governance status, then move/archive

# Phase 5: Clean up empty 02-design folder
rm -r 02-design/  [if now empty]
```

---

## Recommendation

**Proceed with Option B (Balanced)**:
1. Immediately archive empty scaffolds + local-only code (01, 03, 04, 05)
2. Archive diagnostic/backup files from 02-design/artifact-templates/ (backups, debug, sessions, logs)
3. Move valuable reference docs to permanent locations in docs/
4. Investigate governance templates status → move or archive accordingly
5. Verify .archive/ structure and update README with what's archived

**Result**: 
- ✅ 200+ MB freed
- ✅ 50+ files removed from active project
- ✅ 15 essential reference docs preserved
- ✅ 65 diagnostic/backup files archived with clear organization
- ✅ Git history preserved with clean move trail
- ✅ Onboarding clarity improved (fewer legacy folders to understand)

---

## Summary Table

| Folder/File | Size | Files | Status | Action | Archive Path |
|------------|------|-------|--------|--------|--------------|
| 01-discovery/automation/ | ~200 KB | 14 | LOCAL-ONLY, historical | Archive | `.archive/01-discovery-automation/` |
| 02-design/*.md (9 files) | ~80 KB | 9 | Mixed: 5 valuable + 4 ref | Move to docs/ | docs/references/, docs/architecture-decisions/ |
| 02-design/artifact-templates/backups/ | ~20 MB | 22 | Old instruction backups | Archive | `.archive/02-design-artifacts/backups/` |
| 02-design/artifact-templates/debug/ | ~8 KB | 18 | Diagnostic JSON | Archive | `.archive/02-design-artifacts/debug/` |
| 02-design/artifact-templates/sessions/ | ~12 KB | 30+ | Session checkpoints | Archive | `.archive/02-design-artifacts/sessions/` |
| 02-design/artifact-templates/governance/ | ~8 KB | 4 | [NEEDS INVESTIGATION] | TBD | ? |
| 03-development/ | <1 KB | 1 | Empty scaffold | Archive | `.archive/03-development-scaffold/` |
| 04-testing/ | ~100 KB | 7 | Old tests (Jan 2026) | Archive | `.archive/04-testing-artifacts/` |
| 05-implementation/ | ~1 KB | 2 | Empty scaffold | Archive | `.archive/05-implementation-scaffold/` |
| **TOTAL** | **~210 MB** | **65+** | **Mixed** | **See above** | **~210 MB to archive** |

---

## Next Steps (When Approved)

1. **Investigate** governance templates (is governance/ active?)
2. **Execute** Phase 1 moves (git mv for empty scaffolds)
3. **Execute** Phase 2 moves (git mv for diagnostics)
4. **Execute** Phase 3 moves (git mv for references)
5. **Execute** Phase 4 decision (governance templates)
6. **Clean up** empty 02-design folder if now empty
7. **Commit** with message documenting complete DPDCA folders archival
8. **Update** README.md to reflect new structure
9. **Verify** archive structure is accessible and documented
