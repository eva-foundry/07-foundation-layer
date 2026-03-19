# Project Re-Priming Initiative (Session 37) - 6:53 PM ET

**Status**: READY FOR EXECUTION  
**Date**: March 6, 2026  
**Scope**: All numbered projects (01-56) + utilities (97-99)  

---

## What Is Re-Priming?

Re-priming is a workspace-wide governance refresh that applies:
1. Latest copilot instruction templates (Session 37 edition)
2. Updated DPDCA workflow patterns
3. Correct references to Project 37 data model (all 51 layers)
4. Session 37 context (cache layer fixes, Priority #4 readiness)
5. Best practices from Session 29+ governance work

---

## Pre-Requisites (MUST BE DONE FIRST)

✅ **Session 37 Bootstrap Complete**:
- [x] Project 37 (EVA Data Model) all 51 layers ✅
- [x] Cache layer test fixes (Session 35 Part C) ✅
- [x] Validation schema fixes (Session 35 Part A) ✅
- [x] Priority #4 framework ready for deployment ✅

✅ **Documentation Updated**:
- [x] Workspace copilot-instructions.md (date/time updated)
- [x] Project-level template created (SESSION 37 EDITION)

---

## Project Status Before Re-Priming

```
Total Projects:     57
Have Instructions:  54
Need Template:      6 (08, 17, 20, 34-eva-agents, 54, 99)
```

**Projects needing template creation**:
- 08-cds-rag
- 17-apim
- 20-assistme
- 34-eva-agents
- 54-ai-engineering-hub
- 99-test-project

**Projects with existing instructions** (update needed):
- All 51 remaining projects need timestamp + Session 37 context update

---

## Re-Priming Workflow

### Recommended: Use Built-In Automation

The foundation-layer provides production-ready priming scripts in `02-design/artifact-templates/`:

**Scripts Available**:
- `Invoke-PrimeWorkspace.ps1` (v1.0.0) - **RECOMMENDED**
- `Apply-Project07-Artifacts.ps1` (v1.5.0)
- `Reseed-Projects.ps1`
- `Bootstrap-Project07.ps1`

#### Step 1: Prime Single Project (Dry-Run First)

```powershell
cd C:\eva-foundry\07-foundation-layer\02-design\artifact-templates

# Preview what would be applied (no changes)
.\Invoke-PrimeWorkspace.ps1 `
  -TargetPath "C:\eva-foundry\01-documentation-generator" `
  -DryRun

# Apply for real (creates backup, preserves PART 2)
.\Invoke-PrimeWorkspace.ps1 `
  -TargetPath "C:\eva-foundry\01-documentation-generator"
```

#### Step 2: Prime All Projects in Workspace

```powershell
cd C:\eva-foundry\07-foundation-layer\02-design\artifact-templates

# Preview all projects (no changes)
.\Invoke-PrimeWorkspace.ps1 `
  -WorkspaceRoot "C:\eva-foundry\eva-foundry" `
  -DryRun

# Apply to all (idempotent - safe to run on already-primed projects)
.\Invoke-PrimeWorkspace.ps1 `
  -WorkspaceRoot "C:\eva-foundry\eva-foundry"
```

#### Step 3: Verify Results

```powershell
# Audit: check timestamps updated to Session 37
Get-ChildItem C:\eva-foundry\eva-foundry -Directory -Filter "[0-9]*" | ForEach-Object {
    $file = "$($_.FullName)\.github\copilot-instructions.md"
    if (Test-Path $file) {
        $updated = (Get-Content $file) -match "6:53 PM ET|March 6, 2026"
        "[$($_.Name)]: $updated"
    }
}

# Expected output: [01-documentation-generator]: True, [02-poc-agent-skills]: True, etc.
```

---

## What Invoke-PrimeWorkspace.ps1 Does

The automation script handles all these operations idempotently:

**For copilot-instructions.md**:
- ✅ Detects existing file and reads PART 2 (project-specific content)
- ✅ Backs up the original to `copilot-instructions.md.backup_YYYYMMDDHHMSS`
- ✅ Replaces PART 1 (universal rules) with updated version
- ✅ Preserves PART 2 (custom project rules)
- ✅ Updates timestamps and token substitutions
- ✅ Safe to run 100 times - PART 2 never lost

**For governance docs** (PLAN, STATUS, ACCEPTANCE, README):
- ✅ Creates from templates if missing
- ✅ Prevents overwrites if already present (idempotent markers: `<!-- eva-primed-plan -->`)
- ✅ Token substitution: {{PROJECT_FOLDER}}, {{PROJECT_LABEL}}, {{PROJECT_MATURITY}}, etc.
- ✅ Validates deployment after each project

**Built-in Templates**:
- `governance/PLAN-template.md` - Project phases, stories, features
- `governance/STATUS-template.md` - Last session, blockers, metrics
- `governance/ACCEPTANCE-template.md` - Definition of Done, quality gates
- `governance/README-header-block.md` - Project identity block

---

## Automation Script Parameters

### Key Flags

| Flag | Purpose | Default |
|------|---------|---------|
| `-TargetPath` | Single project | (none - use -WorkspaceRoot instead) |
| `-WorkspaceRoot` | All projects | (none - use -TargetPath instead) |
| `-DryRun` | Preview without changes | false |
| `-SkipCopilotInstructions` | Skip copilot-instructions.md | false |
| `-DataModelBase` | Data model URL | http://localhost:8010 |
| `-Actor` | Who is running this | agent:copilot |

### Examples

```powershell
cd C:\eva-foundry\07-foundation-layer\02-design\artifact-templates

# Example 1: Single project, dry-run
.\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\37-data-model" -DryRun

# Example 2: Single project, apply
.\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\37-data-model"

# Example 3: Entire workspace, dry-run (preview all changes)
.\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry" -DryRun

# Example 4: Entire workspace, apply (full re-prime)
.\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry"

# Example 5: Skip copilot-instructions, update governance only
.\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\51-ACA" -SkipCopilotInstructions
```

---

---

## Manual Approach (If Preferred)

### Manual Step 1: Update Timestamps

```powershell
# Update the "Last Updated" field to 2026-03-06 18:53 ET
Get-ChildItem C:\eva-foundry\eva-foundry -Directory -Filter "[0-9]*" | ForEach-Object {
    $file = "$($_.FullName)\.github\copilot-instructions.md"
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $content = $content -replace 'Last Updated.*?ET', 'Last Updated**: March 6, 2026 @ 6:53 PM ET'
        Set-Content $file -Value $content -Encoding UTF8
        Write-Host "Updated: $($_.Name)"
    }
}
```

### Manual Step 2: Add Session 37 Context

Add note to projects' STATUS.md or PLAN.md:
> **Session 37 Update** (6:53 PM ET): All 51 data model layers operational. Project 37 now single source of truth. Cache layer test fixes (Session 35 Part C) complete and ready for production deployment.

### Manual Step 3: For Missing Templates (6 Projects)

Get the template from foundation layer and customize:

```powershell
$template = Get-Content "C:\eva-foundry\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md" -Raw

# Replace template tokens for specific project:
$instructions = $template -replace '{PROJECT_NAME}', '08-cds-rag'
$instructions = $instructions -replace '{PROJECT_FOLDER}', '08-cds-rag'
$instructions = $instructions -replace '{PROJECT_STACK}', '[FILL_IN_TECH_STACK]'

# Save to project
$path = "C:\eva-foundry\08-cds-rag\.github"
New-Item $path -ItemType Directory -Force | Out-Null
Set-Content "$path\copilot-instructions.md" -Value $instructions -Encoding UTF8
```

**Note**: The automated `Invoke-PrimeWorkspace.ps1` does this for all projects in seconds. Recommended for consistency.

### Manual Step 4: Verify & Commit

```powershell
# Quick audit
Get-ChildItem C:\eva-foundry\eva-foundry -Directory  -Filter "[0-9]*" | ForEach-Object {
    $file = "$($_.FullName)\.github\copilot-instructions.md"
    $hasFile = Test-Path $file
    Write-Host "$($_.Name): $hasFile"
}

# Commit all updates
git add C:\eva-foundry\.github\copilot-instructions.md
git add "C:\eva-foundry\*\.github\copilot-instructions.md"
git add "C:\eva-foundry\*\PLAN.md"
git add "C:\eva-foundry\*\STATUS.md"
git add "C:\eva-foundry\*\ACCEPTANCE.md"

git commit -m "chore(workspace): Re-prime all projects with Session 37 context (6:53 PM ET)

Automated via Invoke-PrimeWorkspace.ps1:
- Update timestamps to March 6, 2026 @ 6:53 PM ET
- Add Session 37 status: All 51 data model layers operational
- Create governance templates for 6 projects missing instructions
- Update DPDCA patterns and best practices
- Preserve PART 2 (project-specific rules) in copilot-instructions
- Validate all projects reference Project 37 @ localhost:8010

Projects: 01-documentation-generator through 99-test-project
Template Version: 3.5.0 (March 1, 2026)"
```

```powershell
# Quick audit
Get-ChildItem C:\eva-foundry\eva-foundry -Directory  -Filter "[0-9]*" | ForEach-Object {
    $file = "$($_.FullName)\.github\copilot-instructions.md"
    $hasFile = Test-Path $file
    $isUpdated = $hasFile -and ((Get-Content $file) -match "6:53 PM ET")
    Write-Host "$($_.Name): $hasFile | Updated: $isUpdated"
}

# Commit with workspace-wide scope
git add C:\eva-foundry\.github\copilot-instructions.md
git add "C:\eva-foundry\*\.github\copilot-instructions.md"
git commit -m "chore(workspace): Re-prime all projects with Session 37 context (6:53 PM ET)

- Update timestamps to March 6, 2026 @ 6:53 PM ET
- Add Session 37 status: All 51 data model layers operational
- Create templates for 6 projects missing instructions
- Update DPDCA patterns and best practices
- Add cache layer test fix references (Session 35 Part C)
- Projects ready for individual governance re-seeding by foundation-expert"
```

---

## Post-Priming Actions

### For Foundation Expert (@foundation-expert)
Each project can now be re-seeded individually:

```powershell
# From project directory:
@foundation-expert prime [XX-PROJECT-ID]

# Or from workspace root:
@foundation-expert prime [XX-PROJECT-ID]
```

This will:
- Apply latest governance standards (PLAN, STATUS, ACCEPTANCE)
- Initialize/update data model references  
- Create/update skill manifests
- Validate against workspace patterns

### For Individual Projects
Once re-primed, each project should:
1. Read updated `copilot-instructions.md`
2. Update `PLAN.md` with Session 37 data model references
3. Validate test suite connects to Project 37 @ port 8010
4. Update `STATUS.md` with new session context

---

## Backlog: Projects Requiring Follow-Up

**Recommended Priority**:
1. **High**: 37-data-model, 51-ACA, 07-foundation-layer (core infrastructure)
2. **High**: 48-eva-veritas, 39-ado-dashboard, 31-eva-faces (governance tracking)
3. **Medium**: All remaining numbered projects (individual priming)

---

## References

- **Workspace Instructions**: `C:\eva-foundry\.github\copilot-instructions.md`
- **Template**: `07-foundation-layer\.github\PROJECT-COPILOT-INSTRUCTIONS-TEMPLATE.md`
- **Foundation Expert Skill**: `07-foundation-layer\.github\copilot-skills\foundation-expert.skill.md`
- **Session 37 Summary**: `37-data-model\SESSION-37-BOOTSTRAP-SUMMARY.md`

---

**Generated by**: Copilot Agent (March 6, 2026 @ 6:53 PM ET)  
**Status**: READY FOR EXECUTION - foundation-expert can proceed with re-priming  

