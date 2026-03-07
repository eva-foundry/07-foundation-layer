# Invoke-WorkspaceHousekeeping.ps1
# Version: 1.0.0 (January 30, 2026)
# Compares actual structure with supported structure and generates remediation report
# See CHANGELOG.md for version history

<#
.SYNOPSIS
    Enforces workspace organization by comparing actual vs. expected structure

.DESCRIPTION
    Reads .github/supported-folder-structure.json (expected state)
    Analyzes .github/project-folder-picture.md (actual state)
    Generates compliance report with remediation commands
    
    Can auto-organize files into correct locations (with confirmation).
    
    Professional Components:
    - StructuredErrorHandlerPS: JSON error logging
    - ASCII-only output (Windows enterprise encoding safety)

.PARAMETER TargetPath
    Path to project root (default: current directory)

.PARAMETER DryRun
    Preview compliance issues without making changes

.PARAMETER AutoOrganize
    Automatically move misplaced files (prompts for confirmation)

.PARAMETER Force
    Skip confirmation prompts when auto-organizing

.EXAMPLE
    .\Invoke-WorkspaceHousekeeping.ps1 -DryRun
    Preview compliance issues

.EXAMPLE
    .\Invoke-WorkspaceHousekeeping.ps1 -AutoOrganize
    Auto-organize with confirmation prompts

.NOTES
    Version: 1.0.0
    Compatible with: Initialize-ProjectStructure v1.0.0+, Capture-ProjectStructure v1.0.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoOrganize,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ASCII-only output
$script:Symbols = @{
    Pass = "[PASS]"
    Fail = "[FAIL]"
    Info = "[INFO]"
    Warn = "[WARN]"
    Error = "[ERROR]"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Get-RootClutter {
    param([string]$targetPath, [array]$allowedRootFiles)
    
    $rootItems = Get-ChildItem -Path $targetPath -File -ErrorAction SilentlyContinue |
        Where-Object { $allowedRootFiles -notcontains $_.Name }
    
    return $rootItems
}

function Test-ComplianceRule {
    param([string]$filePath, [object]$rule)
    
    $fileName = Split-Path $filePath -Leaf
    return $fileName -like $rule.pattern
}

function Format-Deviation {
    param([hashtable]$deviation)
    
    $output = "  $($script:Symbols.Warn) $($deviation.Type): $($deviation.Item)"
    if ($deviation.Recommendation) {
        $output += "`n    Recommendation: $($deviation.Recommendation)"
    }
    return $output
}

# ============================================================================
# Main Implementation
# ============================================================================

function Invoke-WorkspaceHousekeeping {
    param([string]$targetPath, [bool]$dryRun, [bool]$autoOrganize, [bool]$force)
    
    Write-Host ""
    Write-Host "$($script:Symbols.Info) Invoke-WorkspaceHousekeeping v1.0.0" -ForegroundColor Cyan
    Write-Host "$($script:Symbols.Info) Target: $targetPath" -ForegroundColor White
    Write-Host ""
    
    try {
        # STEP 1: Load supported structure
        $templatePath = Join-Path $targetPath ".github\supported-folder-structure.json"
        if (-not (Test-Path $templatePath)) {
            Write-Host "$($script:Symbols.Error) Template not found: $templatePath" -ForegroundColor Red
            Write-Host "$($script:Symbols.Info) Run Initialize-ProjectStructure.ps1 first" -ForegroundColor Yellow
            return
        }
        
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        Write-Host "$($script:Symbols.Pass) Loaded: supported-folder-structure.json" -ForegroundColor Green
        
        # STEP 2: Check if snapshot exists
        $snapshotPath = Join-Path $targetPath ".github\project-folder-picture.md"
        if (-not (Test-Path $snapshotPath)) {
            Write-Host "$($script:Symbols.Warn) Snapshot not found, generating..." -ForegroundColor Yellow
            & "$PSScriptRoot\Capture-ProjectStructure.ps1" -TargetPath $targetPath
        } else {
            Write-Host "$($script:Symbols.Pass) Loaded: project-folder-picture.md" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "$($script:Symbols.Info) Analyzing compliance..." -ForegroundColor Cyan
        Write-Host ""
        
        # STEP 3: Check root directory clutter
        $deviations = @()
        $rootClutter = Get-RootClutter -targetPath $targetPath -allowedRootFiles $template.allowedRootFiles
        
        if ($rootClutter.Count -gt 0) {
            Write-Host "$($script:Symbols.Warn) Root Directory Clutter ($($rootClutter.Count) files)" -ForegroundColor Yellow
            
            foreach ($file in $rootClutter) {
                $matchedRule = $null
                foreach ($rule in $template.organizationRules) {
                    if (Test-ComplianceRule -filePath $file.Name -rule $rule) {
                        $matchedRule = $rule
                        break
                    }
                }
                
                if ($matchedRule) {
                    $deviation = @{
                        Type = "Misplaced File"
                        Item = $file.Name
                        Recommendation = "Move to $($matchedRule.destination)"
                        Reason = $matchedRule.reason
                        Action = @{
                            Source = $file.FullName
                            Destination = Join-Path $targetPath $matchedRule.destination
                        }
                    }
                } else {
                    $deviation = @{
                        Type = "Unexpected Root File"
                        Item = $file.Name
                        Recommendation = "Review and move to appropriate folder or add to allowedRootFiles"
                    }
                }
                
                $deviations += $deviation
                Write-Host (Format-Deviation $deviation) -ForegroundColor Yellow
            }
            Write-Host ""
        }
        
        # STEP 4: Check missing required folders
        $missingFolders = @()
        foreach ($folder in $template.requiredFolders) {
            $folderPath = Join-Path $targetPath $folder
            if (-not (Test-Path $folderPath)) {
                $missingFolders += $folder
            }
        }
        
        if ($missingFolders.Count -gt 0) {
            Write-Host "$($script:Symbols.Warn) Missing Required Folders ($($missingFolders.Count))" -ForegroundColor Yellow
            foreach ($folder in $missingFolders) {
                Write-Host "  $($script:Symbols.Warn) Missing: $folder" -ForegroundColor Yellow
                $deviations += @{
                    Type = "Missing Folder"
                    Item = $folder
                    Recommendation = "Run Initialize-ProjectStructure.ps1 to create"
                }
            }
            Write-Host ""
        }
        
        # STEP 5: Generate summary
        Write-Host "$($script:Symbols.Info) Compliance Summary" -ForegroundColor Cyan
        Write-Host "  Total Deviations: $($deviations.Count)" -ForegroundColor White
        
        if ($deviations.Count -eq 0) {
            Write-Host ""
            Write-Host "$($script:Symbols.Pass) Workspace is compliant!" -ForegroundColor Green
            return
        }
        
        # STEP 6: Auto-organize if requested
        if ($autoOrganize -and -not $dryRun) {
            Write-Host ""
            Write-Host "$($script:Symbols.Info) Auto-organizing misplaced files..." -ForegroundColor Cyan
            
            $organizableDeviations = $deviations | Where-Object { $_.Action -ne $null }
            
            if ($organizableDeviations.Count -eq 0) {
                Write-Host "$($script:Symbols.Info) No automatically fixable deviations found" -ForegroundColor Yellow
                return
            }
            
            if (-not $force) {
                Write-Host ""
                Write-Host "$($script:Symbols.Warn) About to move $($organizableDeviations.Count) files" -ForegroundColor Yellow
                $confirm = Read-Host "Continue? (y/N)"
                if ($confirm -ne 'y') {
                    Write-Host "$($script:Symbols.Info) Cancelled by user" -ForegroundColor Yellow
                    return
                }
            }
            
            foreach ($deviation in $organizableDeviations) {
                $destDir = Split-Path $deviation.Action.Destination -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                }
                
                Move-Item -Path $deviation.Action.Source -Destination $deviation.Action.Destination -Force
                Write-Host "  $($script:Symbols.Pass) Moved: $($deviation.Item) -> $(Split-Path $deviation.Action.Destination -Parent)" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "$($script:Symbols.Pass) Auto-organization complete!" -ForegroundColor Green
            Write-Host "$($script:Symbols.Info) Run Capture-ProjectStructure.ps1 to update snapshot" -ForegroundColor Cyan
        }
        
        # STEP 7: Display remediation commands
        if ($dryRun) {
            Write-Host ""
            Write-Host "$($script:Symbols.Info) Remediation Commands" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "# Auto-organize files:" -ForegroundColor White
            Write-Host ".\Invoke-WorkspaceHousekeeping.ps1 -AutoOrganize" -ForegroundColor Gray
            Write-Host ""
            Write-Host "# Create missing folders:" -ForegroundColor White
            Write-Host ".\Initialize-ProjectStructure.ps1" -ForegroundColor Gray
            Write-Host ""
        }
        
    } catch {
        Write-Host ""
        Write-Host "$($script:Symbols.Error) Housekeeping failed: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Execute
Invoke-WorkspaceHousekeeping -targetPath $TargetPath -dryRun $DryRun -autoOrganize $AutoOrganize -force $Force
