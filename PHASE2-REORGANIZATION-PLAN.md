# Project 07 - Phase 2 Reorganization Plan: Move 01-discovery & 02-design to docs/

**Date**: March 7, 2026  
**Status**: Planning Phase

---

## Remaining Content to Move

### 01-discovery/
- `README.md` (historical discovery phase documentation)
- **Destination**: `docs/discovery-reference/01-discovery-README.md` OR `docs/discovery-reference/phase-01-discovery.md`

### 02-design/
- `README.md` (historical design phase documentation)
- `architecture-decision-records/` (currently EMPTY - already moved)
- `artifact-templates/` (remaining diagnostic subfolders):
  - `backups/` (old instruction backups - pre-archived? Need verification)
  - `debug/` (diagnostic data)
  - `governance/` (governance templates - duplicate of templates/governance/)
  - `logs/` (logs)
  - `sessions/` (session state)
- **Destination for README**: `docs/discovery-reference/02-design-README.md`
- **Destination for artifact-templates subfolders**: `.archive/02-design-artifacts/` (consolidate remaining)

---

## Scripts Requiring Updates

| Script | Current Path | New Path | Lines |
|--------|--------------|----------|-------|
| `Reseed-Projects.ps1` | `02-design\artifact-templates\copilot-instructions-template.md` | `templates\copilot-instructions-template.md` | 35 |
| `Reseed-Projects.ps1` | `02-design\artifact-templates\backups` | `.archive\02-design-artifacts\backups` | 36 |
| `Bootstrap-Project07.ps1` | `.\02-design\artifact-templates\Invoke-PrimeWorkspace.ps1` | `.\scripts\deployment\Invoke-PrimeWorkspace.ps1` | 264,268,272 |
| `Apply-Project07-Artifacts.ps1` | `02-design\artifact-templates` | `templates` | 388 |
| `Test-Project07-Deployment.ps1` | `02-design\artifact-templates` | `templates` | 57,58 |
| `Fix-Project07-Paths.ps1` | `02-design\artifact-templates\Apply-Project07-Artifacts.ps1` | `scripts\deployment\Apply-Project07-Artifacts.ps1` | 17,23 |

---

## Execution Plan

### Phase 1: Move Remaining README.md Files
- Move `01-discovery/README.md` → `docs/discovery-reference/`
- Move `02-design/README.md` → `docs/discovery-reference/`

### Phase 2: Clean Up 02-design/artifact-templates
- Verify what's still in each subfolder
- Move remaining diagnostic subfolders to `.archive/02-design-artifacts/`
- Delete empty `02-design/` structure

### Phase 3: Update Scripts
- Update 5 scripts with new paths
- Test path references

### Phase 4: Final Verification
- Verify all paths still resolve correctly
- Verify scripts can find templates
- Commit changes

---

## Implementation
Starting now...
