# 07-foundation-layer -- Acceptance Criteria

**Template Version**: v7.0.0 (Session 71 - reduced current surface)  
**Last Updated**: 2026-03-15  
**Data Model**: GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/07-foundation-layer  
**Status**: PASS -- current Project 07 scope validated against live priming workflow

---

<!-- eva-primed-acceptance -->

## Summary

| Gate | Criteria | Status |
|------|----------|--------|
| AC-1 | Data Model API is reachable and project record is queryable | PASS |
| AC-2 | Project instruction template uses the current project contract markers | PASS |
| AC-3 | Core priming scripts parse and execute in dry-run mode without startup failure | PASS |
| AC-4 | Governance templates exist and align to API-first local continuity | PASS |
| AC-5 | Project 07 active docs no longer advertise retired PART-era or MCP-era operator paths | PASS |
| AC-6 | Superseded scripts and stale governance/test files are archived out of the active path | PASS |
| AC-7 | Workspace scaffolding utilities remain available for current use | PASS |

---

## AC-1: Data Model API Reachability

**Criteria**: The cloud data model health endpoint responds and the Project 07 record is queryable.  
**Verification**: Health check and bootstrap sequence executed on 2026-03-15.  
**Evidence**:
- Health: `status=ok`, `store=cosmos`
- Bootstrap loaded `agent-guide` successfully
- Project record query returned `id=07-foundation-layer`

---

## AC-2: Current Project Contract Template

**Criteria**: `templates/copilot-instructions-template.md` contains the current structure:
- `## Bootstrap First`
- `## Project-Owned Context`
- `## Validation Pattern`

**Verification**: `Bootstrap-Project07.ps1` and `Test-Project07-Deployment.ps1` both check these markers.  
**Evidence**: Template version is `7.0.0 (Session 71 - project authority contract)`.

---

## AC-3: Priming Workflow Executes Cleanly

**Criteria**:
- `Apply-Project07-Artifacts.ps1` parses and executes in dry-run mode
- `Invoke-PrimeWorkspace.ps1` parses and executes in dry-run mode
- `Reseed-Projects.ps1` parses successfully
- `Bootstrap-Project07.ps1` runs without startup/init failure

**Verification Date**: 2026-03-15  
**Evidence**:
- `Bootstrap-Project07.ps1` completed successfully after MCP removal from the active path
- `Invoke-PrimeWorkspace.ps1 -TargetPath C:\eva-foundry\99-test-project -DryRun` completed successfully
- `Apply-Project07-Artifacts.ps1 -TargetPath C:\eva-foundry\99-test-project -DryRun` completed successfully with no file writes

---

## AC-4: Governance Templates Present

**Criteria**: The live governance template set exists under `templates/governance/` and reflects the current API-first continuity model.  
**Verification**:
- `PLAN-template.md`
- `STATUS-template.md`
- `ACCEPTANCE-template.md`
- `README-header-block.md`
- `PROJECT-ORGANIZATION-template.md`

All were present and aligned during the 2026-03-15 validation pass.

---

## AC-5: Active Documentation Matches Current Scope

**Criteria**: Active Project 07 docs describe the live feature set only:
- template ownership split
- priming and reseed scripts
- scaffolding utilities
- API-first governance alignment

They must not advertise retired live dependencies on:
- legacy multi-section operator flows
- retired design-era template paths
- a retired workspace MCP helper as an active Project 07 dependency

**Verification**: Active README, bootstrap guide, organization docs, and validation script were rewritten on 2026-03-15.

---

## AC-6: Superseded Surfaces Archived

**Criteria**: Retired Project 07 scripts and documents are preserved in archive, not left in the active operator path.  
**Archived on 2026-03-15**:
- legacy lock utility
- PART-era compatibility test scripts
- reorganization one-off scripts and RCA/quick-start notes
- push helper and related batch file
- stale governance and validation files replaced by current versions

**Archive Location**: `.archive/20260315_111500-project7-superseded-surfaces/`

---

## AC-7: Essential Current Functions Preserved

**Criteria**: Project 07 still provides these active functions:
- project instruction templates
- governance templates
- single-project priming
- workspace priming
- project reseed
- workspace scaffolding/capture/housekeeping utilities
- validation of the active Project 07 surface

**Verification**: File presence confirmed and active path validated on 2026-03-15.

---

## Current Acceptance Decision

Project 07 is accepted for its reduced current mission:
- keep the workspace and project instruction templates authoritative and separated
- propagate current governance scaffolding safely
- avoid carrying retired MCP and PART-era operator surfaces in the live path

Historical evidence remains archived. Active operator guidance now reflects the current implementation.