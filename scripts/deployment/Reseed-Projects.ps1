# Reseed-Projects.ps1
# Version: 2.0.0 (March 15, 2026)
# Refreshes copilot-instructions across numbered projects from the live Project 07 template.
#
# Strategy:
#   - Projects WITH existing copilot-instructions.md: refresh the managed foundation contract and preserve the
#     project-owned context block.
#   - Projects WITHOUT instructions: create from template substituting project placeholders.
#   - Legacy PART-based files are converted by wrapping prior project-specific content into the new
#     Project-Owned Context section.
#
# Usage:
#   # Dry run (preview only):
#   .\Reseed-Projects.ps1 -DryRun
#
#   # Reseed a specific project:
#   .\Reseed-Projects.ps1 -Projects "33-eva-brain-v2"
#
#   # Reseed all active projects:
#   .\Reseed-Projects.ps1 -Scope active
#
#   # Reseed everything (all numbered folders, blank slate for empties):
#   .\Reseed-Projects.ps1 -Scope all

[CmdletBinding()]
param(
    [string[]]$Projects = @(),
    [ValidateSet("active","all","specified")]
    [string]$Scope = "specified",
    [switch]$DryRun,
    [switch]$SkipBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$WorkspaceRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
$FOUNDATION   = $WorkspaceRoot
$TEMPLATE     = Join-Path $FOUNDATION "07-foundation-layer\templates\copilot-instructions-template.md"
$BACKUP_ROOT  = Join-Path $FOUNDATION "07-foundation-layer\.archive\02-design-artifacts\backups"

# ----- Active project list (update if registry changes) -----
$ACTIVE_PROJECTS = @(
    "18-azure-best",
    "19-ai-gov",
    "29-foundry",
    "31-eva-faces",
    "33-eva-brain-v2",
    "36-red-teaming",
    "37-data-model",
    "38-ado-poc",
    "39-ado-dashboard",
    "40-eva-control-plane",
    "43-spark",
    "44-eva-jp-spark"
)

# Project metadata for placeholder substitution (new projects only)
$PROJECT_META = @{
    "18-azure-best"        = @{ name="EVA Azure Best";          desc="Azure best practices (11 modules)";               stack="Markdown, Python" }
    "19-ai-gov"            = @{ name="EVA AI Governance";       desc="AI Governance frameworks";                        stack="Python, Markdown" }
    "29-foundry"           = @{ name="EVA Foundry Library";     desc="Agentic capabilities hub (MCP, RAG, eval)";       stack="Python, FastAPI" }
    "31-eva-faces"         = @{ name="EVA Faces";               desc="Admin + chat + portal frontend";                  stack="React, TypeScript, Fluent UI v9" }
    "33-eva-brain-v2"      = @{ name="EVA Brain v2";            desc="Agentic backend (FastAPI + multi-agent)";          stack="Python, FastAPI, Azure AI" }
    "36-red-teaming"       = @{ name="EVA Red Teaming";         desc="Red teaming with Promptfoo";                      stack="Node.js, Promptfoo" }
    "37-data-model"        = @{ name="EVA Data Model";          desc="Single source of truth API (port 8010)";          stack="Python, FastAPI, SQLite" }
    "38-ado-poc"           = @{ name="EVA ADO Command Center";  desc="Scrum orchestration hub";                         stack="Python, FastAPI, Azure DevOps" }
    "39-ado-dashboard"     = @{ name="EVA ADO Dashboard";       desc="Sprint views and metrics";                        stack="React, TypeScript" }
    "40-eva-control-plane" = @{ name="EVA Control Plane";       desc="Runtime evidence spine (port 8020)";              stack="Python, FastAPI" }
    "43-spark"             = @{ name="EVA JP Spark";            desc="Jurisprudence assistant (older)";                 stack="Python, FastAPI, React" }
    "44-eva-jp-spark"      = @{ name="EVA JP Spark v2";         desc="Bilingual GC AI assistant";                       stack="Python, FastAPI, React, TypeScript" }
}

# ----- Helpers -----

function Write-Log([string]$msg, [string]$type="INFO") {
    $prefix = switch ($type) {
        "PASS" { "[PASS]" } "FAIL" { "[FAIL]" } "WARN" { "[WARN]" } default { "[INFO]" }
    }
    Write-Host "$prefix $msg"
}

function Split-TemplateContent([string]$content) {
    $lines = $content -split "`n"
    $ownedStart = -1
    $validationStart = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## Project-Owned Context') { $ownedStart = $i }
        if ($lines[$i] -match '^## Validation Pattern') { $validationStart = $i }
    }

    if ($ownedStart -lt 0 -or $validationStart -lt 0) {
        throw "[FAIL] Template missing Project-Owned Context or Validation Pattern section headers"
    }

    return @{
        Prefix        = ($lines[0..($ownedStart-1)] -join "`n").TrimEnd()
        OwnedTemplate = ($lines[$ownedStart..($validationStart-1)] -join "`n").TrimEnd()
        Suffix        = ($lines[$validationStart..($lines.Count-1)] -join "`n").TrimEnd()
    }
}

function Get-ExistingOwnedContext([string]$filePath) {
    # Returns:
    #   $null    -> file does not exist (caller uses template owned-context block)
    #   [string] -> existing owned-context block to preserve
    # Supports both current and legacy PART-based files.
    if (-not (Test-Path $filePath)) { return $null }
    $content = Get-Content $filePath -Raw
    $lines = $content -split "`n"
    $ownedStart = -1
    $validationStart = -1
    $p2s = -1
    $p3s = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## Project-Owned Context') { $ownedStart = $i }
        if ($lines[$i] -match '^## Validation Pattern') { $validationStart = $i }
        if ($lines[$i] -match '^## PART 2') { $p2s = $i }
        if ($lines[$i] -match '^## PART 3') { $p3s = $i }
    }

    if ($ownedStart -ge 0 -and $validationStart -gt $ownedStart) {
        return ($lines[$ownedStart..($validationStart-1)] -join "`n").TrimEnd()
    }

    if ($p2s -ge 0) {
        $endIdx = if ($p3s -ge 0) { $p3s - 1 } else { $lines.Count - 1 }
        $legacyBody = ($lines[$p2s..$endIdx] -join "`n").TrimEnd()
        return @"
## Project-Owned Context

This section was preserved from a legacy PART-based project instruction file.
Review and normalize it during the next project-specific maintenance cycle.

$legacyBody
"@.TrimEnd()
    }

    return @"
## Project-Owned Context

This section was preserved from an older unstructured project instruction file.
Review and normalize it during the next project-specific maintenance cycle.

$($content.TrimEnd())
"@.TrimEnd()
}

function Expand-ProjectTokens([string]$projectFolder, [string]$content) {
    $meta = $PROJECT_META[$projectFolder]
    $name  = if ($meta) { $meta.name  } else { $projectFolder }
    $desc  = if ($meta) { $meta.desc  } else { "{PROJECT_ONE_LINE_DESCRIPTION}" }
    $stack = if ($meta) { $meta.stack } else { "{PROJECT_STACK}" }

    return $content `
        -replace '\{PROJECT_NAME\}',                $name `
        -replace '\{PROJECT_ONE_LINE_DESCRIPTION\}', $desc `
        -replace '\{PROJECT_FOLDER\}',              $projectFolder `
        -replace '\{PROJECT_STACK\}',               $stack
}

# ----- Main -----

if (-not (Test-Path $TEMPLATE)) {
    Write-Log "Template not found: $TEMPLATE" "FAIL"
    exit 1
}

$tmplContent = Get-Content $TEMPLATE -Raw
$tmpl = Split-TemplateContent $tmplContent
Write-Log "Template loaded - Prefix: $(($tmpl.Prefix -split "`n").Count) lines, Project-Owned Context: $(($tmpl.OwnedTemplate -split "`n").Count) lines, Suffix: $(($tmpl.Suffix -split "`n").Count) lines"

# Determine target list
$targets = switch ($Scope) {
    "active"    { $ACTIVE_PROJECTS }
    "all"       { Get-ChildItem $FOUNDATION -Directory | Where-Object { $_.Name -match '^\d' } | Select-Object -ExpandProperty Name }
    "specified" { $Projects }
}

if ($targets.Count -eq 0) {
    Write-Log "No targets. Use -Scope active|all or -Projects (folder)" "WARN"
    exit 0
}

Write-Log "Targets: $($targets.Count) project(s). DryRun=$DryRun"
Write-Host ""

$pass = 0; $skip = 0; $fail = 0

foreach ($folder in $targets) {
    $projPath  = Join-Path $FOUNDATION $folder
    $ciPath    = Join-Path $projPath ".github\copilot-instructions.md"

    if (-not (Test-Path $projPath)) {
        Write-Log "$folder - project folder not found, skipping" "WARN"; $skip++; continue
    }

    $existingOwnedContext = Get-ExistingOwnedContext $ciPath
    $isNew = ($null -eq $existingOwnedContext)

    $ownedContextToUse = if ($isNew) {
        Expand-ProjectTokens $folder $tmpl.OwnedTemplate
    } else {
        $existingOwnedContext
    }

    $prefix = Expand-ProjectTokens $folder $tmpl.Prefix
    $suffix = Expand-ProjectTokens $folder $tmpl.Suffix
    $assembled = "$prefix`n`n$ownedContextToUse`n`n$suffix"

    $action = if ($isNew) {
        "CREATE (new from template)"
    } elseif ($existingOwnedContext -match 'legacy PART-based') {
        "UPDATE (convert legacy PART-based content to Project-Owned Context)"
    } elseif ($existingOwnedContext -match 'older unstructured') {
        "UPDATE (wrap prior unstructured content as Project-Owned Context)"
    } else {
        "UPDATE (preserve Project-Owned Context)"
    }
    Write-Log "$folder - $action" "INFO"

    if ($DryRun) {
        Write-Host "    [DRY-RUN] Would write: $ciPath"
        $pass++; continue
    }

    # Backup if file exists
    if ((Test-Path $ciPath) -and -not $SkipBackup) {
        $ts = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = Join-Path $BACKUP_ROOT "$folder"
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Copy-Item $ciPath (Join-Path $backupDir "copilot-instructions_$ts.md") -Force
    }

    # Write
    New-Item -ItemType Directory -Path (Split-Path $ciPath) -Force | Out-Null
    Set-Content -Path $ciPath -Value $assembled -Encoding UTF8

    $lineCount = (Get-Content $ciPath | Measure-Object -Line).Lines
    Write-Log "$folder - written ($lineCount lines): $ciPath" "PASS"
    $pass++
}

Write-Host ""
Write-Log "Done. PASS=$pass SKIP=$skip FAIL=$fail"
