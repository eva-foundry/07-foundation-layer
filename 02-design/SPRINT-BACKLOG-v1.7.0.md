# Sprint Backlog: Project 07 v1.7.0

**Sprint ID**: Sprint-P07-v1.7.0  
**Sprint Goal**: Integrate comprehensive EVA ecosystem awareness into Project 07 with support for 10+ project types, AI governance validation, and multi-module detection  
**Sprint Duration**: 2 weeks (January 30 - February 13, 2026)  
**Team**: Marco + AI Assistant (Copilot)  
**Capacity**: 60 story points (30 per week)

---

## Sprint Goals & Success Criteria

### Primary Goals
1. ✅ **Enhanced Project Detection**: Expand from 4 to 14 specialized project types with 95%+ accuracy
2. ✅ **Governance Integration**: Automatic validation of AI governance requirements (agent levels L0-L3)
3. ✅ **Multi-Module Support**: Native detection and documentation of hub projects (Project 18 pattern)
4. ✅ **Rich Context Generation**: Project-specific PART 2 templates with discovered metadata

### Success Criteria
- [ ] All 18 EVA projects correctly classified (100% accuracy)
- [ ] Governance compliance detection for L0-L3 agent levels working
- [ ] Project 18 generates 11-module navigation correctly
- [ ] Test coverage expands to 120+ cases with 95%+ pass rate
- [ ] Template v3.0.0 deployed with new governance placeholders
- [ ] Migration guide validated on 3+ test projects
- [ ] Zero breaking changes to existing v1.3.0 functionality

---

## Backlog Overview

### Story Points by Category

| Category | Points | % of Sprint |
|----------|--------|-------------|
| **Enhanced Detection** | 21 | 35% |
| **Template Generation** | 16 | 27% |
| **Multi-Module Support** | 8 | 13% |
| **Governance Integration** | 8 | 13% |
| **Test Expansion** | 5 | 8% |
| **Documentation** | 2 | 3% |
| **TOTAL** | **60** | **100%** |

### Sprint Commitment Level
- **Must Have**: 42 points (70%)
- **Should Have**: 13 points (22%)
- **Could Have**: 5 points (8%)

---

## User Stories

### Epic 1: Enhanced Project Type Detection

#### US-001: Expand Project Type Detection to 14 Types
**Priority**: Must Have  
**Story Points**: 8  
**Assignee**: Marco

**As a** developer  
**I want** Project 07 to detect 14 specialized project types (vs 4)  
**So that** PART 2 templates are highly relevant and accurate

**Acceptance Criteria**:
- [ ] **AC-001**: New project types detected:
  - AI Governance Framework (YAML policies, controls)
  - Azure Best Practices Hub (numbered modules)
  - FinOps / Cost Management (cost CSVs, FinOps PowerShell)
  - Documentation / Code Generation (templates, generators)
  - Browser Automation - Playwright (Playwright scripts)
  - Enhanced RAG with Citations (approaches/, citation tracking)
  - Azure Functions - Advanced (Durable Functions, bindings)
  - Infrastructure Orchestration (Terraform + PowerShell)
  - Monitoring & Observability (Grafana, Prometheus, AMBA)
  - Container Orchestration (ACA, AKS manifests)
- [ ] **AC-002**: Detection accuracy >95% on 18 EVA projects
- [ ] **AC-003**: `-Interactive` mode allows manual override
- [ ] **AC-004**: Detection logic documented in Apply-Project07-Artifacts.ps1 comments

**Technical Notes**:
```powershell
# Update Get-ProjectMetadata function (lines 373-469)
# Add new detection patterns:

# AI Governance Framework detection
$hasGovernancePolicies = Test-Path (Join-Path $ProjectPath "10-policy\*.yml")
$hasGovernanceControls = Test-Path (Join-Path $ProjectPath "20-controls\*.json")

if ($hasGovernancePolicies -and $hasGovernanceControls) {
    $ProjectType = "AI Governance Framework"
    $SpecialFeatures += "YAML Policies"
    $SpecialFeatures += "JSON Controls"
    $SpecialFeatures += "Agent Level Classification"
}

# Azure Best Practices Hub detection
$numberedModules = Get-ChildItem $ProjectPath -Directory | 
    Where-Object { $_.Name -match '^\d{2}-' }

if ($numberedModules.Count -ge 5) {
    $ProjectType = "Azure Best Practices Hub"
    $SpecialFeatures += "Multi-Module Structure"
    $SpecialFeatures += "$($numberedModules.Count) Sub-Modules"
}

# Continue for all 14 types...
```

**Dependencies**: None  
**Blocked By**: None

---

#### US-002: Add Special Features Detection
**Priority**: Must Have  
**Story Points**: 5  
**Assignee**: Marco

**As a** developer  
**I want** Project 07 to detect special features within projects  
**So that** PART 2 includes relevant technology-specific guidance

**Acceptance Criteria**:
- [ ] **AC-001**: Playwright scripts detected (`*.spec.ts`, `playwright.config.ts`)
- [ ] **AC-002**: RAG approaches detected (`approaches/chatread*.py`)
- [ ] **AC-003**: Cost management tools detected (`*cost*.csv`, `*finops*.ps1`)
- [ ] **AC-004**: Monitoring stacks detected (`prometheus.yml`, `grafana/`)
- [ ] **AC-005**: Special features added to metadata object
- [ ] **AC-006**: Template generation uses special features for conditional content

**Technical Notes**:
```powershell
# Add to Get-ProjectMetadata function
$SpecialFeatures = @()

# Playwright detection
$playwrightConfig = Get-ChildItem $ProjectPath -Recurse -Filter "playwright.config.*" -ErrorAction SilentlyContinue
if ($playwrightConfig) {
    $SpecialFeatures += "Playwright Browser Automation"
    
    $specFiles = Get-ChildItem $ProjectPath -Recurse -Filter "*.spec.ts" -ErrorAction SilentlyContinue
    $SpecialFeatures += "$($specFiles.Count) Playwright Test Specs"
}

# RAG approaches detection
$approachesDir = Join-Path $ProjectPath "app\backend\approaches"
if (Test-Path $approachesDir) {
    $approaches = Get-ChildItem $approachesDir -Filter "*.py"
    $SpecialFeatures += "RAG System with $($approaches.Count) Approaches"
    
    foreach ($approach in $approaches) {
        $SpecialFeatures += "  - $($approach.BaseName)"
    }
}

# Add to metadata return object
return @{
    ProjectType = $ProjectType
    SpecialFeatures = $SpecialFeatures
    # ... existing properties
}
```

**Dependencies**: US-001  
**Blocked By**: None

---

#### US-003: Implement Governance Compliance Level Detection
**Priority**: Must Have  
**Story Points**: 8  
**Assignee**: Marco

**As a** developer  
**I want** Project 07 to detect AI governance compliance level (L0-L3)  
**So that** appropriate governance requirements are documented

**Acceptance Criteria**:
- [ ] **AC-001**: Parse `solution.yml` for `agent_level` field
- [ ] **AC-002**: Validate agent level is L0, L1, L2, or L3
- [ ] **AC-003**: Detect L2+ requirements:
  - operational-readiness-checklist.md exists
  - Kill-switch mechanism documented
- [ ] **AC-004**: Detect L3 requirements:
  - EARB approval documented
  - Human oversight procedures defined
- [ ] **AC-005**: Add governance level to metadata object
- [ ] **AC-006**: Warning if agent_level missing but governance structure present

**Technical Notes**:
```powershell
# Add new function
function Get-GovernanceLevel {
    param([string]$ProjectPath)
    
    $solutionYml = Join-Path $ProjectPath "solution.yml"
    if (-not (Test-Path $solutionYml)) {
        return $null
    }
    
    $content = Get-Content $solutionYml -Raw
    
    $agentLevel = $null
    if ($content -match 'agent_level:\s*(\S+)') {
        $agentLevel = $matches[1]
    }
    
    # Validate level
    if ($agentLevel -notin @('L0', 'L1', 'L2', 'L3')) {
        Write-Warning "Invalid agent level: $agentLevel"
        return $null
    }
    
    # Check L2+ requirements
    $compliance = @{
        AgentLevel = $agentLevel
        HasOperationalReadiness = $false
        HasKillSwitch = $false
        HasEARBApproval = $false
    }
    
    if ($agentLevel -in @('L2', 'L3')) {
        $opReadiness = Join-Path $ProjectPath "operational-readiness-checklist.md"
        $compliance.HasOperationalReadiness = Test-Path $opReadiness
        
        # Check for kill-switch documentation
        if (Test-Path $opReadiness) {
            $opContent = Get-Content $opReadiness -Raw
            $compliance.HasKillSwitch = $opContent -match 'kill-?switch'
        }
    }
    
    if ($agentLevel -eq 'L3') {
        # Check for EARB approval
        $compliance.HasEARBApproval = $content -match 'earb_approval'
    }
    
    return $compliance
}
```

**Dependencies**: None  
**Blocked By**: None

---

### Epic 2: Intelligent PART 2 Template Generation

#### US-004: Create Governance Framework Template
**Priority**: Must Have  
**Story Points**: 5  
**Assignee**: Marco

**As a** developer  
**I want** specialized PART 2 template for AI Governance Framework projects  
**So that** governance policies, controls, and evidence templates are documented

**Acceptance Criteria**:
- [ ] **AC-001**: Template includes discovered policy count
- [ ] **AC-002**: Template includes control count
- [ ] **AC-003**: Template includes evidence template count
- [ ] **AC-004**: Template includes agent level definitions (L0-L3)
- [ ] **AC-005**: Template includes validation workflow documentation
- [ ] **AC-006**: Template includes PR gating process

**Technical Notes**:
```powershell
function Get-GovernanceFrameworkTemplate {
    param($Metadata)
    
    $template = @"
## PART 2: AI GOVERNANCE FRAMEWORK - PROJECT SPECIFIC

### System Overview
**Purpose**: Governance-as-code framework for AI agent development
**Agent Levels**: L0 (No AI) → L3 (Autonomous)
**Policies**: $($Metadata.PolicyCount) YAML policies
**Controls**: $($Metadata.ControlCount) JSON controls
**Evidence Templates**: $($Metadata.EvidenceTemplateCount) templates

### Governance Structure
``````
10-policy/           # YAML policy definitions
  allowed-agent-levels.yml
  data-residency.yml
  ...
20-controls/         # JSON control specifications
  operational-readiness.json
  kill-switch.json
  ...
30-evidence/         # Evidence collection templates
  templates/
  examples/
40-automation/       # Validation scripts
  validators/
  pr-gate/
``````

### Agent Level Classification
$($Metadata.AgentLevelTable)

### Validation Workflow
1. **PR Creation**: Developer commits governance changes
2. **Schema Validation**: YAML/JSON syntax and schema validation
3. **Compliance Check**: Policy adherence validation
4. **Evidence Review**: Required evidence documents checked
5. **Approval**: Manual review by governance team
6. **Merge**: Changes merged to main branch

### Critical Patterns
- **Policy Changes**: Require 2+ approvals
- **Agent Level Upgrades**: Document operational readiness
- **L2+ Projects**: Kill-switch mechanism mandatory
- **L3 Projects**: EARB approval required
"@
    
    return $template
}
```

**Dependencies**: US-003  
**Blocked By**: None

---

#### US-005: Create Azure Best Practices Hub Template
**Priority**: Must Have  
**Story Points**: 5  
**Assignee**: Marco

**As a** developer  
**I want** specialized PART 2 template for multi-module hub projects  
**So that** module navigation and deployment workflows are documented

**Acceptance Criteria**:
- [ ] **AC-001**: Template includes module count and list
- [ ] **AC-002**: Template includes per-module navigation table with links
- [ ] **AC-003**: Template includes upstream repository count
- [ ] **AC-004**: Template includes deployment workflow per module
- [ ] **AC-005**: Template includes testing guidance per module
- [ ] **AC-006**: Template works for Project 18 (11 modules)

**Technical Notes**:
```powershell
function Get-BestPracticesHubTemplate {
    param($Metadata)
    
    # Generate module navigation table
    $moduleTable = "| Module | Purpose | Est. Time | Deployment |\n"
    $moduleTable += "|--------|---------|-----------|------------|\n"
    
    foreach ($module in $Metadata.Modules) {
        $moduleTable += "| [$($module.Name)]($($module.Path)/README.md) | "
        $moduleTable += "$($module.Purpose) | "
        $moduleTable += "$($module.EstimatedTime) | "
        $moduleTable += "``````./Deploy-$($module.Number)-*.ps1`````` |\n"
    }
    
    $template = @"
## PART 2: AZURE BEST PRACTICES HUB - PROJECT SPECIFIC

### Hub Overview
**Total Modules**: $($Metadata.Modules.Count)
**Upstream Repositories**: $($Metadata.UpstreamRepoCount)
**Categories**: $($Metadata.Categories -join ', ')

### Module Navigation
$moduleTable

### Deployment Workflow
1. **Clone Upstream Repositories**: ``````.\generation-modules\05-Clone-Upstream-Repos.ps1``````
2. **Deploy Module**: ``````.\Deploy-01-MarcoSub.ps1`````` (adjust number for target module)
3. **Validate Deployment**: ``````.\tests\Test-Module-Deployment.ps1 -ModuleName 01-monitoring``````
4. **Sync Upstream Changes**: ``````.\Update-From-Upstream.ps1 -ModuleName 01-monitoring``````

### Module-Specific Testing
Each module has dedicated tests in ``````tests/``````directory:
- **Structure Tests**: Validate folder organization
- **Deployment Tests**: Test deployment scripts
- **Integration Tests**: Validate Azure resource provisioning

### Critical Patterns
- **Module Independence**: Each module deployable standalone
- **Upstream Sync**: Weekly sync from original repositories
- **Testing Required**: All modules have ≥80% test coverage
- **Documentation Standard**: Each module has README with AC validation
"@
    
    return $template
}
```

**Dependencies**: US-006 (multi-module detection)  
**Blocked By**: None

---

#### US-006: Create Browser Automation Template
**Priority**: Should Have  
**Story Points**: 3  
**Assignee**: Marco

**As a** developer  
**I want** specialized PART 2 template for Playwright automation projects  
**So that** browser automation patterns and test specs are documented

**Acceptance Criteria**:
- [ ] **AC-001**: Template includes Playwright version
- [ ] **AC-002**: Template includes test spec count
- [ ] **AC-003**: Template includes page object model structure (if present)
- [ ] **AC-004**: Template includes authentication flow documentation
- [ ] **AC-005**: Template includes critical wait patterns
- [ ] **AC-006**: Template works for Project 06

**Technical Notes**:
```powershell
function Get-BrowserAutomationTemplate {
    param($Metadata)
    
    $template = @"
## PART 2: BROWSER AUTOMATION (PLAYWRIGHT) - PROJECT SPECIFIC

### Automation Overview
**Framework**: Playwright for Python
**Test Specs**: $($Metadata.TestSpecCount) test files
**Authentication**: $($Metadata.AuthenticationMethod)
**Encoding Safety**: UTF-8 enforced (Windows cp1252 workaround)

### Project Structure
``````
scripts/
  authenticate_jp.py        # Authentication module
  run_jp_batch.py          # Batch execution runner
  [OTHER_SCRIPTS]
input/
  questions.csv            # Input data
output/
  jp_answers.csv          # Results
  jp_answers.json         # Structured output
debug/
  screenshots/            # Visual evidence
  html/                   # HTML dumps
``````

### Critical Patterns
**Encoding Safety** (MANDATORY):
``````powershell
# Always run with UTF-8 encoding
set PYTHONIOENCODING=utf-8 && python scripts\run_jp_batch.py
``````

**Response Completion Detection**:
- Poll every 5 seconds for content changes
- Require 3 consecutive stable checks
- Complex queries take 3-8 minutes
- Check for citations: "2024 FC 679", "Decision:"

**Evidence Collection**:
- Screenshots at operation boundaries (before/after/error)
- HTML dumps for post-mortem analysis
- Structured JSON logs with timestamps
"@
    
    return $template
}
```

**Dependencies**: US-002 (special features detection)  
**Blocked By**: None

---

#### US-007: Create FinOps Template
**Priority**: Should Have  
**Story Points**: 3  
**Assignee**: Marco

**As a** developer  
**I want** specialized PART 2 template for FinOps/cost management projects  
**So that** cost analysis tools and optimization workflows are documented

**Acceptance Criteria**:
- [ ] **AC-001**: Template includes cost analysis script count
- [ ] **AC-002**: Template includes cost CSV structure
- [ ] **AC-003**: Template includes optimization workflow
- [ ] **AC-004**: Template includes budget alert configuration
- [ ] **AC-005**: Template works for Project 14

**Dependencies**: US-002  
**Blocked By**: None

---

### Epic 3: Multi-Module Support

#### US-008: Implement Multi-Module Metadata Extraction
**Priority**: Must Have  
**Story Points**: 8  
**Assignee**: Marco

**As a** developer  
**I want** Project 07 to extract metadata from hub sub-modules  
**So that** module-specific information is available for template generation

**Acceptance Criteria**:
- [ ] **AC-001**: Detect numbered modules (##-name pattern)
- [ ] **AC-002**: Extract module purpose from README.md (first paragraph)
- [ ] **AC-003**: Extract estimated deployment time from README.md
- [ ] **AC-004**: Detect deployment scripts per module (`Deploy-##-*.ps1`)
- [ ] **AC-005**: Detect test directories per module (`tests/Test-*`)
- [ ] **AC-006**: Count upstream cloned repositories per module
- [ ] **AC-007**: Build module navigation data structure

**Technical Notes**:
```powershell
function Get-MultiModuleMetadata {
    param([string]$ProjectPath)
    
    $modules = Get-ChildItem $ProjectPath -Directory | 
        Where-Object { $_.Name -match '^(\d{2})-(.+)$' }
    
    if ($modules.Count -eq 0) {
        return $null
    }
    
    $moduleData = @()
    
    foreach ($module in $modules) {
        $moduleNumber = $matches[1]
        $moduleName = $matches[2]
        $modulePath = $module.FullName
        
        # Extract purpose from README
        $readmePath = Join-Path $modulePath "README.md"
        $purpose = "No description available"
        $estimatedTime = "Unknown"
        
        if (Test-Path $readmePath) {
            $readmeContent = Get-Content $readmePath -Raw
            
            # First paragraph after title
            if ($readmeContent -match '(?s)^#[^\n]+\n\n(.+?)\n\n') {
                $purpose = $matches[1].Trim()
            }
            
            # Extract estimated time
            if ($readmeContent -match 'Estimated.*?(\d+\s*(?:hours?|mins?))', 'i') {
                $estimatedTime = $matches[1]
            }
        }
        
        # Detect deployment scripts
        $deployScripts = Get-ChildItem $ProjectPath -Filter "Deploy-$moduleNumber-*.ps1"
        
        # Detect tests
        $testDir = Join-Path $modulePath "tests"
        $testCount = 0
        if (Test-Path $testDir) {
            $testCount = (Get-ChildItem $testDir -Filter "Test-*.ps1").Count
        }
        
        # Detect cloned repos
        $clonedDir = Join-Path $modulePath "cloned-repos"
        $repoCount = 0
        if (Test-Path $clonedDir) {
            $repoCount = (Get-ChildItem $clonedDir -Directory).Count
        }
        
        $moduleData += @{
            Number = $moduleNumber
            Name = "$moduleNumber-$moduleName"
            Path = $module.Name
            Purpose = $purpose
            EstimatedTime = $estimatedTime
            DeploymentScripts = $deployScripts
            TestCount = $testCount
            UpstreamRepoCount = $repoCount
        }
    }
    
    return @{
        Modules = $moduleData
        TotalModules = $moduleData.Count
        TotalUpstreamRepos = ($moduleData | Measure-Object -Property UpstreamRepoCount -Sum).Sum
    }
}
```

**Dependencies**: None  
**Blocked By**: None

---

### Epic 4: Governance-Aware Validation

#### US-009: Implement Test-GovernanceCompliance Function
**Priority**: Must Have  
**Story Points**: 8  
**Assignee**: Marco

**As a** developer  
**I want** automated governance compliance validation  
**So that** L2+ projects are validated for required documentation

**Acceptance Criteria**:
- [ ] **AC-001**: Check solution.yml exists
- [ ] **AC-002**: Validate agent_level field present and valid (L0/L1/L2/L3)
- [ ] **AC-003**: For L2+: Validate operational-readiness-checklist.md exists
- [ ] **AC-004**: For L2+: Validate kill-switch mechanism documented
- [ ] **AC-005**: For L3: Validate EARB approval documented
- [ ] **AC-006**: Check evidence directory structure exists (if L1+)
- [ ] **AC-007**: Generate remediation steps for failures
- [ ] **AC-008**: Return compliance report object

**Technical Notes**:
```powershell
function Test-GovernanceCompliance {
    param(
        [string]$ProjectPath,
        [switch]$GenerateReport
    )
    
    $report = @{
        Compliant = $true
        AgentLevel = "L0"
        Checks = @()
        Violations = @()
        Recommendations = @()
    }
    
    # Check 1: solution.yml exists
    $solutionYml = Join-Path $ProjectPath "solution.yml"
    if (Test-Path $solutionYml) {
        $report.Checks += "[PASS] solution.yml exists"
        
        # Parse agent level
        $content = Get-Content $solutionYml -Raw
        if ($content -match 'agent_level:\s*(\S+)') {
            $agentLevel = $matches[1]
            
            if ($agentLevel -in @('L0', 'L1', 'L2', 'L3')) {
                $report.AgentLevel = $agentLevel
                $report.Checks += "[PASS] Agent level valid: $agentLevel"
            } else {
                $report.Compliant = $false
                $report.Violations += "[FAIL] Invalid agent level: $agentLevel"
                $report.Recommendations += "Set agent_level to L0, L1, L2, or L3"
            }
        } else {
            $report.Compliant = $false
            $report.Violations += "[FAIL] agent_level not declared in solution.yml"
            $report.Recommendations += "Add 'agent_level: L1' to solution.yml"
        }
    } else {
        $report.Checks += "[WARN] solution.yml not found (L0 assumed)"
        $report.Recommendations += "Create solution.yml with agent_level declaration"
    }
    
    # Check 2: L2+ requirements
    if ($report.AgentLevel -in @('L2', 'L3')) {
        $opReadiness = Join-Path $ProjectPath "operational-readiness-checklist.md"
        
        if (Test-Path $opReadiness) {
            $report.Checks += "[PASS] Operational readiness documented"
            
            # Check for kill-switch
            $opContent = Get-Content $opReadiness -Raw
            if ($opContent -match 'kill-?switch|emergency.*shutdown|manual.*override') {
                $report.Checks += "[PASS] Kill-switch mechanism documented"
            } else {
                $report.Compliant = $false
                $report.Violations += "[FAIL] Kill-switch not documented (required for L2+)"
                $report.Recommendations += "Add kill-switch section to operational-readiness-checklist.md"
            }
        } else {
            $report.Compliant = $false
            $report.Violations += "[FAIL] operational-readiness-checklist.md missing (required for L2+)"
            $report.Recommendations += "Copy template from docs\eva-ai-governance\30-evidence\templates\"
        }
    }
    
    # Check 3: L3 requirements
    if ($report.AgentLevel -eq 'L3') {
        $content = Get-Content $solutionYml -Raw
        
        if ($content -match 'earb_approval|EARB.*approval') {
            $report.Checks += "[PASS] EARB approval documented"
        } else {
            $report.Compliant = $false
            $report.Violations += "[FAIL] EARB approval not documented (required for L3)"
            $report.Recommendations += "Add 'earb_approval: YYYY-MM-DD' to solution.yml"
        }
    }
    
    # Check 4: Evidence directory
    if ($report.AgentLevel -in @('L1', 'L2', 'L3')) {
        $evidenceDir = Join-Path $ProjectPath "evidence"
        
        if (Test-Path $evidenceDir) {
            $report.Checks += "[PASS] Evidence directory exists"
        } else {
            $report.Recommendations += "Create evidence/ directory for compliance artifacts"
        }
    }
    
    # Generate report
    if ($GenerateReport) {
        $reportFile = Join-Path $ProjectPath "governance-compliance-report.txt"
        
        $reportContent = @"
Governance Compliance Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Project: $ProjectPath
Agent Level: $($report.AgentLevel)
Overall Status: $(if ($report.Compliant) { '[PASS] COMPLIANT' } else { '[FAIL] NON-COMPLIANT' })

Validation Checks:
$($report.Checks -join "`n")

Violations:
$($report.Violations -join "`n")

Recommendations:
$($report.Recommendations -join "`n")
"@
        
        Set-Content $reportFile $reportContent -Encoding UTF8
        Write-Host "[INFO] Compliance report generated: $reportFile" -ForegroundColor Cyan
    }
    
    return $report
}
```

**Dependencies**: US-003  
**Blocked By**: None

---

### Epic 5: Test Suite Expansion

#### US-010: Expand Test Suite to 120+ Cases
**Priority**: Must Have  
**Story Points**: 5  
**Assignee**: Marco

**As a** developer  
**I want** comprehensive test coverage for v1.7.0 features  
**So that** regressions are prevented and quality is maintained

**Acceptance Criteria**:
- [ ] **AC-001**: 60 → 120+ test cases implemented
- [ ] **AC-002**: New test contexts added:
  - Multi-Module Project Detection (10 tests)
  - AI Governance Compliance (15 tests)
  - Extended Project Type Detection (20 tests)
  - Specialized Template Generation (10 tests)
  - Module Navigation (5 tests)
- [ ] **AC-003**: Test coverage >95% for new functions
- [ ] **AC-004**: All tests pass on clean v1.7.0 codebase
- [ ] **AC-005**: Test execution time <15 minutes
- [ ] **AC-006**: Test results generate HTML report

**Technical Notes**:
```powershell
# Add to Test-Project07-Deployment.ps1

Describe "Multi-Module Project Detection" {
    Context "Project 18 Azure Best Practices Hub" {
        It "Should detect 11 sub-modules" {
            $metadata = & .\Get-ProjectMetadata.ps1 -ProjectPath "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
            $metadata.Modules.Count | Should -Be 11
        }
        
        It "Should detect numbered module pattern (##-name)" {
            $metadata = & .\Get-ProjectMetadata.ps1 -ProjectPath "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
            $metadata.Modules[0].Number | Should -Match '^\d{2}$'
        }
        
        It "Should extract module purpose from README" {
            $metadata = & .\Get-ProjectMetadata.ps1 -ProjectPath "I:\EVA-JP-v1.2\docs\eva-foundation\projects\18-azure-best"
            $metadata.Modules[0].Purpose | Should -Not -BeNullOrEmpty
        }
        
        # ... 7 more tests
    }
}

Describe "AI Governance Compliance Validation" {
    Context "Agent Level L0 (No AI)" {
        It "Should not require operational readiness" {
            $report = Test-GovernanceCompliance -ProjectPath "TestDrive:\L0Project"
            $report.Compliant | Should -Be $true
        }
    }
    
    Context "Agent Level L2 (Semi-Autonomous)" {
        It "Should require operational-readiness-checklist.md" {
            Mock Test-Path { $false } -ParameterFilter { $Path -like "*operational-readiness*" }
            
            $report = Test-GovernanceCompliance -ProjectPath "TestDrive:\L2Project"
            $report.Compliant | Should -Be $false
            $report.Violations | Should -Contain "*operational-readiness*"
        }
        
        It "Should require kill-switch documentation" {
            # ... test implementation
        }
        
        # ... 12 more tests
    }
}

Describe "Extended Project Type Detection" {
    Context "AI Governance Framework" {
        It "Should detect governance framework from YAML policies" {
            # ... test implementation
        }
        # ... 4 more tests for governance
    }
    
    Context "Browser Automation - Playwright" {
        It "Should detect Playwright from config file" {
            # ... test implementation
        }
        # ... 3 more tests for Playwright
    }
    
    # ... 6 more project type contexts
}
```

**Dependencies**: All US-001 through US-009  
**Blocked By**: None

---

### Epic 6: Documentation & Migration

#### US-011: Update Template to v3.0.0
**Priority**: Must Have  
**Story Points**: 2  
**Assignee**: Marco

**As a** developer  
**I want** copilot-instructions-template.md upgraded to v3.0.0  
**So that** new governance and multi-module placeholders are available

**Acceptance Criteria**:
- [ ] **AC-001**: Add governance placeholders:
  - [AGENT_LEVEL]
  - [KILL_SWITCH_DOCUMENTED]
  - [EARB_APPROVAL_DATE]
- [ ] **AC-002**: Add multi-module placeholders:
  - [MODULE_COUNT]
  - [MODULE_LIST]
  - [UPSTREAM_REPO_COUNT]
- [ ] **AC-003**: Add enhanced discovery placeholders:
  - [AUTOMATION_TYPE]
  - [RAG_APPROACH_LIST]
  - [COST_TOOLS_DETECTED]
  - [MONITORING_STACK]
- [ ] **AC-004**: Update version number to v3.0.0
- [ ] **AC-005**: Update CHANGELOG.md with v3.0.0 changes

**Dependencies**: None  
**Blocked By**: None

---

## Task Breakdown by Sprint Day

### Week 1: Core Implementation

**Day 1-2 (Jan 30-31)**: Enhanced Detection
- [ ] US-001: Expand project types (8 points)
- [ ] US-002: Special features detection (5 points)
- **Subtasks**:
  - Update Get-ProjectMetadata function (lines 373-469)
  - Add 10 new project type detection patterns
  - Add Playwright, RAG, cost tool detection
  - Test on 18 EVA projects
  - Document detection logic

**Day 3-4 (Feb 1-2)**: Governance Integration
- [ ] US-003: Governance level detection (8 points)
- [ ] US-009: Test-GovernanceCompliance function (8 points)
- **Subtasks**:
  - Create Get-GovernanceLevel function
  - Parse solution.yml files
  - Validate L2+ requirements (operational readiness, kill-switch)
  - Create Test-GovernanceCompliance function
  - Test on projects with solution.yml

**Day 5 (Feb 3)**: Buffer & Testing
- [ ] Integration testing for Week 1 deliverables
- [ ] Fix issues found during testing
- [ ] Code review and documentation

---

### Week 2: Templates & Testing

**Day 6-7 (Feb 6-7)**: Template Generation
- [ ] US-004: Governance framework template (5 points)
- [ ] US-005: Best practices hub template (5 points)
- [ ] US-006: Browser automation template (3 points)
- [ ] US-007: FinOps template (3 points)
- **Subtasks**:
  - Create Get-GovernanceFrameworkTemplate
  - Create Get-BestPracticesHubTemplate
  - Create Get-BrowserAutomationTemplate
  - Create Get-FinOpsTemplate
  - Test template generation on real projects

**Day 8 (Feb 8)**: Multi-Module Support
- [ ] US-008: Multi-module metadata extraction (8 points)
- **Subtasks**:
  - Create Get-MultiModuleMetadata function
  - Extract purpose, estimated time, deployment scripts
  - Build module navigation data structure
  - Test on Project 18 (11 modules)

**Day 9 (Feb 9)**: Test Expansion
- [ ] US-010: Expand test suite to 120+ (5 points)
- **Subtasks**:
  - Add multi-module tests (10 tests)
  - Add governance compliance tests (15 tests)
  - Add project type tests (20 tests)
  - Add template generation tests (10 tests)
  - Generate HTML test report

**Day 10 (Feb 10)**: Documentation & Cleanup
- [ ] US-011: Template v3.0.0 upgrade (2 points)
- [ ] Final integration testing
- [ ] Update CHANGELOG.md
- [ ] Update README.md
- [ ] Code review and refinement

---

## Sprint Velocity Tracking

### Story Points Completed by Day

| Day | Date | Points Completed | Cumulative | % Complete |
|-----|------|------------------|------------|------------|
| 1 | Jan 30 | 0 | 0 | 0% |
| 2 | Jan 31 | 13 | 13 | 22% |
| 3 | Feb 1 | 8 | 21 | 35% |
| 4 | Feb 2 | 8 | 29 | 48% |
| 5 | Feb 3 | 0 (buffer) | 29 | 48% |
| 6 | Feb 6 | 8 | 37 | 62% |
| 7 | Feb 7 | 8 | 45 | 75% |
| 8 | Feb 8 | 8 | 53 | 88% |
| 9 | Feb 9 | 5 | 58 | 97% |
| 10 | Feb 10 | 2 | 60 | 100% |

---

## Risk Assessment & Mitigation

### High Risks

**None identified** - all dependencies available, prerequisites met

### Medium Risks

1. **Project Reclassification Accuracy**
   - **Risk**: New detection logic misclassifies existing projects
   - **Probability**: 40%
   - **Impact**: Medium (requires manual correction)
   - **Mitigation**:
     - DryRun mode testing on all 18 projects before applying
     - `-Interactive` mode for manual override
     - Backup enforcement before any changes
     - Rollback procedures documented in migration guide

2. **Governance Integration Complexity**
   - **Risk**: solution.yml parsing fails on edge cases
   - **Probability**: 30%
   - **Impact**: Medium (blocks L2+ validation)
   - **Mitigation**:
     - Test on all existing solution.yml files
     - Graceful degradation if parsing fails
     - Clear error messages with remediation steps

3. **Multi-Module Navigation Generation**
   - **Risk**: Module count/links incorrect for Project 18
   - **Probability**: 25%
   - **Impact**: Medium (navigation broken)
   - **Mitigation**:
     - Dedicated tests for Project 18
     - Manual validation of generated navigation
     - Fallback to manual placeholder if detection fails

### Low Risks

4. **Test Suite Execution Time**
   - **Risk**: 120+ tests take >15 minutes
   - **Probability**: 20%
   - **Impact**: Low (developer inconvenience)
   - **Mitigation**: Parallel test execution, selective test runs

5. **Template Placeholder Overload**
   - **Risk**: Too many new placeholders (>70% TODO density)
   - **Probability**: 30%
   - **Impact**: Low (quality validation flags)
   - **Mitigation**: Prioritize [CRITICAL] placeholders, staged population

---

## Dependencies & Blockers

### External Dependencies
- **Pester 5.x**: ✅ Installed and working
- **EVA Project Structure**: ✅ Stable, no breaking changes expected
- **Governance Framework**: ✅ Finalized, policies and controls defined

### Internal Dependencies
```
US-001 (Detection) ─┬─> US-002 (Special Features) ─┬─> US-006 (Browser Template)
                    │                               └─> US-007 (FinOps Template)
                    └─> US-003 (Governance) ────────┬─> US-004 (Gov Template)
                                                     └─> US-009 (Compliance)

US-008 (Multi-Module) ──────────────────────────────> US-005 (Hub Template)

US-001 through US-009 ───────────────────────────────> US-010 (Test Expansion)

All US ───────────────────────────────────────────────> US-011 (Template v3.0.0)
```

### Current Blockers
**NONE** - Ready to start implementation

---

## Definition of Done

A user story is considered **DONE** when:

1. ✅ **Code Complete**: All functions implemented and commented
2. ✅ **Unit Tests Pass**: Pester tests for new functions pass (100%)
3. ✅ **Integration Tests Pass**: Tested on real EVA projects
4. ✅ **Code Review**: Peer review complete (AI assistant + self-review)
5. ✅ **Documentation Updated**: Inline comments and README.md current
6. ✅ **No Regressions**: Existing v1.3.0 functionality still works
7. ✅ **Acceptance Criteria Met**: All AC checkboxes verified
8. ✅ **Performance Acceptable**: Test suite runs in <15 minutes

The sprint is considered **DONE** when:

1. ✅ All 60 story points completed
2. ✅ Test suite expands to 120+ tests with 95%+ pass rate
3. ✅ All 18 EVA projects correctly classified
4. ✅ Project 18 multi-module navigation working
5. ✅ Governance compliance validation operational
6. ✅ Template v3.0.0 deployed
7. ✅ Migration guide validated on test projects
8. ✅ CHANGELOG.md and README.md updated
9. ✅ No critical or high-severity bugs
10. ✅ Sprint retrospective complete

---

## Sprint Ceremonies

### Daily Standup (Self-Review)
- **When**: Each morning before work
- **Duration**: 5 minutes
- **Questions**:
  1. What did I complete yesterday?
  2. What will I work on today?
  3. Any blockers or risks?

### Sprint Review (Feb 13, End of Day)
- **Attendees**: Self-review with documentation
- **Agenda**:
  1. Demo new features (14 project types, governance validation, multi-module)
  2. Review test results (120+ tests)
  3. Validate on real projects (Project 06, 11, 18)
  4. Identify incomplete work
  5. Plan production rollout

### Sprint Retrospective (Feb 13, After Review)
- **Duration**: 30 minutes
- **Questions**:
  1. What went well?
  2. What could be improved?
  3. What will we do differently in next sprint?
  4. Lessons learned for documentation

---

## Next Steps After Sprint

### Immediate (Week of Feb 13)
1. Production rollout to 18 EVA projects (phased, 6 weeks)
2. Team communication and training
3. Monitor for issues and bugs
4. Create v1.7.1 patch if needed

### Future Sprints
1. **v1.8.0**: Additional project types (API services, data pipelines)
2. **v2.0.0**: Machine learning-based project classification
3. **v2.1.0**: Automated PART 2 content generation (reduce TODOs)

---

**Sprint Status**: ✅ Ready to Begin  
**Start Date**: January 30, 2026  
**End Date**: February 13, 2026  
**Last Updated**: January 29, 2026
