# Migration Guide: v1.3.0 to v1.7.0

**Project**: Apply-Project07-Artifacts.ps1  
**Migration Type**: Major upgrade with ecosystem integration  
**Estimated Time**: 2-4 hours per project (6+ hours for multi-module projects)  
**Risk Level**: Medium-High (new detection logic, governance integration)

---

## Executive Summary

v1.7.0 represents a **major evolution** in Project 07's capabilities:

- **10+ New Project Types**: From 4 basic types to 14 specialized classifications
- **EVA Ecosystem Integration**: Full awareness of 18 EVA projects + 11 Azure best practices
- **AI Governance Support**: Automatic detection and validation of governance requirements
- **Multi-Module Detection**: Native support for Project 18-style hub structures
- **Rich Context Generation**: Project-specific templates with discovered metadata

**Critical Change**: Projects may be **reclassified** with new detection logic. Review carefully before production deployment.

---

## Breaking Changes Summary

| Change | Impact | Mitigation |
|--------|--------|------------|
| **Project Type Expansion** | 4 → 14 types, reclassification likely | Review new classification, use `-Interactive` to override |
| **Governance Integration** | New validation checks for L2+ projects | Populate solution.yml, operational-readiness-checklist.md |
| **Multi-Module Support** | Changes PART 2 structure for hub projects | Review module navigation, adjust links |
| **Template v3.0.0** | New governance placeholders | Extract PART 2, re-run, merge governance sections |
| **Enhanced Validation** | 8 → 15 compliance checks | Fix new violations, use `-SkipValidation` temporarily |
| **Metadata Discovery** | Auto-populated fields may be inaccurate | Review and correct detected values |

---

## Pre-Migration Checklist

- [ ] **Backup all projects** (see Step 1)
- [ ] **Document current classifications** (4 old types)
- [ ] **Review AI governance requirements** (solution.yml, agent levels)
- [ ] **Identify multi-module projects** (Project 18, any hubs)
- [ ] **Test on sandbox project first** (non-critical, recoverable)
- [ ] **Review v1.7.0 CHANGELOG.md** (breaking changes)
- [ ] **Check governance compliance** (L2+ projects need extra prep)
- [ ] **Allocate time for 18 projects** (if migrating all)
- [ ] **Install Pester 5.x** (if running tests)
- [ ] **Read sprint backlog** (SPRINT-BACKLOG-v1.7.0.md)

---

## Migration Steps

### Step 1: Comprehensive Backup Strategy

```powershell
# Enhanced backup for v1.7.0 (includes governance files)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = "I:\EVA-Backups\project07-v1.7.0-migration-$timestamp"

$projects = @(
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\01-documentation-generator",
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\06-JP-Auto-Extraction",
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\11-MS-InfoJP",
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops",
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
    # Add all 18 projects if migrating ecosystem-wide
)

foreach ($project in $projects) {
    $projectName = Split-Path $project -Leaf
    $projectBackup = Join-Path $backupRoot $projectName
    New-Item -ItemType Directory -Path $projectBackup -Force | Out-Null
    
    # Backup copilot instructions
    $copilotFile = Join-Path $project ".github\copilot-instructions.md"
    if (Test-Path $copilotFile) {
        Copy-Item $copilotFile (Join-Path $projectBackup "copilot-instructions.md.v1.3.0") -Force
        Write-Host "[PASS] Backed up copilot instructions: $projectName" -ForegroundColor Green
    }
    
    # Backup governance files (NEW in v1.7.0)
    $governanceFiles = @(
        "solution.yml",
        "operational-readiness-checklist.md",
        "evidence\*"
    )
    
    foreach ($govFile in $governanceFiles) {
        $sourcePath = Join-Path $project $govFile
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $projectBackup -Recurse -Force
            Write-Host "[INFO] Backed up governance: $govFile" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "[PASS] Backup complete: $backupRoot" -ForegroundColor Green
Write-Host "[INFO] Retain backups for 90 days minimum" -ForegroundColor Yellow
```

### Step 2: Document Current State (CRITICAL for v1.7.0)

```powershell
# Generate pre-migration inventory
$inventoryFile = "I:\EVA-Backups\project07-pre-migration-inventory-$timestamp.csv"

$inventory = @()

foreach ($project in $projects) {
    $projectName = Split-Path $project -Leaf
    $copilotFile = Join-Path $project ".github\copilot-instructions.md"
    
    if (Test-Path $copilotFile) {
        $content = Get-Content $copilotFile -Raw
        
        # Extract current classification
        $classification = "Unknown"
        if ($content -match '\*\*System Type\*\*:\s*(.+)') {
            $classification = $matches[1].Trim()
        }
        
        # Check governance status
        $hasSolutionYml = Test-Path (Join-Path $project "solution.yml")
        $hasGovernance = Test-Path (Join-Path $project "docs\eva-ai-governance")
        
        $inventory += [PSCustomObject]@{
            Project = $projectName
            CurrentClassification = $classification
            HasCopilotInstructions = $true
            HasSolutionYml = $hasSolutionYml
            HasGovernanceFramework = $hasGovernance
            BackedUp = $true
        }
    }
}

$inventory | Export-Csv $inventoryFile -NoTypeInformation
Write-Host "[PASS] Inventory saved: $inventoryFile" -ForegroundColor Green
```

### Step 3: Test Detection on Sandbox Project

```powershell
# Test v1.7.0 detection logic before mass migration
cd "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\02-design\artifact-templates"

# Create test project structure
$testProject = "I:\EVA-Backups\project07-test-sandbox"
New-Item -ItemType Directory -Path $testProject -Force | Out-Null

# DRY RUN with verbose output
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $testProject `
    -DryRun `
    -Verbose

# Expected output shows:
# - New project type detection logic
# - Governance validation checks
# - Multi-module analysis (if applicable)
# - Template v3.0.0 preview
```

### Step 4: Run v1.7.0 Detection Analysis

```powershell
# Analyze all 18 projects without applying changes
$analysisResults = @()

foreach ($project in $projects) {
    Write-Host ""
    Write-Host "Analyzing: $project" -ForegroundColor Cyan
    
    # Run with -DryRun to preview classification
    $output = & .\Apply-Project07-Artifacts.ps1 `
        -TargetPath $project `
        -DryRun `
        2>&1 | Out-String
    
    # Extract detected type
    if ($output -match 'Project Type:\s*(.+)') {
        $newType = $matches[1].Trim()
        
        $analysisResults += [PSCustomObject]@{
            Project = Split-Path $project -Leaf
            DetectedType = $newType
            Timestamp = Get-Date
        }
        
        Write-Host "[INFO] Detected: $newType" -ForegroundColor Green
    }
}

# Compare with pre-migration inventory
$analysisResults | Export-Csv "I:\EVA-Backups\project07-v1.7.0-detection-analysis.csv" -NoTypeInformation
Write-Host ""
Write-Host "[PASS] Analysis complete. Review CSV for reclassifications." -ForegroundColor Green
```

### Step 5: Handle Reclassifications (CRITICAL REVIEW)

**Likely Reclassification Scenarios**:

| Old Type (v1.3.0) | New Type (v1.7.0) | Example Projects |
|-------------------|-------------------|------------------|
| General Purpose | AI Governance Framework | eva-ai-governance detection |
| General Purpose | Azure Best Practices Hub | Project 18 with 11 modules |
| General Purpose | FinOps / Cost Management | Project 14 with cost CSVs |
| Automation | Browser Automation (Playwright) | Project 06 with Playwright scripts |
| RAG System | Enhanced RAG with Citations | Project 11 with approaches/ detection |

**Review Process**:

```powershell
# For each reclassified project:

# 1. Check if new type is accurate
$project = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
$metadata = & .\Get-ProjectMetadata.ps1 -ProjectPath $project

Write-Host "Detected: $($metadata.ProjectType)"
Write-Host "Components: $($metadata.Components -join ', ')"
Write-Host "Special Features: $($metadata.SpecialFeatures -join ', ')"

# 2. If incorrect, use -Interactive mode to override
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $project `
    -Interactive

# When prompted:
# > Detected project type: Azure Best Practices Hub
# > Accept? (y/n): n
# > Select correct type:
# >   1. RAG System / Full-Stack Application
# >   2. Azure Functions / Serverless
# >   3. Automation / Scripting System
# >   ...
# > Enter number: 5
```

### Step 6: Apply v1.7.0 with Governance Integration

```powershell
# For governance-aware projects (has solution.yml)
$project = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\11-MS-InfoJP"

# Check governance status FIRST
$solutionYml = Join-Path $project "solution.yml"
if (Test-Path $solutionYml) {
    $content = Get-Content $solutionYml -Raw
    
    if ($content -match 'agent_level:\s*(\S+)') {
        $agentLevel = $matches[1]
        Write-Host "[INFO] Agent Level: $agentLevel" -ForegroundColor Cyan
        
        # L2+ requires operational readiness
        if ($agentLevel -in @('L2', 'L3')) {
            $opReadiness = Join-Path $project "operational-readiness-checklist.md"
            if (-not (Test-Path $opReadiness)) {
                Write-Host "[WARN] L2+ requires operational-readiness-checklist.md" -ForegroundColor Yellow
                Write-Host "[INFO] Create file before migration or use -SkipGovernanceValidation" -ForegroundColor Yellow
            }
        }
    }
}

# Apply migration
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $project `
    -ValidateGovernance  # NEW in v1.7.0
```

### Step 7: Handle Multi-Module Projects (Project 18 Pattern)

```powershell
# Special handling for hub projects with sub-modules
$hubProject = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"

# Detect modules
$modules = Get-ChildItem -Path $hubProject -Directory | Where-Object { $_.Name -match '^\d{2}-' }

Write-Host "[INFO] Detected $($modules.Count) sub-modules" -ForegroundColor Cyan
foreach ($module in $modules) {
    Write-Host "  - $($module.Name)" -ForegroundColor White
}

# Apply with multi-module detection enabled
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $hubProject `
    -DetectModules  # NEW in v1.7.0

# Generated PART 2 includes:
# - Module navigation table
# - Per-module deployment instructions
# - Upstream synchronization commands
# - Module-specific testing guidance
```

### Step 8: Extract and Merge PART 2 (Enhanced for v1.7.0)

```powershell
$instructionsFile = ".github\copilot-instructions.md"
$content = Get-Content $instructionsFile -Raw

# Extract PART 2 with governance sections
$part2Start = $content.IndexOf("## PART 2:")
$part2Content = $content.Substring($part2Start)

# Save extraction
$extractedFile = ".github\copilot-instructions-PART2-v1.3.0-extracted.md"
Set-Content $extractedFile $part2Content -Encoding UTF8

# NEW in v1.7.0: Extract governance sections separately
$governanceSections = @(
    "### Agent Level Classification",
    "### Compliance Validation",
    "### Governance Structure"
)

$governanceExtracted = ""
foreach ($section in $governanceSections) {
    if ($part2Content -match "(?s)($section.*?)(?=###|$)") {
        $governanceExtracted += $matches[1] + "`n`n"
    }
}

if ($governanceExtracted) {
    $govFile = ".github\governance-sections-v1.3.0.md"
    Set-Content $govFile $governanceExtracted -Encoding UTF8
    Write-Host "[INFO] Governance sections extracted: $govFile" -ForegroundColor Cyan
}

# Merge strategy for v1.7.0
Write-Host ""
Write-Host "Merge Instructions:" -ForegroundColor Yellow
Write-Host "1. Open side-by-side:"
Write-Host "   code --diff $extractedFile $instructionsFile"
Write-Host "2. Keep custom content from v1.3.0 extraction"
Write-Host "3. Add new v3.0.0 governance placeholders:"
Write-Host "   - [AGENT_LEVEL]: L0, L1, L2, L3"
Write-Host "   - [KILL_SWITCH_DOCUMENTED]: Yes/No (for L2+)"
Write-Host "   - [EARB_APPROVAL_DATE]: Date (for L3)"
Write-Host "4. Integrate multi-module navigation (if hub project)"
Write-Host "5. Update module count and links"
```

### Step 9: Validate Governance Compliance (NEW in v1.7.0)

```powershell
# Run governance-specific validation
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -ValidateOnly `
    -ValidateGovernance

# Expected checks:
# [CHECK] solution.yml exists
# [CHECK] agent_level declared: L1
# [CHECK] Agent level is valid (L0/L1/L2/L3)
# [CHECK] Operational readiness documented (L2+)
# [CHECK] Kill-switch mechanism documented (L2+)
# [CHECK] Evidence directory exists
# [CHECK] Governance policies present (if framework)
# [WARN] EARB approval recommended for L3

# Fix failures:
if ($failureDetected) {
    # Create missing files
    New-Item "solution.yml" -ItemType File -Force
    
    # Add agent_level
    @"
name: MyProject
version: 1.0.0
agent_level: L1
"@ | Set-Content "solution.yml"
    
    # For L2+: Create operational readiness
    if ($agentLevel -in @('L2', 'L3')) {
        Copy-Item "I:\EVA-JP-v1.2\docs\eva-ai-governance\30-evidence\templates\operational-readiness-checklist.md" .
    }
}
```

### Step 10: Review Enhanced Metadata (v3.0.0 Template)

```powershell
# New placeholders in v3.0.0 (vs v2.1.0)
$newPlaceholders = @"
**Governance Compliance**:
- Agent Level: [AGENT_LEVEL] (L0/L1/L2/L3)
- Kill-Switch: [KILL_SWITCH_DOCUMENTED] (for L2+)
- EARB Approval: [EARB_APPROVAL_DATE] (for L3)

**Module Structure** (if hub):
- Total Modules: [MODULE_COUNT]
- Module List: [MODULE_LIST]
- Upstream Repos: [UPSTREAM_REPO_COUNT]

**Enhanced Discovery**:
- Browser Automation: [AUTOMATION_TYPE] (Playwright/Selenium/Puppeteer)
- RAG Approaches: [RAG_APPROACH_LIST]
- Cost Management: [COST_TOOLS_DETECTED]
- Monitoring: [MONITORING_STACK]
"@

# Populate from analysis
$project = "I:\YourProject"
$metadata = & .\Get-ProjectMetadata.ps1 -ProjectPath $project

# Replace placeholders
$instructionsFile = ".github\copilot-instructions.md"
$content = Get-Content $instructionsFile -Raw

$content = $content -replace '\[AGENT_LEVEL\]', $metadata.AgentLevel
$content = $content -replace '\[MODULE_COUNT\]', $metadata.BestPracticeCount
# ... continue for all placeholders

Set-Content $instructionsFile $content -Encoding UTF8
```

### Step 11: Run Expanded Test Suite

```powershell
# v1.7.0 expands tests from 60 → 120+ cases
cd "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\02-design\artifact-templates"

# Full test suite (includes governance tests)
Invoke-Pester .\Test-Project07-Deployment.ps1 -Output Detailed

# Expected results:
# - 120+ tests
# - 15+ new governance compliance tests
# - 10+ multi-module detection tests
# - 20+ enhanced project type tests
# - Duration: ~8-10 minutes (vs 3-5 for v1.3.0)

# Review failures and fix
```

### Step 12: Mass Migration Strategy (18 Projects)

```powershell
# Phased rollout for ecosystem-wide migration

# Phase 1: Non-critical test projects (Week 1)
$phase1Projects = @(
    "01-documentation-generator",
    "10-MkDocs-PoC",
    "13-vscode-tools"
)

# Phase 2: Automation and infrastructure (Week 2)
$phase2Projects = @(
    "06-JP-Auto-Extraction",
    "14-az-finops",
    "15-cdc"
)

# Phase 3: RAG systems (Week 3)
$phase3Projects = @(
    "08-CDS-RAG",
    "11-MS-InfoJP",
    "16-engineered-case-law"
)

# Phase 4: Multi-module hubs and governance (Week 4)
$phase4Projects = @(
    "18-azure-best",
    "eva-ai-governance"  # Special handling
)

# Phase 5: Remaining projects (Week 5-6)
# ... rest of 18 projects

# Migration script
function Invoke-ProjectMigration {
    param(
        [string[]]$ProjectNames,
        [string]$Phase
    )
    
    Write-Host ""
    Write-Host "=== PHASE $Phase MIGRATION ===" -ForegroundColor Cyan
    
    foreach ($name in $ProjectNames) {
        $projectPath = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\$name"
        
        Write-Host ""
        Write-Host "[INFO] Migrating: $name" -ForegroundColor Yellow
        
        try {
            .\Apply-Project07-Artifacts.ps1 `
                -TargetPath $projectPath `
                -ValidateGovernance `
                -ErrorAction Stop
            
            Write-Host "[PASS] Success: $name" -ForegroundColor Green
        }
        catch {
            Write-Host "[FAIL] Failed: $name" -ForegroundColor Red
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
            
            # Log failure for review
            Add-Content "migration-failures.log" "$name,$Phase,$($_.Exception.Message)"
        }
    }
}

# Execute phased migration
Invoke-ProjectMigration -ProjectNames $phase1Projects -Phase "1"
# Review, adjust, continue with phase 2...
```

---

## Rollback Procedures

### Quick Rollback (Single Project)

```powershell
# Restore from backup
$project = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\11-MS-InfoJP"
$backup = "I:\EVA-Backups\project07-v1.7.0-migration-20260129_143052\11-MS-InfoJP"

Copy-Item (Join-Path $backup "copilot-instructions.md.v1.3.0") `
          (Join-Path $project ".github\copilot-instructions.md") `
          -Force

Write-Host "[PASS] Rolled back: $project" -ForegroundColor Green
```

### Ecosystem-Wide Rollback

```powershell
# Restore all projects from timestamped backup
$backupRoot = "I:\EVA-Backups\project07-v1.7.0-migration-20260129_143052"

Get-ChildItem $backupRoot -Directory | ForEach-Object {
    $projectName = $_.Name
    $projectPath = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\$projectName"
    
    if (Test-Path $projectPath) {
        $backupFile = Join-Path $_.FullName "copilot-instructions.md.v1.3.0"
        $targetFile = Join-Path $projectPath ".github\copilot-instructions.md"
        
        if (Test-Path $backupFile) {
            Copy-Item $backupFile $targetFile -Force
            Write-Host "[PASS] Rolled back: $projectName" -ForegroundColor Green
        }
    }
}
```

---

## Common Migration Issues

### Issue 1: Project Reclassified to Wrong Type

**Symptom**: Project 06 detected as "General Purpose" instead of "Browser Automation"

**Root Cause**: Playwright scripts in subdirectories not detected

**Solution**:
```powershell
# Use -Interactive mode with manual override
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\EVA-JP-v1.2\docs\eva-foundation\projects\06-JP-Auto-Extraction" `
    -Interactive

# When prompted:
# > Detected: General Purpose Project
# > Correct? (y/n): n
# > Override to: Browser Automation (Playwright)
```

### Issue 2: Governance Validation Blocks Deployment

**Symptom**: [FAIL] L2 requires operational-readiness-checklist.md

**Root Cause**: Agent level L2 but missing required documentation

**Solution**:
```powershell
# Option 1: Create missing file
cd "I:\YourProject"
Copy-Item "I:\EVA-JP-v1.2\docs\eva-ai-governance\30-evidence\templates\operational-readiness-checklist.md" .

# Add kill-switch documentation (required for L2)
# Edit operational-readiness-checklist.md and add:
# - Kill-switch mechanism description
# - Emergency shutdown procedures
# - Human intervention capabilities

# Option 2: Skip governance validation temporarily
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -SkipGovernanceValidation

# Then fix governance files before production
```

### Issue 3: Multi-Module Project Generates Wrong Navigation

**Symptom**: Module list incomplete or links broken

**Root Cause**: Non-standard module naming (not ##-name pattern)

**Solution**:
```powershell
# Check module structure
cd "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
Get-ChildItem -Directory | Where-Object { $_.Name -match '^\d{2}-' }

# If modules exist but not detected:
# 1. Verify naming: 01-monitoring, 02-cost-management (leading zero required)
# 2. Check for README.md in each module
# 3. Use -DetectModules flag explicitly

.\Apply-Project07-Artifacts.ps1 `
    -TargetPath $PWD `
    -DetectModules `
    -Verbose  # Shows detection logic
```

### Issue 4: Too Many New Placeholders

**Symptom**: Quality validation fails with >70% TODO density

**Root Cause**: v3.0.0 template adds 20+ new placeholders

**Solution**:
```powershell
# Strategy 1: Incremental population (recommended)
# Focus on [CRITICAL] governance placeholders only:
# - [AGENT_LEVEL]
# - [KILL_SWITCH_DOCUMENTED] (if L2+)

# Strategy 2: Relaxed validation threshold
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -AllowHighTodoThreshold  # NEW in v1.7.0

# Strategy 3: Staged population over sprints
# Week 1: Governance placeholders (5-10 items)
# Week 2: Module navigation (5-10 items)
# Week 3: Enhanced metadata (10-15 items)
```

### Issue 5: Governance Framework Project Misdetected

**Symptom**: eva-ai-governance detected as "General Purpose"

**Root Cause**: Detection looks for `docs\eva-ai-governance`, not root governance folder

**Solution**:
```powershell
# Manually specify project type
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\EVA-JP-v1.2\docs\eva-ai-governance" `
    -ProjectType "AI Governance Framework" `
    -Interactive

# Or adjust detection logic in script (lines 414-430)
# Add check for root-level governance structure
```

### Issue 6: Lost Custom Governance Sections

**Symptom**: Custom L2 documentation disappeared after migration

**Root Cause**: Failed to extract governance sections separately

**Solution**:
```powershell
# Restore and re-merge carefully
$backup = ".github\copilot-instructions.md.v1.3.0.backup"
$current = ".github\copilot-instructions.md"

# Extract governance sections from backup
$backupContent = Get-Content $backup -Raw
$govSections = @(
    "### Agent Level Classification",
    "### Kill-Switch Documentation"
)

# Extract each section
foreach ($section in $govSections) {
    if ($backupContent -match "(?s)($section.*?)(?=###|##|$)") {
        $extracted = $matches[1]
        
        # Append to current file in correct location
        # (before "### Next Steps" typically)
        # Manual merge required
    }
}
```

---

## Post-Migration Validation Checklist

### Per-Project Validation

- [ ] **Classification Correct**: Project type matches reality
- [ ] **PART 2 Complete**: All [CRITICAL] placeholders populated
- [ ] **Governance Valid**: agent_level declared (if applicable)
- [ ] **L2+ Requirements**: Operational readiness + kill-switch documented
- [ ] **Multi-Module Navigation**: All modules listed with working links
- [ ] **Custom Content Preserved**: Pre-migration PART 2 content retained
- [ ] **Quality Score**: >70% (or approved exception)
- [ ] **Copilot Tested**: Ask 3-5 project-specific questions
- [ ] **Team Notified**: Developers aware of new instructions
- [ ] **Backup Retained**: Keep for 90 days minimum

### Ecosystem-Wide Validation

- [ ] **All 18 Projects Migrated**: No projects left on v1.3.0
- [ ] **Governance Projects Validated**: eva-ai-governance, solution.ymls correct
- [ ] **Multi-Module Hubs Validated**: Project 18 and any other hubs
- [ ] **Test Suite Passing**: 120+ tests at >95% pass rate
- [ ] **No Regressions**: Existing functionality still works
- [ ] **Documentation Updated**: README.md, changelogs current
- [ ] **Team Training**: Developers understand new features
- [ ] **Migration Log Complete**: All issues documented
- [ ] **Backups Archived**: Stored in secure location
- [ ] **Rollback Tested**: Verified rollback procedures work

---

## Migration Timeline (6-Week Recommended)

### **Week 1: Preparation & Testing**
- **Day 1-2**: Backup all projects, document current state
- **Day 3-4**: Test v1.7.0 on 2-3 sandbox projects
- **Day 5**: Review reclassifications, adjust detection logic if needed

### **Week 2: Phase 1 Migration (Non-Critical Projects)**
- **Day 1-3**: Migrate projects 01, 10, 13 (documentation generators)
- **Day 4-5**: Populate [CRITICAL] placeholders, validate quality

### **Week 3: Phase 2 Migration (Automation & Infrastructure)**
- **Day 1-2**: Migrate projects 06, 14, 15 (automation, finops, cdc)
- **Day 3-4**: Handle Project 06 Playwright detection edge cases
- **Day 5**: Validate all Phase 2 with test suite

### **Week 4: Phase 3 Migration (RAG Systems)**
- **Day 1-2**: Migrate projects 08, 11, 16 (RAG, InfoJP, case law)
- **Day 3**: Populate enhanced RAG metadata (approaches, citations)
- **Day 4-5**: Validate Copilot integration with RAG-specific prompts

### **Week 5: Phase 4 Migration (Multi-Module & Governance)**
- **Day 1-2**: Migrate Project 18 (11 sub-modules) - most complex
- **Day 3-4**: Migrate eva-ai-governance (special handling)
- **Day 5**: Validate multi-module navigation, governance compliance

### **Week 6: Cleanup & Documentation**
- **Day 1-2**: Migrate any remaining projects (if >18 total)
- **Day 3**: Ecosystem-wide validation, test suite run
- **Day 4**: Update team documentation, conduct training
- **Day 5**: Retrospective, archive backups, mark complete

---

## Support & Resources

- **SPRINT-BACKLOG-v1.7.0.md**: User stories and task breakdown
- **v1.7.0-IMPLEMENTATION-SUMMARY.md**: Implementation details and progress
- **CHANGELOG.md**: Full list of v1.7.0 changes
- **README.md**: Updated Project 07 documentation
- **copilot-instructions-template.md v3.0.0**: New template reference
- **Test-Project07-Deployment.ps1**: Expanded test suite (120+ tests)
- **EVA AI Governance INDEX.md**: Governance requirements reference
- **Project 18 README.md**: Multi-module hub example

---

## Success Criteria

**Migration considered successful when**:
1. All 18 EVA projects migrated to v1.7.0
2. Project classifications accurate (manual review confirms)
3. Governance compliance validated for L2+ projects
4. Multi-module navigation working (Project 18 validated)
5. Quality scores >70% across ecosystem
6. Test suite passing at >95% (120+ tests)
7. Zero Copilot regressions reported
8. Team trained on new governance features
9. Backups archived and retention policy implemented
10. Migration retrospective completed with lessons learned

---

## Lessons Learned (Update Post-Migration)

**What Went Well**:
- [TODO: Add after migration]

**What Could Be Improved**:
- [TODO: Add after migration]

**Unexpected Issues**:
- [TODO: Add after migration]

**Recommendations for v2.0.0**:
- [TODO: Add after migration]

---

**Last Updated**: January 29, 2026  
**Guide Version**: 1.0  
**Applies To**: Apply-Project07-Artifacts.ps1 v1.3.0 → v1.7.0  
**Migration Status**: Planning Phase - Ready for Implementation
