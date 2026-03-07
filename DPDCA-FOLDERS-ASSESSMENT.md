# DPDCA Folders (01-05) Assessment - Session 38

**Analysis Date**: March 7, 2026

---

## Folder-by-Folder Assessment

### 01-discovery (15 files - ACTIVE)

**Content Type**: Python utilities, test code, evidence generation

**Key Files**:
- `evidence.py` — Evidence collection utility (ACTIVE)
- `generate-docs.py` — Documentation generator (ACTIVE)
- `generate.ps1` — PowerShell generator
- `pytest.ini`, `requirements.txt` — Testing setup
- Tests: `test_generator.py`, `validators.py`
- Utilities: `preflight-check.ps1`, `run-tests.ps1`

**Verdict**: ✅ **KEEP** - Contains functional utilities actively used by other projects
- Evidence collection is referenced by 37-data-model integration
- Test framework used by other discovery projects
- Code has actual dependencies and function

**Action**: Leave as-is (some utilities may be referenced externally)

---

### 02-design (78 files - MIXED VALUE)

**Critical Content** (KEEP):
- `best-practices-reference.md` (584 lines) — Referenced in multiple copilot-instructions
- `standards-specification.md` — Governance standards reference
- `marco-framework-architecture.md` — Framework design doc
- `MIGRATION-GUIDE-*.md` — Version migration guides
- `SPRINT-BACKLOG-v1.7.0.md` — Historical sprint planning
- `ACCEPTANCE-template.md`, `PLAN-template.md`, `STATUS-template.md` — Templates

**Backup Files** (ARCHIVE):
- Multiple `copilot-instructions_*.md` dated 2/23, 2/25 (backups)
- Multiple `checkpoint_*.json` files (session state snapshots from 1/29-3/5)
- Multiple `after_*`, `before_*`, `deployment_start_*.json` (diagnostic snapshots)

**Subdirectories** (Already migrated):
- `architecture-decision-records/` — Already moved to docs/
- `artifact-templates/` — Already reorganized

**Verdict**: 🟡 **SPLIT** — Keep critical docs, archive session snapshots/backups

**Action**: 
- Create `02-design/.archive/` subfolder
- Move checkpoint JSON files → `02-design/.archive/checkpoints/`
- Move copilot-instructions backups → `02-design/.archive/backups/`
- Keep: best-practices-reference.md, standards-specification.md, migration guides, templates

**Result**: 02-design shrinks from 78 → ~15 files (critical reference only)

---

### 03-development (1 file - EMPTY)

**Content**: Only README.md (scaffold marker)

**Verdict**: 🗑️ **ARCHIVE** — Empty scaffold with no functional content

**Action**: Archive entire folder to `.archive/empty-scaffolds/03-development/`

---

### 04-testing (7 files - LOW VALUE)

**Content Type**: Old test scripts (1/30/2026) + test results

**Files**:
- `manual-test-workspace-mgmt.ps1` — Test script (January)
- `test-results-workspace-mgmt-v1.0.0.md` — Results summary
- `housekeeping-dryrun_*.txt` — Dry-run output (archived earlier)
- `initialize-dryrun_*.txt` — Dry-run output (archived earlier)
- `project-folder-picture_*.md` — Folder structure snapshot

**Verdict**: 🟡 **ARCHIVE** — Historical test artifacts with limited ongoing value

**Action**: Archive entire `04-testing/` folder to `.archive/empty-scaffolds/04-testing/`

**Keep in active**: None (tests migrated to `scripts/testing/` in earlier phase)

---

### 05-implementation (2 files - MINIMAL)

**Content**:
- `README.md` — Scaffold marker
- `copilot-instructions-ORIGINAL-20260129.md` — Backup from 1/29 (already archived to .archive/ earlier)

**Verdict**: ➖ **MOSTLY EMPTY** — Scaffold with one archived file

**Action**: Archive entire folder to `.archive/empty-scaffolds/05-implementation/`

---

## Summary: DPDCA Folder Cleanup Plan

| Folder | Status | Files | Action |
|--------|--------|-------|--------|
| 01-discovery | ✅ ACTIVE | 15 | **KEEP** - Contains functional utilities |
| 02-design | 🟡 MIXED | 78 → 15 | **PRUNE** - Archive session snapshots/backups, keep critical docs |
| 03-development | 🗑️ EMPTY | 1 | **ARCHIVE** - Empty scaffold |
| 04-testing | 🟡 LOW-VALUE | 7 | **ARCHIVE** - Old test artifacts |
| 05-implementation | ➖ MINIMAL | 2 | **ARCHIVE** - Empty scaffold + backup |

---

## Implementation Options

### Option A: Minimal (Recommended - Low Risk)
- **Archive**: 03-development/, 04-testing/, 05-implementation/
- **Keep**: 01-discovery/, 02-design (as-is for now)
- **Rationale**: Removes obvious empties; keeps functional code+docs safe

### Option B: Aggressive (Higher Value Cleanup)
- **Archive**: 03-development/, 04-testing/, 05-implementation/
- **Prune 02-design**: Move checkpoint/backup JSON + old copilot-instructions to `.archive/`
- **Result**: 78 → 15 files in 02-design, much cleaner
- **Risk**: Medium (non-critical but potentially useful for reference)

### Option C: Maximum Cleanup (Delete Old Folders)
- Archive all 01-05 to `.archive/empty-scaffolds/`
- Keep reference docs (best-practices, standards) as top-level in docs/
- Delete empty folder structure entirely
- **Risk**: High (loses organizational context if someone wants to understand DPDCA process used)

---

## Recommendation

**Proceed with Option A or B?**

- **Option A** if you want to preserve 02-design as historical reference
- **Option B** if you want cleaner 02-design (removes ~60 diagnostic/backup files to archive)
- **Avoid Option C** (historical context valuable for future sessions)

**User should decide**: Do you want Option A (minimal) or Option B (aggressive)?
