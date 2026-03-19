# 07-foundation-layer -- EVA Foundation Layer

<!-- markdownlint-configure-file {"MD012": false} -->
<!-- eva-primed -->
<!-- project07-readme-reviewed: 2026-03-15 by agent:copilot -->

Project 07 is the live foundation and priming surface for the EVA workspace. Its current job is to maintain the workspace authority template, the project authority template, the governance scaffolding templates, and the scripts that safely repair or prime numbered projects.

## Current Role

- Build and repair project instruction contracts with a clear workspace-versus-project authority split.
- Prime managed governance artifacts without blindly overwriting user-managed project content.
- Validate the active Project 07 operator path before any change propagates across the workspace.
- Keep retired migration-era, legacy multi-section, and old MCP-era operator surfaces out of the active path.

## Active Surface

The current live entry points are:

- `scripts/deployment/Bootstrap-Project07.ps1`
- `scripts/deployment/Apply-Project07-Artifacts.ps1`
- `scripts/deployment/Invoke-PrimeWorkspace.ps1`
- `scripts/deployment/Reseed-Projects.ps1`
- `scripts/testing/Test-Project07-Deployment.ps1`
- `templates/copilot-instructions-template.md`
- `templates/copilot-instructions-workspace-template.md`
- `templates/governance/`

See `PROJECT-ORGANIZATION.md` for the current structure contract.

## Authority Model

Project 07 follows a strict split.

- Workspace authority belongs in the workspace-level instructions.
- Project authority belongs in each project-level `.github/copilot-instructions.md` file.
- Project priming preserves `Project-Owned Context` instead of flattening project meaning into a generic scaffold.
- Governed truth is API-first. Local `PLAN.md`, `STATUS.md`, and `ACCEPTANCE.md` are continuity artifacts, not the source of truth.

The data model authority for Project 07 is the Project 37 API record at [Project 07 record](https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/07-foundation-layer).

## Recommended Workflow

Use this sequence for Project 07 changes and for workspace repair work.

1. Run `scripts/deployment/Bootstrap-Project07.ps1`.
2. Run `scripts/testing/Test-Project07-Deployment.ps1`.
3. Dry-run priming first with `scripts/deployment/Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry" -ManagedArtifactsOnly -DryRun`, or target one project.
4. Apply only after the dry-run is clean.
5. Re-run the validator after any Project 07 script or template change.

For fallout repair across numbered projects, prefer `-ManagedArtifactsOnly` so managed artifacts are repaired without re-touching user-managed project files.

## Validation

The active Project 07 smoke validator checks:

- required live files exist
- active scripts parse successfully
- template markers are present
- bootstrap runs cleanly
- workspace prime dry-run works
- single-project apply dry-run works
- stale live operator references are not reintroduced

Primary validation command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\testing\Test-Project07-Deployment.ps1
```

Bootstrap check:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deployment\Bootstrap-Project07.ps1
```

## Archive Policy

Historical but superseded material stays under `.archive/`.

- The March 15 cleanup batch is preserved in `.archive/20260315_111500-project7-superseded-surfaces/`.
- The historical Project 07 MCP prototype remains under `.archive/prototypes/mcp-server/`.

If a file documents or drives a retired workflow, archive it instead of leaving it in the live operator path.

## Related Files

- `PLAN.md`
- `STATUS.md`
- `ACCEPTANCE.md`
- `PROJECT-ORGANIZATION.md`
- `.github/PROJECT-ORGANIZATION.md`
- `.github/copilot-skills/foundation-expert.skill.md`

## Status

As of 2026-03-15, the active Project 07 surface has been reduced to the current priming, repair, and validation workflow. The retired workspace MCP helper dependency is no longer part of the live path, and the current validator plus bootstrap checks pass against the rebuilt surface.
<!-- eof -->
<!-- end -->

