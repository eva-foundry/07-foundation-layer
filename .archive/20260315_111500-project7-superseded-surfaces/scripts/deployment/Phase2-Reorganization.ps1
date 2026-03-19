#!/usr/bin/env pwsh
# File: Phase2-Reorganization.ps1
# Purpose: Complete Phase 2 of Project 07 reorganization (move 01/02 content, update script paths)

Set-Location "C:\eva-foundry\07-foundation-layer"

Write-Host "`n[PHASE 2] Final Reorganization - 01-discovery & 02-design" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# === PHASE 1: MOVE README FILES ===
Write-Host "[PHASE 1] Move README.md files" -ForegroundColor Yellow

Write-Host "`n  Moving 01-discovery/README.md..." -ForegroundColor White
$result1 = & git mv "01-discovery/README.md" "docs/discovery-reference/01-discovery-phase-README.md" 2>&1
if ($LASTEXITCODE -eq 0) { 
    Write-Host "  [OK] Moved to docs/discovery-reference/" -ForegroundColor Green 
} else { 
    Write-Host "  [ERROR] $result1" -ForegroundColor Red 
}

Write-Host "`n  Moving 02-design/README.md..." -ForegroundColor White
$result2 = & git mv "02-design/README.md" "docs/discovery-reference/02-design-phase-README.md" 2>&1
if ($LASTEXITCODE -eq 0) { 
    Write-Host "  [OK] Moved to docs/discovery-reference/" -ForegroundColor Green 
} else { 
    Write-Host "  [ERROR] $result2" -ForegroundColor Red 
}

Write-Host "`n  Removing now-empty 01-discovery folder..." -ForegroundColor White
$emptyCheck = @(Get-ChildItem "01-discovery" -ErrorAction SilentlyContinue).Count
if ($emptyCheck -eq 0) {
    $result3 = & git rm -r "01-discovery" 2>&1
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "  [OK] Removed empty folder" -ForegroundColor Green 
    } else { 
        Write-Host "  [SKIP] Folder may have .gitignored files" -ForegroundColor Yellow 
    }
} else {
    Write-Host "  [SKIP] Folder not empty ($emptyCheck items)" -ForegroundColor Gray
}

# === PHASE 2: CONSOLIDATE REMAINING 02-design/artifact-templates ===
Write-Host "`n[PHASE 2] Consolidate remaining diagnostic folders" -ForegroundColor Yellow

$diagnosticFolders = @("backups", "debug", "governance", "logs", "sessions")
$movedCount = 0

foreach ($folder in $diagnosticFolders) {
    $src = "02-design/artifact-templates/$folder"
    $dst = ".archive/02-design-artifacts/$folder"
    
    if (Test-Path $src) {
        Write-Host "`n  Moving artifact-templates/$folder..." -ForegroundColor White
        $result = & git mv $src $dst 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK]" -ForegroundColor Green
            $movedCount++
        } else {
            Write-Host "  [WARN] $result" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n  Note: Moved $movedCount diagnostic folders to .archive/" -ForegroundColor Gray

# === PHASE 3: CLEAN UP EMPTY 02-design STRUCTURE ===
Write-Host "`n[PHASE 3] Remove now-empty 02-design folder" -ForegroundColor Yellow

if ((Test-Path "02-design") -and @(Get-ChildItem "02-design" -ErrorAction SilentlyContinue -Force).Count -le 0) {
    Write-Host "`n  Removing empty 02-design/..." -ForegroundColor White
    $result = & git rm -r "02-design" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK]" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $result" -ForegroundColor Yellow
    }
}

# === PHASE 4: UPDATE SCRIPTS ===
Write-Host "`n[PHASE 4] Update script path references" -ForegroundColor Yellow

$updates = @(
    @{
        File = "scripts/deployment/Reseed-Projects.ps1"
        Find = '02-design\artifact-templates\copilot-instructions-template.md'
        Replace = 'templates\copilot-instructions-template.md'
        Label = "Template path (line 35)"
    },
    @{
        File = "scripts/deployment/Reseed-Projects.ps1"
        Find = '02-design\artifact-templates\backups'
        Replace = '.archive\02-design-artifacts\backups'
        Label = "Backup path (line 36)"
    },
    @{
        File = "scripts/deployment/Bootstrap-Project07.ps1"
        Find = '.\02-design\artifact-templates\Invoke-PrimeWorkspace.ps1'
        Replace = '.\scripts\deployment\Invoke-PrimeWorkspace.ps1'
        Label = "Invoke-PrimeWorkspace path (lines 264,268,272)"
    },
    @{
        File = "scripts/deployment/Apply-Project07-Artifacts.ps1"
        Find = '02-design\artifact-templates'
        Replace = 'templates'
        Label = "Templates path (line 388)"
    },
    @{
        File = "scripts/testing/Test-Project07-Deployment.ps1"
        Find = '02-design\artifact-templates'
        Replace = 'templates'
        Label = "Templates path (lines 57-58)"
    },
    @{
        File = "scripts/utilities/Fix-Project07-Paths.ps1"
        Find = '02-design\artifact-templates'
        Replace = 'templates'
        Label = "Templates path"
    }
)

$updateCount = 0
foreach ($update in $updates) {
    $filepath = $update.File
    $find = $update.Find
    $replace = $update.Replace
    $label = $update.Label
    
    if (Test-Path $filepath) {
        Write-Host "`n  Updating $filepath..." -ForegroundColor White
        Write-Host "    $label" -ForegroundColor Gray
        Write-Host "    FROM: $find" -ForegroundColor Gray
        Write-Host "    TO:   $replace" -ForegroundColor Gray
        
        $content = Get-Content $filepath -Raw
        if ($content -match [regex]::Escape($find)) {
            $newContent = $content -replace [regex]::Escape($find), $replace
            Set-Content $filepath $newContent -Encoding UTF8
            Write-Host "    [OK]" -ForegroundColor Green
            $updateCount++
        } else {
            Write-Host "    [SKIP] Pattern not found" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n  [SKIP] File not found: $filepath" -ForegroundColor Gray
    }
}

Write-Host "`n  Updated $updateCount script paths" -ForegroundColor Gray

# === FINAL STATUS ===
Write-Host "`n[GIT STATUS]" -ForegroundColor Cyan
$status = & git status --short
Write-Host "Staged changes: $($status.Count) items`n" -ForegroundColor Yellow
$status | Select-Object -First 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

Write-Host "`n[PHASE 2 COMPLETE] All moves and updates done" -ForegroundColor Green
Write-Host "Next: Review changes, then commit with git commit -m 'feat(07): finalize reorganization - move 01,02 to docs/'" -ForegroundColor Cyan
