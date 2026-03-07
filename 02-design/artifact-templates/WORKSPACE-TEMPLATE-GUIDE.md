# Workspace Copilot Instructions Template — Project 7 Implementation Guide

**File**: `copilot-instructions-workspace-template.md`  
**Location**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\`  
**Version**: 4.1.0 (API-First Bootstrap Aligned)  
**Created**: 2026-03-07 (Session 38)  
**For**: Project 7 workspace distribution automation

---

## Overview

This template is designed for **Project 7's distribution script** (`Invoke-PrimeWorkspace.ps1` or equivalent) to automatically generate and update the workspace-level copilot-instructions.md file at `C:\AICOE\.github\copilot-instructions.md`.

Unlike project-level templates (which have PART 1/PART 2 split), the **workspace template is a complete replacement** — all content is regenerated on each sync cycle with current context values.

---

## Key Features

✅ **API-First Bootstrap** — Directs agents to call `/model/agent-guide` first  
✅ **51 Operational Layers** — Accurate layer count (50 base + 1 metadata)  
✅ **Workspace Skills** — Table of workspace-level skills available via `@skill-name`  
✅ **Architecture References** — Key projects (37, 07, 48, 51) and their roles  
✅ **Substitution Variables** — Template placeholders for Project 7 automation  
✅ **Automation Rules** — Guidance on idempotency, dry-run, rollback  

---

## Template Substitution Variables

Replace these before writing to workspace:

| Variable | Example | How to Get |
|----------|---------|-----------|
| `{WORKSPACE_OWNER}` | Marco Presta | From organization context |
| `{TIMESTAMP}` | 2026-03-07 6:53 PM ET | `Get-Date -Format "yyyy-MM-dd h:mm tt ZZ"` |
| `{SESSION_NUMBER}` | 38 | From session context |
| `{SESSION_DESCRIPTION}` | Instruction Hardening | From session plan/status |
| `{PROJECT_COUNT}` | 57 | Count folders matching `[0-9][0-9]-*` + test-99 |
| `{PROJECT_RANGE}` | 01-56 | First and last project numbers |
| `{SESSION_PHASE}` | Active Development | From current sprint/plan |
| `{LAST_STATUS_UPDATE}` | 2026-03-06 | Latest timestamp from project STATUS.md files |
| `{ACTIVE_PROJECT_COUNT}` | 54 | Count projects with maturity=active (from API) |
| `{UNPRIMED_COUNT}` | 6 | Count missing `.github/copilot-instructions.md` |
| `{TEST_COVERAGE}` | 87 | Average coverage across all projects (if available) |

---

## Usage for Project 7 Automation

### Recommended Workflow

```powershell
# 1. Load template
$template = Get-Content "07-foundation-layer/02-design/artifact-templates/copilot-instructions-workspace-template.md"

# 2. Gather context
$owner = Read-Host "Workspace owner"
$session = Read-Host "Session number"
$timestamp = Get-Date -Format "yyyy-MM-dd h:mm tt ZZ"

# 3. Expand placeholders
$expanded = $template `
    -replace '{WORKSPACE_OWNER}', $owner `
    -replace '{TIMESTAMP}', $timestamp `
    -replace '{SESSION_NUMBER}', $session `
    -replace '{SESSION_DESCRIPTION}', "Routine Sync" `
    -replace '{PROJECT_COUNT}', 57 `
    -replace '{PROJECT_RANGE}', "01-56" `
    -replace '{ACTIVE_PROJECT_COUNT}', (Count-ActiveProjects) `
    -replace '{UNPRIMED_COUNT}', (Count-UnprimedProjects)

# 4. Write to workspace
Set-Content "C:\AICOE\.github\copilot-instructions.md" $expanded

# 5. Commit
git add ".github/copilot-instructions.md"
git commit -m "chore(session $session): Update workspace instructions"
git push origin main
```

### Dry-Run Example

```powershell
# Test expansion without writing
$expanded = Invoke-TemplateExpansion -Template $template -DryRun
Write-Host $expanded | head -30  # Show first 30 lines
```

---

## Integration Points

### Where This Template Fits

```
Project 7 (Foundation Orchestrator)
        ↓
   Workspace Sync Cycle
        ↓
   Load template from: 
   /07-foundation-layer/02-design/artifact-templates/
   copilot-instructions-workspace-template.md
        ↓
   Expand variables with current session context
        ↓
   Write to: C:\AICOE\.github\copilot-instructions.md
        ↓
   Distribute to all 57 projects
```

### Compatibility

- **Stable with**: Project-level templates (separate filenames, no conflict)
- **Triggers**: Workspace sync, session start, major deliverables
- **Affects**: All agent sessions (reads workspace context first)
- **Depends on**: Project 37 API availability (bootstrap step)

---

## Content Sections

1. **Workspace Overview** — High-level description of EVA architecture
2. **Agent Bootstrap** — Directs agents to `/model/agent-guide` (CRITICAL)
3. **Workspace-Level Skills** — Available via `@skill-name`
4. **Key Architecture References** — Projects 37, 07, 48, 51
5. **For More Information** — Where to find docs at workspace level
6. **Workspace Context per Session** — Metrics updated each sync

---

## Testing the Template

### Validate Placeholder Coverage

```powershell
# Find all placeholders
$template = Get-Content "copilot-instructions-workspace-template.md"
[regex]::Matches($template, '{[A-Z_]+}') | Select-Object Value -Unique

# Expected output: 11 placeholders
```

### Validate Expansion

```powershell
# Ensure no placeholders remain after expansion
$expanded | Select-String '{[A-Z_]+}' | Measure-Object
# Should return 0 matches
```

### Validate against Project 51 Usage

```powershell
# Verify Project 51 (reference implementation) can read it
cd C:\AICOE\eva-foundry\51-ACA
# Agent should be able to:
# 1. Read workspace copilot-instructions from ../.github/
# 2. Bootstrap from /model/agent-guide
# 3. Access workspace skills list
```

---

## Maintenance Guidelines

### When to Update This Template

- API changes (new layers, new endpoints, bootstrap steps)
- Workspace architecture changes (new projects, new skills)
- Session context structure changes (new metrics)
- Bootstrap procedure updates in Project 37

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.1.0 | 2026-03-07 | API-first bootstrap aligned, 51 layers documented |
| 4.0.0 | 2026-03-07 | Initial template created for Session 38 |

### Migration Path

If stored in version control:
- Tag each version (e.g., `workspace-template-v4.1.0`)
- Keep historical versions for 2 quarters
- Document breaking changes in CHANGELOG

---

## FAQ

**Q: Can I customize the Workspace template for specific projects?**  
A: No. The workspace template is intentionally uniform across all 57 projects. Use project-level templates (PART 2) for customization.

**Q: How often should Project 7 update this?**  
A: Typically once per session (weekly). More frequent updates (e.g., daily) are OK; just ensure timestamps reflect actual sync time.

**Q: What if a variable can't be computed (e.g., {TEST_COVERAGE})?**  
A: Leave placeholder as-is. Use `$null` or "unknown" for reporting, but DO NOT break the template expansion.

**Q: Can agents cache this file locally?**  
A: Yes. Agents can read once per session and store in `$session.workspace_instructions`. Add a TTL of 4 hours (reset if > 4 hours old).

---

*Workspace template v4.1.0 | For Project 7 automation only | See copilot-instructions.md for agent usage*
