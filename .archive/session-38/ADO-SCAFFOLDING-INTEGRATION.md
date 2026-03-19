# ADO Scaffolding Integration Pattern

**Document**: ADO Project Scaffolding Integration  
**Task**: F07-02-003-T03 - Add ADO project creation to scaffolding workflow  
**Status**: Formalized (Session 38)  
**Applicability**: All new EVA projects during scaffolding  

---

## Overview

When a new project is scaffolded using Project 07's `Initialize-ProjectStructure.ps1` or `Apply-Project07-Artifacts.ps1`, the scaffolding workflow should automatically:

1. Generate `ado-artifacts.json` schema for the project
2. Register the project in Azure DevOps (create Epic → Features → PBIs)
3. Sync initial PLAN.md structure to ADO work items
4. Configure cost attribution headers

This document formalizes the integration pattern.

---

## Pattern: ADO Scaffolding Integration Flow

### Execution Sequence (After Folder Structure Creation)

```
Step 1: Create folder structure
    └── Initialize-ProjectStructure.ps1
        └── Creates required folders (scripts/, docs/, tests/, eval/, evidence/, .eva/)

Step 2: Apply Project 07 Copilot Instructions
    └── Apply-Project07-Artifacts.ps1
        ├── Deploy copilot-instructions.md (PART 1/2/3)
        └── Generate debug/ folder for evidence

Step 3: [NEW] Generate ADO Artifacts Schema
    └── Generate-ADO-Artifacts.ps1 (proposed)
        ├── Parse PLAN.md (project name, epics, features)
        ├── Parse README.md (project description)
        └── Generate ./ado-artifacts.json from template

Step 4: [NEW] Register Project in ADO
    └── Invoke-ADO-Registration.ps1 (proposed)
        ├── Call 38-ado-poc/scripts/ado-import-project.ps1
        ├── Create Epic in Azure DevOps
        ├── Create Features from PLAN.md
        ├── Create PBIs from stories
        └── Assign to current sprint

Step 5: [NEW] Seed Project 37 Data Model
    └── seed-from-plan.py
        ├── Parse PLAN.md
        ├── Generate .eva/veritas-plan.json
        └── POST to Project 37 API endpoint

Step 6: Configure Cost Attribution (APIM)
    └── Add .eva/config.json with project metadata
        ├── x-eva-project-id = project number
        ├── x-eva-business-unit = workspace config
        └── Agents will inject these headers on API calls
```

### Integrated Script: Initialize-Project-Full.ps1 (Proposed)

```powershell
param(
    [string]$ProjectFolder,           # e.g., "52-new-project"
    [string]$ProjectNumber,            # e.g., "52"
    [bool]$RegisterADO = $true,        # Auto-register in ADO
    [bool]$SeedDataModel = $true,      # Auto-seed Project 37
    [bool]$DryRun = $false
)

# Step 1: Scaffold folder structure
.\Initialize-ProjectStructure.ps1 `
    -ProjectRoot $ProjectFolder `
    -TemplateFile "supported-folder-structure-rag.json"

# Step 2: Apply Project 07 Copilot Instructions + Evidence
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $ProjectFolder `
    -DryRun:$DryRun

# Step 3: Generate ADO Artifacts Schema
if ($RegisterADO) {
    .\Generate-ADO-Artifacts.ps1 `
        -ProjectPath $ProjectFolder `
        -ProjectNumber $ProjectNumber
}

# Step 4: Register in ADO (if artifacts generated successfully)
if ($RegisterADO) {
    $ado_artifacts = Join-Path $ProjectFolder "ado-artifacts.json"
    if (Test-Path $ado_artifacts) {
        & "38-ado-poc/scripts/ado-import-project.ps1" `
            -ProjectId $ProjectNumber `
            -ArtifactsPath $ado_artifacts
    }
}

# Step 5: Seed Project 37 Data Model
if ($SeedDataModel) {
    Push-Location $ProjectFolder
    python "../07-foundation-layer/scripts/data-seeding/seed-from-plan.py" `
        --project-id $ProjectNumber
    Pop-Location
}

# Step 6: Configure Cost Attribution
$project_meta = @{
    project_id = $ProjectNumber
    business_unit = "AI COE"
    client_id = "internal-r&d"
} | ConvertTo-Json
Set-Content -Path "$ProjectFolder/.eva/config.json" -Value $project_meta
```

---

## Implementation Details

### Step 3a: Generate-ADO-Artifacts.ps1 (New Script)

**Purpose**: Auto-generate `ado-artifacts.json` from PLAN.md and README.md  
**Location**: `07-foundation-layer/scripts/deployment/Generate-ADO-Artifacts.ps1`  

```powershell
#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectNumber
)

function Get-ProjectNameFromPlan {
    param([string]$PlanPath)
    
    # Parse PLAN.md for project name
    # Look for pattern: "# PROJECT NN -- Title"
    # or "## EPIC 01 -- <Title>"
    if (Test-Path $PlanPath) {
        $content = Get-Content $PlanPath -Raw
        $match = [regex]::Match($content, "^#+\s+(?:PROJECT|EPIC)\s+\d+\s+--\s+(.+?)$", "Multiline")
        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        }
    }
    return "Project $ProjectNumber"
}

function Get-ProjectDescriptionFromReadme {
    param([string]$ReadmePath)
    
    # First non-comment line of README
    if (Test-Path $ReadmePath) {
        $content = Get-Content $ReadmePath | Where-Object { $_ -notmatch "^<!--|^#.*href" }
        return $content[0].Trim()
    }
    return "New EVA Project"
}

function Parse-PlanStructure {
    param([string]$PlanPath)
    
    $features = @()
    
    if (Test-Path $PlanPath) {
        $content = Get-Content $PlanPath -Raw
        $lines = $content -split "`n"
        
        $current_epic = $null
        $epic_count = 0
        $feature_count = 0
        
        foreach ($line in $lines) {
            # Match epic
            if ($line -match "^#+\s+EPIC\s+(\d+)\s+--\s+(.+)$") {
                $epic_count = [int]$matches[1]
                $current_epic = @{
                    epic_num = $epic_count
                    title = $matches[2]
                    features = @()
                }
            }
            
            # Match feature
            if ($line -match "^\s{0,4}Feature\s+(\d+)\.(\d+)\s+--\s+(.+)$") {
                $feature_num = [int]$matches[2]
                $feature_obj = @{
                    num = $feature_num
                    title = $matches[3]
                    stories = @()
                }
                
                if ($current_epic) {
                    $current_epic.features += $feature_obj
                }
                
                $features += $feature_obj
            }
            
            # Match story
            if ($line -match "^\s{2,6}Story\s+(\d+)\.(\d+)\.(\d+)\s+(.+)$") {
                $story_title = $matches[4]
                if ($current_epic -and $current_epic.features.Count -gt 0) {
                    $current_epic.features[-1].stories += @{ title = $story_title }
                }
            }
        }
    }
    
    return $features
}

function Generate-ADOArtifactsJson {
    param(
        [string]$ProjectNumber,
        [string]$ProjectName,
        [string]$ProjectDescription,
        [array]$Features
    )
    
    $artifacts = @{
        version = "1.0"
        project = @{
            id = $ProjectNumber
            name = $ProjectName
            description = $ProjectDescription
            area_path = "eva-foundry\project-$ProjectNumber"
            iteration_path = "eva-poc\Sprint 2026-Q1"
        }
        epic = @{
            id = [int]$ProjectNumber
            title = $ProjectName
            description = $ProjectDescription
            tags = @("project", "q1-2026", "active")
        }
        features = @()
    }
    
    foreach ($feature in $Features) {
        $feature_obj = @{
            id = "$($ProjectNumber)-$('{0:d2}' -f $feature.num)"
            title = $feature.title
            description = ""
            stories = @()
        }
        
        $story_counter = 1
        foreach ($story in $feature.stories) {
            $story_obj = @{
                id = "$($ProjectNumber)-$('{0:d2}' -f $feature.num)-$('{0:d3}' -f $story_counter)"
                title = $story.title
                acceptance = @(
                    "As a developer, I can execute this story",
                    "Then it contributes to project progress",
                    "Given all acceptance criteria are met"
                )
            }
            $feature_obj.stories += $story_obj
            $story_counter++
        }
        
        $artifacts.features += $feature_obj
    }
    
    return $artifacts | ConvertTo-Json -Depth 10
}

# Main execution
$PlanPath = Join-Path $ProjectPath "PLAN.md"
$ReadmePath = Join-Path $ProjectPath "README.md"
$OutputPath = Join-Path $ProjectPath "ado-artifacts.json"

$ProjectName = Get-ProjectNameFromPlan $PlanPath
$ProjectDescription = Get-ProjectDescriptionFromReadme $ReadmePath
$Features = Parse-PlanStructure $PlanPath

$JsonContent = Generate-ADOArtifactsJson $ProjectNumber $ProjectName $ProjectDescription $Features

Set-Content -Path $OutputPath -Value $JsonContent -Encoding UTF8

Write-Host "[PASS] Generated ado-artifacts.json"
Write-Host "  Project ID: $ProjectNumber"
Write-Host "  Features: $($Features.Count)"
```

### Step 4: Integration with ado-import-project.ps1

The existing `ado-import-project.ps1` script from Project 38 is called with the generated `ado-artifacts.json`:

```powershell
pwsh -File "38-ado-poc/scripts/ado-import-project.ps1" `
     -ProjectId $ProjectNumber `
     -ArtifactsPath "$ProjectPath/ado-artifacts.json" `
     -Force

# Output:
# [INFO] Reading ado-artifacts.json...
# [PASS] Epic 52 - New Project created
# [PASS] Feature 52-01 created
# [PASS] PBI 52-01-001 through 52-01-003 created
# [SUMMARY] 1 epic, 1 feature, 3 PBIs | Import complete
```

### Step 5: seed-from-plan.py Integration

Once ado-artifacts.json is generated and ADO is registered, the data model sync happens:

```bash
cd 52-new-project
python ../07-foundation-layer/scripts/data-seeding/seed-from-plan.py --reseed-model

# Output:
# [INFO] Inferred project ID from folder: 52
# [PASS] 3 stories seeded | veritas-plan.json written
# [INFO] Seeding HTTP data model...
# [PASS] Stories synced to Project 37 API
```

### Step 6: Cost Attribution Configuration

A `.eva/config.json` is created with metadata for APIM cost attribution:

```json
{
  "project_id": "52",
  "business_unit": "AI COE",
  "client_id": "internal-r&d",
  "contact": "project-lead@microsoft.com",
  "created_date": "2026-03-07",
  "registration_status": "active"
}
```

When agents in this project call EVA APIs, APIM injects headers:
```
x-eva-project-id: 52
x-eva-business-unit: AI COE
x-eva-client-id: internal-r&d
```

---

## Implementation Checklist

### To Implement This Pattern

- [ ] Create `Generate-ADO-Artifacts.ps1` script
  - Parse PLAN.md for epic/feature structure
  - Extract project name and description
  - Generate valid `ado-artifacts.json`
  - Test with Projects 36, 38, 39, 40, 48

- [ ] Create composite `Initialize-Project-Full.ps1` script
  - Orchestrate all 6 steps in sequence
  - Add error handling and rollback
  - Log each step to debug/ folder
  - Generate compliance report

- [ ] Integrate ADO PAT authentication
  - Store Azure DevOps PAT in GitHub Secrets or Key Vault
  - Retrieve at runtime for ado-import-project.ps1 calls
  - Handle authentication failures gracefully

- [ ] Add to `Invoke-PrimeWorkspace.ps1`
  - Include ADO registration as optional task
  - Add `--ado-register` flag for batch registration
  - Generate summary report (X projects registered)

- [ ] Testing & Validation
  - Test scaffolding workflow end-to-end on test project (99)
  - Verify ado-artifacts.json schema compliance
  - Verify ADO Epic/Feature/PBI creation
  - Verify veritas-plan.json generation
  - Verify Project 37 API sync

- [ ] Documentation
  - Update README.md with ADO scaffolding section
  - Add troubleshooting guide for ADO registration failures
  - Create runbook for manual ADO registration

---

## Error Scenarios & Recovery

### Scenario 1: ADO Registration Fails (PAT Expired)

```powershell
# Detection
if ($ado_result.Exit_Code -ne 0) {
    Write-Host "[FAIL] ADO registration failed"
    Write-Host "  Error: $($ado_result.Error)"
    
    # Recovery
    # Step 1: Refresh Azure DevOps PAT
    $new_pat = Read-Host "Enter new ADO PAT (or press Ctrl+C to exit)"
    $env:ADO_PAT = $new_pat
    
    # Step 2: Retry
    & "38-ado-poc/scripts/ado-import-project.ps1" `
         -ProjectId $ProjectNumber `
         -ArtifactsPath $ado_artifacts
}
```

### Scenario 2: PLAN.md Parsing Fails (Malformed)

```powershell
# Detection
if ($Features.Count -eq 0) {
    Write-Host "[WARN] No features detected in PLAN.md"
    Write-Host "  Expected format: '## EPIC NN -- Title' and '### Feature N.M -- Title'"
    
    # Recovery: Skip ADO registration, continue with manual creation
    Write-Host "[INFO] Skipping ADO registration. Creating empty ado-artifacts.json template."
    # Generate minimal template for manual editing
    $template = @{
        version = "1.0"
        project = @{ id = $ProjectNumber; name = "Manual Configuration Required" }
        features = @()
    } | ConvertTo-Json
    Set-Content -Path $ado_artifacts -Value $template
}
```

### Scenario 3: Project 37 Seed Fails (API Offline)

```powershell
# Detection
if ($seed_result.Exit_Code -ne 0) {
    Write-Host "[WARN] Project 37 seed failed, but ADO registration succeeded"
    Write-Host "  veritas-plan.json will be regenerated on next seed-from-plan.py run"
    
    # Recovery: File remains dirty, next seed will fix it
    # Write to evidence log for manual follow-up
    Add-Content -Path ".eva/evidence/scaffolding-incomplete.log" `
                -Value "Seed failed $(Get-Date): $($seed_result.Error)"
}
```

---

## Timeline & Phases

### Phase 1: Formalization (Session 38 - COMPLETE)
- ✅ Document pattern as part of F07-02-003-T03
- ✅ Create Generate-ADO-Artifacts.ps1 pseudo-code
- ✅ Define error handling scenarios
- ✅ Create checklist for implementation

### Phase 2: Implementation (F07-03-001 - Proposed)
- Create Generate-ADO-Artifacts.ps1 (real implementation)
- Create Initialize-Project-Full.ps1 (orchestrator)
- Test on Projects 36, 38, 39, 40, 48, 51, 99
- Integrate into Invoke-PrimeWorkspace.ps1

### Phase 3: Validation (F07-03-002 - Proposed)
- Full end-to-end test with new project scaffold
- Verify ADO → Project 37 → Veritas traceability
- Verify cost attribution headers configured
- Generate validation report

### Phase 4: Rollout (F07-03-003 - Proposed)
- Deploy to all projects via Invoke-PrimeWorkspace.ps1
- Update workspace documentation
- Close F07-02-003 and F07-03 epics

---

## Anti-Patterns & Pitfalls

❌ **Do NOT**: Hard-code Azure DevOps PAT in scripts  
✅ **DO**: Retrieve from GitHub Secrets or Key Vault at runtime

❌ **Do NOT**: Skip error handling for ado-import-project.ps1 failures  
✅ **DO**: Catch, log, and allow manual retry

❌ **Do NOT**: Assume PLAN.md has perfect formatting  
✅ **DO**: Create template if parsing fails (manual editing required)

❌ **Do NOT**: Register in ADO before Project 37 seed is complete  
✅ **DO**: Seed → ADO Register → Verify traceability

---

## Related Documentation

- **Data Model Integration**: [data-model-admin.skill.md](../../.github/copilot-skills/data-model-admin.skill.md)
- **ADO Integration Skill**: [ado-integration.skill.md](../../.github/copilot-skills/ado-integration.skill.md)
- **Seeding Pattern**: [SEED-FROM-PLAN-PATTERN.md](../SEED-FROM-PLAN-PATTERN.md)
- **Project 38**: [38-ado-poc/README.md](../../38-ado-poc/README.md)
- **Project 38 Scripts**: [38-ado-poc/scripts/](../../38-ado-poc/scripts/)

---

**Pattern Owner**: Project 07 (Foundation Layer)  
**Status**: Formalized (Session 38)  
**Implementation Ready**: Yes (all pseudo-code and patterns defined)  
**Target Completion**: F07-03-001 (implementation) + F07-03-002 (validation)  

