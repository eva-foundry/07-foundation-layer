# Priming Compatibility Check - Quick Start

**Date**: 2026-03-09
**Purpose**: Prevent priming failures by validating compatibility BEFORE execution

---

## The Problem We Solved

Session 42 discovered that **all 4 automated priming attempts failed** when upgrading Project 14-az-finops from template v2.1.0 to v4.2.0:

1. ❌ Invoke-PrimeWorkspace.ps1 → Missing governance templates
2. ❌ Apply-Project07-Artifacts.ps1 (auto-detect) → Could not find artifacts
3. ❌ Apply-Project07-Artifacts.ps1 (root path) → Template not found
4. ❌ Apply-Project07-Artifacts.ps1 (templates path) → **"Extracted only 100 lines (expected >200)"**

**Root Cause**: Scripts v1.5.0 expect templates v2.1.0/v3.0.0 structure, incompatible with v4.2.0

**Solution**: Run pre-flight compatibility check BEFORE priming

---

## Quick Start

### Before ANY Priming Operation

```powershell
# Navigate to deployment scripts
cd C:\eva-foundry\07-foundation-layer\scripts\deployment

# Run pre-flight check
.\Test-PrimingCompatibility.ps1

# Check exit code
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SAFE] Proceed with priming" -ForegroundColor Green
} else {
    Write-Host "[STOP] DO NOT proceed - fix compatibility issues first" -ForegroundColor Red
}
```

### Detailed Diagnostics

```powershell
# Get detailed compatibility report
.\Test-PrimingCompatibility.ps1 -Detailed

# Output shows:
# - Template version (e.g., 4.2.0)
# - Script version (e.g., 1.5.0)
# - Compatibility status
# - Regex extraction simulation
# - Missing files
# - Recommended actions
```

---

## What It Checks

| Check | Purpose |
|-------|---------|
| **Template File Exists** | Validates file at `../../templates/copilot-instructions-template.md` |
| **Script File Exists** | Validates Apply-Project07-Artifacts.ps1 present |
| **Template Version** | Extracts version from `**Template Version**: X.Y.Z` header |
| **Script Version** | Extracts version from script comments |
| **Template Structure** | Validates PART 1/2/3 markers present |
| **Regex Extraction** | Simulates PART 1 extraction, validates line count |
| **Compatibility Matrix** | Checks script version supports template version |
| **Governance Templates** | Validates templates for Invoke-PrimeWorkspace.ps1 |

---

## Output Examples

### Compatible (Safe to Proceed)

```
[PASS] Status: COMPATIBLE - Safe to proceed with priming
```
Exit code: 0

### Incompatible (DO NOT PROCEED)

```
[FAIL] Status: INCOMPATIBLE - DO NOT PROCEED WITH PRIMING

[FAIL] Critical Issues:
[FAIL]   - Regex extraction produces insufficient lines (100 < 200)
[FAIL]   - Script v1.5.0 does not support template v4.2.0

[INFO] Recommendation:
[INFO]   1. Update Apply-Project07-Artifacts.ps1 to handle template v4.2.0
[INFO]   2. OR use manual priming approach (see .eva/PRIMING-NOTES-*.md)
[INFO]   3. OR wait for script v2.0.0 with v4.2.0+ support
```
Exit code: 1

---

## Compatibility Matrix

| Script Version | Compatible Templates |
|----------------|---------------------|
| v1.4.1 | v2.1.0, v3.0.0 |
| v1.5.0 | v2.1.0, v3.0.0 |
| v2.0.0 (needed) | **v4.2.0+** |

**Current Status**: Script v1.5.0 cannot prime template v4.2.0 projects (manual approach required)

---

## When Incompatible: Manual Priming

If pre-flight check fails, use manual priming:

### Step 1: Create Backup
```powershell
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item copilot-instructions.md "copilot-instructions.md.backup_$timestamp"
```

### Step 2: Read Template and Existing File
```powershell
$template = Get-Content 'C:\eva-foundry\07-foundation-layer\templates\copilot-instructions-template.md' -Raw
$existing = Get-Content '.github\copilot-instructions.md'
```

### Step 3: Extract and Merge
```powershell
# Extract PART 1 from template
$part1Match = $template -match '(?s)(.*?)(?=\n## PART 2 -- PROJECT-SPECIFIC)'
$part1 = $Matches[1]

# Substitute placeholders
$part1 = $part1 -replace '\{PROJECT_NAME\}', 'YOUR_PROJECT_NAME'
$part1 = $part1 -replace '\{PROJECT_FOLDER\}', 'YOUR_PROJECT_FOLDER'
$part1 = $part1 -replace '\{PROJECT_STACK\}', 'YOUR_TECH_STACK'

# Extract existing PART 2 (find line numbers first)
$part2StartLine = ($existing | Select-String -Pattern '^## PART 2:').LineNumber
$part2EndLine = ($existing | Select-String -Pattern '^## (PART 3|END)').LineNumber - 1
$part2 = ($existing[$part2StartLine..$part2EndLine] -join "`n")

# Extract PART 3 from template
$part3Match = $template -match '(?s).*\n(## PART 3 -- QUALITY GATES.*)'
$part3 = $Matches[1]

# Merge
$newContent = "$part1`n`n$part2`n`n$part3"
$newContent | Set-Content '.github\copilot-instructions.md.new' -Encoding UTF8
```

### Step 4: Validate and Replace
```powershell
# Count lines
$oldCount = $existing.Count
$newCount = (Get-Content '.github\copilot-instructions.md.new').Count

Write-Host "Old: $oldCount lines"
Write-Host "New: $newCount lines"

# Verify PART 2 content preserved (spot check)
$newContent | Select-String -Pattern 'PROJECT_SPECIFIC_PATTERN'

# If validation passes, replace
Move-Item '.github\copilot-instructions.md.new' '.github\copilot-instructions.md' -Force
```

### Step 5: Document Evidence
```powershell
$evidence = @{
    operation = "manual-prime-v4.2.0"
    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    template_version = "4.2.0"
    previous_version = "X.Y.Z"
    method = "manual-merge"
    results = @{
        old_line_count = $oldCount
        new_line_count = $newCount
        backup_created = "copilot-instructions.md.backup_$timestamp"
    }
}

New-Item -ItemType Directory -Path '.eva' -Force | Out-Null
$evidence | ConvertTo-Json -Depth 5 | Set-Content '.eva\prime-evidence.json'
```

---

## Integration with Existing Workflows

### Before Using Apply-Project07-Artifacts.ps1

```powershell
# OLD (risky)
.\Apply-Project07-Artifacts.ps1 -TargetPath "C:\eva-foundry\14-az-finops"

# NEW (safe)
.\Test-PrimingCompatibility.ps1
if ($LASTEXITCODE -eq 0) {
    .\Apply-Project07-Artifacts.ps1 -TargetPath "C:\eva-foundry\14-az-finops"
} else {
    Write-Host "COMPATIBILITY CHECK FAILED - See output above for recommended actions"
}
```

### Before Using Invoke-PrimeWorkspace.ps1

```powershell
# Check governance templates exist
.\Test-PrimingCompatibility.ps1

# If PASS, proceed
if ($LASTEXITCODE -eq 0) {
    .\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry"
}
```

---

## Files Created (Session 42)

| File | Purpose |
|------|---------|
| `Test-PrimingCompatibility.ps1` | Pre-flight validation script |
| `PRIMING-RCA-20260309.md` | Comprehensive root cause analysis |
| `PRIMING-QUICK-START.md` | This quick reference guide |
| `14-az-finops/.eva/PRIMING-NOTES-20260309.md` | Manual priming documentation |

---

## Next Steps

### Immediate (Before Priming Any Project)
- [ ] Run `Test-PrimingCompatibility.ps1`
- [ ] If incompatible, use manual priming approach
- [ ] Document evidence in `.eva/prime-evidence.json`

### Short-Term (This Sprint)
- [ ] Update Apply-Project07-Artifacts.ps1 to v2.0.0 with v4.2.0 support
- [ ] Create missing governance templates (PLAN, STATUS, ACCEPTANCE, README header)
- [ ] Test updated scripts against all template versions

### Medium-Term (Next Sprint)
- [ ] Build regression test suite
- [ ] Implement automated compatibility testing in CI/CD
- [ ] Create priming dashboard (which projects on which versions)

---

## Support

**Questions?** See comprehensive RCA: `PRIMING-RCA-20260309.md`

**Issues?** Create evidence file:
```powershell
# Run with detailed output
.\Test-PrimingCompatibility.ps1 -Detailed > compatibility-report.txt

# Attach to issue or share with team
```

**Manual Priming Example**: See `14-az-finops/.eva/PRIMING-NOTES-20260309.md`

---

**Version**: 1.0
**Author**: agent:copilot (Session 42 Part 2)
**Last Updated**: 2026-03-09 19:50 ET
