# Apply-Project07-Artifacts.ps1
# Version: 1.4.1 (February 2, 2026)
# Intelligent primer script for deploying Project 07 artifacts to any EVA project
# Self-demonstrating: Uses the same professional patterns it deploys
# See CHANGELOG.md for version history and upgrade notes
#
# ENHANCEMENTS in 1.4.1:
# - Fixed hardcoded paths after folder rename (07-copilot-instructions -> 07-foundation-layer)
# - Enhanced auto-detection with self-awareness ($PSScriptRoot)
# - Added -Diagnostic and -ValidateOnly parameters
# - Improved path detection robustness (environment variables, upward traversal)
#
# CRITICAL FIXES in 1.4.0:
# - Fixed PART 1 extraction regex to use multiline anchors (^## PART 2:)
# - Enhanced compliance validation to check implementation presence, not just names
# - Added line count validation (>1000 lines) to detect truncated extractions
# - Integrated debug evidence collection at extraction operations

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
    - Self-aware auto-detection (works from any location)
    
    Features:
    1. Analyzes target project structure
    2. Detects existing copilot-instructions.md and preserves PART 2
    3. Applies universal PART 1 patterns
    4. Generates project-specific PART 2 template with discovered content
    5. Creates backup before any changes
    6. Validates deployment against Project 07 standards
    7. Generates compliance report

.PARAMETER TargetPath
    Path to target project folder (default: current directory)

.PARAMETER SourcePath
    Path to Project 07 artifacts (default: auto-detect from EVA-JP-v1.2)

.PARAMETER DryRun
    Preview changes without applying them

.PARAMETER Force
    Skip safety prompts (use with caution)

.PARAMETER SkipBackup
    Skip backup creation (not recommended)

.PARAMETER SkipValidation
    Skip post-deployment compliance validation

.PARAMETER Diagnostic
    Show diagnostic information about path detection and exit

.PARAMETER ValidateOnly
    Validate Project 07 source detection and exit (no deployment)

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "I:\MyProject" -DryRun
    Preview what would be applied to MyProject

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -Diagnostic
    Show diagnostic information about Project 07 source detection

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -ValidateOnly
    Validate that Project 07 artifacts can be detected

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "I:\CDS-AI-Answers"
    Apply Project 07 artifacts with interactive prompts

.EXAMPLE
    .\Apply-Project07-Artifacts.ps1 -TargetPath "I:\EVA Suite" -Force
    Force apply without prompts (use with caution)

.NOTES
    Version: 1.4.1 (February 2, 2026)
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
    [switch]$SkipValidation,
    
    [Parameter(Mandatory=$false)]
    [switch]$Diagnostic,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly
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
