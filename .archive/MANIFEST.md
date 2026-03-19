# Archive Manifest - Project 07 Foundation Layer

**Last Updated**: March 15, 2026
**Session**: 71 (superseded surface reduction and repair)
**Previous Updates**: Session 44 (March 10, 2026), Session 38 (March 7, 2026)

---

## Session 71 Additions (March 15, 2026)

### Superseded Active Surfaces (`20260315_111500-project7-superseded-surfaces/`)

Archived after the Project 07 live surface was reduced to the current priming and validation path.

Moved out of the active path:

- stale governance docs that still described retired operator flows
- stale Project 07 deployment and compatibility test scripts
- retired push-helper and reorganization utilities
- historical quick-start, RCA, and refactoring notes tied to old priming behavior
- backup files left in active deployment or template paths

Representative archived files include:

- `ACCEPTANCE.md`
- `STATUS.md`
- `PROJECT-ORGANIZATION.md`
- `.github/PROJECT-ORGANIZATION.md`
- `scripts/testing/Test-Project07-Deployment.ps1` (legacy suite)
- `scripts/testing/Test-PostReorganization.ps1`
- `scripts/utilities/Add-ProjectLock.ps1`
- `scripts/deployment/Test-PrimingCompatibility.ps1`
- `scripts/deployment/Phase2-Reorganization.ps1`
- `scripts/deployment/PRIMING-QUICK-START.md`
- `scripts/deployment/PRIMING-RCA-20260309.md`
- `scripts/deployment/FRACTAL-DPDCA-IMPLEMENTATION.md`
- `scripts/deployment/Push-CopilotInstructions.ps1`
- `scripts/deployment/run-push.bat`
- `scripts/deployment/Invoke-PrimeWorkspace.ps1.backup_20260309_204028`
- `scripts/deployment/Invoke-PrimeWorkspace.ps1.backup_20260309_210819`
- `scripts/deployment/fractal-dpdca-refactoring-20260309-204653.json`
- `templates/copilot-instructions-template-v5-backup.md`

**Reason**: These files described or enforced retired operator behavior and increased the risk of reintroducing broken priming paths. They were archived and replaced by the current reduced live surface.

---

## Session 44 Additions (March 10, 2026)

### Session 38 Completion Artifacts (`session-38/` - 18 files)

Root-level session and planning documents from the Session 38 reorganization effort.

- `SESSION-38-*.md` (6 files) for task completion, DPDCA, and audit reports
- `REORGANIZATION-*.md` (5 files) for proposals, summaries, and completion status
- `PHASE2-REORGANIZATION-*.md` (3 files) for Phase 2 plan, status, and completion
- `ADO-SCAFFOLDING-INTEGRATION.md`
- `CONTROL-PLANE-OWNERSHIP-BOUNDARY.md`
- `DPDCA-FOLDERS-ASSESSMENT.md`
- `EXECUTION-PLAN.md`
- `OPTION-3-ASSESSMENT.md`
- `SEED-FROM-PLAN-PATTERN.md`
- `UNIFIED-DATAMODEL-WORKFLOW.md`
- `VERITAS-SCAFFOLDING-INTEGRATION.md`

**Reason**: Session 38 artifacts were superseded by the implemented scripts and templates.

### Planning Proposals (`planning/` - 7 files)

Early design and planning documents from the old docs surface.

- `copilot-instructions-reorganization-proposal.md`
- `foundation-completion-plan.md`
- `40-control-plane-RACI.md`
- `BOOTSTRAP-API-FIRST.md`
- `DATA-MODEL-HEALTH-DETECTION.md`
- `github-features-inventory.md`
- `github-projects-setup.md`

**Reason**: These proposals were either implemented or superseded by the current references in docs and templates.

### Deprecated Prototypes (`prototypes/` - `mcp-server/`)

Non-functional MCP server material referencing deleted directory structure.

- `mcp-server/foundation-primer/` — early MCP server prototype
- references non-existent `02-design/artifact-templates/` paths
- not registered in workspace settings
- superseded by Project 48 (`eva-veritas`) for production MCP capability

**Reason**: The prototype points at deleted paths and is no longer part of the supported operator surface.

### Obsolete Template Documentation (`session-44/` - 2 files)

Template documentation that referenced obsolete paths and structures.

- `PATH-FIX-IMPLEMENTATION-SUMMARY.md`
- `template-v2-usage-guide.md`

**Reason**: These documents reference deleted paths and were superseded by the current template guide.

---

## Session 38 Contents (March 7, 2026)

### Superseded Implementation Summaries (v1.3.0 - v1.5.2)

- `v1.3.0-IMPLEMENTATION-SUMMARY.md`
- `IMPLEMENTATION-COMPLETE-v1.5.2.md`
- `PHASE-3-IMPLEMENTATION-COMPLETE.md`

**Reason**: Obsoleted by the later active status trail.

### Diagnostic Artifacts

- `CLOUD-ENDPOINT-TIMEOUT-INVESTIGATION.md`
- `ENDPOINT-VERIFICATION-COMPLETE.md`
- `analyze_endpoints.ps1`
- `verify_endpoints.ps1`
- `test-output.txt`

**Reason**: Investigation complete; artifacts retained only for audit history.

### Stale Documentation

- `PREVIEW-Project14.md`
- `PROJECT7-VALUE-TO-AI-AGENTS.md`

**Reason**: Content superseded by current active documentation.

### Misplaced Folders

- `15-cdc/`

**Reason**: CDC content does not belong in Project 07 scope.

---

## Recovery

To restore any item:

```powershell
# Example: Restore session-38 file
Move-Item ".archive\session-38\<filename>" -Destination "../"

# Example: Restore planning proposal
Move-Item ".archive\planning\<filename>" -Destination "../docs/"

# Example: Restore entire directory
Move-Item ".archive\prototypes\mcp-server" -Destination "../"
```

---

## Archive Structure

```text
.archive/
├── session-38/
├── planning/
├── prototypes/
├── session-37/
├── old-backups/
├── diagnostics/
├── testing-2026-01/
├── empty-scaffolds/
├── templates/
├── 01-discovery-automation/
├── 03-development-scaffold/
├── 04-testing-artifacts/
├── 05-implementation-scaffold/
└── 15-cdc/
```

---

## Active Components (Not Archived)

**Kept in Project 07**:

- `github-discussion-agent/`
- `patterns/`
- `scripts/`
- `templates/`
- `tests/`
- `docs/`
- `.github/`

**Superseded By**:

- MCP server functionality now belongs to Project 48 (`eva-veritas`)
- Bootstrapping logic now belongs to workspace instructions plus Project 37 API endpoints
- Template deployment now belongs to `scripts/deployment/Invoke-PrimeWorkspace.ps1`
