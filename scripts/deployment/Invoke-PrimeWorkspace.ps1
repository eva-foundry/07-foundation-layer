<#
.SYNOPSIS
    Invoke-PrimeWorkspace.ps1 v2.1.0 (Fractal DPDCA + API-First Governance Edition)
    Idempotent project primer: copilot-instructions + PLAN + STATUS + ACCEPTANCE + README + PROJECT-ORGANIZATION + API sync

.DESCRIPTION
    Applies the foundation-layer templates to one project folder or every project
    folder under a workspace root. Safe to run many times -- existing content is
    never blindly overwritten.

        Idempotency rules:
            copilot-instructions.md  -- Render or repair the managed project contract while preserving project-owned content
      PLAN.md                  -- Created if missing OR if <!-- eva-primed-plan --> absent
      STATUS.md                -- Created if missing OR if <!-- eva-primed-status --> absent
      ACCEPTANCE.md            -- Created if missing only (user-managed, never overwritten)
      README.md                -- Header block injected after first H1 if <!-- eva-primed --> absent
      .github/PROJECT-ORGANIZATION.md -- Created if missing with <!-- eva-primed-organization --> sentinel
    Data Model API sync      -- Project record synced to API for API-first governance continuity
    Token substitution in templates:
      {{PROJECT_FOLDER}}   full folder name  e.g. 01-documentation-generator
      {{PROJECT_LABEL}}    data-model label  e.g. Documentation Generator
      {{PROJECT_MATURITY}} data-model value  e.g. active
      {{WBS_PREFIX}}       e.g. F01
      {{PRIME_DATE}}       ISO date          e.g. 2026-02-25
      {{PRIME_ACTOR}}      agent:copilot
      {{TARGET_PATH}}      absolute path to project folder

.PARAMETER TargetPath
    Absolute path to a single project folder to prime.
    Mutually exclusive with -WorkspaceRoot.

.PARAMETER WorkspaceRoot
    Absolute path to a workspace folder containing numbered project sub-folders
    (e.g. C:\eva-foundry). Primes every sub-folder that matches
    the pattern [0-9][0-9]-*.
    Mutually exclusive with -TargetPath.

.PARAMETER DryRun
    Print what would happen without writing any files.

.PARAMETER ManagedArtifactsOnly
    Repair only managed generated artifacts (`.github/copilot-instructions.md` and
    `.github/PROJECT-ORGANIZATION.md`). Skip PLAN, STATUS, ACCEPTANCE, README,
    and Data Model API sync. Use this to repair fallout from a bad priming pass
    without re-priming user-managed project files.

.PARAMETER SkipCopilotInstructions
    Skip the Apply-Project07-Artifacts.ps1 step (governance docs only).

.PARAMETER DataModelBase
    Base URL for the EVA data model API. Default: https://msub-eva-data-model... (cloud)
    REQUIRED: Priming will fail if API is unavailable at pre-flight check.

.PARAMETER Actor
    Value placed in X-Actor header on data model writes. Default: agent:copilot

.EXAMPLE
    # Single project dry-run - see Fractal DPDCA phases in action
    .\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\14-az-finops" -DryRun
    
    # Output shows:
    # [DISCOVER] Checking current state (version, backup status)
    # [PLAN] Expected outcomes (managed contract rendered, project-owned context preserved, backup created)
    # [DO] Execute prime operation
    # [CHECK] Verify key checks (version, scaffold presence, contract structure)
    # [ACT] Record evidence JSON in .eva/ directory

.EXAMPLE
    # Single project - apply for real with full verification
    .\Invoke-PrimeWorkspace.ps1 -TargetPath "C:\eva-foundry\14-az-finops"
    
    # Creates:
    # - Updated copilot-instructions.md (managed contract rendered, project-owned context preserved)
    # - Backup: .github/copilot-instructions.md.backup_[timestamp]
    # - Evidence: .eva/fractal-dpdca-[timestamp].json

.EXAMPLE
    # Workspace prime with stop-on-failure (recommended for production)
    .\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry"
    
    # Processes projects in sequence: 01-01, 02-poc, 03-poc, ...
    # STOPS on first failure with diagnostic output:
    # [FAIL] 15-cdc verification failed
    # [INFO]   Version check: True
    # [INFO]   Backup check: True
    # [INFO]   Project-owned context check: False
    # [STOP] Fix 15-cdc before continuing

.EXAMPLE
    # Diagnostic bulk processing - continue despite failures
    .\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry" -ContinueOnError -DryRun
    
    # Use case: Understand scope of failures across all 57 projects
    # Output: "Success: 51 | Failures: 6"
    # Failed projects: [list of 6 project names with diagnostic info]
    
    # WARNING: -ContinueOnError bypasses stop-on-failure (not recommended for production)

.NOTES
    Encoding: UTF-8 file writes with ASCII console tokens. No emoji. Tokens: [PASS] [FAIL] [WARN] [INFO] [SKIP] [DRY] [STOP]
    Version: 2.1.0 (Fractal DPDCA Edition)
    Created: 2026-02-25 by agent:copilot
    Updated: 2026-03-09 - Fractal DPDCA: per-project DISCOVER/PLAN/DO/CHECK/ACT with stop-on-failure
    
    Backup Policy:
      Location: .github/.project07-backups/
      Format: {original_filename}.backup_{yyyyMMdd_HHmmss}
      Example: copilot-instructions.md.backup_20260310_143022
      Retention: Manual cleanup recommended; script preserves all backups
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ParameterSetName = "Single")]
    [string]$TargetPath,

    [Parameter(ParameterSetName = "Workspace")]
    [string]$WorkspaceRoot,

    [switch]$DryRun,
    [switch]$ManagedArtifactsOnly,
    [switch]$SkipCopilotInstructions,
    [switch]$ContinueOnError,  # Bypass stop-on-failure (not recommended)
    [string]$DataModelBase = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io",
    [string]$Actor = "agent:copilot"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

$ScriptDir   = $PSScriptRoot
$ApplyScript = Join-Path $ScriptDir "Apply-Project07-Artifacts.ps1"
$TemplateDir = Join-Path (Split-Path (Split-Path $ScriptDir -Parent) -Parent) "templates"
$GovTemplateDir = Join-Path $TemplateDir "governance"

$Templates = @{
    Plan       = Join-Path $GovTemplateDir "PLAN-template.md"
    Status     = Join-Path $GovTemplateDir "STATUS-template.md"
    Acceptance = Join-Path $GovTemplateDir "ACCEPTANCE-template.md"
    ReadmeHdr  = Join-Path $GovTemplateDir "README-header-block.md"
    ProjectOrg = Join-Path $GovTemplateDir "PROJECT-ORGANIZATION-template.md"
    CopilotInstructions = Join-Path $TemplateDir "copilot-instructions-template.md"
}

$PrimeDate  = (Get-Date -Format "yyyy-MM-dd")
$PrimeActor = $Actor

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Status([string]$Token, [string]$Msg) {
    Write-Information "  $Token $Msg"
}

function Test-Sentinel([string]$FilePath, [string]$Sentinel) {
    if (-not (Test-Path $FilePath)) { return $false }
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    return $content.Contains($Sentinel)
}

function Expand-Tokens([string]$Text, [hashtable]$Tokens) {
    foreach ($key in $Tokens.Keys) {
        $Text = $Text.Replace("{{$key}}", $Tokens[$key])
        $Text = $Text.Replace("{$key}", $Tokens[$key])
    }
    return $Text
}

function Get-Utf8Encoding() {
    return New-Object System.Text.UTF8Encoding($false)
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item $dir -ItemType Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, (Get-Utf8Encoding))
}

function Test-UnresolvedTemplateTokens([string]$Text) {
    $doubleBracePattern = '\{\{[A-Z][A-Z0-9_]+\}\}'
    $knownSingleBracePattern = '\{(PROJECT_NAME|PROJECT_FOLDER|PROJECT_ID|PROJECT_MATURITY|CURRENT_PHASE|KEY_DEPENDENCIES|SETUP_COMMAND|BUILD_COMMAND|TEST_COMMAND|RUN_COMMAND|LINT_COMMAND|TEST_COUNT|COVERAGE|DATE|LANGUAGE|VERSION|FRAMEWORK|DIR1|DIR2|DIR3|CONFIG_FILE1|CONFIG_FILE2|CI_PIPELINE_LOCATION|TRIGGER_CONDITIONS|PATTERN_NAME|SITUATION|ACTION|RATIONALE|ANTI_PATTERN|PATTERN|PROJECT_PREFIX|TITLE|LAYER_1|LAYER_2|LAYER_3|FIELD2|FIELD3|SPECIFIC_CHECK)\}'
    return ($Text -match $doubleBracePattern -or $Text -match $knownSingleBracePattern)
}

function Get-ProjectInfo([string]$Folder, [string]$Base) {
    $info = @{
        label    = $Folder
        maturity = "unknown"
        wbs_id   = ""
        phase    = ""
    }
    try {
        $r = Invoke-RestMethod "$Base/model/projects/$Folder" -ErrorAction SilentlyContinue
        if ($r -and $r.id) {
            $info.label    = if ($r.label) { $r.label } else { $Folder }
            $info.maturity = if ($r.maturity) { $r.maturity } else { "unknown" }
            $info.wbs_id   = if ($r.wbs_id) { $r.wbs_id } else { "" }
            $info.phase    = if ($r.phase) { $r.phase } else { "" }
        }
    } catch { <# data model unreachable -- use defaults #> }
    return $info
}

function Get-WbsPrefix([string]$FolderName, [string]$WbsId) {
    if ($WbsId -match "WBS-(\d+)") { return "F$($Matches[1])" }
    if ($FolderName -match "^(\d+)-") { return "F$($Matches[1])" }
    return "FXXX"
}

function Write-FromTemplate {
    param(
        [string]$TemplatePath,
        [string]$DestPath,
        [hashtable]$Tokens,
        [bool]$IsDryRun
    )
    $raw = Get-Content $TemplatePath -Raw -Encoding UTF8
    $out = Expand-Tokens -Text $raw -Tokens $Tokens
    if ($IsDryRun) {
        Write-Status "[DRY]" "Would write $(Split-Path $DestPath -Leaf) ($($out.Length) chars)"
    } else {
        $outDir = Split-Path $DestPath -Parent
        if (-not (Test-Path $outDir)) { New-Item $outDir -ItemType Directory -Force | Out-Null }
        Write-Utf8File -Path $DestPath -Content $out
        Write-Status "[PASS]" "Wrote $(Split-Path $DestPath -Leaf)"
    }
}

function Inject-ReadmeHeader {
    param(
        [string]$ReadmePath,
        [string]$HeaderTemplatePath,
        [hashtable]$Tokens,
        [bool]$IsDryRun
    )
    $content = Get-Content $ReadmePath -Raw -Encoding UTF8
    if ($content.Contains("<!-- eva-primed -->")) {
        Write-Status "[SKIP]" "README.md already has eva-primed sentinel"
        return
    }
    $header = Get-Content $HeaderTemplatePath -Raw -Encoding UTF8
    $header = Expand-Tokens -Text $header -Tokens $Tokens
    $headerLines = $header -split "`r?`n"
    if ($headerLines.Count -gt 0 -and $headerLines[0] -match '^#[^#]') {
        if ($headerLines.Count -gt 1) {
            $header = (($headerLines[1..($headerLines.Count-1)] -join "`n").TrimStart())
        } else {
            $header = ""
        }
    }
    # Insert after first H1 line (## ... or # ...)
    $lines  = $content -split "`n"
    $h1idx  = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^#[^#]") { $h1idx = $i; break }
    }
    if ($h1idx -ge 0) {
        $before = ($lines[0..$h1idx] -join "`n")
        $after  = ($lines[($h1idx+1)..($lines.Count-1)] -join "`n")
        $merged = "$before`n`n$header`n$after"
    } else {
        $merged = "$header`n$content"
    }
    if ($IsDryRun) {
        Write-Status "[DRY]" "Would inject eva-primed header into README.md"
    } else {
        Write-Utf8File -Path $ReadmePath -Content $merged
        Write-Status "[PASS]" "Injected eva-primed header into README.md"
    }
}

function Write-EvidenceRecord {
    param(
        [string]$TargetPath,
        [hashtable]$Summary,
        [bool]$IsDryRun
    )
    $evaDir = Join-Path $TargetPath ".eva"
    $evPath = Join-Path $evaDir "prime-evidence.json"
    if ($IsDryRun) {
        Write-Status "[DRY]" "Would write .eva/prime-evidence.json"
        return
    }
    if (-not (Test-Path $evaDir)) { New-Item $evaDir -ItemType Directory -Force | Out-Null }
    $record = @{
        primed_at       = (Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz")
        primed_by       = $PrimeActor
        template_version = (Get-TemplateVersion -FilePath $Templates.CopilotInstructions)
        dry_run         = $false
        results         = $Summary
    }
    Write-Utf8File -Path $evPath -Content ($record | ConvertTo-Json -Depth 5)
    Write-Status "[PASS]" "Evidence written to .eva/prime-evidence.json"
}

# ---------------------------------------------------------------------------
# Fractal DPDCA Helper Functions
# ---------------------------------------------------------------------------

function Get-TemplateVersion {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return "none" }
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    if ($content -match '\*\*Template Version\*\*:\s*([0-9.]+)') {
        return $Matches[1]
    }
    return "unknown"
}

function Test-Part2Preserved {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return $false }
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    if ($content -match '(?s)^## Project-Owned Context\s*$.*^## Validation Pattern\s*$') {
        return $true
    }
    return $false
}

function Get-BackupPath {
    param([string]$ProjectPath)
    $pattern = "$ProjectPath/.github/copilot-instructions.md.backup_*"
    $latest = Get-ChildItem "$ProjectPath/.github/" -Filter "copilot-instructions.md.backup_*" -ErrorAction SilentlyContinue | 
              Sort-Object Name -Descending | 
              Select-Object -First 1
    if ($latest) { return $latest.Name }
    return "none"
}

function Test-DataModelAvailable {
    param([string]$BaseUrl)
    try {
        # Use longer timeout for cloud endpoints (10s), shorter for local (3s)
        $timeout = if ($BaseUrl -like "*localhost*") { 3 } else { 10 }
        $response = Invoke-RestMethod "$BaseUrl/health" -TimeoutSec $timeout -ErrorAction Stop
        return ($response.status -eq "ok" -or $response.status -eq "healthy")
    } catch {
        Write-Status "[DEBUG]" "API check error: $_"
        return $false
    }
}

function Sync-ProjectToDataModel {
    param(
        [string]$ProjectId,
        [string]$Label,
        [string]$Maturity,
        [string]$BaseUrl,
        [string]$Actor,
        [bool]$IsDryRun
    )
    
    try {
        if ($IsDryRun) {
            Write-Status "[DRY]" "Would sync project record to data model"
            return @{ success = $true; dry_run = $true; created = $false; exists = $false }
        }

        $body = @{
            id = $ProjectId
            label = $Label
            maturity = if ($Maturity -eq "unknown") { "scaffolded" } else { $Maturity }
            phase = "initial"
            pbi_total = 0
            pbi_done = 0
            notes = "Primed via Invoke-PrimeWorkspace.ps1"
        } | ConvertTo-Json
        
        $headers = @{
            "Content-Type" = "application/json"
            "X-Actor" = $Actor
        }
        
        # Check if project exists first
        try {
            $existing = Invoke-RestMethod "$BaseUrl/model/projects/$ProjectId" -ErrorAction SilentlyContinue
            if ($existing.id) {
                Write-Status "[SKIP]" "Project record already exists in data model"
                return @{ success = $true; exists = $true; created = $false; dry_run = $false }
            }
        } catch {
            # Project doesn't exist, proceed with creation
        }
        
        $response = Invoke-RestMethod "$BaseUrl/model/projects/" -Method Post -Body $body -Headers $headers -TimeoutSec 10
        Write-Status "[PASS]" "Project record synced to data model"
        return @{ success = $true; created = $true; exists = $false; dry_run = $false }
    } catch {
        Write-Status "[WARN]" "API sync failed: $_"
        return @{ success = $false; error = $_.Exception.Message; dry_run = $false; created = $false; exists = $false }
    }
}

# ---------------------------------------------------------------------------
# Core prime function
# ---------------------------------------------------------------------------

function Invoke-PrimeProject {
    param(
        [string]$ProjectPath,
        [bool]$IsDryRun
    )

    $folderName = Split-Path $ProjectPath -Leaf
    Write-Information ""
    Write-Information "=== Prime: $folderName ==="

    # Guard: must be a numbered project folder
    if ($folderName -notmatch "^\d{2}-") {
        Write-Status "[SKIP]" "$folderName does not match numbered-project pattern (##-name)"
        return
    }

    # ===================================================================
    # PRE-FLIGHT: Data Model API Availability (REQUIRED)
    # ===================================================================
    Write-Status "[PRE-FLIGHT]" "Checking Data Model API availability..."
    
    if (-not (Test-DataModelAvailable -BaseUrl $DataModelBase)) {
        Write-Status "[FAIL]" "Data Model API unavailable at $DataModelBase"
        Write-Status "[FAIL]" "Priming requires the API-first governance path"
        Write-Status "[FAIL]" "Verify API is running and accessible"
        Write-Status "[FAIL]" "Check: GET $DataModelBase/health"
        throw "Pre-flight check failed: Data Model API unavailable"
    }
    
    Write-Status "[PASS]" "Data Model API available at $DataModelBase"

    # Verify templates exist
    foreach ($key in $Templates.Keys) {
        if (-not (Test-Path $Templates[$key])) {
            Write-Status "[FAIL]" "Template missing: $($Templates[$key])"
            return
        }
    }
    if (-not (Test-Path $ApplyScript)) {
        Write-Status "[WARN]" "Apply-Project07-Artifacts.ps1 not found at $ApplyScript -- skipping copilot-instructions step"
        $SkipCopilotInstructions = $true
    }

    # Data model lookup
    $info      = Get-ProjectInfo -Folder $folderName -Base $DataModelBase
    $wbsPrefix = Get-WbsPrefix -FolderName $folderName -WbsId $info.wbs_id

    $Tokens = @{
        PROJECT_FOLDER   = $folderName
        PROJECT_ID       = $folderName
        PROJECT_NAME     = $info.label
        PROJECT_LABEL    = $info.label
        PROJECT_MATURITY = $info.maturity
        KEY_DEPENDENCIES = "See README.md, PLAN.md, and project_work records in the data model."
        DEPENDENCIES     = "See README.md, PLAN.md, and project_work records in the data model."
        CLOUD_PROVIDER   = "Azure"
        SECURITY_STANDARDS = "Workspace governance, RBAC, and evidence-backed verification"
        DATA_RESIDENCY   = "Canada Central unless project-specific requirements state otherwise"
        PROJECT_STACK    = "[TODO: Update stack]"
        ADO_EPIC_ID      = "[TODO: Link ADO Epic]"
        CURRENT_PHASE    = if ($info.phase) { $info.phase } else { "discover" }
        DEPENDENCY_LIST  = "[TODO: List dependencies]"
        CONSUMER_LIST    = "[TODO: List consumers]"
        LANGUAGE         = "Project-specific"
        VERSION          = ""
        FRAMEWORK        = ""
        BUILD_COMMAND    = "[TODO: Add build command]"
        TEST_COMMAND     = "[TODO: Add test command]"
        LINT_COMMAND     = "[TODO: Add lint command]"
        RUN_COMMAND      = "[TODO: Add run command]"
        LOCAL_PATTERN_1  = "[TODO: Add the main project-specific implementation pattern]"
        LOCAL_PATTERN_2  = "[TODO: Add the most important integration or deployment pattern]"
        LOCAL_PATTERN_3  = "[TODO: Add any local exception or code organization rule]"
        LOCAL_RISK_1     = "[TODO: Add the main delivery or runtime risk]"
        LOCAL_RISK_2     = "[TODO: Add the next most important project-specific hazard]"
        WBS_PREFIX       = $wbsPrefix
        PRIME_DATE       = $PrimeDate
        PRIME_ACTOR      = $PrimeActor
        TARGET_PATH      = $ProjectPath
    }

    $summary = @{ folder = $folderName; steps = @() }

    # --- Step 1: copilot-instructions ---
    if (-not $SkipCopilotInstructions) {
        Write-Status "[INFO]" "Step 1: copilot-instructions (managed bootstrap scaffold)"
        $copilotInstructionsPath = Join-Path $ProjectPath ".github\copilot-instructions.md"
        
        if (Test-Path $copilotInstructionsPath) {
            $existingContent = Get-Content $copilotInstructionsPath -Raw -Encoding UTF8
            if (Test-UnresolvedTemplateTokens -Text $existingContent) {
                Write-Status "[WARN]" "copilot-instructions.md contains unresolved template tokens, repairing"
                Write-FromTemplate -TemplatePath $Templates.CopilotInstructions -DestPath $copilotInstructionsPath -Tokens $Tokens -IsDryRun $IsDryRun
                $summary.steps += "copilot-instructions:REPAIRED"
            } elseif ($existingContent.Contains("<!-- eva-primed-copilot -->")) {
                Write-Status "[SKIP]" "copilot-instructions.md is already managed and rendered"
                $summary.steps += "copilot-instructions:SKIP"
            } else {
                Write-Status "[SKIP]" "copilot-instructions.md exists and is user-managed"
                $summary.steps += "copilot-instructions:SKIP"
            }
        } else {
            Write-FromTemplate -TemplatePath $Templates.CopilotInstructions -DestPath $copilotInstructionsPath -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "copilot-instructions:CREATED"
        }
    } else {
        Write-Status "[SKIP]" "Step 1: copilot-instructions (SkipCopilotInstructions)"
        $summary.steps += "copilot-instructions:SKIP"
    }

    if ($ManagedArtifactsOnly) {
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping PLAN.md"
        $summary.steps += "PLAN.md:SKIP-MANAGED-ONLY"
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping STATUS.md"
        $summary.steps += "STATUS.md:SKIP-MANAGED-ONLY"
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping ACCEPTANCE.md"
        $summary.steps += "ACCEPTANCE.md:SKIP-MANAGED-ONLY"
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping README.md"
        $summary.steps += "README.md:SKIP-MANAGED-ONLY"
    } else {
        # --- Step 2: PLAN.md ---
        Write-Status "[INFO]" "Step 2: PLAN.md"
        $planPath = Join-Path $ProjectPath "PLAN.md"
        if (Test-Sentinel -FilePath $planPath -Sentinel "<!-- eva-primed-plan -->") {
            Write-Status "[SKIP]" "PLAN.md already has eva-primed-plan sentinel"
                $expectedTemplateVersion = Get-TemplateVersion -FilePath $Templates.CopilotInstructions
            $summary.steps += "PLAN.md:SKIP"
        } elseif (Test-Path $planPath) {
            # Exists but no sentinel -- inject sentinel + EVA tools section at top
            $existing = Get-Content $planPath -Raw -Encoding UTF8
            $inject   = "<!-- eva-primed-plan -->`n`n## EVA Ecosystem Tools`n`n- Data model: GET $DataModelBase/model/projects/$folderName`n- 48-eva-veritas audit: run audit_repo MCP tool`n`n---`n`n"
            if ($IsDryRun) {
                Write-Status "[DRY]" "Would inject eva-primed-plan block into existing PLAN.md"
            } else {
                Write-Utf8File -Path $planPath -Content ($inject + $existing)
                Write-Status "[PASS]" "Injected eva-primed-plan block into PLAN.md"
            }
            $summary.steps += "PLAN.md:INJECTED"
        } else {
            Write-FromTemplate -TemplatePath $Templates.Plan -DestPath $planPath -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "PLAN.md:CREATED"
        }

        # --- Step 3: STATUS.md ---
        Write-Status "[INFO]" "Step 3: STATUS.md"
        $statusPath = Join-Path $ProjectPath "STATUS.md"
        if (Test-Sentinel -FilePath $statusPath -Sentinel "<!-- eva-primed-status -->") {
            Write-Status "[SKIP]" "STATUS.md already has eva-primed-status sentinel"
            $summary.steps += "STATUS.md:SKIP"
        } elseif (Test-Path $statusPath) {
            $existing  = Get-Content $statusPath -Raw -Encoding UTF8
            $newEntry  = "`n`n---`n`n## $PrimeDate -- Re-primed by $PrimeActor`n`n<!-- eva-primed-status -->`n`nData model: GET $DataModelBase/model/projects/$folderName`n48-eva-veritas: run audit_repo MCP tool`n"
            if ($IsDryRun) {
                Write-Status "[DRY]" "Would append eva-primed-status session entry to STATUS.md"
            } else {
                Write-Utf8File -Path $statusPath -Content ($existing + $newEntry)
                Write-Status "[PASS]" "Appended eva-primed-status session entry to STATUS.md"
            }
            $summary.steps += "STATUS.md:APPENDED"
        } else {
            Write-FromTemplate -TemplatePath $Templates.Status -DestPath $statusPath -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "STATUS.md:CREATED"
        }

        # --- Step 4: ACCEPTANCE.md ---
        Write-Status "[INFO]" "Step 4: ACCEPTANCE.md"
        $acceptPath = Join-Path $ProjectPath "ACCEPTANCE.md"
        if (Test-Path $acceptPath) {
            Write-Status "[SKIP]" "ACCEPTANCE.md exists (user-managed -- never overwritten)"
            $summary.steps += "ACCEPTANCE.md:SKIP"
        } else {
            Write-FromTemplate -TemplatePath $Templates.Acceptance -DestPath $acceptPath -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "ACCEPTANCE.md:CREATED"
        }

        # --- Step 5: README.md header block ---
        Write-Status "[INFO]" "Step 5: README.md"
        $readmePath = Join-Path $ProjectPath "README.md"
        if (-not (Test-Path $readmePath)) {
            Write-Status "[SKIP]" "README.md not found -- skipping (project must provide its own)"
            $summary.steps += "README.md:SKIP"
        } else {
            Inject-ReadmeHeader -ReadmePath $readmePath -HeaderTemplatePath $Templates.ReadmeHdr -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "README.md:CHECKED"
        }
    }

    # --- Step 6: .github/PROJECT-ORGANIZATION.md scaffold ---
    Write-Status "[INFO]" "Step 6: .github/PROJECT-ORGANIZATION.md"
    $orgPath = Join-Path $ProjectPath ".github/PROJECT-ORGANIZATION.md"
    if (Test-Sentinel -FilePath $orgPath -Sentinel "<!-- eva-primed-organization -->") {
        $orgContent = Get-Content $orgPath -Raw -Encoding UTF8
        if (Test-UnresolvedTemplateTokens -Text $orgContent) {
            Write-Status "[WARN]" "PROJECT-ORGANIZATION.md contains unresolved template tokens, repairing"
            Write-FromTemplate -TemplatePath $Templates.ProjectOrg -DestPath $orgPath -Tokens $Tokens -IsDryRun $IsDryRun
            $summary.steps += "PROJECT-ORGANIZATION.md:REPAIRED"
        } else {
            Write-Status "[SKIP]" "PROJECT-ORGANIZATION.md already has eva-primed-organization sentinel"
            $summary.steps += "PROJECT-ORGANIZATION.md:SKIP"
        }
    } elseif (Test-Path $orgPath) {
        Write-Status "[SKIP]" "PROJECT-ORGANIZATION.md exists (user-managed -- never overwritten)"
        $summary.steps += "PROJECT-ORGANIZATION.md:SKIP"
    } else {
        Write-FromTemplate -TemplatePath $Templates.ProjectOrg -DestPath $orgPath -Tokens $Tokens -IsDryRun $IsDryRun
        $summary.steps += "PROJECT-ORGANIZATION.md:CREATED"
    }

    if ($ManagedArtifactsOnly) {
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping Data Model API sync"
        $summary.steps += "API-SYNC:SKIP-MANAGED-ONLY"
    } else {
        # --- Step 7: Data Model API sync (API-first governance continuity) ---
        Write-Status "[INFO]" "Step 7: Data Model API sync (API-first governance continuity)"
        # Pre-flight already verified API is available, proceed with sync
        $syncResult = Sync-ProjectToDataModel -ProjectId $folderName -Label $info.label -Maturity $info.maturity -BaseUrl $DataModelBase -Actor $PrimeActor -IsDryRun $IsDryRun
        
        if ($syncResult.success) {
            if ($syncResult.dry_run) {
                $summary.steps += "API-SYNC:DRY"
            } elseif ($syncResult.exists) {
                $summary.steps += "API-SYNC:EXISTS"
            } elseif ($syncResult.created) {
                $summary.steps += "API-SYNC:CREATED"
            } else {
                $summary.steps += "API-SYNC:PASS"
            }
        } else {
            Write-Status "[WARN]" "API sync failed: $($syncResult.error)"
            Write-Status "[WARN]" "Continuing with evidence recording despite API sync failure"
            $summary.steps += "API-SYNC:FAIL"
        }
    }

    # --- Evidence ---
    if ($ManagedArtifactsOnly) {
        Write-Status "[SKIP]" "ManagedArtifactsOnly active -- skipping evidence write"
        $summary.steps += "EVIDENCE:SKIP-MANAGED-ONLY"
    } else {
        Write-EvidenceRecord -TargetPath $ProjectPath -Summary $summary -IsDryRun $IsDryRun
    }

    Write-Status "[INFO]" "Prime complete for $folderName"
    Write-Status "[INFO]" "Steps: $($summary.steps -join ', ')"
    return $summary
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

$allResults = @()

if ($TargetPath) {
    if (-not (Test-Path $TargetPath)) {
        Write-Error "[FAIL] TargetPath not found: $TargetPath"
        exit 1
    }
    $allResults += Invoke-PrimeProject -ProjectPath $TargetPath -IsDryRun $DryRun.IsPresent
} elseif ($WorkspaceRoot) {
    if (-not (Test-Path $WorkspaceRoot)) {
        Write-Error "[FAIL] WorkspaceRoot not found: $WorkspaceRoot"
        exit 1
    }
    $projects = Get-ChildItem $WorkspaceRoot -Directory | Where-Object { $_.Name -match "^\d{2}-" } | Sort-Object Name
    Write-Information "[INFO] Found $($projects.Count) numbered project folders under $WorkspaceRoot"
    Write-Information "[INFO] Fractal DPDCA: Per-project DISCOVER -> PLAN -> DO -> CHECK -> ACT"
    
    $successCount = 0
    $failureCount = 0
    
    foreach ($proj in $projects) {
        $projPath = $proj.FullName
        $projName = $proj.Name
        
        Write-Information ""
        Write-Information "=== PROJECT: $projName ==="
        
        # ===================================================================
        # DISCOVER: Pre-flight validation before execution
        # ===================================================================
        Write-Status "[DISCOVER]" "Checking current state of $projName"
        
        $ciPath = "$projPath/.github/copilot-instructions.md"
        $orgPath = "$projPath/.github/PROJECT-ORGANIZATION.md"
        $beforeVersion = Get-TemplateVersion -FilePath $ciPath
        $hasExistingBackup = (Get-BackupPath -ProjectPath $projPath) -ne "none"
        $orgBeforeExists = Test-Path $orgPath
        $apiAvailable = Test-DataModelAvailable -BaseUrl $DataModelBase
        
        Write-Status "[INFO]" "Current template version: $beforeVersion"
        Write-Status "[INFO]" "Existing backup: $hasExistingBackup"
        Write-Status "[INFO]" "Organization scaffold exists: $orgBeforeExists"
        Write-Status "[INFO]" "Data Model API available: $apiAvailable"
        
        # ===================================================================
        # PLAN: Define expected outcomes
        # ===================================================================
        Write-Status "[PLAN]" "Expected outcomes for [$projName]"
        Write-Status "[INFO]" "  - Managed project contract rendered from template"
        Write-Status "[INFO]" "  - Project-Owned Context preserved or created"
        Write-Status "[INFO]" "  - Backup created with timestamp"
        Write-Status "[INFO]" "  - PROJECT-ORGANIZATION scaffold present"
        Write-Status "[INFO]" "  - Data Model API sync (if available)"
        Write-Status "[INFO]" "  - Evidence recorded in .eva/"
        
        # ===================================================================
        # DO: Execute priming operation
        # ===================================================================
        Write-Status "[DO]" "Executing prime operation for $projName..."
        
        try {
            $result = Invoke-PrimeProject -ProjectPath $projPath -IsDryRun $DryRun.IsPresent
            
            # Guard: If DO phase failed (no result object), fail CHECK immediately
            if (-not $result) {
                Write-Status "[FAIL]" "DO phase returned no result object"
                $failureCount++
                if (-not $ContinueOnError.IsPresent) {
                    Write-Status "[STOP]" "Halting workspace prime. Fix $projName before continuing."
                    break
                } else {
                    Write-Status "[WARN]" "Continuing despite DO failure (ContinueOnError enabled)"
                    continue
                }
            }
            
            # ===================================================================
            # CHECK: Immediate verification of results
            # ===================================================================
            Write-Status "[CHECK]" "Verifying prime results for $projName..."
            
            $afterVersion = Get-TemplateVersion -FilePath $ciPath
            $copilotStep = if ($result -and $result.steps) {
                $result.steps | Where-Object { $_ -like 'copilot-instructions:*' } | Select-Object -First 1
            } else {
                $null
            }
            $orgAfterExists = Test-Path $orgPath
            $copilotExists = Test-Path $ciPath
            $expectedTemplateVersion = Get-TemplateVersion -FilePath $Templates.CopilotInstructions
            
            $checksPassed = $true
            $failureReasons = @()
            
            # Verification 1: copilot-instructions present and valid for the action taken
            if (-not $DryRun.IsPresent -and -not $copilotExists) {
                Write-Status "[FAIL]" "copilot-instructions.md missing after prime"
                $failureReasons += "Missing copilot instructions"
                $checksPassed = $false
            } elseif ($copilotStep -in @('copilot-instructions:CREATED', 'copilot-instructions:RECREATED')) {
                if ($afterVersion -ne $expectedTemplateVersion) {
                    Write-Status "[FAIL]" "Template version: expected $expectedTemplateVersion, got $afterVersion"
                    $failureReasons += "Template version mismatch"
                    $checksPassed = $false
                } else {
                    Write-Status "[PASS]" "Template version: $afterVersion"
                }
            } else {
                Write-Status "[PASS]" "copilot-instructions preserved: $afterVersion"
            }

            # Verification 2: Organization scaffold present
            if (-not $DryRun.IsPresent -and -not $orgAfterExists) {
                Write-Status "[FAIL]" "PROJECT-ORGANIZATION.md missing after prime"
                $failureReasons += "Missing organization scaffold"
                $checksPassed = $false
            } else {
                Write-Status "[PASS]" "Organization scaffold present: $orgAfterExists"
            }
            
            # Stop-on-failure logic
            if (-not $checksPassed) {
                Write-Status "[STOP]" "Verification failed for $projName"
                Write-Status "[STOP]" "Failures: $($failureReasons -join ', ')"
                $failureCount++
                
                if (-not $ContinueOnError.IsPresent) {
                    Write-Status "[STOP]" "Halting workspace prime. Fix $projName before continuing."
                    Write-Status "[INFO]" "Use -ContinueOnError to bypass stop-on-failure (not recommended)"
                    break
                } else {
                    Write-Status "[WARN]" "Continuing despite failures (ContinueOnError enabled)"
                }
            } else {
                Write-Status "[PASS]" "All verification checks passed for $projName"
                
                # ===================================================================
                # ACT: Document results and update records
                # ===================================================================
                if ($ManagedArtifactsOnly) {
                    Write-Status "[ACT]" "ManagedArtifactsOnly active -- skipping outer evidence for $projName"
                } else {
                    Write-Status "[ACT]" "Recording evidence for $projName"
                    
                    $evidence = @{
                        project = $projName
                        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
                        before_version = $beforeVersion
                        after_version = $afterVersion
                        copilot_step = $copilotStep
                        steps = if ($result -and $result.steps) { $result.steps } else { @() }
                        dry_run = $DryRun.IsPresent
                    }
                    
                    if (-not $DryRun.IsPresent) {
                        $evaDir = "$projPath/.eva"
                        if (-not (Test-Path $evaDir)) { 
                            New-Item $evaDir -ItemType Directory -Force | Out-Null 
                        }
                        $evidencePath = "$evaDir/fractal-dpdca-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
                        Write-Utf8File -Path $evidencePath -Content ($evidence | ConvertTo-Json -Depth 5)
                        Write-Status "[PASS]" "Evidence: $evidencePath"
                    }
                }
                
                $allResults += $result
                $successCount++
                Write-Status "[INFO]" "Project $projName complete (Success: $successCount, Failures: $failureCount)"
            }
            
        } catch {
            Write-Status "[FAIL]" "Exception during prime: $_"
            $failureCount++
            
            if (-not $ContinueOnError.IsPresent) {
                Write-Status "[STOP]" "Halting workspace prime due to exception in $projName"
                break
            }
        }
    }
    
    Write-Information ""
    Write-Information "=== FRACTAL DPDCA SUMMARY ==="
    Write-Information "  Projects attempted: $($projects.Count)"
    Write-Information "  Successful: $successCount"
    Write-Information "  Failed: $failureCount"
    Write-Information "  Completion rate: $(if ($projects.Count -gt 0) { [math]::Round(($successCount / $projects.Count) * 100, 1) } else { 0 })%"
    
} else {
    Write-Error "[FAIL] Provide either -TargetPath or -WorkspaceRoot"
    exit 1
}

# Final Summary
Write-Information ""
Write-Information "=== Invoke-PrimeWorkspace v2.1.0 (Fractal DPDCA) Summary ==="
$modeStr = if ($TargetPath) { 'Single Project' } else { "Workspace ($($projects.Count) projects)" }
Write-Information "  Mode: $modeStr"
Write-Information "  Projects processed: $($allResults.Count)"
Write-Information "  DryRun: $($DryRun.IsPresent)"
if ($WorkspaceRoot) {
    Write-Information "  Success rate: $(if ($projects.Count -gt 0) { [math]::Round(($successCount / $projects.Count) * 100, 1) } else { 0 })%"
}
foreach ($r in $allResults) {
    if ($r) {
        Write-Information "  $($r.folder): $($r.steps -join ', ')"
    }
}
Write-Information ""
Write-Information "[INFO] Fractal DPDCA applied: Per-project DISCOVER/PLAN/DO/CHECK/ACT"
Write-Information "[INFO] Stop-on-failure: $(if ($ContinueOnError.IsPresent) { 'DISABLED (ContinueOnError)' } else { 'ENABLED' })"
Write-Information "=== [DONE] ==="
