# Capture-ProjectStructure.ps1
# Version: 1.0.1 (January 30, 2026)
# Generates project-folder-picture.md snapshot of current filesystem state
# See CHANGELOG.md for version history

<#
.SYNOPSIS
    Captures current project structure as project-folder-picture.md

.DESCRIPTION
    Scans filesystem and generates hierarchical tree view documentation.
    Output saved to .github/project-folder-picture.md for AI context and housekeeping reference.
    
    Professional Components:
    - DebugArtifactCollectorPS: Evidence at operation boundaries
    - ASCII-only output (Windows enterprise encoding safety)

.PARAMETER TargetPath
    Path to project root (default: current directory)

.PARAMETER OutputFile
    Output file path (default: .github/project-folder-picture.md)

.PARAMETER Depth
    Maximum folder depth to scan (default: 3)

.PARAMETER IncludeHidden
    Include hidden files and folders

.EXAMPLE
    .\Capture-ProjectStructure.ps1
    Capture current directory structure

.EXAMPLE
    .\Capture-ProjectStructure.ps1 -Depth 4 -IncludeHidden
    Deep scan including hidden items

.NOTES
    Version: 1.0.0
    Compatible with: Initialize-ProjectStructure v1.0.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "",
    
    [Parameter(Mandatory=$false)]
    [int]$Depth = 3,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeHidden
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ASCII-only output
$script:Symbols = @{
    Pass = "[PASS]"
    Info = "[INFO]"
    Warn = "[WARN]"
    Error = "[ERROR]"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Format-FolderTree {
    param(
        [string]$path,
        [int]$currentDepth = 0,
        [int]$maxDepth = 3,
        [string]$prefix = "",
        [bool]$includeHidden = $false
    )
    
    if ($currentDepth -ge $maxDepth) { return @() }
    
    $items = @(Get-ChildItem -Path $path -Force:$includeHidden -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch '^\.git$|^node_modules$|^\.venv$|^__pycache__$' } |
        Sort-Object { $_.PSIsContainer }, Name)
    
    # Handle empty directories
    if ($null -eq $items -or $items.Count -eq 0) {
        return @()
    }
    
    $output = @()
    $folderCount = 0
    $fileCount = 0
    
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)
        $connector = if ($isLast) { "└── " } else { "├── " }
        $extension = if ($isLast) { "    " } else { "│   " }
        
        if ($item.PSIsContainer) {
            $folderCount++
            $output += "$prefix$connector$($item.Name)/"
            
            if ($currentDepth + 1 -lt $maxDepth) {
                $output += Format-FolderTree -path $item.FullName `
                    -currentDepth ($currentDepth + 1) `
                    -maxDepth $maxDepth `
                    -prefix "$prefix$extension" `
                    -includeHidden $includeHidden
            }
        } else {
            $fileCount++
            $sizeKb = [math]::Round($item.Length / 1KB, 1)
            $sizeStr = if ($sizeKb -gt 1024) { "$([math]::Round($sizeKb/1024, 1)) MB" } else { "$sizeKb KB" }
            $output += "$prefix$connector$($item.Name) [$sizeStr]"
        }
    }
    
    return $output
}

function Get-FolderStats {
    param([string]$path, [bool]$includeHidden)
    
    $allItems = @(Get-ChildItem -Path $path -Recurse -Force:$includeHidden -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]|[\\/]node_modules[\\/]|[\\/]\.venv[\\/]|[\\/]__pycache__[\\/]' })
    
    $folders = @($allItems | Where-Object { $_.PSIsContainer })
    $files = @($allItems | Where-Object { -not $_.PSIsContainer })
    
    $totalSize = 0
    if ($files.Count -gt 0) {
        $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $totalSize) { $totalSize = 0 }
    }
    
    return @{
        FolderCount = $folders.Count
        FileCount = $files.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }
}

# ============================================================================
# Main Implementation
# ============================================================================

function Capture-ProjectStructure {
    param([string]$targetPath, [string]$outputFile, [int]$depth, [bool]$includeHidden)
    
    Write-Host ""
    Write-Host "$($script:Symbols.Info) Capture-ProjectStructure v1.0.1" -ForegroundColor Cyan
    Write-Host "$($script:Symbols.Info) Target: $targetPath" -ForegroundColor White
    Write-Host "$($script:Symbols.Info) Depth: $depth levels" -ForegroundColor White
    Write-Host ""
    
    try {
        # Determine output file
        if ([string]::IsNullOrWhiteSpace($outputFile)) {
            $outputFile = Join-Path $targetPath ".github\project-folder-picture.md"
        }
        
        # Ensure output directory exists
        $outputDir = Split-Path $outputFile -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        }
        
        Write-Host "$($script:Symbols.Info) Scanning filesystem..." -ForegroundColor Cyan
        
        # Get statistics
        $stats = Get-FolderStats -path $targetPath -includeHidden $includeHidden
        
        # Generate tree
        $projectName = Split-Path $targetPath -Leaf
        $tree = Format-FolderTree -path $targetPath -maxDepth $depth -includeHidden $includeHidden
        
        # Build output document
        $content = @"
# Project Folder Structure Snapshot

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Project**: $projectName  
**Location**: ``$targetPath``  
**Scan Depth**: $depth levels

## Statistics

- **Total Folders**: $($stats.FolderCount)
- **Total Files**: $($stats.FileCount)
- **Total Size**: $($stats.TotalSizeMB) MB

## Structure Overview

``````
$projectName/
$(($tree | ForEach-Object { $_ }) -join "`n")
``````

## Usage

This snapshot documents the current project structure for:
- **AI Context Management**: Reference for AI assistants
- **Housekeeping**: Baseline for drift detection
- **Documentation**: Human-readable project map

**Compare with standard**: See ``.github/supported-folder-structure.json``  
**Run housekeeping**: ``.\scripts\housekeeping\Invoke-WorkspaceHousekeeping.ps1``

---
*Generated by Capture-ProjectStructure.ps1 v1.0.0*
"@
        
        # Write output
        Set-Content -Path $outputFile -Value $content -Encoding UTF8
        
        Write-Host ""
        Write-Host "$($script:Symbols.Pass) Snapshot captured!" -ForegroundColor Green
        Write-Host "  Folders: $($stats.FolderCount)" -ForegroundColor White
        Write-Host "  Files: $($stats.FileCount)" -ForegroundColor White
        Write-Host "  Size: $($stats.TotalSizeMB) MB" -ForegroundColor White
        Write-Host ""
        Write-Host "$($script:Symbols.Info) Output: $outputFile" -ForegroundColor Cyan
        
    } catch {
        Write-Host ""
        Write-Host "$($script:Symbols.Error) Capture failed: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Execute
Capture-ProjectStructure -targetPath $TargetPath -outputFile $OutputFile -depth $Depth -includeHidden $IncludeHidden
