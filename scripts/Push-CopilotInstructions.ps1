# Push-CopilotInstructions.ps1
# Commits and pushes copilot-instructions.md changes across all numbered project repos.
# Discovers each folder's git root first -- handles both monorepo and per-project repo layouts.
# February 26, 2026

$msg = "docs(copilot-instructions): add Project Lock block + PUT Rules 6-8 (template v3.3.2)"

$folders = @(
    "C:\AICOE\eva-foundry\07-foundation-layer",
    "C:\AICOE\eva-foundry\31-eva-faces",
    "C:\AICOE\eva-foundry\33-eva-brain-v2",
    "C:\AICOE\eva-foundry\37-data-model",
    "C:\AICOE\eva-foundry\29-foundry",
    "C:\AICOE\eva-foundry\32-logging",
    "C:\AICOE\eva-foundry\36-red-teaming",
    "C:\AICOE\eva-foundry\38-ado-poc",
    "C:\AICOE\eva-foundry\39-ado-dashboard",
    "C:\AICOE\eva-foundry\40-eva-control-plane",
    "C:\AICOE\eva-foundry\41-eva-cli",
    "C:\AICOE\eva-foundry\43-spark",
    "C:\AICOE\eva-foundry\44-eva-jp-spark",
    "C:\AICOE\eva-foundry\45-aicoe-page",
    "C:\AICOE\eva-foundry\46-accelerator",
    "C:\AICOE\eva-foundry\47-eva-mti",
    "C:\AICOE\eva-foundry\48-eva-veritas",
    "C:\AICOE\eva-foundry\49-eva-dtl"
)

# Discover distinct repo roots
$roots = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($f in $folders) {
    if (-not (Test-Path $f)) { continue }
    $root = git -C $f rev-parse --show-toplevel 2>$null
    if ($root) { $roots.Add($root.Replace('/', '\')) | Out-Null }
}

Write-Host "[INFO] Distinct git roots found: $($roots.Count)"
$roots | ForEach-Object { Write-Host "  $_" }
Write-Host ""

$pushed = 0
$nothing = 0
$failed = 0

foreach ($root in $roots) {
    $dirty = git -C $root status --short 2>$null |
        Where-Object { $_ -match 'copilot-instructions\.md|Add-ProjectLock\.ps1|Push-CopilotInstructions\.ps1' }

    if (-not $dirty) {
        Write-Host "[INFO] SKIP (nothing to commit): $root"
        $nothing++
        continue
    }

    Write-Host "[INFO] Staging in: $root ($($dirty.Count) file(s))"
    $dirty | ForEach-Object { Write-Host "  $_" }

    # Stage changed copilot-instructions.md files and 07 scripts
    git -C $root add "*.github/copilot-instructions.md" 2>$null
    git -C $root add -- (git -C $root ls-files --modified --others --exclude-standard 2>$null |
        Where-Object { $_ -match 'copilot-instructions\.md|scripts/Add-ProjectLock|scripts/Push-CopilotInstructions' })

    $br = git -C $root rev-parse --abbrev-ref HEAD 2>$null
    $commitOut = git -C $root commit -m $msg 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARN] Commit skipped or empty: $root -- $commitOut"
        $nothing++
        continue
    }

    $pushOut = git -C $root push origin $br 2>&1
    if ($LASTEXITCODE -eq 0) {
        $hash = git -C $root rev-parse --short HEAD 2>$null
        Write-Host "[PASS] Pushed $root ($br) $hash"
        $pushed++
    } else {
        Write-Host "[FAIL] Push failed: $root"
        Write-Host "       $pushOut"
        $failed++
    }
}

Write-Host ""
Write-Host "[INFO] Done. pushed=$pushed  nothing=$nothing  failed=$failed"
