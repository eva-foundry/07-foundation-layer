# 07-foundation-layer -- Status

**Last Updated**: 2026-03-19  
**Current Phase**: check  
**Overall State**: stable, with authority chain refreshed to Sprint 9 active and Project 37 Sprint 11 downstream-enablement posture

---

<!-- eva-primed-status -->

## Current Role

Project 07 is the workspace foundation layer for:

- workspace and project copilot-instruction templates
- governance scaffolding templates
- single-project and workspace priming
- reseed operations for current project instruction contracts
- project structure initialization, capture, and housekeeping utilities

Project 07 is also the current scrum-master certification owner for the workspace authority chain, paperless onboarding refresh flow, and audit/tooling readiness posture.

It is no longer the live home of a workspace-wide MCP service and it no longer treats PART-era instruction structure as an active operator model.

---

## Current Active Functions

### Templates

- `templates/copilot-instructions-template.md`
- `templates/copilot-instructions-workspace-template.md`
- `templates/governance/*.md`

### Deployment And Propagation

- `scripts/deployment/Apply-Project07-Artifacts.ps1`
- `scripts/deployment/Invoke-PrimeWorkspace.ps1`
- `scripts/deployment/Reseed-Projects.ps1`
- `scripts/deployment/Bootstrap-Project07.ps1`

### Utilities

- `scripts/utilities/Initialize-ProjectStructure.ps1`
- `scripts/utilities/Capture-ProjectStructure.ps1`
- `scripts/utilities/Invoke-WorkspaceHousekeeping.ps1`
- `scripts/Initialize-WorkspaceMemorySystem.ps1`

### Validation

- `scripts/testing/Test-Project07-Deployment.ps1`
- `tests/test-bootstrap-api.py`

---

## 2026-03-15 Reduction And Repair

### Completed

- Rewrote the live project and workspace copilot-instruction templates around the authority split.
- Rewrote the governance templates to the API-first local continuity model.
- Updated `Reseed-Projects.ps1` to preserve `Project-Owned Context` instead of the legacy multi-section template block.
- Updated `Apply-Project07-Artifacts.ps1` to assemble the current project contract and to keep dry-run side-effect free.
- Updated `Invoke-PrimeWorkspace.ps1` to use current placeholders and non-destructive dry-run API sync behavior.
- Removed the live bootstrap dependency on the retired workspace MCP helper path.
- Archived superseded scripts, stale governance docs, test suites, and operator notes under `.archive/20260315_111500-project7-superseded-surfaces/`.
- Recreated the active governance and validation docs around the reduced current scope.

### Archived From Active Path

- legacy multi-section lock and compatibility tooling
- stale reorganization/RCA/quick-start notes
- push helper scripts for old propagation flow
- stale governance and validation files replaced by current versions
- obsolete backup copies left in deployment and templates paths

---

## Validation Summary

Validated on 2026-03-15:

- Data Model API bootstrap: PASS
- `Bootstrap-Project07.ps1`: PASS
- `Invoke-PrimeWorkspace.ps1 -TargetPath C:\eva-foundry\99-test-project -DryRun`: PASS
- `Apply-Project07-Artifacts.ps1 -TargetPath C:\eva-foundry\99-test-project -DryRun`: PASS
- parser/errors check on updated deployment scripts: PASS

No startup/init failures were observed in the active priming path.

---

## 2026-03-19 Authority Refresh

### Refresh Actions Completed

- Re-queried the live Project 19 recurring packet, Project 37 Sprint 11 packet, Project 60 release-readiness packet, and Project 07 project record before editing authority surfaces.
- Refreshed the workspace root instruction chain so it no longer describes Project 37 Sprint 11 as ready-only.
- Refreshed the Project 07 instruction chain so GovOps closure and Sprint 9 promotion are treated as proven and the remaining dependency is correctly narrowed to Project 37 to Project 60 provider-consumer closure.
- Published a bounded Project 07 scrum-master execution note at `evidence/20260319_022000-paperless-authority-refresh-and-master-plan.md` covering nested D3PDCA, workspace skills/tools, and the next operator packet.

### Current Packet Truth

- Recurring packet: `19-ai-gov-2026-03-18-numbered-project-paperless-onboarding-packet`
- Correlation ID: `paperless-onboarding-20260318T041500Z`
- Active onboarding posture: Sprint 9 active for `57-FKTE` after governed dry-run workflow run `23272454604`
- Project 37 posture: Sprint 11 / D2 Do active - public L112-L120 runtime contract now proven live on revision `msub-eva-data-model--iac-layers-20260318` with `100%` traffic
- Project 60 posture: active release-readiness packet, with route completeness now proven and the remaining blocker narrowed to explicit API/navigation/six-screen handoff acceptance

---

## Open Risks

- Historical references to PART-era structure remain in archived and evidence files by design.
- Some older live skill docs outside the active Project 07 operator path may still mention PART terminology as historical guidance or anti-pattern references.
- Project 07 still depends on accurate cloud API availability for governance-aligned operations.

---

## Next Useful Work

1. Execute the bounded scrum-master packet in `evidence/20260319_022000-paperless-authority-refresh-and-master-plan.md`, starting with Project 37 provider closure and the Sprint 9 check/act decision.
2. Keep the workspace root and Project 07 instruction chain synchronized whenever Sprint 9, Project 37 Sprint 11, or Project 60 handoff-acceptance posture changes.
3. Keep new work aligned to the project-owned-context contract and avoid reintroducing template-era duplication.
