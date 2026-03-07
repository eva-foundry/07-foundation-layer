# EVA Foundation Documentation Generator - PowerShell Launcher
# ⚠️ LOCAL-ONLY - DO NOT COMMIT

param(
    [string]$Phase = "all",
    [switch]$DryRun = $false,
    [switch]$SkipValidation = $false,
    [switch]$Setup = $false
)

$ErrorActionPreference = "Stop"
$AutomationDir = $PSScriptRoot
$VenvDir = Join-Path $AutomationDir ".venv"
$PythonScript = Join-Path $AutomationDir "generate-docs.py"
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $AutomationDir))

# Colors
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "════════════════════════════════════════════════════════"
Write-Info " EVA Foundation Documentation Generator"
Write-Info "════════════════════════════════════════════════════════"
Write-Host ""

# Check if setup is requested
if ($Setup) {
    Write-Info "🔧 Setting up environment..."
    
    # Check Python
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Error "❌ Python not found. Please install Python 3.10 or later."
        exit 1
    }
    
    $pythonVersion = python --version
    Write-Success "✅ Found: $pythonVersion"
    
    # Create virtual environment
    if (-not (Test-Path $VenvDir)) {
        Write-Info "📦 Creating virtual environment..."
        python -m venv $VenvDir
        Write-Success "✅ Virtual environment created"
    } else {
        Write-Success "✅ Virtual environment exists"
    }
    
    # Activate and install dependencies
    Write-Info "📦 Installing dependencies..."
    $ActivateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
    & $ActivateScript
    
    $RequirementsFile = Join-Path $AutomationDir "requirements.txt"
    python -m pip install --upgrade pip -q
    python -m pip install -r $RequirementsFile -q
    
    Write-Success "✅ Dependencies installed"
    
    # Check for .env file
    $EnvFile = Join-Path $AutomationDir ".env"
    if (-not (Test-Path $EnvFile)) {
        Write-Warning "⚠️  .env file not found"
        Write-Info "📝 Creating .env from template..."
        $EnvExample = Join-Path $AutomationDir ".env.example"
        Copy-Item $EnvExample $EnvFile
        Write-Warning "⚠️  Please edit .env with your Azure OpenAI credentials"
        Write-Info "   File: $EnvFile"
    } else {
        Write-Success "✅ .env file exists"
    }
    
    Write-Host ""
    Write-Success "════════════════════════════════════════════════════════"
    Write-Success " Setup Complete!"
    Write-Success "════════════════════════════════════════════════════════"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "1. Edit .env file with your credentials"
    Write-Info "2. Run: .\generate.ps1 -Phase 0 -DryRun"
    Write-Info "3. Run: .\generate.ps1 -Phase 0"
    Write-Host ""
    exit 0
}

# Check if virtual environment exists
if (-not (Test-Path $VenvDir)) {
    Write-Error "❌ Virtual environment not found"
    Write-Info "💡 Run: .\generate.ps1 -Setup"
    exit 1
}

# Activate virtual environment
$ActivateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
& $ActivateScript

# Check for .env file
$EnvFile = Join-Path $AutomationDir ".env"
if (-not (Test-Path $EnvFile)) {
    Write-Error "❌ .env file not found"
    Write-Info "💡 Run: .\generate.ps1 -Setup"
    exit 1
}

# Build command arguments
$Args = @("--phase", $Phase)
if ($DryRun) { $Args += "--dry-run" }
if ($SkipValidation) { $Args += "--skip-validation" }

# Display configuration
Write-Info "Configuration:"
Write-Host "  Phase: $Phase" -ForegroundColor Gray
Write-Host "  Dry Run: $DryRun" -ForegroundColor Gray
Write-Host "  Skip Validation: $SkipValidation" -ForegroundColor Gray
Write-Host ""

# Run Python script
try {
    python $PythonScript @Args
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "════════════════════════════════════════════════════════"
        Write-Success " Generation Complete!"
        Write-Success "════════════════════════════════════════════════════════"
        Write-Host ""
        Write-Info "Output directory: docs\eva-foundation\output\"
        Write-Info "State file: docs\eva-foundation\generation-state.json"
        Write-Info "Log file: docs\eva-foundation\eva-foundation-generation.log"
        Write-Host ""
    } else {
        Write-Error "❌ Generation failed with exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "❌ Error running generator: $_"
    exit 1
}
