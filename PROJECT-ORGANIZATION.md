# 07-foundation-layer -- Organization Standards

**Version**: v7.0.0 (Session 71 - reduced current surface)  
**Last Updated**: 2026-03-15  
**Status**: current live organization guide

---

## Root Rules

Keep Project 07 focused on the live foundation function:
- current templates
- current priming and reseed scripts
- current scaffolding utilities
- current validation for the active operator path

Do not keep retired migration, PART-era, or MCP-era operator surfaces in active folders when they are no longer part of the current workflow.

---

## Current Structure

```text
07-foundation-layer/
  .github/
    copilot-instructions.md
    PROJECT-ORGANIZATION.md
    copilot-skills/

  templates/
    copilot-instructions-template.md
    copilot-instructions-workspace-template.md
    governance/
    docs/
    supported-folder-structure-rag.json

  scripts/
    deployment/
      Apply-Project07-Artifacts.ps1
      Bootstrap-Project07.ps1
      Invoke-PrimeWorkspace.ps1
      Reseed-Projects.ps1
    testing/
      Test-Project07-Deployment.ps1
    utilities/
      Initialize-ProjectStructure.ps1
      Capture-ProjectStructure.ps1
      Invoke-WorkspaceHousekeeping.ps1
      Test-GovernanceConsistency.ps1
    planning/
    data-seeding/
    Initialize-WorkspaceMemorySystem.ps1

  tests/
    test-bootstrap-api.py

  .archive/
    prototypes/
    session-*/
    20260315_111500-project7-superseded-surfaces/

  README.md
  PLAN.md
  STATUS.md
  ACCEPTANCE.md
```

---

## Active Functions By Area

### Template Authority
- workspace template remains workspace authority only
- project template remains project authority only
- project reseed preserves `Project-Owned Context`

### Priming And Propagation
- `Apply-Project07-Artifacts.ps1` builds a project instruction contract for one project
- `Invoke-PrimeWorkspace.ps1` applies governance scaffolding and optional prime flow
- `Reseed-Projects.ps1` refreshes current project contracts safely
- `Bootstrap-Project07.ps1` verifies the live Project 07 operator path before use

### Utilities
- project structure initialization
- workspace structure capture
- housekeeping and consistency support
- workspace memory initialization

### Validation
- `scripts/testing/Test-Project07-Deployment.ps1` validates the active Project 07 surface
- `tests/test-bootstrap-api.py` covers bootstrap API behavior

---

## Archive Policy

Archive, do not keep live, when a file is any of the following:
- one-off reorganization or migration script
- PART-era compatibility checker no longer used by the current template model
- push helper built for a superseded propagation path
- retired MCP prototype notes or operator wrappers
- backup copies left in active folders after a repair cycle

Archive location for the 2026-03-15 cleanup:
- `.archive/20260315_111500-project7-superseded-surfaces/`

The historical MCP prototype remains preserved under:
- `.archive/prototypes/mcp-server/`

---

## Governance Alignment

Project 07 uses API-first governance alignment:
- bootstrap from the workspace authority first
- treat Project 37 Data Model API as governance truth
- use local PLAN, STATUS, and ACCEPTANCE as continuity artifacts
- keep project instructions limited to project-specific operating context

Do not describe the current model as a transition-era governance hybrid in active docs. That language belonged to an earlier migration stage and is no longer the operator framing.

---

## Validation Pattern

Before changing Project 07 live surfaces:
1. Parse updated scripts and check for errors.
2. Run `Bootstrap-Project07.ps1`.
3. Run `Invoke-PrimeWorkspace.ps1` in dry-run mode against a representative numbered project.
4. Run `Apply-Project07-Artifacts.ps1` in dry-run mode against the same representative project.
5. Run `scripts/testing/Test-Project07-Deployment.ps1`.

If a change cannot survive that sequence, it is not ready to propagate across the workspace.