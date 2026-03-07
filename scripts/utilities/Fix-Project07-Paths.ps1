# Fix-Project07-Paths.ps1
# Quick fix for hardcoded path issues after folder rename from 07-copilot-instructions to 07-foundation-layer
# Version: 1.0.0
# Date: February 2, 2026

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Project 07 Path Fix Utility" -ForegroundColor Cyan
Write-Host " Fixing hardcoded paths after rename" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fixes = @(
    @{
        File = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\scripts\deployment\Apply-Project07-Artifacts.ps1"
        OldText = "07-copilot-instructions"
        NewText = "07-foundation-layer"
        Description = "Apply-Project07-Artifacts.ps1 - Auto-detection paths"
    },
    @{
        File = "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\scripts\testing\Test-Project07-Deployment.ps1"
        OldText = "07-copilot-instructions"
        NewText = "07-foundation-layer"
        Description = "Test-Project07-Deployment.ps1 - Pester test paths"
    }
)

$successCount = 0
$failCount = 0

foreach ($fix in $fixes) {
    Write-Host "[INFO] Processing: $($fix.Description)" -ForegroundColor Cyan
    
    if (-not (Test-Path $fix.File)) {
        Write-Host "[FAIL] File not found: $($fix.File)" -ForegroundColor Red
        $failCount++
        continue
    }
    
    try {
        $content = Get-Content $fix.File -Raw
        $occurrences = ([regex]::Matches($content, [regex]::Escape($fix.OldText))).Count
        
        if ($occurrences -gt 0) {
            # Create backup
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$($fix.File).backup_$timestamp"
            Copy-Item -Path $fix.File -Destination $backupPath -Force
            Write-Host "  [INFO] Backup created: $(Split-Path $backupPath -Leaf)" -ForegroundColor Gray
            
            # Apply fix
            $updated = $content -replace [regex]::Escape($fix.OldText), $fix.NewText
            Set-Content -Path $fix.File -Value $updated -Encoding UTF8 -NoNewline
            
            Write-Host "  [PASS] Fixed $occurrences occurrences" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  [SKIP] No changes needed (already fixed)" -ForegroundColor Yellow
            $successCount++
        }
    } catch {
        Write-Host "  [FAIL] Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Fix Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Success: $successCount files" -ForegroundColor Green
Write-Host "Failed: $failCount files" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "[PASS] All fixes applied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Test auto-detection: .\Apply-Project07-Artifacts.ps1 -Diagnostic" -ForegroundColor White
    Write-Host "  2. Deploy to Project 15: .\Apply-Project07-Artifacts.ps1 -TargetPath 'I:\EVA-JP-v1.2\docs\eva-foundation\projects\15-cdc' -DryRun" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "[FAIL] Some fixes failed. Review errors above." -ForegroundColor Red
    exit 1
}
