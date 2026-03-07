# Add-ProjectLock.ps1
# Distributes the Project Lock block (top of PART 2) to all numbered project
# copilot-instructions.md files under eva-foundry.
# Safe to re-run -- skips files that already have ### Project Lock.
# Template Version 3.3.0 | February 26, 2026

param(
    [switch]$DryRun,
    [switch]$Verbose
)

$root = "C:\AICOE\eva-foundry"
$updated = 0
$skipped_lock = 0
$skipped_depth = 0
$skipped_no_part2 = 0

# Collect all .github\copilot-instructions.md files
$all = Get-ChildItem $root -Recurse -Filter "copilot-instructions.md" |
    Where-Object { $_.FullName -match '\\.github\\copilot-instructions\.md$' }

foreach ($f in $all) {
    $path = $f.FullName

    # --- Depth check: primary project files only ---
    # Primary: C:\AICOE\eva-foundry\<NN>-xxx\.github\copilot-instructions.md
    # or:      C:\AICOE\eva-foundry\.github\copilot-instructions.md  (workspace root)
    $rel = $path.Substring($root.Length).TrimStart('\')
    $parts = $rel -split '\\'
    # parts[0] = project-folder (or .github for workspace root)
    # parts[1] = .github
    # parts[2] = copilot-instructions.md
    if ($parts.Count -ne 3 -and $parts.Count -ne 2) {
        if ($Verbose) { Write-Host "[INFO] SKIP (depth>1): $rel" }
        $skipped_depth++
        continue
    }

    # Extract project folder
    if ($parts.Count -eq 3) {
        $projectFolder = $parts[0]
    } else {
        $projectFolder = "eva-foundry"
    }

    # Read file
    $content = [System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false))

    # Skip if Project Lock already present
    if ($content -match '### Project Lock') {
        if ($Verbose) { Write-Host "[INFO] SKIP (has lock): $rel" }
        $skipped_lock++
        continue
    }

    # Find first ## PART 2 heading line
    $lines = $content -split "`n"
    $part2Idx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## PART 2') {
            $part2Idx = $i
            break
        }
    }

    if ($part2Idx -eq -1) {
        if ($Verbose) { Write-Host "[WARN] SKIP (no PART 2): $rel" }
        $skipped_no_part2++
        continue
    }

    # Extract project name from **Project**: line
    $projectNameMatch = [regex]::Match($content, '\*\*Project\*\*:\s*(.+)')
    if ($projectNameMatch.Success) {
        # Take text up to first " -- " or end, remove trailing whitespace
        $projectName = $projectNameMatch.Groups[1].Value.Trim() -replace '\s*--.*$', ''
        $projectName = $projectName.Trim()
    } else {
        $projectName = $projectFolder
    }

    # Build the Project Lock block (ASCII only, no backtick escaping issues)
    $lockBlock = @"

### Project Lock

This file is the copilot-instructions for **$projectFolder** ($projectName).

The workspace-level bootstrap rule "Step 1 -- Identify the active project from the currently open file path"
applies **only at the initial load of this file** (first read at session start).
Once this file has been loaded, the active project is locked to **$projectFolder** for the entire session.
Do NOT re-evaluate project identity from editorContext or terminal CWD on each subsequent request.
Work state and sprint context are read from ``STATUS.md`` and ``PLAN.md`` at bootstrap -- not from this file.

---
"@

    # Insert lock block right after the ## PART 2 heading line
    $newLines = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $newLines.Add($lines[$i])
        if ($i -eq $part2Idx) {
            # Append lock block lines after heading
            $lockBlock -split "`n" | ForEach-Object { $newLines.Add($_) }
        }
    }

    $newContent = $newLines -join "`n"

    if ($DryRun) {
        Write-Host "[DRY ] Would update: $rel"
    } else {
        [System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
        Write-Host "[PASS] Updated: $rel"
    }
    $updated++
}

Write-Host ""
Write-Host "[INFO] Done. updated=$updated  skipped_lock=$skipped_lock  skipped_depth=$skipped_depth  skipped_no_part2=$skipped_no_part2"
