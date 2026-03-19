[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspaceRoot = "c:\eva-foundry",

    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[1-5]$')]
    [string]$PhaseToActive = "1",

    [Parameter(Mandatory = $false)]
    [string[]]$ProjectIds = @(),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectPattern = '^\d{2}-'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ApiBase = 'https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io'
$StartTime = Get-Date
$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$LogsDir = Join-Path $WorkspaceRoot 'logs'
$EvidenceDir = Join-Path $WorkspaceRoot 'evidence'
$DebugDir = Join-Path $WorkspaceRoot 'debug'
$LogPath = Join-Path $LogsDir ("{0}-workspace-memory-init.log" -f $Timestamp)
$EvidencePath = Join-Path $EvidenceDir ("{0}-workspace-memory-init-evidence.json" -f $Timestamp)

function Write-LogEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'PASS', 'SKIP', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $entryTimestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$entryTimestamp] [$Level] $Message"

    $color = switch ($Level) {
        'PASS' { 'Green' }
        'SKIP' { 'Yellow' }
        'WARN' { 'Yellow' }
        'ERROR' { 'Red' }
        default { 'Cyan' }
    }

    Write-Host $entry -ForegroundColor $color
    Add-Content -Path $LogPath -Value $entry
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path $Path) {
        return
    }

    if ($DryRun) {
        Write-LogEntry "[DRY-RUN] Would create directory: $Path" 'INFO'
        return
    }

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Test-ApiHealth {
    $health = Invoke-RestMethod "$ApiBase/health" -TimeoutSec 10 -ErrorAction Stop
    if ($health.status -ne 'ok' -or $health.store -ne 'cosmos') {
        throw "API health check failed. status=$($health.status) store=$($health.store)"
    }
    return $health
}

function Get-TargetProjects {
    if ($ProjectIds.Count -gt 0) {
        $resolved = foreach ($projectId in $ProjectIds) {
            $path = Join-Path $WorkspaceRoot $projectId
            [pscustomobject]@{
                ProjectId = $projectId
                ProjectPath = $path
                Exists = (Test-Path $path -PathType Container)
            }
        }
        return $resolved
    }

    $projects = Get-ChildItem -Path $WorkspaceRoot -Directory |
        Where-Object { $_.Name -match $ProjectPattern } |
        Sort-Object Name |
        ForEach-Object {
            [pscustomobject]@{
                ProjectId = $_.Name
                ProjectPath = $_.FullName
                Exists = $true
            }
        }

    return $projects
}

function Get-CheckpointContent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$PhaseNumber
    )

    $generatedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC'

    return @"
<!-- foundation-memory-checkpoint -->
# [$ProjectId] Agent Wake-Up Checkpoint

**Generated**: $generatedDate
**Purpose**: Local continuity aid only. Governance truth lives in the Data Model API.
**Authoritative State**: $ApiBase

## Wake-Up Order

1. Load workspace and project governance files.
2. Bootstrap session.guide and session.userGuide from the API.
3. Query authoritative project state from projects, project_work, sprints, and evidence.
4. Read local continuity notes in .memories/session/.
5. Reconcile conflicts by trusting API state over local notes.
6. Start the next D3PDCA loop with explicit scope and evidence targets.

## Governance Refresh

    `$workspacePolicies = Get-Content ".github/copilot-instructions.md" -Raw
    `$projectPlan = Get-Content "PLAN.md" -Raw -ErrorAction SilentlyContinue
    `$projectStatus = Get-Content "STATUS.md" -Raw -ErrorAction SilentlyContinue

## API Bootstrap

    `$base = "$ApiBase"
    `$health = Invoke-RestMethod "$ApiBase/health" -TimeoutSec 10
    `$session = @{
        base = `$base
        initialized_at = Get-Date
        guide = Invoke-RestMethod "$ApiBase/model/agent-guide" -TimeoutSec 10
        userGuide = Invoke-RestMethod "$ApiBase/model/user-guide" -TimeoutSec 10
    }

## Authoritative Queries

    `$project = Invoke-RestMethod "$ApiBase/model/projects/$ProjectId"
    `$projectWork = Invoke-RestMethod "$ApiBase/model/project_work/?project_id=$ProjectId"
    `$sprints = Invoke-RestMethod "$ApiBase/model/sprints/?project_id=$ProjectId"
    `$evidence = Invoke-RestMethod "$ApiBase/model/evidence/?project_id=$ProjectId"

## Local Continuity Rules

- Local files in .memories/session/ are prompts for fast recovery, not sources of truth.
- Do not create or update sprint_N_config.json here.
- Do not persist project_work, sprint, or evidence truth locally.
- If local notes disagree with the API, update the local note after confirming the API record.
- Use timestamp-prefix names for any additional local notes you create.

## WS06 Learning Loop

- Emit execution events and lessons as immutable evidence in the API workflow, not as hidden local truth.
- Record local observations only as short handoff notes for the next agent wake-up.
- Promote stable patterns into shared memory or Foundation docs after validation.

## Session Opening Checklist

- [ ] Governance files loaded
- [ ] API health verified
- [ ] agent-guide and user-guide loaded
- [ ] Project state queried from API
- [ ] Local continuity notes reviewed
- [ ] Next D3PDCA scope defined

## Suggested Local Files

- {YYYYMMDD_HHMMSS}-phase-$PhaseNumber-kickoff-checkpoint.md
- {YYYYMMDD_HHMMSS}-phase-$PhaseNumber-blockers.md
- {YYYYMMDD_HHMMSS}-phase-$PhaseNumber-handoff-summary.md

**Status**: [PASS] READY FOR AGENT WAKE-UP
"@
}

function Set-ManagedFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $action = 'create'
    if (Test-Path $Path) {
        $existingContent = Get-Content $Path -Raw
        if ($existingContent -eq $Content) {
            Write-LogEntry "Unchanged: $Path" 'SKIP'
            return 'unchanged'
        }

        $isManaged = ($existingContent -match '<!-- foundation-memory-checkpoint -->') -or
            ($existingContent -match 'Ready for sprint planning') -or
            ($existingContent -match 'Activate sprint via sprint_activation.py')

        if (-not $isManaged) {
            Write-LogEntry "Skipped unmanaged file: $Path" 'WARN'
            return 'skipped'
        }

        $action = 'update'
    }

    if ($DryRun) {
        Write-LogEntry "[DRY-RUN] Would $action file: $Path" 'INFO'
        return $action
    }

    Set-Content -Path $Path -Value $Content -Encoding utf8
    Write-LogEntry (("{0}: {1}" -f ($action.Substring(0, 1).ToUpper() + $action.Substring(1)), $Path)) 'PASS'
    return $action
}

function Initialize-ProjectMemory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$ProjectPath,

        [Parameter(Mandatory = $true)]
        [string]$PhaseNumber
    )

    $sessionPath = Join-Path $ProjectPath '.memories\session'
    $checkpointPath = Join-Path $sessionPath ("phase-{0}-kickoff-checkpoint.md" -f $PhaseNumber)

    Ensure-Directory -Path $sessionPath
    $content = Get-CheckpointContent -ProjectId $ProjectId -PhaseNumber $PhaseNumber
    $result = Set-ManagedFile -Path $checkpointPath -Content $content

    return [pscustomobject]@{
        SessionPath = $sessionPath
        CheckpointPath = $checkpointPath
        CheckpointResult = $result
    }
}

try {
    Ensure-Directory -Path $LogsDir
    Ensure-Directory -Path $EvidenceDir
    Ensure-Directory -Path $DebugDir

    Write-LogEntry '========== WORKSPACE MEMORY SYSTEM INITIALIZATION ==========' 'INFO'
    Write-LogEntry "Workspace root: $WorkspaceRoot" 'INFO'
    Write-LogEntry "Dry run: $DryRun" 'INFO'

    if (-not (Test-Path $WorkspaceRoot -PathType Container)) {
        throw "Workspace root not found: $WorkspaceRoot"
    }

    $apiHealth = Test-ApiHealth
    Write-LogEntry "API healthy: status=$($apiHealth.status) store=$($apiHealth.store)" 'PASS'

    $projects = Get-TargetProjects
    if ($projects.Count -eq 0) {
        Write-LogEntry 'No target projects discovered.' 'ERROR'
        exit 1
    }

    Write-LogEntry "Projects discovered: $($projects.Count)" 'INFO'

    $results = @()
    $successCount = 0
    $skipCount = 0
    $failCount = 0

    foreach ($project in $projects) {
        if (-not $project.Exists) {
            Write-LogEntry "Project not found: $($project.ProjectId)" 'SKIP'
            $skipCount++
            $results += [pscustomobject]@{
                project = $project.ProjectId
                status = 'SKIP'
                reason = 'project-missing'
            }
            continue
        }

        Write-LogEntry "Processing project: $($project.ProjectId)" 'INFO'

        try {
            $projectResult = Initialize-ProjectMemory -ProjectId $project.ProjectId -ProjectPath $project.ProjectPath -PhaseNumber $PhaseToActive
            $resultStatus = if ($projectResult.CheckpointResult -eq 'skipped') { 'WARN' } else { 'PASS' }
            if ($resultStatus -eq 'PASS') {
                $successCount++
            } else {
                $skipCount++
            }

            $results += [pscustomobject]@{
                project = $project.ProjectId
                status = $resultStatus
                checkpoint = $projectResult.CheckpointPath
                checkpoint_result = $projectResult.CheckpointResult
            }
        } catch {
            $failCount++
            Write-LogEntry "Project failed: $($project.ProjectId) - $($_.Exception.Message)" 'ERROR'
            $results += [pscustomobject]@{
                project = $project.ProjectId
                status = 'FAIL'
                reason = $_.Exception.Message
            }
        }
    }

    $elapsedSeconds = [math]::Round(((Get-Date) - $StartTime).TotalSeconds, 2)
    $overallStatus = if ($failCount -gt 0) { 'PARTIAL' } else { 'SUCCESS' }
    $exitCode = if ($failCount -gt 0) { 1 } else { 0 }

    $evidence = [ordered]@{
        task = 'workspace-memory-system-initialization'
        timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
        workspace_root = $WorkspaceRoot
        api_base = $ApiBase
        phase_seeded = [int]$PhaseToActive
        dry_run = [bool]$DryRun
        project_pattern = $ProjectPattern
        projects_requested = if ($ProjectIds.Count -gt 0) { @($ProjectIds) } else { @() }
        projects_discovered = @($projects.ProjectId)
        projects_success = $successCount
        projects_skipped = $skipCount
        projects_failed = $failCount
        execution_time_seconds = $elapsedSeconds
        log_file = $LogPath
        evidence_file = $EvidencePath
        status = $overallStatus
        exit_code = $exitCode
        results = $results
    }

    if ($DryRun) {
        Write-LogEntry "[DRY-RUN] Would write evidence file: $EvidencePath" 'INFO'
    } else {
        $evidence | ConvertTo-Json -Depth 6 | Set-Content -Path $EvidencePath -Encoding utf8
        Write-LogEntry "Evidence saved: $EvidencePath" 'PASS'
    }

    Write-LogEntry "Summary: success=$successCount skip=$skipCount fail=$failCount duration=${elapsedSeconds}s" 'INFO'
    exit $exitCode
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "[ERROR] $errorMessage" -ForegroundColor Red

    $errorEvidence = [ordered]@{
        task = 'workspace-memory-system-initialization'
        timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
        status = 'ERROR'
        exit_code = 2
        message = $errorMessage
    }

    try {
        if (-not $DryRun) {
            Ensure-Directory -Path $EvidenceDir
            $errorEvidence | ConvertTo-Json -Depth 4 | Set-Content -Path $EvidencePath -Encoding utf8
        }
    } catch {
        Write-Host "[ERROR] Failed to write error evidence: $($_.Exception.Message)" -ForegroundColor Red
    }

    exit 2
}
