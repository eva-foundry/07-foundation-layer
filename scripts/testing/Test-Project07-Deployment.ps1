<#
.SYNOPSIS
    Validate the active Project 07 deployment surface.

.DESCRIPTION
    Runs a focused smoke validation against the current live Project 07 operator path.
    This script validates only the current implementation, not retired PART-era or MCP-era behavior.

.NOTES
    Encoding: ASCII-only
    Exit codes: 0 success, 1 validation failure, 2 technical failure
#>

[CmdletBinding()]
param(
    [string]$FoundationRoot = "C:\eva-foundry\07-foundation-layer",
    [string]$RepresentativeProject = "C:\eva-foundry\99-test-project"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path $FoundationRoot "logs"
$evidenceDir = Join-Path $FoundationRoot "evidence"
$debugDir = Join-Path $FoundationRoot "debug"
foreach ($dir in @($logDir, $evidenceDir, $debugDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$logPath = Join-Path $logDir "$timestamp-project7-validation.log"
$evidencePath = Join-Path $evidenceDir "$timestamp-project7-validation.json"

function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )

    $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Add-Content -Path $logPath -Value $entry
    Write-Host "[$Level] $Message"
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Bucket,
        [string]$Name,
        [bool]$Passed,
        [string]$Detail
    )

    $Bucket.Add([pscustomobject]@{
        name = $Name
        passed = $Passed
        detail = $Detail
    }) | Out-Null
}

function Test-FileParse {
    param([string]$Path)
    $content = Get-Content $Path -Raw -Encoding UTF8
    $null = [scriptblock]::Create($content)
}

$results = [System.Collections.Generic.List[object]]::new()

try {
    Write-Log "INFO" "Starting Project 07 validation"

    $requiredFiles = @(
        "README.md",
        "ACCEPTANCE.md",
        "STATUS.md",
        "PROJECT-ORGANIZATION.md",
        ".github\PROJECT-ORGANIZATION.md",
        "templates\copilot-instructions-template.md",
        "templates\copilot-instructions-workspace-template.md",
        "scripts\deployment\Apply-Project07-Artifacts.ps1",
        "scripts\deployment\Invoke-PrimeWorkspace.ps1",
        "scripts\deployment\Reseed-Projects.ps1",
        "scripts\deployment\Bootstrap-Project07.ps1",
        "scripts\testing\Test-Project07-Deployment.ps1",
        "scripts\utilities\Initialize-ProjectStructure.ps1",
        "scripts\utilities\Capture-ProjectStructure.ps1",
        "scripts\utilities\Invoke-WorkspaceHousekeeping.ps1",
        "scripts\Initialize-WorkspaceMemorySystem.ps1",
        "tests\test-bootstrap-api.py"
    )

    foreach ($relativePath in $requiredFiles) {
        $fullPath = Join-Path $FoundationRoot $relativePath
        $exists = Test-Path $fullPath
        Add-Result -Bucket $results -Name "exists:$relativePath" -Passed $exists -Detail $(if ($exists) { "present" } else { "missing" })
        if (-not $exists) {
            Write-Log "FAIL" "Missing required file: $relativePath"
        }
    }

    $scriptsToParse = @(
        "scripts\deployment\Apply-Project07-Artifacts.ps1",
        "scripts\deployment\Invoke-PrimeWorkspace.ps1",
        "scripts\deployment\Reseed-Projects.ps1",
        "scripts\deployment\Bootstrap-Project07.ps1",
        "scripts\testing\Test-Project07-Deployment.ps1"
    )

    foreach ($relativePath in $scriptsToParse) {
        $fullPath = Join-Path $FoundationRoot $relativePath
        try {
            Test-FileParse -Path $fullPath
            Add-Result -Bucket $results -Name "parse:$relativePath" -Passed $true -Detail "parsed"
        } catch {
            Add-Result -Bucket $results -Name "parse:$relativePath" -Passed $false -Detail $_.Exception.Message
            Write-Log "FAIL" ("Parser failed for {0}: {1}" -f $relativePath, $_.Exception.Message)
        }
    }

    $templatePath = Join-Path $FoundationRoot "templates\copilot-instructions-template.md"
    $templateContent = Get-Content $templatePath -Raw -Encoding UTF8
    foreach ($marker in @("## Bootstrap First", "## Project-Owned Context", "## Validation Pattern")) {
        $hasMarker = $templateContent.Contains($marker)
        Add-Result -Bucket $results -Name "template-marker:$marker" -Passed $hasMarker -Detail $(if ($hasMarker) { "present" } else { "missing" })
    }

    $stalePattern = '02-design[\\/]+artifact-templates|foundation-primer|mcp-server[\\/]+foundation-primer|## PART 1|## PART 2|## PART 3|Hybrid Paperless Governance'
    $filesToScan = @(
        "README.md",
        "ACCEPTANCE.md",
        "STATUS.md",
        "PROJECT-ORGANIZATION.md",
        ".github\PROJECT-ORGANIZATION.md",
        "scripts\deployment\Bootstrap-Project07.ps1"
    )

    foreach ($relativePath in $filesToScan) {
        $fullPath = Join-Path $FoundationRoot $relativePath
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        $hasStale = $content -match $stalePattern
        Add-Result -Bucket $results -Name "stale-scan:$relativePath" -Passed (-not $hasStale) -Detail $(if ($hasStale) { "stale references found" } else { "clean" })
        if ($hasStale) {
            Write-Log "FAIL" "Stale reference found in $relativePath"
        }
    }

    $bootstrapScript = Join-Path $FoundationRoot "scripts\deployment\Bootstrap-Project07.ps1"
    try {
        & $bootstrapScript *> $null
        Add-Result -Bucket $results -Name "run:Bootstrap-Project07" -Passed $true -Detail "executed"
    } catch {
        Add-Result -Bucket $results -Name "run:Bootstrap-Project07" -Passed $false -Detail $_.Exception.Message
        Write-Log "FAIL" "Bootstrap-Project07.ps1 failed: $($_.Exception.Message)"
    }

    $primeScript = Join-Path $FoundationRoot "scripts\deployment\Invoke-PrimeWorkspace.ps1"
    try {
        & $primeScript -TargetPath $RepresentativeProject -DryRun *> $null
        Add-Result -Bucket $results -Name "run:Invoke-PrimeWorkspace-dryrun" -Passed $true -Detail "executed"
    } catch {
        Add-Result -Bucket $results -Name "run:Invoke-PrimeWorkspace-dryrun" -Passed $false -Detail $_.Exception.Message
        Write-Log "FAIL" "Invoke-PrimeWorkspace.ps1 dry-run failed: $($_.Exception.Message)"
    }

    $applyScript = Join-Path $FoundationRoot "scripts\deployment\Apply-Project07-Artifacts.ps1"
    try {
        & $applyScript -TargetPath $RepresentativeProject -DryRun *> $null
        Add-Result -Bucket $results -Name "run:Apply-Project07-Artifacts-dryrun" -Passed $true -Detail "executed"
    } catch {
        Add-Result -Bucket $results -Name "run:Apply-Project07-Artifacts-dryrun" -Passed $false -Detail $_.Exception.Message
        Write-Log "FAIL" "Apply-Project07-Artifacts.ps1 dry-run failed: $($_.Exception.Message)"
    }

    $failed = @($results | Where-Object { -not $_.passed })
    $payload = [pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        foundation_root = $FoundationRoot
        representative_project = $RepresentativeProject
        total_checks = $results.Count
        passed_checks = @($results | Where-Object { $_.passed }).Count
        failed_checks = $failed.Count
        results = $results
    }
    $payload | ConvertTo-Json -Depth 6 | Out-File $evidencePath -Encoding utf8

    if ($failed.Count -gt 0) {
        Write-Log "FAIL" "Validation failed with $($failed.Count) failing checks"
        exit 1
    }

    Write-Log "PASS" "Validation passed with $($results.Count) checks"
    exit 0
}
catch {
    $payload = [pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        foundation_root = $FoundationRoot
        representative_project = $RepresentativeProject
        error_type = $_.Exception.GetType().Name
        message = $_.Exception.Message
    }
    $payload | ConvertTo-Json -Depth 6 | Out-File $evidencePath -Encoding utf8
    Write-Log "ERROR" "Technical validation failure: $($_.Exception.Message)"
    exit 2
}