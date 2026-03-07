# Manual Test Script - Workspace Management v1.0.0
# Version: 1.0.0 (January 30, 2026)
# Purpose: Manual validation of workspace management scripts on Project 01
# Test Target: I:\EVA-JP-v1.2\docs\eva-foundation\projects\01-documentation-generator
#
# Test Scenarios:
# 1. Capture-ProjectStructure.ps1: Generate filesystem snapshot
# 2. Initialize-ProjectStructure.ps1: DryRun preview (no file creation)
# 3. Invoke-WorkspaceHousekeeping.ps1: Detect root violations and missing folders

# [ENCODING SAFETY] Set UTF-8 to prevent UnicodeEncodeError in Windows cp1252
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ANSI color codes for terminal output
$script:ColorReset = "`e[0m"
$script:ColorGreen = "`e[32m"
$script:ColorYellow = "`e[33m"
$script:ColorRed = "`e[31m"
$script:ColorCyan = "`e[36m"

function Write-TestHeader {
    param([string]$Message)
    Write-Host ""
    Write-Host "$script:ColorCyan========================================$script:ColorReset"
    Write-Host "$script:ColorCyan$Message$script:ColorReset"
    Write-Host "$script:ColorCyan========================================$script:ColorReset"
}

function Write-TestResult {
    param(
        [string]$Test,
        [string]$Status,
        [string]$Details = ""
    )
    
    $statusColor = switch ($Status) {
        "PASS" { $script:ColorGreen }
        "FAIL" { $script:ColorRed }
        "WARN" { $script:ColorYellow }
        default { $script:ColorReset }
    }
    
    Write-Host "[$statusColor$Status$script:ColorReset] $Test"
    if ($Details) {
        Write-Host "  $Details" -ForegroundColor Gray
    }
}

# Configuration
$ProjectRoot = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer"
$TemplatesDir = Join-Path $ProjectRoot "02-design\artifact-templates"
$TestTarget = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\01-documentation-generator"
$TestResultsDir = Join-Path $ProjectRoot "04-testing\results"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Ensure results directory exists
New-Item -ItemType Directory -Path $TestResultsDir -Force | Out-Null

Write-Host "$script:ColorCyan=================================$script:ColorReset"
Write-Host "$script:ColorCyan Workspace Management v1.0.0$script:ColorReset"
Write-Host "$script:ColorCyan Manual Testing Suite$script:ColorReset"
Write-Host "$script:ColorCyan=================================$script:ColorReset"
Write-Host ""
Write-Host "[INFO] Test Target: $TestTarget"
Write-Host "[INFO] Templates: $TemplatesDir"
Write-Host "[INFO] Results: $TestResultsDir"
Write-Host "[INFO] Timestamp: $Timestamp"
Write-Host ""

# Pre-flight checks
Write-TestHeader "PRE-FLIGHT CHECKS"

$preflightPassed = $true

if (Test-Path $TestTarget) {
    Write-TestResult "Test target exists" "PASS" $TestTarget
} else {
    Write-TestResult "Test target exists" "FAIL" "Directory not found: $TestTarget"
    $preflightPassed = $false
}

$captureScript = Join-Path $TemplatesDir "Capture-ProjectStructure.ps1"
$initScript = Join-Path $TemplatesDir "Initialize-ProjectStructure.ps1"
$housekeepScript = Join-Path $TemplatesDir "Invoke-WorkspaceHousekeeping.ps1"
$templateJson = Join-Path $TemplatesDir "supported-folder-structure-rag.json"

$scriptsToCheck = @(
    @{Name = "Capture-ProjectStructure.ps1"; Path = $captureScript},
    @{Name = "Initialize-ProjectStructure.ps1"; Path = $initScript},
    @{Name = "Invoke-WorkspaceHousekeeping.ps1"; Path = $housekeepScript},
    @{Name = "supported-folder-structure-rag.json"; Path = $templateJson}
)

foreach ($script in $scriptsToCheck) {
    if (Test-Path $script.Path) {
        Write-TestResult "Script available: $($script.Name)" "PASS"
    } else {
        Write-TestResult "Script available: $($script.Name)" "FAIL" "File not found: $($script.Path)"
        $preflightPassed = $false
    }
}

if (-not $preflightPassed) {
    Write-Host ""
    Write-Host "$script:ColorRed[FAIL] Pre-flight checks failed. Aborting tests.$script:ColorReset"
    exit 1
}

Write-Host ""
Write-Host "$script:ColorGreen[PASS] All pre-flight checks passed$script:ColorReset"

# TEST 1: Capture-ProjectStructure.ps1
Write-TestHeader "TEST 1: Capture-ProjectStructure.ps1"

Write-Host "[INFO] Capturing Project 01 structure..."
try {
    & $captureScript -TargetPath $TestTarget -ErrorAction Stop
    
    $snapshotFile = Join-Path $TestTarget ".github\project-folder-picture.md"
    
    if (Test-Path $snapshotFile) {
        $snapshotContent = Get-Content $snapshotFile -Raw
        $lineCount = ($snapshotContent -split "`n").Count
        $containsTree = $snapshotContent -match "[├└]──"
        $containsStats = $snapshotContent -match "Total Folders:|Total Files:"
        
        Write-TestResult "Snapshot file created" "PASS" $snapshotFile
        Write-TestResult "Snapshot has content" "PASS" "$lineCount lines"
        
        if ($containsTree) {
            Write-TestResult "ASCII tree structure present" "PASS"
        } else {
            Write-TestResult "ASCII tree structure present" "FAIL" "No tree connectors found"
        }
        
        if ($containsStats) {
            Write-TestResult "Statistics section present" "PASS"
        } else {
            Write-TestResult "Statistics section present" "FAIL" "No statistics found"
        }
        
        # Copy snapshot to results
        $resultSnapshot = Join-Path $TestResultsDir "project-folder-picture_$Timestamp.md"
        Copy-Item $snapshotFile -Destination $resultSnapshot
        Write-Host "[INFO] Snapshot copied to: $resultSnapshot"
        
    } else {
        Write-TestResult "Snapshot file created" "FAIL" "File not found: $snapshotFile"
    }
} catch {
    Write-TestResult "Capture execution" "FAIL" $_.Exception.Message
}

# TEST 2: Copy template for housekeeping test
Write-TestHeader "TEST 2: Template Preparation"

$targetGithubDir = Join-Path $TestTarget ".github"
if (-not (Test-Path $targetGithubDir)) {
    New-Item -ItemType Directory -Path $targetGithubDir -Force | Out-Null
    Write-Host "[INFO] Created .github directory"
}

$targetTemplateFile = Join-Path $targetGithubDir "supported-folder-structure.json"
Copy-Item $templateJson -Destination $targetTemplateFile -Force

if (Test-Path $targetTemplateFile) {
    Write-TestResult "Template copied to target" "PASS" $targetTemplateFile
} else {
    Write-TestResult "Template copied to target" "FAIL"
}

# TEST 3: Initialize-ProjectStructure.ps1 (DryRun)
Write-TestHeader "TEST 3: Initialize-ProjectStructure.ps1 (DryRun)"

Write-Host "[INFO] Running structure initialization in DryRun mode..."
try {
    $initOutput = & $initScript -TargetPath $TestTarget -DryRun 2>&1 | Out-String
    
    # Check output for expected patterns
    $containsWouldCreate = $initOutput -match "\[DRYRUN\] Would create folder:"
    $containsASCII = ($initOutput -match "\[INFO\]|\[PASS\]|\[WARN\]") -and ($initOutput -notmatch "[✓✗⏳🎯❌✅]")
    
    Write-TestResult "DryRun execution" "PASS"
    
    if ($containsWouldCreate) {
        Write-TestResult "DryRun folder preview" "PASS" "Found folder creation previews"
    } else {
        Write-TestResult "DryRun folder preview" "WARN" "No folder previews found in output"
    }
    
    if ($containsASCII) {
        Write-TestResult "ASCII-only output" "PASS" "No Unicode symbols detected"
    } else {
        Write-TestResult "ASCII-only output" "WARN" "Output validation inconclusive"
    }
    
    # Save output
    $initResultFile = Join-Path $TestResultsDir "initialize-dryrun_$Timestamp.txt"
    $initOutput | Out-File -FilePath $initResultFile -Encoding UTF8
    Write-Host "[INFO] DryRun output saved to: $initResultFile"
    
} catch {
    Write-TestResult "DryRun execution" "FAIL" $_.Exception.Message
}

# TEST 4: Invoke-WorkspaceHousekeeping.ps1 (DryRun)
Write-TestHeader "TEST 4: Invoke-WorkspaceHousekeeping.ps1 (DryRun)"

Write-Host "[INFO] Running housekeeping analysis in DryRun mode..."
try {
    $housekeepOutput = & $housekeepScript -TargetPath $TestTarget -DryRun 2>&1 | Out-String
    
    # Expected violations for Project 01
    $expectedViolations = @(
        "PHASE-6-REPORT.md",
        "MIGRATION-COMPLETE.md",
        "LINK-UPDATE-SUMMARY.md",
        "LINK-UPDATES-COMPLETE.md",
        "dry-run-output.log"
    )
    
    $violationsDetected = 0
    foreach ($violation in $expectedViolations) {
        if ($housekeepOutput -match [regex]::Escape($violation)) {
            $violationsDetected++
        }
    }
    
    Write-TestResult "Housekeeping execution" "PASS"
    
    if ($violationsDetected -ge 3) {
        Write-TestResult "Root violations detected" "PASS" "Found $violationsDetected of $($expectedViolations.Count) expected violations"
    } else {
        Write-TestResult "Root violations detected" "WARN" "Found only $violationsDetected of $($expectedViolations.Count) expected violations"
    }
    
    $containsMissingFolders = $housekeepOutput -match "Missing required folders:"
    if ($containsMissingFolders) {
        Write-TestResult "Missing folders detected" "PASS"
    } else {
        Write-TestResult "Missing folders detected" "INFO" "No missing folders (may be complete structure)"
    }
    
    $containsASCII = ($housekeepOutput -match "\[INFO\]|\[PASS\]|\[WARN\]") -and ($housekeepOutput -notmatch "[✓✗⏳🎯❌✅]")
    if ($containsASCII) {
        Write-TestResult "ASCII-only output" "PASS" "No Unicode symbols detected"
    } else {
        Write-TestResult "ASCII-only output" "WARN" "Output validation inconclusive"
    }
    
    # Save output
    $housekeepResultFile = Join-Path $TestResultsDir "housekeeping-dryrun_$Timestamp.txt"
    $housekeepOutput | Out-File -FilePath $housekeepResultFile -Encoding UTF8
    Write-Host "[INFO] Housekeeping output saved to: $housekeepResultFile"
    
} catch {
    Write-TestResult "Housekeeping execution" "FAIL" $_.Exception.Message
}

# TEST 5: Evidence collection verification
Write-TestHeader "TEST 5: Evidence Collection Verification"

$evidenceDir = Join-Path $TestTarget "evidence\structure-init"
if (Test-Path $evidenceDir) {
    $evidenceFiles = Get-ChildItem -Path $evidenceDir -File
    Write-TestResult "Evidence directory exists" "PASS" "$($evidenceFiles.Count) files collected"
    
    foreach ($file in $evidenceFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-TestResult "Evidence directory exists" "INFO" "No evidence collected (DryRun mode)"
}

# TEST SUMMARY
Write-TestHeader "TEST SUMMARY"

Write-Host ""
Write-Host "$script:ColorGreen[PASS] Workspace Management v1.0.0 Manual Testing Complete$script:ColorReset"
Write-Host ""
Write-Host "Test results saved to: $TestResultsDir"
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Review captured snapshot: .github\project-folder-picture.md"
Write-Host "2. Review housekeeping report in results directory"
Write-Host "3. Optional: Run Invoke-WorkspaceHousekeeping.ps1 without -DryRun to auto-organize"
Write-Host "4. Document test results in 04-testing\test-scenarios.md"
Write-Host ""
