<#
.SYNOPSIS
    Bootstrap-Project07.ps1 v1.0.0
    Session bootstrap for 07-foundation-layer: health check + template verify + session brief.

.DESCRIPTION
    Run this at the start of every session working on project 07 or before running
    Invoke-PrimeWorkspace.ps1. Produces a one-screen session brief that includes:

      - Data model health (ACA preferred, local fallback)
      - Template version and line count vs expected
      - Apply script version and last-modified date
      - Governance template presence
      - Project 07 data model record (maturity, phase, rv)
      - Paste-ready next-step commands

.PARAMETER DataModelBase
    Override the data model base URL. Default: workspace cloud endpoint.

.EXAMPLE
    .\Bootstrap-Project07.ps1

.EXAMPLE
    # Quiet -- summary only
    .\Bootstrap-Project07.ps1 | Select-String "(PASS|FAIL|WARN|BRIEF)"

.NOTES
    Encoding: ASCII-only. No emoji. Tokens: [PASS] [FAIL] [WARN] [INFO] [SKIP]
    Version: 1.0.0
    Created: 2026-02-25 by agent:copilot
#>

param(
    [string]$DataModelBase = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

$ScriptDir    = $PSScriptRoot
$Project07Dir = (Resolve-Path (Join-Path $ScriptDir "../..")).Path
$TemplateFile = Join-Path $Project07Dir "templates\copilot-instructions-template.md"
$ApplyScript  = Join-Path $ScriptDir "Apply-Project07-Artifacts.ps1"
$GovDir       = Join-Path $Project07Dir "templates\governance"
$AcaBase      = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

$Issues = [System.Collections.Generic.List[string]]::new()

function Get-OptionalPropertyValue {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Default = "n/a"
    )

    if ($null -eq $Object) {
        return $Default
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        return $Default
    }

    return [string]$property.Value
}

Write-Host ""
Write-Host "=== Bootstrap: 07-foundation-layer ==="
Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm zzz')"
Write-Host ""

# ---------------------------------------------------------------------------
# 1. Data model health (ACA cloud endpoint only)
# ---------------------------------------------------------------------------

Write-Host "--- [1] Data Model Health (Cloud only) ---"

$base = $AcaBase
$aca_health = $null
$aca_ok = $false

# Test ACA endpoint (CLOUD ONLY - localhost:8010 disabled)
$aca_health = Invoke-RestMethod "$AcaBase/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
if ($aca_health -and $aca_health.status -eq "ok") {
    $aca_ok = $true
    Write-Host "  [PASS] Cloud API: store=$($aca_health.store) v=$($aca_health.version) uptime=$($aca_health.uptime_seconds)s"
} else {
    Write-Host "  [FAIL] Cloud API unreachable (localhost:8010 disabled - cloud only)"
    $Issues.Add("Data model cloud endpoint unreachable")
}

# ---------------------------------------------------------------------------
# 2. Template file checks
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [2] Template Checks ---"

if (Test-Path $TemplateFile) {
    $tLines = (Get-Content $TemplateFile).Count
    $tVer   = Select-String -Path $TemplateFile -Pattern "^\*\*Template Version\*\*:" | Select-Object -First 1
    $verStr = if ($tVer) { $tVer.Line.Trim() } else { "(version line not found)" }
    if ($tLines -ge 100 -and $tLines -le 220) {
        Write-Host "  [PASS] copilot-instructions-template.md: $tLines lines, $verStr"
    } else {
        Write-Host "  [WARN] copilot-instructions-template.md: $tLines lines (expected 100-220), $verStr"
        $Issues.Add("Template line count unexpected: $tLines")
    }
    $ownedCheck = Select-String -Path $TemplateFile -Pattern "^## Project-Owned Context$" | Select-Object -First 1
    $validationCheck = Select-String -Path $TemplateFile -Pattern "^## Validation Pattern$" | Select-Object -First 1
    if ($ownedCheck -and $validationCheck) {
        Write-Host "  [PASS] Template has Project-Owned Context and Validation Pattern markers"
    } else {
        Write-Host "  [WARN] Template markers for current project contract are missing"
        $Issues.Add("Template project contract markers missing")
    }
} else {
    Write-Host "  [FAIL] copilot-instructions-template.md not found at: $TemplateFile"
    $Issues.Add("Template file missing")
}

# ---------------------------------------------------------------------------
# 3. Apply script checks
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [3] Apply Script ---"

if (Test-Path $ApplyScript) {
    $aLines  = (Get-Content $ApplyScript).Count
    $aMod    = (Get-Item $ApplyScript).LastWriteTime.ToString("yyyy-MM-dd")
    $aPart2R = Select-String -Path $ApplyScript -Pattern "Project-Owned Context|Validation Pattern" | Select-Object -First 1
    Write-Host "  [PASS] Apply-Project07-Artifacts.ps1: $aLines lines, modified $aMod"
    if ($aPart2R) {
        Write-Host "  [PASS] Apply script references current project contract markers"
    } else {
        Write-Host "  [WARN] Apply script may not be aligned to the current project contract markers"
        $Issues.Add("Apply script project contract markers suspect")
    }
} else {
    Write-Host "  [FAIL] Apply-Project07-Artifacts.ps1 not found at: $ApplyScript"
    $Issues.Add("Apply script missing")
}

# ---------------------------------------------------------------------------
# 4. Governance templates
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [4] Governance Templates ---"

$govFiles = @("PLAN-template.md", "STATUS-template.md", "ACCEPTANCE-template.md", "README-header-block.md")
foreach ($gf in $govFiles) {
    $gp = Join-Path $GovDir $gf
    if (Test-Path $gp) {
        Write-Host "  [PASS] governance/$gf"
    } else {
        Write-Host "  [FAIL] governance/$gf -- MISSING"
        $Issues.Add("Governance template missing: $gf")
    }
}

# ---------------------------------------------------------------------------
# 5. Project 07 data model record
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [5] Project 07 Data Model Record ---"

$p07 = Invoke-RestMethod "$base/model/projects/07-foundation-layer" -ErrorAction SilentlyContinue
if ($p07 -and $p07.id) {
    $maturity = Get-OptionalPropertyValue -Object $p07 -Name "maturity"
    $rowVersion = Get-OptionalPropertyValue -Object $p07 -Name "row_version"
    $phase = Get-OptionalPropertyValue -Object $p07 -Name "phase"
    $pbiDone = Get-OptionalPropertyValue -Object $p07 -Name "pbi_done"
    $pbiTotal = Get-OptionalPropertyValue -Object $p07 -Name "pbi_total"
    Write-Host "  [PASS] id=$($p07.id)  maturity=$maturity  rv=$rowVersion"
    Write-Host "  [INFO] phase=$phase  pbi=$pbiDone/$pbiTotal"
} else {
    Write-Host "  [WARN] Project 07 not found in data model (check connectivity)"
    $Issues.Add("Project 07 not found in data model")
}

# ---------------------------------------------------------------------------
# 6. Validation entrypoints
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [6] Validation Entry Points ---"

$validationScript = Join-Path $Project07Dir "scripts\testing\Test-Project07-Deployment.ps1"
if (Test-Path $validationScript) {
    Write-Host "  [PASS] Test-Project07-Deployment.ps1 present"
} else {
    Write-Host "  [FAIL] Test-Project07-Deployment.ps1 missing at: $validationScript"
    $Issues.Add("Validation script missing")
}

# ---------------------------------------------------------------------------
# Session Brief
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "=== SESSION BRIEF ==="
Write-Host "  Project    : 07-foundation-layer"
Write-Host "  Data model : $base"
if ($p07 -and $p07.id) {
    Write-Host "  DM status  : maturity=$(Get-OptionalPropertyValue -Object $p07 -Name 'maturity') rv=$(Get-OptionalPropertyValue -Object $p07 -Name 'row_version')"
}
if (Test-Path $TemplateFile) {
    $templateVersionLine = Select-String -Path $TemplateFile -Pattern '^\*\*Template Version\*\*:' | Select-Object -First 1
    $templateStatus = if ($templateVersionLine) { $templateVersionLine.Line.Trim() } else { 'present (version line missing)' }
} else {
    $templateStatus = 'MISSING'
}
Write-Host "  Template   : $templateStatus"
Write-Host "  Apply scrpt: $(if (Test-Path $ApplyScript) { 'present' } else { 'MISSING' })"
Write-Host "  Issues     : $($Issues.Count)"
if ($Issues.Count -gt 0) {
    foreach ($iss in $Issues) {
        Write-Host "    [WARN] $iss"
    }
}

Write-Host ""
Write-Host "=== NEXT STEP COMMANDS ==="
Write-Host "  # Prime a single project (dry-run first):"
Write-Host "  .\scripts\deployment\Invoke-PrimeWorkspace.ps1 ``"
Write-Host "        -TargetPath `"C:\eva-foundry\01-documentation-generator`" -DryRun"
Write-Host ""
Write-Host "  # Prime a single project (apply):"
Write-Host "  .\scripts\deployment\Invoke-PrimeWorkspace.ps1 ``"
Write-Host "        -TargetPath `"C:\eva-foundry\01-documentation-generator`""
Write-Host ""
Write-Host "  # Prime entire workspace:"
Write-Host "  .\scripts\deployment\Invoke-PrimeWorkspace.ps1 ``"
Write-Host "        -WorkspaceRoot `"C:\eva-foundry`""
Write-Host ""
Write-Host "  # Validate the active Project 07 surface:"
Write-Host "  .\scripts\testing\Test-Project07-Deployment.ps1"
Write-Host ""

if ($Issues.Count -eq 0) {
    Write-Host "[PASS] Bootstrap complete -- no issues found"
} else {
    Write-Host "[WARN] Bootstrap complete -- $($Issues.Count) issue(s) require attention"
}
