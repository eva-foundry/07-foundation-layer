<!-- eva-primed-organization -->

# 07-foundation-layer - Organization Standards

**Version**: v7.0.0 (Session 71 - current live contract)  
**Primed**: 2026-03-15 by agent:copilot  
**Status**: active local organization guide

---

## Root Rules

Use Project 07 for the current foundation function only:
- instruction templates
- governance templates
- priming and reseed scripts
- structure utilities
- validation of the active operator path

Archive superseded migration, push, PART-era, and MCP-era surfaces instead of keeping them in active folders.

---

## Recommended Structure

```text
templates/
  copilot-instructions-template.md
  copilot-instructions-workspace-template.md
  governance/
  docs/

scripts/
  deployment/
  testing/
  utilities/
  planning/
  data-seeding/

tests/
  test-bootstrap-api.py

.archive/
  prototypes/
  session-*/
  20260315_111500-project7-superseded-surfaces/
```

---

## Organization Principles

1. Keep the workspace authority and project authority separate.
2. Keep only current operator surfaces live.
3. Preserve history in archive rather than mixing it with current entrypoints.
4. Validate the active priming path after every structural change.

---

## D3PDCA Application

Use D3PDCA when changing Project 07:
- discover the current live propagation path
- decide what is still active versus what is only historical
- do the minimum current-state edits
- check bootstrap, dry-run prime, dry-run apply, and validation script
- act by archiving superseded surfaces and updating the active docs

---

## Governance Alignment

Project 07 aligns to API-first governance and local continuity artifacts. The current live docs and scripts should not depend on a retired workspace MCP service or on a legacy multi-section project instruction structure.

---

## Verification Checklist

- `Bootstrap-Project07.ps1` passes
- `Invoke-PrimeWorkspace.ps1` dry-run passes
- `Apply-Project07-Artifacts.ps1` dry-run passes
- `Test-Project07-Deployment.ps1` passes
- active docs describe only the current Project 07 feature set