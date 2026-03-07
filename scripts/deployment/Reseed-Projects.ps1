# Reseed-Projects.ps1
# Version: 1.0.0 (February 23, 2026)
# Applies the v3.0.0 copilot-instructions template to EVA Foundation numbered projects.
#
# Strategy:
#   - Projects WITH existing copilot-instructions.md: refresh PART 1 + PART 3, preserve PART 2
#   - Projects WITHOUT: create from template substituting {PROJECT_NAME} etc.
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

$FOUNDATION   = "C:\AICOE\eva-foundation"
$TEMPLATE     = "$FOUNDATION\07-foundation-layer\templates\copilot-instructions-template.md"
$BACKUP_ROOT  = "$FOUNDATION\07-foundation-layer\.archive\02-design-artifacts\backups"

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
    # Returns hashtable: Part1, Part2, Part3
    # Headers: "## PART 1 - UNIVERSAL RULES", "## PART 2 - PROJECT-SPECIFIC", "## PART 3 - QUALITY GATES"
    $lines  = $content -split "`n"
    $p1s = $p2s = $p3s = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## PART 1') { $p1s = $i }
        if ($lines[$i] -match '^## PART 2') { $p2s = $i }
        if ($lines[$i] -match '^## PART 3') { $p3s = $i }
    }
    if ($p1s -lt 0 -or $p2s -lt 0 -or $p3s -lt 0) {
        throw "[FAIL] Template missing PART 1/2/3 section headers"
    }
    return @{
        Header = ($lines[0..($p1s-1)] -join "`n").TrimEnd()
        Part1  = ($lines[$p1s..($p2s-1)] -join "`n").TrimEnd()
        Part2  = ($lines[$p2s..($p3s-1)] -join "`n").TrimEnd()
        Part3  = ($lines[$p3s..($lines.Count-1)] -join "`n").TrimEnd()
    }
}

function Get-ExistingPart2([string]$filePath) {
    # Returns:
    #   $null          -> file does not exist (caller uses template PART 2)
    #   [string]       -> existing PART 2 block to preserve
    #     Case A: file has "## PART 2 ..." header  -> extract that section
    #     Case B: file exists, no PART headers      -> wrap entire file content
    if (-not (Test-Path $filePath)) { return $null }
    $content = Get-Content $filePath -Raw
    $lines   = $content -split "`n"
    $p2s = $p3s = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## PART 2') { $p2s = $i }
        if ($lines[$i] -match '^## PART 3') { $p3s = $i }
    }
    # Case A: structured file with ## PART 2 header
    if ($p2s -ge 0) {
        $endIdx = if ($p3s -ge 0) { $p3s - 1 } else { $lines.Count - 1 }
        return ($lines[$p2s..$endIdx] -join "`n").TrimEnd()
    }
    # Case B: existing file without PART structure - wrap as PART 2 body
    return "## PART 2 - PROJECT-SPECIFIC`n> PRESERVED from previous copilot-instructions.md (no PART structure detected).`n> Review and restructure into the PART 2 sections below as needed.`n`n$($content.TrimEnd())"
}

function Build-Header([string]$projectFolder, [string]$templateHeader) {
    $meta = $PROJECT_META[$projectFolder]
    $name  = if ($meta) { $meta.name  } else { $projectFolder }
    $desc  = if ($meta) { $meta.desc  } else { "{PROJECT_ONE_LINE_DESCRIPTION}" }
    $stack = if ($meta) { $meta.stack } else { "{PROJECT_STACK}" }
    return $templateHeader `
        -replace '\{PROJECT_NAME\}',                $name `
        -replace '\{PROJECT_ONE_LINE_DESCRIPTION\}', $desc `
        -replace '\{PROJECT_FOLDER\}',              $projectFolder `
        -replace '\{PROJECT_STACK\}',               $stack
}

function Build-NewPart2([string]$projectFolder, [string]$templatePart2) {
    $meta = $PROJECT_META[$projectFolder]
    $name  = if ($meta) { $meta.name  } else { $projectFolder }
    $desc  = if ($meta) { $meta.desc  } else { "{PROJECT_ONE_LINE_DESCRIPTION}" }
    $stack = if ($meta) { $meta.stack } else { "{PROJECT_STACK}" }
    return $templatePart2 `
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
Write-Log "Template loaded - PART 1: $(($tmpl.Part1 -split "`n").Count) lines, PART 2: $(($tmpl.Part2 -split "`n").Count) lines, PART 3: $(($tmpl.Part3 -split "`n").Count) lines"

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

    # Extract or generate PART 2
    $existingPart2 = Get-ExistingPart2 $ciPath
    $isNew = ($null -eq $existingPart2)

    $part2ToUse = if ($isNew) {
        Build-NewPart2 $folder $tmpl.Part2
    } else {
        $existingPart2
    }

    $newHeader = Build-Header $folder $tmpl.Header
    $assembled = "$newHeader`n`n$($tmpl.Part1)`n`n$part2ToUse`n`n$($tmpl.Part3)"

    $action = if ($isNew) { "CREATE (new from template)" } elseif ($existingPart2 -match '^## PART 2 - PROJECT-SPECIFIC\r?\n> PRESERVED') { "UPDATE (wrap legacy content as PART 2)" } else { "UPDATE (preserve structured PART 2)" }
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
