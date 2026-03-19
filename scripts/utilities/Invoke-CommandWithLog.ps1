#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Universal Command Wrapper with Log File Pattern
    
.DESCRIPTION
    Solves terminal output capture bug in AI agent sessions.
    
    Pattern:
    1. Takes command + optional search pattern
    2. Runs command with ALL output redirected to uniquely-named log file
    3. Knows exact log file location (no searching)
    4. Echoes back what you're looking for
    5. Returns structured results
    
    Location: 07-foundation-layer/scripts/Invoke-CommandWithLog.ps1
    Version: 1.0.0
    Created: 2026-02-28
    
.PARAMETER Command
    The command to execute (PowerShell expression or external executable)
    
.PARAMETER SearchPattern
    Optional regex pattern to extract from output
    
.PARAMETER Label
    Optional label for log file (default: "cmd")
    
.PARAMETER WorkingDirectory
    Optional working directory (default: current directory)
    
.PARAMETER ReturnFullLog
    Return entire log content instead of just matched lines
    
.PARAMETER KeepLog
    Keep log file after execution (default: auto-cleanup after 1 hour)
    
.EXAMPLE
    Invoke-CommandWithLog -Command "pytest services/ -x -q" -SearchPattern "passed|failed"
    Runs pytest, returns summary line
    
.EXAMPLE
    Invoke-CommandWithLog -Command "az boards work-item show --id 2978" -SearchPattern "IterationPath"
    Queries ADO, returns iteration path
    
.EXAMPLE
    $result = Invoke-CommandWithLog -Command "C:\eva-foundry\.venv\Scripts\python.exe check.py" -ReturnFullLog
    Runs Python script, returns all output
    
.OUTPUTS
    PSCustomObject with:
    - Command: Original command
    - LogFile: Full path to log file
    - ExitCode: Process exit code
    - Output: Matched lines (or full log if -ReturnFullLog)
    - Duration: Execution time in seconds
    - Timestamp: ISO 8601 timestamp
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,
    
    [Parameter(Mandatory = $false)]
    [string]$SearchPattern,
    
    [Parameter(Mandatory = $false)]
    [string]$Label = "cmd",
    
    [Parameter(Mandatory = $false)]
    [string]$WorkingDirectory = (Get-Location).Path,
    
    [Parameter(Mandatory = $false)]
    [switch]$ReturnFullLog,
    
    [Parameter(Mandatory = $false)]
    [switch]$KeepLog
)

$ErrorActionPreference = "Stop"

# Generate unique log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
$logDir = Join-Path $env:TEMP "eva-command-logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$logFile = Join-Path $logDir "${Label}_${timestamp}.log"
$startTime = Get-Date

try {
    # Write header to log
    @"
=== COMMAND LOG ===
Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Command: $Command
WorkingDirectory: $WorkingDirectory
Label: $Label
==================

"@ | Out-File -FilePath $logFile -Encoding UTF8

    # Execute command with output redirection
    Push-Location $WorkingDirectory
    
    $output = $null
    $exitCode = 0
    
    try {
        # Execute and capture ALL output (stdout + stderr)
        $output = Invoke-Expression $Command 2>&1
        $exitCode = $LASTEXITCODE
        
        # Write output to log
        $output | Out-File -FilePath $logFile -Append -Encoding UTF8
        
    } catch {
        $exitCode = 1
        $errorMsg = "ERROR: $_`n$($_.ScriptStackTrace)"
        $errorMsg | Out-File -FilePath $logFile -Append -Encoding UTF8
        throw
    } finally {
        Pop-Location
    }
    
    # Write footer
    @"

==================
Exit Code: $exitCode
Duration: $((Get-Date) - $startTime).TotalSeconds seconds
==================
"@ | Out-File -FilePath $logFile -Append -Encoding UTF8

    # Read log content
    $logContent = Get-Content -Path $logFile -Raw
    
    # Extract what user is looking for
    $result = if ($ReturnFullLog) {
        $logContent
    } elseif ($SearchPattern) {
        $logContent -split "`n" | Select-String -Pattern $SearchPattern
    } else {
        # Return last 20 lines if no pattern specified
        ($logContent -split "`n") | Select-Object -Last 20
    }
    
    # Cleanup old logs (older than 1 hour) unless -KeepLog
    if (-not $KeepLog) {
        Get-ChildItem $logDir -File |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    
    # Return structured result
    [PSCustomObject]@{
        Command      = $Command
        LogFile      = $logFile
        ExitCode     = $exitCode
        Output       = $result
        Duration     = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
        Timestamp    = (Get-Date).ToString("o")
        Success      = ($exitCode -eq 0)
    }
    
} catch {
    Write-Error "Command execution failed: $_"
    
    # Return error result
    [PSCustomObject]@{
        Command      = $Command
        LogFile      = $logFile
        ExitCode     = 1
        Output       = $_.Exception.Message
        Duration     = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
        Timestamp    = (Get-Date).ToString("o")
        Success      = $false
        Error        = $_
    }
}
