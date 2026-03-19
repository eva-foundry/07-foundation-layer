# EVA-FEATURE: F07-02
# EVA-STORY: F07-02-001
# EVA-STORY: F07-02-002
# EVA-STORY: F07-02-003
# EVA-STORY: F07-02-004
# EVA-STORY: F07-03-001
# EVA-STORY: F07-03-002
# EVA-STORY: F07-03-003
# EVA-STORY: F07-03-004
# EVA-STORY: F07-03-005
# EVA-STORY: F07-03-006
# EVA-STORY: F07-05-001
# EVA-STORY: F07-05-002
# EVA-STORY: F07-06-001
# EVA-STORY: F07-06-002
# EVA-STORY: F07-06-003
# EVA-STORY: F07-06-004
# EVA-STORY: F07-07-001
# EVA-STORY: F07-08-001
# EVA-STORY: F07-08-002
# Apply-Project07-Artifacts.ps1
# Version: 2.0.1 (March 19, 2026)
# Intelligent primer script for deploying Project 07 artifacts to any EVA project
# Self-demonstrating: Uses the same professional patterns it deploys
# See CHANGELOG.md for version history and upgrade notes
#
# CHANGES in 2.0.0:
# - Aligns with the v7.1.0 project instruction contract template
# - Preserves the Project-Owned Context block instead of legacy PART 2 content
# - Uses the Validation Pattern section from the live template instead of legacy PART 3 assembly
# - Simplifies validation to the current project contract markers

<#
.SYNOPSIS
    Applies Project 07 Copilot Instructions baseline to target project with smart merging

.DESCRIPTION
    This script embodies Project 07 best practices:
    - Professional Component Architecture (DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS)
    - Evidence Collection at operation boundaries
    - ASCII-only output (Windows enterprise encoding safety)
    - Standards validation with compliance reporting
    - Automated testing integration
    
    Features:
    1. Analyzes target project structure
    2. Detects existing copilot-instructions.md and preserves the Project-Owned Context block
    3. Applies the managed foundation contract from the live template
    4. Generates project-specific Project-Owned Context content when none exists
    5. Creates backup before any changes
    6. Validates deployment against Project 07 standards
    7. Generates compliance report

.PARAMETER TargetPath
    Path to target project folder (default: current directory)

.PARAMETER SourcePath
    Path to Project 07 artifacts (default: auto-detect from C:\eva-foundry\eva-foundation\07-foundation-layer)

.PARAMETER DryRun
    Preview changes without applying them

.PARAMETER Force
    Skip safety prompts (use with caution)

.PARAMETER SkipBackup
    Skip backup creation (not recommended)

.PARAMETER SkipValidation
    Skip post-deployment compliance validation

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "C:\eva-foundry\eva-foundation\31-eva-faces" -DryRun
    Preview what would be applied to 31-eva-faces

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "C:\eva-foundry\eva-foundation\33-eva-brain-v2"
    Apply Project 07 artifacts with interactive prompts

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "C:\eva-foundry\eva-foundation\44-eva-jp-spark" -Force
    Force apply without prompts (use with caution)

.NOTES
    Version: 1.3.0 (January 29, 2026)
    Author: Project 07 - Copilot Instructions & Standards Baseline
    Based on: EVA Professional Component Architecture Standards
    Changelog: See CHANGELOG.md for upgrade notes and breaking changes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBackup,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation
)

# Set error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ASCII-only output (Project 07 encoding safety - CRITICAL)
$script:Symbols = @{
    Pass = "[PASS]"
    Fail = "[FAIL]"
    Info = "[INFO]"
    Warn = "[WARN]"
    Error = "[ERROR]"
    Arrow = "==>"
    Check = "[CHECK]"
}

#region Professional Component Classes

class DebugArtifactCollectorPS {
    <#
    .SYNOPSIS
        Evidence capture at operation boundaries (Project 07 Pattern)
    #>
    
    [string]$ComponentName
    [string]$DebugDir
    [System.Collections.ArrayList]$Artifacts
    
    DebugArtifactCollectorPS([string]$name, [string]$basePath) {
        $this.ComponentName = $name
        $this.DebugDir = Join-Path $basePath "debug\$name"
        $this.Artifacts = [System.Collections.ArrayList]::new()
        
        if (-not (Test-Path $this.DebugDir)) {
            New-Item -ItemType Directory -Path $this.DebugDir -Force | Out-Null
        }
    }
    
    [hashtable] CaptureState([string]$context) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $stateFile = Join-Path $this.DebugDir "${context}_${timestamp}.json"
        
        # Build state object (use .NET APIs - PowerShell classes can't access automatic variables)
        $envData = @{
            user = [System.Environment]::UserName
            machine = [System.Environment]::MachineName
            os_version = [System.Environment]::OSVersion.Version.ToString()
        }
        
        $state = @{
            timestamp = [string](Get-Date).ToString("o")
            context = $context
            component = $this.ComponentName
            environment = $envData
        }
        
        $state | ConvertTo-Json -Depth 5 | Out-File $stateFile -Encoding UTF8
        [void]$this.Artifacts.Add($stateFile)
        
        return @{
            state_file = $stateFile
            timestamp = $timestamp
        }
    }
    
    [string[]] GetArtifacts() {
        return $this.Artifacts.ToArray()
    }
}

class SessionManagerPS {
    <#
    .SYNOPSIS
        Checkpoint/resume capability for long-running operations (Project 07 Pattern)
    #>
    
    [string]$ComponentName
    [string]$SessionDir
    [string]$SessionFile
    [string]$CheckpointDir
    
    SessionManagerPS([string]$name, [string]$basePath) {
        $this.ComponentName = $name
        $this.SessionDir = Join-Path $basePath "sessions\$name"
        $this.SessionFile = Join-Path $this.SessionDir "session_state.json"
        $this.CheckpointDir = Join-Path $this.SessionDir "checkpoints"
        
        if (-not (Test-Path $this.CheckpointDir)) {
            New-Item -ItemType Directory -Path $this.CheckpointDir -Force | Out-Null
        }
    }
    
    [void] SaveCheckpoint([string]$checkpointId, [hashtable]$data) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $checkpointFile = Join-Path $this.CheckpointDir "checkpoint_${checkpointId}_${timestamp}.json"
        
        $checkpoint = @{
            checkpoint_id = $checkpointId
            timestamp = (Get-Date).ToString("o")
            component = $this.ComponentName
            data = $data
        }
        
        $checkpoint | ConvertTo-Json -Depth 10 | Out-File $checkpointFile -Encoding UTF8
        
        # Update session pointer
        @{
            component = $this.ComponentName
            last_updated = (Get-Date).ToString("o")
            latest_checkpoint = $checkpointFile
            checkpoint_id = $checkpointId
        } | ConvertTo-Json | Out-File $this.SessionFile -Encoding UTF8
    }
    
    [hashtable] LoadLatestCheckpoint() {
        if (-not (Test-Path $this.SessionFile)) {
            return $null
        }
        
        try {
            $session = Get-Content $this.SessionFile -Raw | ConvertFrom-Json
            $checkpointFile = $session.latest_checkpoint
            
            if (Test-Path $checkpointFile) {
                $checkpoint = Get-Content $checkpointFile -Raw | ConvertFrom-Json
                return @{
                    checkpoint_id = $checkpoint.checkpoint_id
                    timestamp = $checkpoint.timestamp
                    data = $checkpoint.data
                }
            }
        } catch {
            Write-Warning "Failed to load checkpoint: $_"
        }
        
        return $null
    }
}

class StructuredErrorHandlerPS {
    <#
    .SYNOPSIS
        JSON-based error logging with context (Project 07 Pattern)
    #>
    
    [string]$ComponentName
    [string]$ErrorDir
    
    StructuredErrorHandlerPS([string]$name, [string]$basePath) {
        $this.ComponentName = $name
        $this.ErrorDir = Join-Path $basePath "logs\errors"
        
        if (-not (Test-Path $this.ErrorDir)) {
            New-Item -ItemType Directory -Path $this.ErrorDir -Force | Out-Null
        }
    }
    
    [string] LogError([System.Management.Automation.ErrorRecord]$error, [hashtable]$context) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $errorFile = Join-Path $this.ErrorDir "$($this.ComponentName)_error_${timestamp}.json"
        
        $errorReport = @{
            timestamp = (Get-Date).ToString("o")
            component = $this.ComponentName
            error_type = $error.Exception.GetType().Name
            error_message = $error.Exception.Message
            stack_trace = $error.ScriptStackTrace
            context = $context
            category_info = $error.CategoryInfo.ToString()
        }
        
        $errorReport | ConvertTo-Json -Depth 10 | Out-File $errorFile -Encoding UTF8
        
        # Best Practice: Use Write-Error for error reporting (proper stream)
        Write-Error "$($this.ComponentName): $($error.Exception.GetType().Name)"
        Write-Error "Message: $($error.Exception.Message)"
        Write-Error "Details saved to: $errorFile"
        
        return $errorFile
    }
    
    [void] LogStructuredEvent([string]$eventType, [hashtable]$data) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $eventFile = Join-Path $this.ErrorDir "$($this.ComponentName)_event_${timestamp}.json"
        
        $eventReport = @{
            timestamp = (Get-Date).ToString("o")
            component = $this.ComponentName
            event_type = $eventType
            data = $data
        }
        
        $eventReport | ConvertTo-Json -Depth 10 | Out-File $eventFile -Encoding UTF8
    }
}

#endregion

#region Helper Functions

function Write-Status {
    <#
    .SYNOPSIS
        ASCII-only status output (Windows enterprise encoding safety)
        Outputs to both console (colored) and Information stream (capturable)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Pass", "Fail", "Info", "Warn", "Error", "Arrow", "Check")]
        [string]$Type = "Info",
        
        [Parameter(Mandatory=$false)]
        [switch]$NoNewline
    )
    
    $symbol = $script:Symbols[$Type]
    $color = switch ($Type) {
        "Pass" { "Green" }
        "Fail" { "Red" }
        "Error" { "Red" }
        "Warn" { "Yellow" }
        "Info" { "Cyan" }
        "Arrow" { "Magenta" }
        "Check" { "White" }
    }
    
    $formattedMessage = "$symbol $Message"
    
    # Best Practice: Write to both streams
    # - Console: Colored output for interactive use
    # - Information: Capturable output for logging/automation
    if ($NoNewline) {
        Write-Host $formattedMessage -ForegroundColor $color -NoNewline
    } else {
        Write-Host $formattedMessage -ForegroundColor $color
        Write-Information $formattedMessage -InformationAction Continue
    }
}

function New-BackupCopy {
    <#
    .SYNOPSIS
        Creates timestamped backup before modifications
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        return $null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path (Split-Path $FilePath -Parent) ".project07-backups"
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $fileName = Split-Path $FilePath -Leaf
    $backupPath = Join-Path $backupDir "${fileName}.backup_${timestamp}"
    
    Copy-Item -Path $FilePath -Destination $backupPath -Force
    
    return $backupPath
}

function Find-Project07Source {
    <#
    .SYNOPSIS
        Auto-detect Project 07 artifact location
    #>
    
    $searchPaths = @(
        "C:\eva-foundry\07-foundation-layer\templates",
        (Join-Path (Split-Path $PSScriptRoot -Parent) "templates"),
        (Join-Path $PSScriptRoot "."),
        ".\templates"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $templatePath = Join-Path $path "copilot-instructions-template.md"
            if (Test-Path $templatePath) {
                return (Resolve-Path $path).Path
            }
        }
    }
    
    return $null
}

function Get-ProjectMetadata {
    <#
    .SYNOPSIS
        Analyze target project structure and detect type
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectPath
    )
    
    $metadata = @{
        Name = Split-Path $ProjectPath -Leaf
        HasGitHub = Test-Path (Join-Path $ProjectPath ".github")
        HasCopilotInstructions = $false
        HasArchitectureDoc = $false
        HasDocs = Test-Path (Join-Path $ProjectPath "docs")
        HasScripts = Test-Path (Join-Path $ProjectPath "scripts")
        HasTests = Test-Path (Join-Path $ProjectPath "tests")
        HasFunctions = Test-Path (Join-Path $ProjectPath "functions")
        HasInfra = Test-Path (Join-Path $ProjectPath "infra")
        ProjectType = "Unknown"
        Components = @()
        TechStack = @()
        ExistingCopilotPath = $null
        ExistingArchitecturePath = $null
    }
    
    # Check for existing copilot instructions
    $copilotPath = Join-Path $ProjectPath ".github\copilot-instructions.md"
    if (Test-Path $copilotPath) {
        $metadata.HasCopilotInstructions = $true
        $metadata.ExistingCopilotPath = $copilotPath
    }
    
    # Check for architecture doc
    $archPath = Join-Path $ProjectPath ".github\architecture-ai-context.md"
    if (Test-Path $archPath) {
        $metadata.HasArchitectureDoc = $true
        $metadata.ExistingArchitecturePath = $archPath
    }
    
    # Detect project type and components
    if (Test-Path (Join-Path $ProjectPath "app\backend")) {
        $metadata.ProjectType = "RAG System / Full-Stack Application"
        $metadata.Components += "Backend API"
    }
    
    if (Test-Path (Join-Path $ProjectPath "app\frontend")) {
        $metadata.Components += "Frontend SPA"
    }
    
    if ($metadata.HasFunctions) {
        if ($metadata.ProjectType -eq "Unknown") {
            $metadata.ProjectType = "Azure Functions / Serverless"
        }
        $metadata.Components += "Azure Functions"
    }
    
    if ($metadata.HasInfra) {
        $metadata.Components += "Infrastructure as Code"
    }
    
    if ($metadata.HasScripts -and $metadata.ProjectType -eq "Unknown") {
        # Check for automation patterns
        $scriptFiles = @(Get-ChildItem -Path (Join-Path $ProjectPath "scripts") -Filter "*.py" -ErrorAction SilentlyContinue)
        if ($scriptFiles -and $scriptFiles.Count -gt 0) {
            $metadata.ProjectType = "Automation / Scripting System"
            $metadata.Components += "Python Scripts"
        }
    }
    
    # Detect tech stack
    if (Test-Path (Join-Path $ProjectPath "package.json")) {
        $metadata.TechStack += "Node.js/TypeScript"
    }
    
    if (Test-Path (Join-Path $ProjectPath "requirements.txt")) {
        $metadata.TechStack += "Python"
    }
    
    if (Test-Path (Join-Path $ProjectPath "Makefile")) {
        $metadata.TechStack += "Make"
    }
    
    if (Test-Path (Join-Path $ProjectPath "*.csproj")) {
        $metadata.TechStack += ".NET"
    }
    
    # Default to generic if still unknown
    if ($metadata.ProjectType -eq "Unknown") {
        $metadata.ProjectType = "General Purpose Project"
    }
    
    return $metadata
}

function Resolve-TemplateTokens {
    <#
    .SYNOPSIS
        Resolve managed template placeholders using target project metadata
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Content,

        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata
    )

    $projectFolder = $Metadata.Name
    $projectName = $Metadata.Name
    $wbsPrefix = if ($projectFolder -match '^(\d{2})-') { "F$($matches[1])" } else { 'FXX' }
    $projectStack = if ($Metadata.TechStack.Count -gt 0) { $Metadata.TechStack -join ' + ' } else { '[TODO: Replace with real stack]' }
    $projectPatterns = if ($Metadata.Components.Count -gt 0) {
        @(
            "$($Metadata.ProjectType) architecture aligned to components: $($Metadata.Components -join ', ')",
            '[TODO: Add the most important implementation pattern for this project]',
            '[TODO: Add any delivery or integration constraint that must be preserved]'
        )
    } else {
        @(
            '[TODO: Add the most important implementation pattern for this project]',
            '[TODO: Add the second most important implementation pattern for this project]',
            '[TODO: Add any delivery or integration constraint that must be preserved]'
        )
    }

    $tokenMap = [ordered]@{
        '{{PROJECT_NAME}}' = $projectName
        '{{PROJECT_FOLDER}}' = $projectFolder
        '{{WBS_PREFIX}}' = $wbsPrefix
        '{{PROJECT_MATURITY}}' = '[TODO: Confirm maturity]'
        '{{CURRENT_PHASE}}' = '[TODO: Confirm current phase]'
        '{{KEY_DEPENDENCIES}}' = '[TODO: Replace with real dependencies]'
        '{{PROJECT_STACK}}' = $projectStack
        '{{BUILD_COMMAND}}' = '[TODO: Add build command]'
        '{{TEST_COMMAND}}' = '[TODO: Add test command]'
        '{{LINT_COMMAND}}' = '[TODO: Add lint command]'
        '{{RUN_COMMAND}}' = '[TODO: Add run command]'
        '{{LOCAL_PATTERN_1}}' = $projectPatterns[0]
        '{{LOCAL_PATTERN_2}}' = $projectPatterns[1]
        '{{LOCAL_PATTERN_3}}' = $projectPatterns[2]
        '{{LOCAL_RISK_1}}' = '[TODO: Add the main execution or deployment risk]'
        '{{LOCAL_RISK_2}}' = '[TODO: Add known exceptions, temporary waivers, or operating hazards]'
    }

    $resolvedContent = $Content
    foreach ($token in $tokenMap.Keys) {
        $resolvedContent = $resolvedContent.Replace($token, $tokenMap[$token])
    }

    return $resolvedContent
}

function Extract-ExistingPart2 {
    <#
    .SYNOPSIS
        Extract the current Project-Owned Context block or convert legacy content
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$CopilotInstructionsPath
    )
    
    if (-not (Test-Path $CopilotInstructionsPath)) {
        return $null
    }
    
    $content = Get-Content $CopilotInstructionsPath -Raw
    
    if ($content -match '(?sm)^## Project-Owned Context\s*$.*?(?=^## Validation Pattern\s*$)') {
        $ownedContextContent = $matches[0].TrimEnd()

        Write-Status "Extracted existing Project-Owned Context ($($ownedContextContent.Length) chars)" -Type Pass

        return @{
            Content = $ownedContextContent
            Source = 'current'
        }
    }

    if ($content -match '(?sm)^## PART 2[: -].*?(?=^## PART 3[: -]|\z)') {
        $legacyContent = $matches[0].TrimEnd()

        Write-Status "Converted legacy PART 2 content into Project-Owned Context ($($legacyContent.Length) chars)" -Type Warn

        return @{
            Content = @"
## Project-Owned Context

This section was preserved from a legacy PART-based project instruction file.
Review and normalize it during the next project-specific maintenance cycle.

$legacyContent
"@.TrimEnd()
            Source = 'legacy-part'
        }
    }

    $trimmed = $content.Trim()
    if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
        Write-Status "Wrapped existing unstructured project instructions into Project-Owned Context" -Type Warn

        return @{
            Content = @"
## Project-Owned Context

This section was preserved from an older unstructured project instruction file.
Review and normalize it during the next project-specific maintenance cycle.

$trimmed
"@.TrimEnd()
            Source = 'legacy-unstructured'
        }
    }

    return $null
}

function New-ProjectSpecificPart2 {
    <#
    .SYNOPSIS
        Generate the Project-Owned Context section based on project analysis
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$ExistingPart2
    )
    
    $projectName = $Metadata.Name
    $components = if ($Metadata.Components.Count -gt 0) { $Metadata.Components -join ", " } else { "[TODO: Document components]" }
    $techStack = if ($Metadata.TechStack.Count -gt 0) { $Metadata.TechStack -join " + " } else { "[TODO: Document tech stack]" }
    
    $componentList = ""
    if ($Metadata.Components.Count -gt 0) {
        $i = 1
        foreach ($comp in $Metadata.Components) {
            $componentList += "$i. **$comp** - [TODO: Add path and description]`n"
            $i++
        }
    } else {
        $componentList = "[TODO: Document core components]"
    }
    
    if ($ExistingPart2 -and $ExistingPart2.Content) {
        Write-Status "Preserving existing Project-Owned Context block" -Type Info
        return $ExistingPart2.Content
    }

    return @"
## Project-Owned Context

This section is intended to be edited by the project team and preserved by foundation reseed operations.

Document only the project-specific facts that do not belong in workspace instructions:
- domain purpose
- important dependencies
- real build and test commands
- local architectural constraints
- known exceptions or delivery hazards

**Status**: [TODO: Confirm maturity]  
**Current Phase**: [TODO: Confirm current phase]  
**Dependencies**: [TODO: Replace with real dependencies]  
**Primary Stack**: $techStack

### Local Commands

List the real commands used in this project:
- build: [TODO: Add build command]
- test: [TODO: Add test command]
- lint: [TODO: Add lint command]
- run: [TODO: Add run command]

### Local Patterns

- $($Metadata.ProjectType) architecture with components: $components
- [TODO: Add the most important implementation pattern for this project]
- [TODO: Add any delivery or integration constraint that must be preserved]

### Local Risks Or Exceptions

- [TODO: Add the main execution or deployment risk]
- [TODO: Add known exceptions, temporary waivers, or operating hazards]
"@.TrimEnd()
}

function New-Part1Content {
    <#
    .SYNOPSIS
        Extract the managed foundation contract prefix from the template
    .DESCRIPTION
        Extracts everything before the Project-Owned Context section header.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$TemplatePath,

        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata,
        
        [Parameter(Mandatory=$false)]
        [object]$DebugCollector = $null
    )
    
    # EVIDENCE: Capture pre-state (Project 07 pattern)
    if ($DebugCollector) {
        $DebugCollector.CaptureState("before_part1_extraction") | Out-Null
    }
    
    $templateContent = Resolve-TemplateTokens -Content (Get-Content $TemplatePath -Raw) -Metadata $Metadata
    
    if ($templateContent -match '(?sm)^(.*?)^## Project-Owned Context\s*$') {
        $part1Content = $matches[1]

        $lineCount = ($part1Content -split "`n").Count

        if ($lineCount -lt 20) {
            $error = "CRITICAL: Extracted template prefix has only $lineCount lines. Regex matched the wrong marker."
            Write-Status $error -Type Error

            if ($DebugCollector) {
                $errorFile = Join-Path $DebugCollector.DebugDir "part1_extraction_failed_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                $part1Content | Out-File $errorFile -Encoding UTF8
                $DebugCollector.CaptureState("part1_extraction_validation_failed") | Out-Null
            }

            throw $error
        }

        Write-Status "Extracted managed template prefix: $lineCount lines" -Type Pass

        if ($DebugCollector) {
            $DebugCollector.CaptureState("after_part1_extraction_success") | Out-Null
        }

        return $part1Content
    }

    Write-Status "Could not extract template prefix from Project-Owned Context marker. Using full template." -Type Warn
    
    if ($DebugCollector) {
        $DebugCollector.CaptureState("part1_extraction_fallback") | Out-Null
    }
    
    return $templateContent
}

function New-ValidationContent {
    <#
    .SYNOPSIS
        Extract the Validation Pattern section and trailing references from the template
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$TemplatePath,

        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata
    )

    $templateContent = Resolve-TemplateTokens -Content (Get-Content $TemplatePath -Raw) -Metadata $Metadata

    if ($templateContent -match '(?sm)^## Validation Pattern\s*$.*$') {
        $validationContent = $matches[0].Trim()
        $lineCount = ($validationContent -split "`n").Count
        Write-Status "Extracted validation suffix: $lineCount lines" -Type Pass
        return $validationContent
    }

    throw "CRITICAL: Could not extract Validation Pattern section from template"
}

function Test-DeploymentCompliance {
    <#
    .SYNOPSIS
        Validate deployed artifacts against Project 07 standards
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$TargetPath
    )
    
    $results = @{
        Passed = @()
        Failed = @()
        Warnings = @()
    }
    
    $copilotPath = Join-Path $TargetPath ".github\copilot-instructions.md"
    
    # Check 1: File exists
    if (Test-Path $copilotPath) {
        $results.Passed += "[CHECK] copilot-instructions.md exists"
    } else {
        $results.Failed += "[FAIL] copilot-instructions.md not found"
        return $results
    }
    
    $content = Get-Content $copilotPath -Raw
    
    # Check 2: Has bootstrap section
    if ($content -match '(?m)^## Bootstrap First\s*$') {
        $results.Passed += "[CHECK] Bootstrap First section present"
    } else {
        $results.Failed += "[FAIL] Bootstrap First section missing"
    }

    # Check 3: Has Project-Owned Context section
    if ($content -match '(?m)^## Project-Owned Context\s*$') {
        $results.Passed += "[CHECK] Project-Owned Context present"
    } else {
        $results.Failed += "[FAIL] Project-Owned Context missing"
    }
    
    # Check 4: No Unicode violations (CRITICAL - encoding safety)
    $unicodePatterns = @(
        '[^\u0000-\u007F]'
    )
    
    $unicodeViolations = @()
    foreach ($pattern in $unicodePatterns) {
        if ($content -match $pattern) {
            $unicodeViolations += $pattern
        }
    }
    
    if ($unicodeViolations.Count -eq 0) {
        $results.Passed += "[CHECK] No Unicode violations (encoding safety)"
    } else {
        $results.Failed += "[FAIL] Unicode violations found: $($unicodeViolations -join ', ')"
    }
    
    # Check 5: Has Validation Pattern section
    if ($content -match '(?m)^## Validation Pattern\s*$') {
        $results.Passed += "[CHECK] Validation Pattern present"
    } else {
        $results.Failed += "[FAIL] Validation Pattern missing"
    }

    # Check 6: Has reference block
    if ($content -match '(?m)^## References\s*$') {
        $results.Passed += "[CHECK] References section present"
    } else {
        $results.Warnings += "[WARN] References section missing"
    }

    # Check 7: No unresolved template placeholders remain
    if ($content -match '\{\{[A-Z0-9_]+\}\}') {
        $results.Failed += "[FAIL] Unresolved template placeholders found"
    } else {
        $results.Passed += "[CHECK] No unresolved template placeholders remain"
    }

    # Check 8: Verify any batch files have encoding safety
    $batchFiles = Get-ChildItem -Path $TargetPath -Filter "*.bat" -Recurse -ErrorAction SilentlyContinue
    foreach ($bat in $batchFiles) {
        $batContent = Get-Content $bat.FullName -Raw -ErrorAction SilentlyContinue
        if ($batContent) {
            if ($batContent -match 'PYTHONIOENCODING=utf-8') {
                $results.Passed += "[CHECK] $($bat.Name) has encoding safety"
            } else {
                $results.Warnings += "[WARN] $($bat.Name) missing PYTHONIOENCODING=utf-8"
            }
        }
    }
    
    return $results
}

function Write-ComplianceReport {
    <#
    .SYNOPSIS
        Generate compliance report with pass/fail results
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Results,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Metadata
    )
    
    $totalChecks = $Results.Passed.Count + $Results.Failed.Count
    $passRate = if ($totalChecks -gt 0) { 
        [math]::Round(($Results.Passed.Count / $totalChecks) * 100, 1) 
    } else { 0 }
    
    $statusEmoji = if ($Results.Failed.Count -eq 0) { "[PASS]" } else { "[FAIL]" }
    
    $report = @"
# Project 07 Compliance Report

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Status**: $statusEmoji  
**Pass Rate**: $passRate% ($($Results.Passed.Count)/$totalChecks checks passed)  
$(if ($Metadata) { "**Project**: $($Metadata.Name)" })
$(if ($Metadata) { "**Type**: $($Metadata.ProjectType)" })

## Summary

- **Passed**: $($Results.Passed.Count) checks
- **Failed**: $($Results.Failed.Count) checks
- **Warnings**: $($Results.Warnings.Count) items

## Passed Checks ($($Results.Passed.Count))

$(if ($Results.Passed.Count -eq 0) { 
    "No checks passed."
} else {
    ($Results.Passed | ForEach-Object { "- $_" }) -join "`n"
})

## Failed Checks ($($Results.Failed.Count))

$(if ($Results.Failed.Count -eq 0) { 
    "No failures detected. Deployment is compliant!"
} else {
    ($Results.Failed | ForEach-Object { "- $_" }) -join "`n"
})

## Warnings ($($Results.Warnings.Count))

$(if ($Results.Warnings.Count -eq 0) { 
    "No warnings."
} else {
    ($Results.Warnings | ForEach-Object { "- $_" }) -join "`n"
})

## Remediation Steps

$(if ($Results.Failed.Count -gt 0) {
    "### Critical Issues`n`n"
    $remediation = @()
    foreach ($failure in $Results.Failed) {
        if ($failure -match "Unicode violations") {
            $remediation += "- **Unicode Violations**: Replace Unicode characters with ASCII equivalents:"
            $remediation += "  - Replace checkmarks with [PASS]"
            $remediation += "  - Replace X marks with [FAIL]"
            $remediation += "  - Replace ellipsis with ..."
            $remediation += "  - See: [Encoding Safety Guide](../../copilot-instructions-template.md#critical-encoding--script-safety)"
        }
        if ($failure -match "Bootstrap First section missing") {
            $remediation += "- **Missing Bootstrap Section**: Re-run primer to restore the managed contract header from the live template."
        }
        if ($failure -match "Project-Owned Context missing") {
            $remediation += "- **Missing Project-Owned Context**: Re-run primer to generate or restore the preserved project-specific section."
        }
        if ($failure -match "Validation Pattern missing") {
            $remediation += "- **Missing Validation Pattern**: Restore the template suffix so handoff and verification guidance remain intact."
        }
    }
    ($remediation | Select-Object -Unique) -join "`n"
} else {
    "No critical issues. Deployment meets Project 07 standards."
})

## Standards Reference

- **Template**: [copilot-instructions-template.md](../../templates/copilot-instructions-template.md) v7.1.0
- **Best Practices**: [best-practices-reference.md](../../best-practices-reference.md)
- **Standards Spec**: [standards-specification.md](../../standards-specification.md)
- **Usage Guide**: [template-v2-usage-guide.md](../../template-v2-usage-guide.md)

---

*Generated by Project 07 Compliance Validator*
"@
    
    $report | Out-File $OutputPath -Encoding UTF8
}

function Write-DeploymentReport {
    <#
    .SYNOPSIS
        Generate deployment summary report
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$ExistingPart2,
        
        [Parameter(Mandatory=$false)]
        [string]$BackupPath,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SourcePath
    )
    
    $report = @"
# Project 07 Artifact Deployment Report

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Target**: $($Metadata.Name)  
**Template Version**: 7.0.0

## Deployment Summary

- **Managed Contract**: Refreshed from the live Project 07 project template
- **Project-Owned Context**: Generated from analysis or preserved from the existing file
$(if ($ExistingPart2) { "- **Existing Content**: Preserved as the Project-Owned Context block" })
$(if ($BackupPath) { "- **Backup**: Original file backed up" })

## Project Analysis

- **Type**: $($Metadata.ProjectType)
- **Components**: $($Metadata.Components -join ', ')
- **Tech Stack**: $($Metadata.TechStack -join ', ')
- **Has Existing Copilot Instructions**: $($Metadata.HasCopilotInstructions)

## Next Steps

### 1. Review Generated Content

Open ``.github/copilot-instructions.md`` and review the Project-Owned Context section:
- [ ] Update [TODO] placeholders with actual values
- [ ] Add project-specific code examples
- [ ] Document actual workflows and commands
$(if ($ExistingPart2) { "- [ ] Review preserved content in HTML comments and integrate manually" })

### 2. Customize Based on Project Type

See the live Project 07 templates in ``$SourcePath`` for the current structure and validation expectations.

### 3. Test with Copilot

Run these test scenarios:
1. Ask: "Create a new component following professional architecture"
2. Ask: "Add error handling to this function"
3. Ask: "How do I deploy this project?"
4. Ask: "What are the critical patterns in this codebase?"

### 4. Validate Completeness

``````powershell
# Check for remaining [TODO] items
Select-String -Path ".github/copilot-instructions.md" -Pattern "\[TODO\]"

# Run compliance validation
.\Apply-Project07-Artifacts.ps1 -TargetPath "." -SkipBackup
``````

## Reference Documentation

- **Template Source**: ``$SourcePath``
- **Template Directory**: ``$SourcePath``
- **Best Practices**: [best-practices-reference.md](../../best-practices-reference.md)
- **Standards**: [standards-specification.md](../../standards-specification.md)

$(if ($BackupPath) { @"
## Backup

Original file backed up to: ``$BackupPath``

To restore if needed:
``````powershell
Copy-Item "$BackupPath" ".github\copilot-instructions.md" -Force
``````
"@ })

---

*Generated by Project 07 Artifact Primer v2.0.0*
"@
    
    $report | Out-File $OutputPath -Encoding UTF8
}

#endregion

#region Main Execution with Observability

function Start-ArtifactDeployment {
    <#
    .SYNOPSIS
        Main execution with professional component architecture
    #>
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Project 07 Artifact Primer v2.0.1" -ForegroundColor Cyan
    Write-Host "  Intelligent Copilot Instructions Deployment" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Initialize professional components only for real runs so dry-run stays side-effect free.
    $collector = $null
    $session = $null
    $errorHandler = $null
    if (-not $DryRun) {
        $collector = [DebugArtifactCollectorPS]::new("artifact-deployment", $TargetPath)
        $session = [SessionManagerPS]::new("artifact-deployment", $TargetPath)
        $errorHandler = [StructuredErrorHandlerPS]::new("artifact-deployment", $TargetPath)
        $collector.CaptureState("deployment_start") | Out-Null
    }
    
    try {
        # ===================================================================
        # DISCOVER: Validate environment and analyze target
        # ===================================================================
        
        # Step 1: Validate paths
        Write-Status "Validating target path: $TargetPath" -Type Arrow
        if (-not (Test-Path $TargetPath)) {
            throw "Target path does not exist: $TargetPath"
        }
        
        $TargetPath = (Resolve-Path $TargetPath).Path
        Write-Status "Target: $TargetPath" -Type Pass
        
        if ($session) {
            $session.SaveCheckpoint("paths_validated", @{
                target_path = $TargetPath
                dry_run = $DryRun.IsPresent
            })
        }
        
        # Step 2: Find Project 07 source
        if ($collector) { $collector.CaptureState("before_source_detection") | Out-Null }
        
        if ([string]::IsNullOrWhiteSpace($SourcePath)) {
            Write-Status "Auto-detecting Project 07 artifacts..." -Type Arrow
            $SourcePath = Find-Project07Source
            
            if (-not $SourcePath) {
                throw "Could not find Project 07 artifacts. Specify -SourcePath parameter."
            }
        }
        
        Write-Status "Source: $SourcePath" -Type Pass
        
        $templatePath = Join-Path $SourcePath "copilot-instructions-template.md"
        if (-not (Test-Path $templatePath)) {
            throw "Template not found: $templatePath"
        }
        
        if ($collector) { $collector.CaptureState("after_source_detection") | Out-Null }
        if ($session) {
            $session.SaveCheckpoint("source_validated", @{
                source_path = $SourcePath
                template_path = $templatePath
            })
        }
        
        # Step 3: Analyze target project
        Write-Status "Analyzing target project..." -Type Arrow
        if ($collector) { $collector.CaptureState("before_analysis") | Out-Null }
        
        $metadata = Get-ProjectMetadata -ProjectPath $TargetPath
        
        if ($collector) { $collector.CaptureState("after_analysis") | Out-Null }
        if ($session) {
            $session.SaveCheckpoint("analysis_complete", @{
                project_name = $metadata.Name
                project_type = $metadata.ProjectType
                components = $metadata.Components
                tech_stack = $metadata.TechStack
            })
        }
        
        Write-Host ""
        Write-Status "Project Analysis:" -Type Info
        Write-Host "  Name: $($metadata.Name)"
        Write-Host "  Type: $($metadata.ProjectType)"
        Write-Host "  Components: $($metadata.Components -join ', ')"
        Write-Host "  Tech Stack: $($metadata.TechStack -join ', ')"
        Write-Host "  Has Copilot Instructions: $($metadata.HasCopilotInstructions)"
        Write-Host ""
        
        # Step 4: Check for existing content
        $existingPart2 = $null
        $backupPath = $null
        
        if ($metadata.HasCopilotInstructions) {
            Write-Status "Existing copilot-instructions.md detected" -Type Warn
            
            if ($collector) { $collector.CaptureState("before_extraction") | Out-Null }
            $existingPart2 = Extract-ExistingPart2 -CopilotInstructionsPath $metadata.ExistingCopilotPath
            if ($collector) { $collector.CaptureState("after_extraction") | Out-Null }
            
            if (-not $SkipBackup -and -not $DryRun) {
                Write-Status "Creating backup..." -Type Arrow
                $backupPath = New-BackupCopy -FilePath $metadata.ExistingCopilotPath
                Write-Status "Backup saved: $backupPath" -Type Pass
            }
        }
        
        # ===================================================================
        # PLAN: Define deployment strategy and expected outcomes
        # ===================================================================
        
        # Step 5: Generate deployment plan
        Write-Host ""
        Write-Status "Deployment Plan:" -Type Arrow
        Write-Host "  [1] Apply the managed project contract prefix from the live template"
        Write-Host "  [2] Preserve or generate the Project-Owned Context section"
        if ($existingPart2) {
            Write-Host "  [3] Reuse preserved project-specific content from the existing file"
        }
        Write-Host "  [4] Append the Validation Pattern and References suffix"
        if (-not $SkipValidation) {
            Write-Host "  [5] Validate deployment against Project 07 standards"
        }
        Write-Host ""
        
        # Step 6: Confirm or preview
        if ($DryRun) {
            Write-Status "DRY RUN MODE - No files will be modified" -Type Warn
            Write-Host ""
            Write-Host "Deployment would create/modify:"
            Write-Host "  - .github/copilot-instructions.md"
            Write-Host "  - .github/.project07-deployment-report.md"
            if (-not $SkipValidation) {
                Write-Host "  - .github/.project07-compliance-report.md"
            }
            Write-Host ""
            
            # Generate preview content - Focus on the project-owned context block
            Write-Status "Generating project-specific content preview..." -Type Arrow
            Write-Host ""
            
            $part2Content = New-ProjectSpecificPart2 -Metadata $metadata -ExistingPart2 $existingPart2
            $part2Lines = ($part2Content -split "`n").Count
            
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host " PROJECT-OWNED CONTEXT PREVIEW" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "[INFO] Managed template prefix: workspace bootstrap, project role, read order, and core rules"
            Write-Host ""
            Write-Host "[INFO] Project-Owned Context block: $part2Lines lines"
            Write-Host "        - Project Type: $($metadata.ProjectType)"
            Write-Host "        - Components: $($metadata.Components -join ', ')"
            Write-Host "        - Tech Stack: $($metadata.TechStack -join ', ')"
            Write-Host ""
            
            Write-Host "========================================" -ForegroundColor Green
            Write-Host " PROJECT-OWNED CONTEXT: GENERATED CONTENT (Full)" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            $part2Content -split "`n" | ForEach-Object { Write-Host $_ }
            Write-Host ""
            
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host " CUSTOMIZATION NEEDED" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "After deployment, update these [TODO] items in Project-Owned Context:"
            Write-Host "  1. Complete project structure tree"
            Write-Host "  2. Add setup/start/test/deploy commands"
            Write-Host "  3. Document critical code patterns specific to this project"
            Write-Host "  4. Add common troubleshooting scenarios"
            Write-Host "  5. Update architecture patterns based on actual implementation"
            Write-Host ""
            
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host " DEPLOYMENT SUMMARY" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Total file size: ~$([math]::Round(($part2Lines + 100) / 50, 1)) KB (~$($part2Lines + 100) lines)"
            Write-Host "  - Managed prefix and suffix: ~100 lines (from live template)"
            Write-Host "  - Project-Owned Context: $part2Lines lines (generated or preserved, needs customization)"
            Write-Host ""
            Write-Host "To apply these changes, run without -DryRun flag:"
            Write-Host "  .\Apply-Project07-Artifacts.ps1 -TargetPath `"$TargetPath`""
            Write-Host ""
            
            return
        }
        
        if (-not $Force) {
            $confirm = Read-Host "Proceed with deployment? (y/N)"
            if ($confirm -ne 'y' -and $confirm -ne 'Y') {
                Write-Status "Deployment cancelled by user" -Type Info
                return
            }
        }
        
        # ===================================================================
        # DO: Execute deployment with evidence collection
        # ===================================================================
        
        # Step 7: Execute deployment
        Write-Host ""
        Write-Status "Deploying artifacts..." -Type Arrow
        
        if ($collector) { $collector.CaptureState("before_deployment") | Out-Null }
        
        # Create .github directory if needed
        $githubDir = Join-Path $TargetPath ".github"
        if (-not (Test-Path $githubDir)) {
            New-Item -ItemType Directory -Path $githubDir -Force | Out-Null
            Write-Status "Created .github directory" -Type Pass
        }
        
        # Generate combined content (with debug evidence - Project 07 pattern)
        $part1Content = New-Part1Content -TemplatePath $templatePath -Metadata $metadata -DebugCollector $collector
        $part2Content = New-ProjectSpecificPart2 -Metadata $metadata -ExistingPart2 $existingPart2
        $validationContent = New-ValidationContent -TemplatePath $templatePath -Metadata $metadata
        
        # Validate content size (Project 07 pattern)
        $part1Lines = ($part1Content -split "`n").Count
        $part2Lines = ($part2Content -split "`n").Count
        $totalLines = $part1Lines + $part2Lines
        
        Write-Host ""
        Write-Status "Content Generation Summary:" -Type Info
        Write-Host "  Managed template prefix: $part1Lines lines"
        Write-Host "  Project-Owned Context: $part2Lines lines"
        Write-Host "  Validation suffix: $(($validationContent -split "`n").Count) lines"
        Write-Host "  Total: $totalLines lines"
        
        if ($part1Lines -lt 20) {
            throw "CRITICAL: Managed template prefix extraction failed - only $part1Lines lines"
        }

        if ($totalLines -lt 80) {
            Write-Status "WARNING: Total content is $totalLines lines (expected >80)" -Type Warn
        }
        Write-Host ""

        $finalContent = $part1Content.TrimEnd() + "`n`n" + $part2Content.Trim() + "`n`n" + $validationContent.Trim() + "`n"
        
        # Write copilot-instructions.md
        $outputPath = Join-Path $githubDir "copilot-instructions.md"
        [System.IO.File]::WriteAllText($outputPath, $finalContent, [System.Text.Encoding]::UTF8)
        
        if ($collector) { $collector.CaptureState("after_deployment") | Out-Null }
        
        Write-Status "Created: $outputPath" -Type Pass
        Write-Status "Size: $([math]::Round((Get-Item $outputPath).Length / 1KB, 2)) KB" -Type Info
        
        if ($session) {
            $session.SaveCheckpoint("deployment_complete", @{
                output_path = $outputPath
                file_size = (Get-Item $outputPath).Length
            })
        }
        
        # ===================================================================
        # CHECK: Verify deployment and generate reports
        # ===================================================================
        
        # Step 8: Generate deployment report
        $reportPath = Join-Path $githubDir ".project07-deployment-report.md"
        Write-DeploymentReport `
            -Metadata $metadata `
            -ExistingPart2 $existingPart2 `
            -BackupPath $backupPath `
            -OutputPath $reportPath `
            -SourcePath $SourcePath
        
        Write-Status "Deployment report: $reportPath" -Type Pass
        
        # Step 9: Validate deployment (optional)
        if (-not $SkipValidation) {
            Write-Host ""
            Write-Status "Validating deployment..." -Type Arrow
            
            if ($collector) { $collector.CaptureState("before_validation") | Out-Null }
            
            $validationResults = Test-DeploymentCompliance -TargetPath $TargetPath
            
            if ($collector) { $collector.CaptureState("after_validation") | Out-Null }
            
            # Generate compliance report
            $compliancePath = Join-Path $githubDir ".project07-compliance-report.md"
            Write-ComplianceReport `
                -Results $validationResults `
                -OutputPath $compliancePath `
                -Metadata $metadata
            
            Write-Host ""
            if ($validationResults.Failed.Count -eq 0) {
                Write-Status "Validation passed: $($validationResults.Passed.Count) checks" -Type Pass
            } else {
                Write-Status "Validation issues: $($validationResults.Failed.Count) failures" -Type Warn
            }
            
            Write-Status "Compliance report: $compliancePath" -Type Info
        }
        
        # ===================================================================
        # ACT: Record evidence and provide next steps
        # ===================================================================
        
        # Step 10: Summary
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Status "Deployment Complete!" -Type Pass
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:"
        Write-Host "  1. Open: $outputPath"
        Write-Host "  2. Review Project-Owned Context and update [TODO] items"
        Write-Host "  3. Read: $reportPath"
        if (-not $SkipValidation) {
            Write-Host "  4. Review compliance: $compliancePath"
        }
        Write-Host "  5. Test with GitHub Copilot"
        Write-Host ""
        
        # ALWAYS capture success state (Project 07 pattern)
        if ($collector) { $collector.CaptureState("deployment_success") | Out-Null }
        
        if ($session) {
            $session.SaveCheckpoint("final_state", @{
                status = "success"
                files_created = @($outputPath, $reportPath, $compliancePath)
                validation_passed = $validationResults.Failed.Count -eq 0
            })
        }
        
    } catch {
        if ($collector) { $collector.CaptureState("deployment_error") | Out-Null }

        $errorFile = $null
        if ($errorHandler) {
            $errorFile = $errorHandler.LogError($_, @{
                operation = "artifact_deployment"
                target_path = $TargetPath
                source_path = $SourcePath
                dry_run = $DryRun.IsPresent
            })
        }
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Status "Deployment Failed!" -Type Error
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        if ($collector -or $errorFile) {
            Write-Host "Debug artifacts available in:"
            if ($collector) { Write-Host "  - $($collector.DebugDir)" }
            if ($errorFile) { Write-Host "  - $errorFile" }
            Write-Host ""
        }
        
        throw
    }
}

# Execute main function
Start-ArtifactDeployment

#endregion
