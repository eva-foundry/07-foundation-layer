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
      - MCP server registration status
      - Quick test of the foundation-primer MCP server
      - Paste-ready next-step commands

.PARAMETER DataModelBase
    Override the data model base URL. Default: tries ACA then localhost:8010.

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
$Project07Dir = (Resolve-Path (Join-Path $ScriptDir "../..")).Path  # artifact-templates -> 02-design -> 07-foundation-layer
$TemplateFile = Join-Path $ScriptDir "copilot-instructions-template.md"
$ApplyScript  = Join-Path $ScriptDir "Apply-Project07-Artifacts.ps1"
$GovDir       = Join-Path $ScriptDir "governance"
$McpServerPy  = Join-Path $Project07Dir "mcp-server\foundation-primer\server.py"
$VscMcpJson   = "C:\AICOE\.vscode\mcp.json"
$Venv         = "C:\AICOE\.venv\Scripts\python.exe"

$AcaBase      = "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io"

$Issues = [System.Collections.Generic.List[string]]::new()

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
    if ($tLines -ge 550 -and $tLines -le 650) {
        Write-Host "  [PASS] copilot-instructions-template.md: $tLines lines, $verStr"
    } else {
        Write-Host "  [WARN] copilot-instructions-template.md: $tLines lines (expected 550-650), $verStr"
        $Issues.Add("Template line count unexpected: $tLines")
    }
    # Check PART markers are v3.x style (dash, not colon)
    $part2check = Select-String -Path $TemplateFile -Pattern "^## PART 2 --" | Select-Object -First 1
    if ($part2check) {
        Write-Host "  [PASS] Template PART 2 header is v3.x style (## PART 2 --)"
    } else {
        Write-Host "  [WARN] Template PART 2 header may be v2.x style (colon)"
        $Issues.Add("Template PART 2 header not v3.x style")
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
    $aPart2R = Select-String -Path $ApplyScript -Pattern "PART 2\[" | Select-Object -First 1
    Write-Host "  [PASS] Apply-Project07-Artifacts.ps1: $aLines lines, modified $aMod"
    if ($aPart2R) {
        Write-Host "  [PASS] Apply script has v3.x PART 2 regex"
    } else {
        Write-Host "  [WARN] Apply script PART 2 regex may not be v3.x -- run fix if needed"
        $Issues.Add("Apply script PART 2 regex suspect")
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
    Write-Host "  [PASS] id=$($p07.id)  maturity=$($p07.maturity)  rv=$($p07.row_version)"
    Write-Host "  [INFO] phase=$($p07.phase)  pbi=$($p07.pbi_done)/$($p07.pbi_total)"
} else {
    Write-Host "  [WARN] Project 07 not found in data model (check connectivity)"
    $Issues.Add("Project 07 not found in data model")
}

# ---------------------------------------------------------------------------
# 6. MCP server checks
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [6] MCP Server ---"

if (Test-Path $McpServerPy) {
    $mcpLines = (Get-Content $McpServerPy).Count
    Write-Host "  [PASS] foundation-primer/server.py: $mcpLines lines"
} else {
    Write-Host "  [FAIL] foundation-primer/server.py not found at: $McpServerPy"
    $Issues.Add("MCP server.py missing")
}

if (Test-Path $VscMcpJson) {
    $mcpJson  = Get-Content $VscMcpJson -Raw | ConvertFrom-Json
    $hasPrimer = $mcpJson.mcpServers.PSObject.Properties.Name -contains "foundation-primer"
    if ($hasPrimer) {
        Write-Host "  [PASS] foundation-primer registered in .vscode/mcp.json"
    } else {
        Write-Host "  [WARN] foundation-primer NOT registered in .vscode/mcp.json"
        $Issues.Add("foundation-primer not in .vscode/mcp.json")
    }
} else {
    Write-Host "  [WARN] .vscode/mcp.json not found at $VscMcpJson"
}

# ---------------------------------------------------------------------------
# 7. Quick syntax check on server.py
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [7] MCP Server Syntax Check ---"

if ((Test-Path $McpServerPy) -and (Test-Path $Venv)) {
    $pyCheck = & $Venv -m py_compile $McpServerPy 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [PASS] server.py syntax OK (py_compile)"
    } else {
        Write-Host "  [FAIL] server.py syntax error: $pyCheck"
        $Issues.Add("MCP server.py syntax error")
    }
} else {
    Write-Host "  [SKIP] venv or server.py not found -- skipping syntax check"
}

# ---------------------------------------------------------------------------
# 8. mcp package available
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "--- [8] Python Dependencies ---"

if (Test-Path $Venv) {
    $mcpPkg = & $Venv -c "from mcp.server import Server; from mcp.types import TextContent, Tool; print('OK')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [PASS] mcp package importable (mcp.server + mcp.types)"
    } else {
        Write-Host "  [WARN] mcp package not installed in venv -- run: pip install mcp"
        $Issues.Add("mcp Python package not installed")
    }
    $pydanticPkg = & $Venv -c "import pydantic; print(pydantic.__version__)" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [PASS] pydantic available: v$pydanticPkg"
    } else {
        Write-Host "  [WARN] pydantic not installed -- run: pip install pydantic"
        $Issues.Add("pydantic Python package not installed")
    }
} else {
    Write-Host "  [SKIP] venv not found at $Venv"
}

# ---------------------------------------------------------------------------
# Session Brief
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "=== SESSION BRIEF ==="
Write-Host "  Project    : 07-foundation-layer"
Write-Host "  Data model : $base"
if ($p07 -and $p07.id) {
    Write-Host "  DM status  : maturity=$($p07.maturity) rv=$($p07.row_version)"
}
Write-Host "  Template   : $(if (Test-Path $TemplateFile) { 'v3.1.0 present' } else { 'MISSING' })"
Write-Host "  Apply scrpt: $(if (Test-Path $ApplyScript) { 'present' } else { 'MISSING' })"
Write-Host "  MCP server : $(if (Test-Path $McpServerPy) { 'present' } else { 'MISSING' })"
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
Write-Host "        -TargetPath `"C:\AICOE\eva-foundation\01-documentation-generator`" -DryRun"
Write-Host ""
Write-Host "  # Prime a single project (apply):"
Write-Host "  .\scripts\deployment\Invoke-PrimeWorkspace.ps1 ``"
Write-Host "        -TargetPath `"C:\AICOE\eva-foundation\01-documentation-generator`""
Write-Host ""
Write-Host "  # Prime entire workspace:"
Write-Host "  .\scripts\deployment\Invoke-PrimeWorkspace.ps1 ``"
Write-Host "        -WorkspaceRoot `"C:\AICOE\eva-foundation`""
Write-Host ""
Write-Host "  # Verify template compliance for a project:"
Write-Host "  # (via MCP tool in VS Code agent) audit_project target_path=<path>"
Write-Host ""

if ($Issues.Count -eq 0) {
    Write-Host "[PASS] Bootstrap complete -- no issues found"
} else {
    Write-Host "[WARN] Bootstrap complete -- $($Issues.Count) issue(s) require attention"
}
