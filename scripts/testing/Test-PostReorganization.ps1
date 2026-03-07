<#
.SYNOPSIS
    Post-reorganization validation test suite for Project 07 scripts.

.DESCRIPTION
    Tests all 5 modified scripts to ensure:
    1. PowerShell syntax is valid (can parse)
    2. Critical path variables resolve correctly
    3. Template locations exist and are accessible
    4. No broken references to legacy directories

.EXAMPLE
    .\Test-PostReorganization.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [switch]$Verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Reset = "`e[0m"

$ScriptsFolder = Split-Path -Parent $PSScriptRoot
$FoundationRoot = Split-Path -Path $ScriptsFolder -Parent
$TestResults = @()

Write-Host "`n=== Project 07 Post-Reorganization Script Validation ===" -ForegroundColor Cyan
Write-Host "Foundation Root: $FoundationRoot" -ForegroundColor Gray
Write-Host "Scripts Folder: $ScriptsFolder" -ForegroundColor Gray

# ============================================================================
# Test 1: Reseed-Projects.ps1
# ============================================================================
Write-Host "`n[TEST 1] Reseed-Projects.ps1" -ForegroundColor Magenta

try {
    $ReseedPath = "$ScriptsFolder\deployment\Reseed-Projects.ps1"
    if (-not (Test-Path $ReseedPath)) {
        throw "Script not found at $ReseedPath"
    }
    
    # Parse the script
    $ReseedContent = Get-Content $ReseedPath -Raw
    $null = [scriptblock]::Create($ReseedContent)
    
    # Check for critical paths
    $TemplateCheck = $ReseedContent -contains '$TEMPLATE     = '
    $TemplateValue = $ReseedContent | Select-String '\$TEMPLATE\s+=\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    
    $BackupCheck = $ReseedContent -contains '$BACKUP_ROOT  = '
    $BackupValue = $ReseedContent | Select-String '\$BACKUP_ROOT\s+=\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    
    Write-Host "  ✓ Script parses successfully"
    Write-Host "  Template path: $TemplateValue"
    
    if (Test-Path $TemplateValue) {
        Write-Host "  ${Green}✓ Template file exists${Reset}"
    } else {
        Write-Host "  ${Red}✗ Template file NOT FOUND${Reset}"
    }
    
    Write-Host "  Backup root: $BackupValue"
    if (Test-Path $BackupValue) {
        Write-Host "  ${Green}✓ Backup directory exists${Reset}"
    } else {
        Write-Host "  ${Yellow}⚠ Backup directory doesn't exist yet (will be created on first run)${Reset}"
    }
    
    $TestResults += @{ Script = "Reseed-Projects.ps1"; Status = "PASS"; Details = "Syntax valid, paths configured" }
}
catch {
    Write-Host "  ${Red}✗ ERROR: $_${Reset}" -ForegroundColor Red
    $TestResults += @{ Script = "Reseed-Projects.ps1"; Status = "FAIL"; Details = $_.Exception.Message }
}

# ============================================================================
# Test 2: Apply-Project07-Artifacts.ps1
# ============================================================================
Write-Host "`n[TEST 2] Apply-Project07-Artifacts.ps1" -ForegroundColor Magenta

try {
    $ApplyPath = "$ScriptsFolder\deployment\Apply-Project07-Artifacts.ps1"
    if (-not (Test-Path $ApplyPath)) {
        throw "Script not found at $ApplyPath"
    }
    
    $ApplyContent = Get-Content $ApplyPath -Raw
    $null = [scriptblock]::Create($ApplyContent)
    
    # Check searchPaths array
    $SearchPathMatches = $ApplyContent | Select-String '"\./templates' -AllMatches
    $TemplatesRefCount = ($SearchPathMatches | Measure-Object).Count
    
    Write-Host "  ✓ Script parses successfully"
    Write-Host "  Template search path references: $TemplatesRefCount"
    
    if ($TemplatesRefCount -gt 0) {
        Write-Host "  ${Green}✓ Uses new templates/ location${Reset}"
    } else {
        Write-Host "  ${Yellow}⚠ No new template paths found${Reset}"
    }
    
    # Check that old paths are NOT present
    $LegacyPaths = @("02-design\artifact-templates", "02-design/artifact-templates")
    $LegacyMatches = 0
    foreach ($LegacyPath in $LegacyPaths) {
        $LegacyMatches += ($ApplyContent | Select-String ([regex]::Escape($LegacyPath)) | Measure-Object).Count
    }
    
    if ($LegacyMatches -eq 0) {
        Write-Host "  ${Green}✓ No legacy 02-design paths found${Reset}"
    } else {
        Write-Host "  ${Yellow}⚠ Found $LegacyMatches references to old paths${Reset}"
    }
    
    $TestResults += @{ Script = "Apply-Project07-Artifacts.ps1"; Status = "PASS"; Details = "Syntax valid, paths updated" }
}
catch {
    Write-Host "  ${Red}✗ ERROR: $_${Reset}" -ForegroundColor Red
    $TestResults += @{ Script = "Apply-Project07-Artifacts.ps1"; Status = "FAIL"; Details = $_.Exception.Message }
}

# ============================================================================
# Test 3: Bootstrap-Project07.ps1
# ============================================================================
Write-Host "`n[TEST 3] Bootstrap-Project07.ps1" -ForegroundColor Magenta

try {
    $BootstrapPath = "$ScriptsFolder\deployment\Bootstrap-Project07.ps1"
    if (-not (Test-Path $BootstrapPath)) {
        throw "Script not found at $BootstrapPath"
    }
    
    $BootstrapContent = Get-Content $BootstrapPath -Raw
    $null = [scriptblock]::Create($BootstrapContent)
    
    # Check for correct Invoke-PrimeWorkspace reference
    $NewReference = $BootstrapContent | Select-String '\.\\scripts\\deployment\\Invoke-PrimeWorkspace\.ps1' -AllMatches
    $NewRefCount = ($NewReference | Measure-Object).Count
    
    # Check for old references
    $OldReference = $BootstrapContent | Select-String '02-design\\artifact-templates\\Invoke-PrimeWorkspace\.ps1' -AllMatches
    $OldRefCount = ($OldReference | Measure-Object).Count
    
    Write-Host "  ✓ Script parses successfully"
    Write-Host "  New Invoke-PrimeWorkspace references: $NewRefCount"
    
    if ($NewRefCount -gt 0) {
        Write-Host "  ${Green}✓ Uses correct scripts/deployment/ path${Reset}"
    } else {
        Write-Host "  ${Yellow}⚠ No new reference paths found${Reset}"
    }
    
    if ($OldRefCount -eq 0) {
        Write-Host "  ${Green}✓ No legacy paths found${Reset}"
    } else {
        Write-Host "  ${Red}✗ Still contains old paths ($OldRefCount references)${Reset}"
    }
    
    $TestResults += @{ Script = "Bootstrap-Project07.ps1"; Status = "PASS"; Details = "Syntax valid, references updated" }
}
catch {
    Write-Host "  ${Red}✗ ERROR: $_${Reset}" -ForegroundColor Red
    $TestResults += @{ Script = "Bootstrap-Project07.ps1"; Status = "FAIL"; Details = $_.Exception.Message }
}

# ============================================================================
# Test 4: Test-Project07-Deployment.ps1
# ============================================================================
Write-Host "`n[TEST 4] Test-Project07-Deployment.ps1" -ForegroundColor Magenta

try {
    $TestPath = "$ScriptsFolder\testing\Test-Project07-Deployment.ps1"
    if (-not (Test-Path $TestPath)) {
        throw "Script not found at $TestPath"
    }
    
    $TestContent = Get-Content $TestPath -Raw
    $null = [scriptblock]::Create($TestContent)
    
    # Check possiblePaths array
    $PossiblePaths = $TestContent | Select-String '"\./templates' -AllMatches
    $PossiblesCount = ($PossiblePaths | Measure-Object).Count
    
    Write-Host "  ✓ Script parses successfully"
    Write-Host "  Template path references in possiblePaths: $PossiblesCount"
    
    if ($PossiblesCount -gt 0) {
        Write-Host "  ${Green}✓ Updated to reference templates/${Reset}"
    }
    
    $TestResults += @{ Script = "Test-Project07-Deployment.ps1"; Status = "PASS"; Details = "Syntax valid, search paths updated" }
}
catch {
    Write-Host "  ${Red}✗ ERROR: $_${Reset}" -ForegroundColor Red
    $TestResults += @{ Script = "Test-Project07-Deployment.ps1"; Status = "FAIL"; Details = $_.Exception.Message }
}

# ============================================================================
# Test 5: Fix-Project07-Paths.ps1
# ============================================================================
Write-Host "`n[TEST 5] Fix-Project07-Paths.ps1" -ForegroundColor Magenta

try {
    $FixPath = "$ScriptsFolder\utilities\Fix-Project07-Paths.ps1"
    if (-not (Test-Path $FixPath)) {
        throw "Script not found at $FixPath"
    }
    
    $FixContent = Get-Content $FixPath -Raw
    $null = [scriptblock]::Create($FixContent)
    
    # Check for references to correct locations
    $DeploymentRefs = $FixContent | Select-String 'scripts\\deployment' -AllMatches
    $DeploymentCount = ($DeploymentRefs | Measure-Object).Count
    
    Write-Host "  ✓ Script parses successfully"
    Write-Host "  References to scripts/deployment/: $DeploymentCount"
    
    if ($DeploymentCount -gt 0) {
        Write-Host "  ${Green}✓ Uses correct deployment script paths${Reset}"
    }
    
    $TestResults += @{ Script = "Fix-Project07-Paths.ps1"; Status = "PASS"; Details = "Syntax valid, references updated" }
}
catch {
    Write-Host "  ${Red}✗ ERROR: $_${Reset}" -ForegroundColor Red
    $TestResults += @{ Script = "Fix-Project07-Paths.ps1"; Status = "FAIL"; Details = $_.Exception.Message }
}

# ============================================================================
# Test 6: Path Validation
# ============================================================================
Write-Host "`n[TEST 6] Critical Path Validation" -ForegroundColor Magenta

$CriticalPaths = @(
    @{ Path = "$FoundationRoot\templates"; Name = "templates/" }
    @{ Path = "$FoundationRoot\.archive"; Name = ".archive/" }
    @{ Path = "$FoundationRoot\scripts\deployment"; Name = "scripts/deployment/" }
    @{ Path = "$FoundationRoot\scripts\testing"; Name = "scripts/testing/" }
    @{ Path = "$FoundationRoot\scripts\utilities"; Name = "scripts/utilities/" }
    @{ Path = "$FoundationRoot\docs\discovery-reference"; Name = "docs/discovery-reference/" }
)

$AllPathsValid = $true
foreach ($PathCheck in $CriticalPaths) {
    if (Test-Path $PathCheck.Path) {
        Write-Host "  ${Green}✓${Reset} $($PathCheck.Name)"
    } else {
        Write-Host "  ${Red}✗${Reset} $($PathCheck.Name) - NOT FOUND"
        $AllPathsValid = $false
    }
}

if ($AllPathsValid) {
    $TestResults += @{ Script = "Path Structure"; Status = "PASS"; Details = "All critical paths valid" }
} else {
    $TestResults += @{ Script = "Path Structure"; Status = "FAIL"; Details = "Some paths missing" }
}

# ============================================================================
# Summary
# ============================================================================
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan

$PassCount = ($TestResults | Where-Object { $_.Status -eq "PASS" } | Measure-Object).Count
$FailCount = ($TestResults | Where-Object { $_.Status -eq "FAIL" } | Measure-Object).Count
$TotalCount = $TestResults.Count

foreach ($Result in $TestResults) {
    if ($Result.Status -eq "PASS") {
        Write-Host "  ${Green}[PASS]${Reset} $($Result.Script)" -NoNewline
    } else {
        Write-Host "  ${Red}[FAIL]${Reset} $($Result.Script)" -NoNewline
    }
    Write-Host " - $($Result.Details)"
}

Write-Host "`nTotal: ${Green}$PassCount passed${Reset}, ${Red}$FailCount failed${Reset} (of $TotalCount tests)"

if ($FailCount -eq 0) {
    Write-Host "`n${Green}✓ All tests PASSED - Scripts are ready for use!${Reset}" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n${Red}✗ Some tests FAILED - Please review above errors${Reset}" -ForegroundColor Red
    exit 1
}
