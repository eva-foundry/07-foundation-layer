# AICOE Workspace -- GitHub Copilot Instructions

**Workspace**: C:\AICOE\eva-foundry  
**Owner**: {WORKSPACE_OWNER} / EVA AI COE  
**Last Updated**: {TIMESTAMP} (Session {SESSION_NUMBER} - {SESSION_DESCRIPTION})  
**Template Version**: 4.1.0 (API-First Bootstrap Aligned)

---

## Workspace Overview

{PROJECT_COUNT} numbered projects ({PROJECT_RANGE} + test-99) implementing the **EVA architecture**: DPDCA-driven AI software engineering with data-first governance, evidence-based quality gates, and automated remediation frameworks. Central data source: **Project 37 (EVA Data Model)** - **51 operational layers** (50 base + 1 metadata) via cloud API.

---

## Agent Bootstrap: The API Entry Point

**Every agent session must start here**, before reading project instructions.

### One-Step Bootstrap

```powershell
# Fetch complete guidance from Project 37 Cosmos DB API
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{ 
    base = $base
    guide = (Invoke-RestMethod "$base/model/agent-guide")
}

# You now have access to:
# - $session.guide.query_patterns (how to query)
# - $session.guide.write_cycle (how to write safely)
# - $session.guide.common_mistakes (what NOT to do)
# - $session.guide.layers_available (all 51 operational layers)
```

**Why?** The API is your single source of truth for:
- ✅ Query safety limits (prevents timeouts & terminal scramble)
- ✅ Write cycle rules (prevents data corruption)  
- ✅ Layer schemas (current definitions, not stale docs)
- ✅ Lessons learned (from recent sessions, live)

**Next**: Read [Project 37 User Guide](eva-foundry/37-data-model/USER-GUIDE.md) for full bootstrap sequence and session state management.

---

## Workspace-Level Skills

Workspace provides these skills via `@skill-name` invocation:

| Skill | Invoke As | Purpose |
|-------|-----------|---------|
| **EVA Factory Guide** | `@eva-factory-guide` | Learn DPDCA process, data model, evidence tracking, patterns |
| **Foundation Expert** | `@foundation-expert` | Prime/scaffold projects, deploy templates, governance checks |
| **Scrum Master** | `@scrum-master` | Sprint cycles, progress reports, velocity, MTI traceability |
| **Workflow Forensics** | `@workflow-forensics-expert` | Evidence audits, metric accuracy, pipeline validation |

Each project may add skills in `.github/copilot-skills/`. Say "list skills" in that project for details.

---

## Key Architecture References

| Component | Role | Location |
|-----------|------|----------|
| **Project 37 (Data Model)** | Single source of truth, 51 layers, cloud API | `eva-foundry/37-data-model/` |
| **Project 07 (Foundation)** | Workspace PM, governance standards, templates | `eva-foundry/07-foundation-layer/` |
| **Project 48 (Veritas)** | Requirements traceability, MTI quality gate | `eva-foundry/48-eva-veritas/` |
| **Project 51 (ACA)** | Reference DPDCA implementation (6+ months refined) | `eva-foundry/51-ACA/` |

---

## For More Information

- **Best Practices**: `C:\AICOE\.github\best-practices-reference.md`
- **Standards & Compliance**: `C:\AICOE\.github\standards-specification.md`
- **Data Model API**: `eva-foundry/37-data-model/USER-GUIDE.md`
- **Azure Guidance**: `eva-foundry/18-azure-best/` (32 entries: WAF, security, AI, IaC, cost)
- **Project Setup**: Each project's `README.md`, `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`

---

## Workspace Context per Session

| Item | Value |
|------|-------|
| **Session Number** | {SESSION_NUMBER} |
| **Session Phase** | {SESSION_PHASE} |
| **Last Status Update** | {LAST_STATUS_UPDATE} |
| **Active Projects** | {ACTIVE_PROJECT_COUNT}/57 |
| **Projects Needing Priming** | {UNPRIMED_COUNT} |
| **Test Coverage** | {TEST_COVERAGE}% (aggregate) |

---

*This instruction file follows GitHub best practices: repository context only, concise, API-first bootstrap. For operational procedures, methodology guides, and detailed API protocol documentation, see [Project 37 User Guide](eva-foundry/37-data-model/USER-GUIDE.md).*

---

## Implementation Notes for Project 7

**This template is designed for Project 7's distribution script** (`Invoke-PrimeWorkspace.ps1`):

### Substitution Variables

Replace these before distributing:
- `{WORKSPACE_OWNER}` → User name or team (e.g., "Marco Presta")
- `{TIMESTAMP}` → Current timestamp (e.g., "2026-03-07 6:53 PM ET")
- `{SESSION_NUMBER}` → Active session (e.g., "38")
- `{SESSION_DESCRIPTION}` → Session focus (e.g., "Instruction Hardening")
- `{PROJECT_COUNT}` → Total projects (e.g., "57")
- `{PROJECT_RANGE}` → Range (e.g., "01-56")
- `{SESSION_PHASE}` → Current phase (e.g., "Active Development")
- `{LAST_STATUS_UPDATE}` → When STATUS.md was last updated workspace-wide
- `{ACTIVE_PROJECT_COUNT}` → Count of active projects (not poc/retired)
- `{UNPRIMED_COUNT}` → Count needing copilot-instructions.md
- `{TEST_COVERAGE}` → Average across all projects (if measurable)

### Automation Rules

- **PART 1** (this entire file): Safe to overwrite on sync cycles
- **Part 2** Note: Not applicable for workspace-level file (differs from project-level)
- **Idempotent**: Can run multiple times without duplication
- **Dry-run**: Test with `-DryRun` flag before full deployment
- **Rollback**: Previous version backed up as `.backup.{timestamp}`

### Distribution via Project 7

```powershell
# Push to workspace root
$template = Get-Content "07-foundation-layer/02-design/artifact-templates/copilot-instructions-workspace-template.md"
$expanded = $template -replace '{WORKSPACE_OWNER}', $owner `
                      -replace '{TIMESTAMP}', (Get-Date -Format "yyyy-MM-dd h:mm tt ZZ") `
                      -replace '{SESSION_NUMBER}', $sessionNumber

Set-Content "C:\AICOE\.github\copilot-instructions.md" $expanded
git add ".github/copilot-instructions.md"
git commit -m "chore: Update workspace instructions (Session $sessionNumber)"
```

---

*Workspace template v4.1.0 | Created for Session 38+ distribution*
