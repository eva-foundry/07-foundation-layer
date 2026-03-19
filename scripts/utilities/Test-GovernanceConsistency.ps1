<#
.SYNOPSIS
    Test-GovernanceConsistency.ps1 v1.1.0
    Automated governance documentation consistency validator

.DESCRIPTION
    Validates consistency across workspace governance documentation:
    - Live layer references (API-first or current 122-layer wording, no stale hardcoded counts)
    - Template version synchronization
    - Timestamp freshness
    - Bootstrap completeness (health + ready + handshake + guide + user-guide)
    - Category runbooks documentation path
    - Session summary coverage
    - Project copilot-instructions coverage

    Output: Markdown report with ✅/❌ for each check + remediation actions

.PARAMETER WorkspaceRoot
    Absolute path to workspace root. Default: C:\eva-foundry

.PARAMETER OutputPath
    Path for output markdown report. Default: console output

.EXAMPLE
    .\Test-GovernanceConsistency.ps1 -WorkspaceRoot "C:\eva-foundry"
    .\Test-GovernanceConsistency.ps1 -OutputPath ".\consistency-report.md"
#>

param(
    [Parameter()]
    [string]$WorkspaceRoot = "C:\eva-foundry",
    
    [Parameter()]
    [string]$OutputPath = $null
)

# DISCOVER Phase: Initialize
Write-Host "[INFO] Governance Consistency Check v1.1.0"
Write-Host "[INFO] Workspace: $WorkspaceRoot"
Write-Host "[INFO] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss ET')"
Write-Host ""

# Detect workspace structure
$parentWorkspace = Split-Path $WorkspaceRoot -Parent
$isEVAFoundrySubfolder = (Test-Path (Join-Path $parentWorkspace ".github\copilot-instructions.md"))

if ($isEVAFoundrySubfolder) {
    Write-Host "[INFO] Detected two-level workspace structure" -ForegroundColor Cyan
    Write-Host "  Parent: $parentWorkspace (workspace-level files)" -ForegroundColor Gray
    Write-Host "  EVA Foundry: $WorkspaceRoot (project folders)" -ForegroundColor Gray
    $workspaceInstructionsRoot = $parentWorkspace
    $evaFoundryRoot = $WorkspaceRoot
    $project07Root = Join-Path $WorkspaceRoot "07-foundation-layer"
} else {
    $workspaceInstructionsRoot = $WorkspaceRoot
    $evaFoundryRoot = $WorkspaceRoot
    $project07Root = Join-Path $WorkspaceRoot "07-foundation-layer"
}

Write-Host ""

$checkResults = @()
$passCount = 0
$failCount = 0
$warnCount = 0

function Add-CheckResult {
    param(
        [string]$Category,
        [string]$Check,
        [string]$Status,  # PASS, FAIL, WARN
        [string]$Details,
        [string]$Remediation = ""
    )
    
    $script:checkResults += [PSCustomObject]@{
        Category = $Category
        Check = $Check
        Status = $Status
        Details = $Details
        Remediation = $Remediation
    }
    
    switch ($Status) {
        "PASS" { $script:passCount++ }
        "FAIL" { $script:failCount++ }
        "WARN" { $script:warnCount++ }
    }
}

# ============================================================================
# CHECK 1: Live Layer Reference Consistency
# ============================================================================

Write-Host "[CHECK 1] Live layer reference consistency..." -ForegroundColor Cyan

$validLivePatterns = @(
    'layers_available\.Count',
    '122 layers',
    '122 live layers',
    'live layer count',
    'current cloud inventory'
)
$stalePatterns = @(
    '111 target layers',
    '91 operational',
    '20 planned',
    '145 layers',
    '111 operational layers',
    '51 operational layers',
    '50 base',
    '87 operational layers \(87 base'
)

# Files to check
$filesToCheck = @(
    "$workspaceInstructionsRoot\.github\copilot-instructions.md",
    "$project07Root\templates\copilot-instructions-workspace-template.md",
    "$project07Root\templates\copilot-instructions-template.md"
)

$layerCountIssues = @()
foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $hasLiveReference = $false
            foreach ($pattern in $validLivePatterns) {
                if ($content -match $pattern) {
                    $hasLiveReference = $true
                    break
                }
            }

            if (-not $hasLiveReference) {
                $layerCountIssues += "$file missing live layer reference terminology"
            }

            foreach ($pattern in $stalePatterns) {
                if ($content -match $pattern) {
                    $layerCountIssues += "$file contains stale layer pattern: '$pattern'"
                    break
                }
            }
        }
    } else {
        $layerCountIssues += "$file does not exist"
    }
}

# Special check for Project 07 copilot-instructions: Allow historical mentions in session summaries
$project07Instructions = "$project07Root\.github\copilot-instructions.md"
if (Test-Path $project07Instructions) {
    $content = Get-Content $project07Instructions -Raw
    
    # Check main content (before session summaries section)
    if ($content -match '(?s)## Session \d+ Updates') {
        $mainContent = $content -split '(?m)^## Session \d+ Updates', 2 | Select-Object -First 1
        $hasCorrectInMain = ($mainContent -match '122 layers') -or ($mainContent -match 'live layer count') -or ($mainContent -match 'current cloud inventory')
        
        if (-not $hasCorrectInMain) {
            $layerCountIssues += "$project07Instructions main content missing current live layer terminology"
        }
    }
}

if ($layerCountIssues.Count -eq 0) {
    Add-CheckResult -Category "Live Layer References" -Check "Consistent API-first layer references" -Status "PASS" `
        -Details "All files reference live layer inventory without stale hardcoded counts"
    Write-Host "  [PASS] Live layer references consistent across files" -ForegroundColor Green
} else {
    Add-CheckResult -Category "Live Layer References" -Check "Consistent API-first layer references" -Status "FAIL" `
        -Details "$($layerCountIssues.Count) live layer reference issues found" `
        -Remediation "Update files to use live layer expressions or the current 122-layer posture and remove stale hardcoded counts"
    Write-Host "  [FAIL] Live layer reference inconsistencies found:" -ForegroundColor Red
    foreach ($issue in $layerCountIssues) {
        Write-Host "    - $issue" -ForegroundColor Yellow
    }
}

# ============================================================================
# CHECK 2: Template Version Sync
# ============================================================================

Write-Host "[CHECK 2] Template version synchronization..." -ForegroundColor Cyan

$workspaceTemplate = "$project07Root\templates\copilot-instructions-workspace-template.md"
$projectTemplate = "$project07Root\templates\copilot-instructions-template.md"

$versions = @{}
foreach ($template in @($workspaceTemplate, $projectTemplate)) {
    if (Test-Path $template) {
        $content = Get-Content $template -Raw
        if ($content -match '\*\*Template Version\*\*[:\s]+(\d+\.\d+\.\d+)') {
            $versions[$template] = $matches[1]
        } else {
            $versions[$template] = "NOT_FOUND"
        }
    } else {
        $versions[$template] = "MISSING"
    }
}

$workspaceVer = $versions[$workspaceTemplate]
$projectVer = $versions[$projectTemplate]

if ($workspaceVer -eq $projectVer -and $workspaceVer -ne "NOT_FOUND" -and $workspaceVer -ne "MISSING") {
    Add-CheckResult -Category "Template Versions" -Check "Version synchronization" -Status "PASS" `
        -Details "Both templates at v$workspaceVer"
    Write-Host "  [PASS] Templates synchronized at v$workspaceVer" -ForegroundColor Green
} else {
    Add-CheckResult -Category "Template Versions" -Check "Version synchronization" -Status "FAIL" `
        -Details "Workspace: v$workspaceVer, Project: v$projectVer" `
        -Remediation "Update project template to match workspace template version"
    Write-Host "  [FAIL] Template version mismatch:" -ForegroundColor Red
    Write-Host "    Workspace: v$workspaceVer" -ForegroundColor Yellow
    Write-Host "    Project:   v$projectVer" -ForegroundColor Yellow
}

# ============================================================================
# CHECK 3: Timestamp Freshness
# ============================================================================

Write-Host "[CHECK 3] Timestamp freshness..." -ForegroundColor Cyan

$workspaceInstructions = "$workspaceInstructionsRoot\.github\copilot-instructions.md"
$timestampPatterns = @(
    '\*\*Last Updated\*\*[:\s]+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})',
    '\*\*Last Updated\*\*[:\s]+(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)'
)

if (Test-Path $workspaceInstructions) {
    $content = Get-Content $workspaceInstructions -Raw
    $lastUpdated = $null
    $timestamp = $null

    if ($content -match $timestampPatterns[0]) {
        $lastUpdated = "$($matches[1]) $($matches[2])"
        try {
            $timestamp = [datetime]::ParseExact($lastUpdated, "yyyy-MM-dd HH:mm", $null)
        } catch {
            Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "FAIL" `
                -Details "Could not parse timestamp: $lastUpdated" `
                -Remediation "Fix timestamp format to 'YYYY-MM-DD HH:MM'"
            Write-Host "  [FAIL] Could not parse timestamp" -ForegroundColor Red
        }
    } elseif ($content -match $timestampPatterns[1]) {
        $lastUpdated = $matches[1]
        try {
            $timestamp = [datetime]::Parse($lastUpdated)
        } catch {
            Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "FAIL" `
                -Details "Could not parse ISO timestamp: $lastUpdated" `
                -Remediation "Fix timestamp format to ISO 8601 or 'YYYY-MM-DD HH:MM'"
            Write-Host "  [FAIL] Could not parse ISO timestamp" -ForegroundColor Red
        }
    }

    if ($null -ne $timestamp) {
        $age = (Get-Date) - $timestamp

        if ($age.TotalHours -lt 24) {
            Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "PASS" `
                -Details "Last updated $([math]::Round($age.TotalHours, 1)) hours ago"
            Write-Host "  [PASS] Timestamp fresh ($([math]::Round($age.TotalHours, 1))h old)" -ForegroundColor Green
        } elseif ($age.TotalDays -lt 7) {
            Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "WARN" `
                -Details "Last updated $([math]::Round($age.TotalDays, 1)) days ago" `
                -Remediation "Consider updating timestamp if recent work has been done"
            Write-Host "  [WARN] Timestamp $([math]::Round($age.TotalDays, 1)) days old" -ForegroundColor Yellow
        } else {
            Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "FAIL" `
                -Details "Last updated $([math]::Round($age.TotalDays, 1)) days ago (too old)" `
                -Remediation "Update timestamp to current date/time"
            Write-Host "  [FAIL] Timestamp $([math]::Round($age.TotalDays, 1)) days old" -ForegroundColor Red
        }
    } else {
        Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "FAIL" `
            -Details "No timestamp found in workspace instructions" `
            -Remediation "Add 'Last Updated' line with timestamp"
        Write-Host "  [FAIL] No timestamp found" -ForegroundColor Red
    }
} else {
    Add-CheckResult -Category "Timestamps" -Check "Workspace instructions freshness" -Status "FAIL" `
        -Details "Workspace instructions file not found" `
        -Remediation "Create workspace copilot-instructions.md"
    Write-Host "  [FAIL] Workspace instructions missing" -ForegroundColor Red
}

# ============================================================================
# CHECK 4: Bootstrap Completeness
# ============================================================================

Write-Host "[CHECK 4] Bootstrap completeness..." -ForegroundColor Cyan

$bootstrapFiles = @(
    "$WorkspaceRoot\07-foundation-layer\templates\copilot-instructions-workspace-template.md",
    "$WorkspaceRoot\07-foundation-layer\templates\copilot-instructions-template.md"
)

$bootstrapIssues = @()
foreach ($file in $bootstrapFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        $hasHealth = $content -match '/health'
        $hasReady = $content -match '/ready'
        $hasHandshake = $content -match '/model/agent-handshake'
        $hasAgentGuide = $content -match '/model/agent-guide'
        $hasUserGuide = $content -match '/model/user-guide'
        
        if (-not $hasHealth) {
            $bootstrapIssues += "$file missing /health reference"
        }
        if (-not $hasReady) {
            $bootstrapIssues += "$file missing /ready reference"
        }
        if (-not $hasHandshake) {
            $bootstrapIssues += "$file missing /model/agent-handshake reference"
        }
        if (-not $hasAgentGuide) {
            $bootstrapIssues += "$file missing /model/agent-guide reference"
        }
        if (-not $hasUserGuide) {
            $bootstrapIssues += "$file missing /model/user-guide reference"
        }
    } else {
        $bootstrapIssues += "$file does not exist"
    }
}

if ($bootstrapIssues.Count -eq 0) {
    Add-CheckResult -Category "Bootstrap" -Check "Complete bootstrap contract" -Status "PASS" `
        -Details "Both templates reference health, ready, handshake, guide, and user-guide"
    Write-Host "  [PASS] Bootstrap complete in both templates" -ForegroundColor Green
} else {
    Add-CheckResult -Category "Bootstrap" -Check "Complete bootstrap contract" -Status "FAIL" `
        -Details "$($bootstrapIssues.Count) bootstrap issues found" `
        -Remediation "Add missing endpoint references to bootstrap section"
    Write-Host "  [FAIL] Bootstrap incomplete:" -ForegroundColor Red
    foreach ($issue in $bootstrapIssues) {
        Write-Host "    - $issue" -ForegroundColor Yellow
    }
}

# ============================================================================
# CHECK 5: Category Runbooks Documented
# ============================================================================

Write-Host "[CHECK 5] Category runbooks documentation..." -ForegroundColor Cyan

$runbookIssues = @()
foreach ($file in $bootstrapFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw

        $hasRunbookPath = $content -match 'category_instructions'
        if (-not $hasRunbookPath) {
            $runbookIssues += "$file missing category_instructions reference"
        }
    }
}

if ($runbookIssues.Count -eq 0) {
    Add-CheckResult -Category "Category Runbooks" -Check "Category runbooks path documented" -Status "PASS" `
        -Details "Both templates reference userGuide.category_instructions"
    Write-Host "  [PASS] Category runbooks path documented" -ForegroundColor Green
} else {
    Add-CheckResult -Category "Category Runbooks" -Check "Category runbooks path documented" -Status "FAIL" `
        -Details "$($runbookIssues.Count) files missing category runbooks path" `
        -Remediation "Add userGuide.category_instructions references to templates"
    Write-Host "  [FAIL] Category runbooks path incomplete:" -ForegroundColor Red
    foreach ($issue in $runbookIssues) {
        Write-Host "    - $issue" -ForegroundColor Yellow
    }
}

# ============================================================================
# CHECK 6: Session Summary Coverage
# ============================================================================

Write-Host "[CHECK 6] Session summary coverage..." -ForegroundColor Cyan

$sessionDocsPath = "$evaFoundryRoot\37-data-model\docs\sessions"
if (Test-Path $sessionDocsPath) {
    $sessionFiles = Get-ChildItem $sessionDocsPath -Filter "SESSION-*.md" -File | Sort-Object Name -Descending | Select-Object -First 10
    
    $recentSessions = @()
    foreach ($file in $sessionFiles) {
        if ($file.Name -match 'SESSION-(\d+)') {
            $sessionNum = [int]$matches[1]
            $recentSessions += $sessionNum
        }
    }
    
    if ($recentSessions.Count -gt 0) {
        $latestSession = $recentSessions | Sort-Object -Descending | Select-Object -First 1
        Add-CheckResult -Category "Session Docs" -Check "Session summary files exist" -Status "PASS" `
            -Details "Found $($sessionFiles.Count) recent session summaries (latest: Session $latestSession)"
        Write-Host "  [PASS] $($sessionFiles.Count) session summaries found (latest: Session $latestSession)" -ForegroundColor Green
    } else {
        Add-CheckResult -Category "Session Docs" -Check "Session summary files exist" -Status "WARN" `
            -Details "No SESSION-*.md files found in expected format" `
            -Remediation "Ensure session summaries follow naming pattern: SESSION-XX-*.md"
        Write-Host "  [WARN] No session summary files found" -ForegroundColor Yellow
    }
} else {
    Add-CheckResult -Category "Session Docs" -Check "Session summary files exist" -Status "FAIL" `
        -Details "Sessions directory not found: $sessionDocsPath" `
        -Remediation "Create sessions directory: 37-data-model/docs/sessions/"
    Write-Host "  [FAIL] Sessions directory not found" -ForegroundColor Red
}

# ============================================================================
# CHECK 7: Project Copilot Instructions Coverage
# ============================================================================

Write-Host "[CHECK 7] Project copilot-instructions coverage..." -ForegroundColor Cyan

$projectFolders = Get-ChildItem $evaFoundryRoot -Directory | Where-Object { $_.Name -match '^\d{2}-' }
$totalProjects = $projectFolders.Count

if ($totalProjects -eq 0) {
    Add-CheckResult -Category "Project Coverage" -Check "Copilot instructions in all projects" -Status "FAIL" `
        -Details "No numbered project folders found" `
        -Remediation "Check workspace path: $evaFoundryRoot"
    Write-Host "  [FAIL] No numbered project folders found" -ForegroundColor Red
} else {
    $projectsWithInstructions = 0
    $projectsMissing = @()

    foreach ($project in $projectFolders) {
        $instructionsPath = Join-Path $project.FullName ".github\copilot-instructions.md"
        if (Test-Path $instructionsPath) {
            $projectsWithInstructions++
        } else {
            $projectsMissing += $project.Name
        }
    }

    $coveragePercent = [math]::Round(($projectsWithInstructions / $totalProjects) * 100, 1)

    if ($coveragePercent -eq 100) {
        Add-CheckResult -Category "Project Coverage" -Check "Copilot instructions in all projects" -Status "PASS" `
            -Details "All $totalProjects projects have copilot-instructions.md"
        Write-Host "  [PASS] 100% coverage ($projectsWithInstructions/$totalProjects projects)" -ForegroundColor Green
    } elseif ($coveragePercent -ge 95) {
        Add-CheckResult -Category "Project Coverage" -Check "Copilot instructions in all projects" -Status "WARN" `
            -Details "$projectsWithInstructions/$totalProjects projects ($coveragePercent%)" `
            -Remediation "Prime missing projects: $($projectsMissing -join ', ')"
        Write-Host "  [WARN] $coveragePercent% coverage ($projectsWithInstructions/$totalProjects projects)" -ForegroundColor Yellow
        Write-Host "    Missing: $($projectsMissing -join ', ')" -ForegroundColor Yellow
    } else {
        Add-CheckResult -Category "Project Coverage" -Check "Copilot instructions in all projects" -Status "FAIL" `
            -Details "$projectsWithInstructions/$totalProjects projects ($coveragePercent%) - too low" `
            -Remediation "Run Invoke-PrimeWorkspace.ps1 on workspace root"
        Write-Host "  [FAIL] $coveragePercent% coverage ($projectsWithInstructions/$totalProjects projects)" -ForegroundColor Red
    }
}

# ============================================================================
# GENERATE REPORT
# ============================================================================

Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "GOVERNANCE CONSISTENCY REPORT" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary: $passCount PASS | $failCount FAIL | $warnCount WARN" -ForegroundColor White
Write-Host ""

$report = @"
# Governance Consistency Report

**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss ET')  
**Workspace**: $workspaceInstructionsRoot (instructions) / $evaFoundryRoot (projects)  
**Tool Version**: 1.1.0

---

## Summary

| Status | Count |
|--------|-------|
| [PASS] PASS | $passCount |
| [FAIL] FAIL | $failCount |
| [WARN] WARN | $warnCount |
| **Total** | $($checkResults.Count) |

---

## Check Results

"@

# Group by category
$categories = $checkResults | Group-Object -Property Category

foreach ($category in $categories) {
    $report += "`n### $($category.Name)`n`n"
    
    foreach ($result in $category.Group) {
        $icon = switch ($result.Status) {
            "PASS" { "[PASS]" }
            "FAIL" { "[FAIL]" }
            "WARN" { "[WARN]" }
        }
        
        $report += "**$icon $($result.Check)**: $($result.Status)`n"
        $report += "- Details: $($result.Details)`n"
        if ($result.Remediation) {
            $report += "- Remediation: $($result.Remediation)`n"
        }
        $report += "`n"
    }
}

# Output
if ($OutputPath) {
    $report | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "[INFO] Report written to: $OutputPath" -ForegroundColor Green
} else {
    Write-Host $report
}

Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "Check complete. Exit code: $failCount" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan

exit $failCount
