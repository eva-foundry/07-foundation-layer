<#
.SYNOPSIS
    Test-PrimingCompatibility.ps1 v1.0.0
    Pre-flight validation for template priming operations

.DESCRIPTION
    Validates compatibility between priming scripts and templates BEFORE
    attempting any priming operations. Prevents failed priming attempts
    due to version mismatches, missing files, or structural incompatibilities.

    Checks performed:
    1. Template version detection (v2.1.0, v3.0.0, v4.2.0, v5.0.0, etc.)
    2. Script version compatibility with template
    3. Required template files existence
    4. Template structure validation (PART 1/2/3 markers)
    5. Regex extraction simulation (validates line count expectations)

.PARAMETER TemplatePath
    Path to copilot-instructions-template.md to validate

.PARAMETER ScriptPath
    Path to Apply-Project07-Artifacts.ps1 to validate compatibility

.PARAMETER Detailed
    Show detailed diagnostic information

.EXAMPLE
    .\Test-PrimingCompatibility.ps1 -TemplatePath "..\templates\copilot-instructions-template.md"

.EXAMPLE
    .\Test-PrimingCompatibility.ps1 -TemplatePath "..\templates\copilot-instructions-template.md" -Detailed

.NOTES
    Version: 1.0.0
    Created: 2026-03-09 by agent:copilot (Session 42 Part 2)
    Purpose: Prevent priming failures discovered in Session 42
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TemplatePath = (Join-Path $PSScriptRoot "..\..\templates\copilot-instructions-template.md"),
    
    [Parameter(Mandatory=$false)]
    [string]$ScriptPath = (Join-Path $PSScriptRoot "Apply-Project07-Artifacts.ps1"),
    
    [switch]$Detailed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet("Pass", "Fail", "Warn", "Info")]
        [string]$Type = "Info"
    )
    
    $token = switch ($Type) {
        "Pass" { "[PASS]"; $color = "Green" }
        "Fail" { "[FAIL]"; $color = "Red" }
        "Warn" { "[WARN]"; $color = "Yellow" }
        "Info" { "[INFO]"; $color = "White" }
    }
    
    Write-Host "$token $Message" -ForegroundColor $color
}

function Get-TemplateVersion {
    param([string]$Content)
    
    # Extract version from header
    if ($Content -match '\*\*Template Version\*\*:\s*([0-9.]+)') {
        return $Matches[1]
    }
    
    return $null
}

function Test-TemplateStructure {
    param(
        [string]$Content,
        [string]$Version
    )
    
    $results = @{
        HasHeader = $false
        HasPart1 = $false
        HasPart2 = $false
        HasPart3 = $false
        Part1LineCount = 0
        TotalLineCount = 0
        Markers = @()
    }
    
    $lines = $Content -split "`n"
    $results.TotalLineCount = $lines.Count
    
    # Check for version header
    $results.HasHeader = $Content -match '\*\*Template Version\*\*:'
    
    # Find section markers
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        if ($line -match '^## PART 1') {
            $results.HasPart1 = $true
            $results.Markers += @{LineNumber = $i + 1; Marker = "PART 1"}
        }
        elseif ($line -match '^## PART 2') {
            $results.HasPart2 = $true
            $results.Markers += @{LineNumber = $i + 1; Marker = "PART 2"}
            
            # Calculate PART 1 line count (from start to first PART 2)
            if ($results.Part1LineCount -eq 0) {
                $results.Part1LineCount = $i
            }
        }
        elseif ($line -match '^## PART 3') {
            $results.HasPart3 = $true
            $results.Markers += @{LineNumber = $i + 1; Marker = "PART 3"}
        }
    }
    
    return $results
}

function Test-RegexExtraction {
    param(
        [string]$Content,
        [string]$Version
    )
    
    # Simulate the regex used in Apply-Project07-Artifacts.ps1 line 714
    $regex = '(?sm)^(.*?)^## PART 2[ :-]'
    
    if ($Content -match $regex) {
        $extracted = $Matches[1]
        $lineCount = ($extracted -split "`n").Count
        
        return @{
            Success = $true
            LineCount = $lineCount
            MeetsExpectation = $lineCount -ge 200  # Script expects >200 lines
        }
    }
    
    return @{
        Success = $false
        LineCount = 0
        MeetsExpectation = $false
    }
}

function Get-ScriptVersion {
    param([string]$ScriptPath)
    
    if (-not (Test-Path $ScriptPath)) {
        return $null
    }
    
    $content = Get-Content $ScriptPath -Raw
    
    # Extract version from header comment
    if ($content -match 'Version:\s*([0-9.]+)') {
        return $Matches[1]
    }
    
    return "unknown"
}

function Test-ScriptTemplateCompatibility {
    param(
        [string]$ScriptVersion,
        [string]$TemplateVersion
    )
    
    # Compatibility matrix (based on testing)
    $compatibility = @{
        "1.4.1" = @("2.1.0", "3.0.0")
        "1.5.0" = @("2.1.0", "3.0.0")
    }
    
    if ($compatibility.ContainsKey($ScriptVersion)) {
        $compatibleVersions = $compatibility[$ScriptVersion]
        return $compatibleVersions -contains $TemplateVersion
    }
    
    # Unknown versions - assume incompatible
    return $false
}

# ---------------------------------------------------------------------------
# Main Validation
# ---------------------------------------------------------------------------

Write-Status "=== Pre-Flight Priming Compatibility Check ===" -Type Info
Write-Status "Template: $TemplatePath" -Type Info
Write-Status "Script: $ScriptPath" -Type Info
Write-Host ""

$issues = @()
$warnings = @()

# Check 1: Template file exists
Write-Status "Check 1: Template file existence..." -Type Info
if (Test-Path $TemplatePath) {
    Write-Status "  Template file found" -Type Pass
} else {
    Write-Status "  Template file NOT FOUND: $TemplatePath" -Type Fail
    $issues += "Template file missing"
}

# Check 2: Script file exists
Write-Status "Check 2: Script file existence..." -Type Info
if (Test-Path $ScriptPath) {
    Write-Status "  Script file found" -Type Pass
} else {
    Write-Status "  Script file NOT FOUND: $ScriptPath" -Type Fail
    $issues += "Script file missing"
}

# If either file is missing, stop here
if ($issues.Count -gt 0) {
    Write-Host ""
    Write-Status "=== VALIDATION FAILED ===" -Type Fail
    Write-Status "Cannot proceed - critical files missing" -Type Fail
    $issues | ForEach-Object { Write-Status "  - $_" -Type Fail }
    exit 1
}

# Check 3: Detect template version
Write-Status "Check 3: Template version detection..." -Type Info
$templateContent = Get-Content $TemplatePath -Raw
$templateVersion = Get-TemplateVersion -Content $templateContent

if ($templateVersion) {
    Write-Status "  Detected template version: $templateVersion" -Type Pass
} else {
    Write-Status "  WARNING: Could not detect template version" -Type Warn
    $warnings += "Template version unknown - compatibility check may be inaccurate"
    $templateVersion = "unknown"
}

# Check 4: Detect script version
Write-Status "Check 4: Script version detection..." -Type Info
$scriptVersion = Get-ScriptVersion -ScriptPath $ScriptPath

if ($scriptVersion -and $scriptVersion -ne "unknown") {
    Write-Status "  Detected script version: $scriptVersion" -Type Pass
} else {
    Write-Status "  WARNING: Could not detect script version" -Type Warn
    $warnings += "Script version unknown - compatibility check may be inaccurate"
}

# Check 5: Template structure validation
Write-Status "Check 5: Template structure validation..." -Type Info
$structure = Test-TemplateStructure -Content $templateContent -Version $templateVersion

if ($structure.HasHeader) {
    Write-Status "  Header present" -Type Pass
} else {
    Write-Status "  Header missing" -Type Fail
    $issues += "Template missing version header"
}

if ($structure.HasPart1) {
    Write-Status "  PART 1 marker found (line $($structure.Markers[0].LineNumber))" -Type Pass
} else {
    Write-Status "  PART 1 marker NOT FOUND" -Type Fail
    $issues += "Template missing PART 1 marker"
}

if ($structure.HasPart2) {
    Write-Status "  PART 2 marker found (line $($structure.Markers[1].LineNumber))" -Type Pass
} else {
    Write-Status "  PART 2 marker NOT FOUND" -Type Fail
    $issues += "Template missing PART 2 marker"
}

if ($structure.HasPart3) {
    Write-Status "  PART 3 marker found (line $($structure.Markers[2].LineNumber))" -Type Pass
} else {
    Write-Status "  PART 3 marker missing (may be optional for older templates)" -Type Warn
    $warnings += "Template missing PART 3 marker (expected in v4.x+)"
}

Write-Status "  Total template lines: $($structure.TotalLineCount)" -Type Info

# Check 6: Regex extraction simulation
Write-Status "Check 6: Regex extraction simulation..." -Type Info
$extraction = Test-RegexExtraction -Content $templateContent -Version $templateVersion

if ($extraction.Success) {
    Write-Status "  Regex extraction successful" -Type Pass
    Write-Status "  Extracted PART 1: $($extraction.LineCount) lines" -Type Info
    
    if ($extraction.MeetsExpectation) {
        Write-Status "  Line count meets script expectation (>200 lines)" -Type Pass
    } else {
        Write-Status "  WARNING: Line count below script expectation" -Type Fail
        Write-Status "    Expected: >200 lines" -Type Info
        Write-Status "    Actual: $($extraction.LineCount) lines" -Type Info
        $issues += "Regex extraction produces insufficient lines ($($extraction.LineCount) < 200)"
    }
} else {
    Write-Status "  Regex extraction FAILED" -Type Fail
    $issues += "Regex cannot extract PART 1 from template"
}

# Check 7: Script-Template compatibility
Write-Status "Check 7: Script-Template version compatibility..." -Type Info
$compatible = Test-ScriptTemplateCompatibility -ScriptVersion $scriptVersion -TemplateVersion $templateVersion

if ($compatible) {
    Write-Status "  Script v$scriptVersion is compatible with template v$templateVersion" -Type Pass
} else {
    Write-Status "  Script v$scriptVersion is NOT compatible with template v$templateVersion" -Type Fail
    $issues += "Script v$scriptVersion does not support template v$templateVersion"
}

# Check 8: Additional template files for Invoke-PrimeWorkspace.ps1
Write-Status "Check 8: Governance template files (for Invoke-PrimeWorkspace.ps1)..." -Type Info
$govDir = Join-Path $PSScriptRoot "governance"
$govTemplates = @(
    "PLAN-template.md",
    "STATUS-template.md",
    "ACCEPTANCE-template.md",
    "README-header-block.md"
)

$missingGovTemplates = @()
foreach ($template in $govTemplates) {
    $templatePath = Join-Path $govDir $template
    if (Test-Path $templatePath) {
        Write-Status "  $template found" -Type Pass
    } else {
        Write-Status "  $template NOT FOUND" -Type Warn
        $missingGovTemplates += $template
    }
}

if ($missingGovTemplates.Count -gt 0) {
    $warnings += "Invoke-PrimeWorkspace.ps1 will fail without governance templates"
}

# ---------------------------------------------------------------------------
# Detailed Output
# ---------------------------------------------------------------------------

if ($Detailed) {
    Write-Host ""
    Write-Status "=== DETAILED DIAGNOSTICS ===" -Type Info
    Write-Host ""
    Write-Status "Template Structure:" -Type Info
    $structure.Markers | ForEach-Object {
        Write-Status "  Line $($_.LineNumber): $($_.Marker)" -Type Info
    }
    Write-Host ""
    Write-Status "Compatibility Matrix:" -Type Info
    Write-Status "  Script v1.4.1 / v1.5.0 → Templates v2.1.0, v3.0.0" -Type Info
    Write-Status "  Script v2.0.0 (current) → Templates v5.0.0+" -Type Info
    Write-Host ""
    Write-Status "Recommended Action:" -Type Info
    if ($issues.Count -gt 0) {
        Write-Status "  1. Fix compatibility issues listed below" -Type Info
        Write-Status "  2. Re-run this pre-flight check" -Type Info
        Write-Status "  3. Proceed with priming only after [PASS]" -Type Info
    } else {
        Write-Status "  All compatibility checks passed - safe to proceed with priming" -Type Info
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Host ""
Write-Status "=== VALIDATION SUMMARY ===" -Type Info
Write-Host ""

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Status "Status: COMPATIBLE - Safe to proceed with priming" -Type Pass
    exit 0
}
elseif ($issues.Count -eq 0 -and $warnings.Count -gt 0) {
    Write-Status "Status: COMPATIBLE WITH WARNINGS - Review warnings before proceeding" -Type Warn
    Write-Host ""
    Write-Status "Warnings:" -Type Warn
    $warnings | ForEach-Object { Write-Status "  - $_" -Type Warn }
    exit 0
}
else {
    Write-Status "Status: INCOMPATIBLE - DO NOT PROCEED WITH PRIMING" -Type Fail
    Write-Host ""
    Write-Status "Critical Issues:" -Type Fail
    $issues | ForEach-Object { Write-Status "  - $_" -Type Fail }
    
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Status "Warnings:" -Type Warn
        $warnings | ForEach-Object { Write-Status "  - $_" -Type Warn }
    }
    
    Write-Host ""
    Write-Status "Recommendation:" -Type Info
    Write-Status "  1. Update Apply-Project07-Artifacts.ps1 to handle template v$templateVersion" -Type Info
    Write-Status "  2. OR use manual priming approach (see .eva/PRIMING-NOTES-*.md)" -Type Info
    Write-Status "  3. OR wait for script v2.0.0 with v5.0.0+ support" -Type Info
    
    exit 1
}
