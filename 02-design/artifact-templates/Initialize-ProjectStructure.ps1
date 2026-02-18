# Initialize-ProjectStructure.ps1
# Version: 1.0.0 (January 30, 2026)
# Creates standardized folder structure from JSON template
# See CHANGELOG.md for version history

<#
.SYNOPSIS
    Initializes project folder structure from supported-folder-structure.json template

.DESCRIPTION
    Reads .github/supported-folder-structure.json and creates the defined folder hierarchy.
    Generates .folderinfo files explaining each directory's purpose.
    
    Professional Components:
    - DebugArtifactCollectorPS: Evidence at operation boundaries
    - SessionManagerPS: Checkpoint/resume capability
    - StructuredErrorHandlerPS: JSON error logging
    - ASCII-only output (Windows enterprise encoding safety)

.PARAMETER TargetPath
    Path to target project (default: current directory)

.PARAMETER TemplateFile
    Path to folder structure JSON template (default: .github/supported-folder-structure.json)

.PARAMETER Force
    Overwrite existing .folderinfo files

.PARAMETER DryRun
    Preview structure without creating folders

.EXAMPLE
    .\Initialize-ProjectStructure.ps1
    Initialize structure in current directory

.EXAMPLE
    .\Initialize-ProjectStructure.ps1 -TargetPath "I:\MyProject" -DryRun
    Preview structure creation

.NOTES
    Version: 1.0.0
    Compatible with: copilot-instructions-template v2.2.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ASCII-only output (Windows enterprise encoding safety)
$script:Symbols = @{
    Pass = "[PASS]"
    Fail = "[FAIL]"
    Info = "[INFO]"
    Warn = "[WARN]"
    Error = "[ERROR]"
}

# ============================================================================
# Professional Component: DebugArtifactCollectorPS
# ============================================================================
class DebugArtifactCollectorPS {
    [string]$ComponentName
    [string]$DebugDir
    
    DebugArtifactCollectorPS([string]$componentName, [string]$basePath) {
        $this.ComponentName = $componentName
        $this.DebugDir = Join-Path $basePath "evidence\structure-init"
        
        if (-not (Test-Path $this.DebugDir)) {
            New-Item -Path $this.DebugDir -ItemType Directory -Force | Out-Null
        }
    }
    
    [void] CaptureState([string]$context) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $stateFile = Join-Path $this.DebugDir "$($context)_$timestamp.json"
        
        $state = @{
            timestamp = Get-Date -Format "o"
            context = $context
            component = $this.ComponentName
            workingDirectory = Get-Location
        }
        
        $state | ConvertTo-Json -Depth 5 | Set-Content -Path $stateFile -Encoding UTF8
    }
}

# ============================================================================
# Professional Component: SessionManagerPS
# ============================================================================
class SessionManagerPS {
    [string]$ComponentName
    [string]$SessionDir
    
    SessionManagerPS([string]$componentName, [string]$basePath) {
        $this.ComponentName = $componentName
        $this.SessionDir = Join-Path $basePath "sessions\structure-init"
        
        if (-not (Test-Path $this.SessionDir)) {
            New-Item -Path $this.SessionDir -ItemType Directory -Force | Out-Null
        }
    }
    
    [void] SaveCheckpoint([string]$checkpointId, [hashtable]$data) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $checkpointFile = Join-Path $this.SessionDir "$($checkpointId)_$timestamp.json"
        
        $checkpoint = @{
            checkpointId = $checkpointId
            timestamp = Get-Date -Format "o"
            component = $this.ComponentName
            data = $data
        }
        
        $checkpoint | ConvertTo-Json -Depth 5 | Set-Content -Path $checkpointFile -Encoding UTF8
    }
}

# ============================================================================
# Professional Component: StructuredErrorHandlerPS
# ============================================================================
class StructuredErrorHandlerPS {
    [string]$ComponentName
    [string]$ErrorDir
    
    StructuredErrorHandlerPS([string]$componentName, [string]$basePath) {
        $this.ComponentName = $componentName
        $this.ErrorDir = Join-Path $basePath "logs\errors"
        
        if (-not (Test-Path $this.ErrorDir)) {
            New-Item -Path $this.ErrorDir -ItemType Directory -Force | Out-Null
        }
    }
    
    [void] LogError([System.Management.Automation.ErrorRecord]$error, [hashtable]$context) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $errorFile = Join-Path $this.ErrorDir "$($this.ComponentName)_error_$timestamp.json"
        
        $errorReport = @{
            timestamp = Get-Date -Format "o"
            component = $this.ComponentName
            errorType = $error.Exception.GetType().Name
            errorMessage = $error.Exception.Message
            stackTrace = $error.ScriptStackTrace
            context = $context
        }
        
        $errorReport | ConvertTo-Json -Depth 5 | Set-Content -Path $errorFile -Encoding UTF8
        
        Write-Host "$($script:Symbols.Error) $($this.ComponentName): $($error.Exception.GetType().Name)" -ForegroundColor Red
        Write-Host "$($script:Symbols.Error) Details saved: $errorFile" -ForegroundColor Red
    }
}

# ============================================================================
# Main Implementation
# ============================================================================

function Initialize-ProjectStructure {
    param([string]$targetPath, [string]$templateFile, [bool]$force, [bool]$dryRun)
    
    Write-Host ""
    Write-Host "$($script:Symbols.Info) Initialize-ProjectStructure v1.0.0" -ForegroundColor Cyan
    Write-Host "$($script:Symbols.Info) Target: $targetPath" -ForegroundColor White
    Write-Host ""
    
    # Initialize professional components
    $debugCollector = [DebugArtifactCollectorPS]::new("structure-init", $targetPath)
    $sessionMgr = [SessionManagerPS]::new("structure-init", $targetPath)
    $errorHandler = [StructuredErrorHandlerPS]::new("structure-init", $targetPath)
    
    try {
        # STEP 1: Locate template file
        $debugCollector.CaptureState("before-locate-template")
        
        if ([string]::IsNullOrWhiteSpace($templateFile)) {
            $templateFile = Join-Path $targetPath ".github\supported-folder-structure.json"
        }
        
        if (-not (Test-Path $templateFile)) {
            throw "Template file not found: $templateFile"
        }
        
        Write-Host "$($script:Symbols.Pass) Template: $templateFile" -ForegroundColor Green
        
        # STEP 2: Read template
        $debugCollector.CaptureState("before-read-template")
        
        $template = Get-Content $templateFile -Raw | ConvertFrom-Json
        $projectType = $template.projectType
        $version = $template.version
        
        Write-Host "$($script:Symbols.Info) Project Type: $projectType" -ForegroundColor White
        Write-Host "$($script:Symbols.Info) Template Version: $version" -ForegroundColor White
        Write-Host ""
        
        $sessionMgr.SaveCheckpoint("template-loaded", @{
            templateFile = $templateFile
            projectType = $projectType
            version = $version
            folderCount = $template.requiredFolders.Count
        })
        
        # STEP 3: Create required folders
        $debugCollector.CaptureState("before-create-folders")
        
        Write-Host "$($script:Symbols.Info) Creating folder structure..." -ForegroundColor Cyan
        $createdCount = 0
        $skippedCount = 0
        
        foreach ($folder in $template.requiredFolders) {
            $folderPath = Join-Path $targetPath $folder
            
            if (Test-Path $folderPath) {
                Write-Host "  $($script:Symbols.Info) Exists: $folder" -ForegroundColor Gray
                $skippedCount++
            } else {
                if ($dryRun) {
                    Write-Host "  $($script:Symbols.Info) Would create: $folder" -ForegroundColor Yellow
                } else {
                    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
                    Write-Host "  $($script:Symbols.Pass) Created: $folder" -ForegroundColor Green
                    $createdCount++
                }
            }
            
            # Create .folderinfo if description exists
            if ($template.folderDescriptions.PSObject.Properties.Name -contains $folder) {
                $folderinfoPath = Join-Path $folderPath ".folderinfo"
                $description = $template.folderDescriptions.$folder
                
                if ((Test-Path $folderinfoPath) -and -not $force) {
                    # Skip existing .folderinfo
                } else {
                    if (-not $dryRun) {
                        $folderinfoContent = @"
# $folder

**Purpose**: $description

**Created**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Template**: $projectType v$version

**AI Context**: This folder is part of the standardized project structure.
"@
                        Set-Content -Path $folderinfoPath -Value $folderinfoContent -Encoding UTF8
                    }
                }
            }
        }
        
        $debugCollector.CaptureState("after-create-folders")
        
        # STEP 4: Create README.md navigation guide
        $readmePath = Join-Path $targetPath "README.md"
        
        if (-not (Test-Path $readmePath) -or $force) {
            if (-not $dryRun) {
                $readmeContent = @"
# Project Structure

**Project Type**: $projectType
**Template Version**: $version
**Initialized**: $(Get-Date -Format "yyyy-MM-dd")

## Folder Organization

See `.folderinfo` files in each directory for detailed descriptions.

### Required Folders
$(($template.requiredFolders | ForEach-Object { "- ``$_``" }) -join "`n")

## Workspace Management

**Capture Current State**:
``````powershell
.\scripts\housekeeping\Capture-ProjectStructure.ps1
``````

**Run Housekeeping**:
``````powershell
.\scripts\housekeeping\Invoke-WorkspaceHousekeeping.ps1 -DryRun
``````

**Reference**: See ``.github/supported-folder-structure.json`` for complete structure definition.
"@
                Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
                Write-Host ""
                Write-Host "$($script:Symbols.Pass) Created: README.md" -ForegroundColor Green
            }
        }
        
        # Summary
        Write-Host ""
        Write-Host "$($script:Symbols.Pass) Structure initialization complete!" -ForegroundColor Green
        Write-Host "  Created: $createdCount folders" -ForegroundColor White
        Write-Host "  Skipped: $skippedCount existing folders" -ForegroundColor White
        
        if ($dryRun) {
            Write-Host ""
            Write-Host "$($script:Symbols.Info) DRY RUN - No changes made" -ForegroundColor Yellow
        }
        
        $sessionMgr.SaveCheckpoint("complete", @{
            createdCount = $createdCount
            skippedCount = $skippedCount
            success = $true
        })
        
    } catch {
        $errorHandler.LogError($_, @{
            operation = "Initialize-ProjectStructure"
            targetPath = $targetPath
            templateFile = $templateFile
        })
        throw
    }
}

# Execute
Initialize-ProjectStructure -targetPath $TargetPath -templateFile $TemplateFile -force $Force -dryRun $DryRun
