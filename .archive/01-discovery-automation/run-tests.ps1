# EVA Foundation Automation - Test Runner
# Runs unit tests with coverage reporting

param(
    [switch]$Coverage = $true,
    [switch]$Verbose = $false,
    [switch]$FailFast = $false,
    [string]$TestFile = "test_generator.py"
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "EVA Foundation Automation - Test Runner" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path ".venv")) {
    Write-Host "❌ Virtual environment not found. Run: .\generate.ps1 -Setup" -ForegroundColor Red
    exit 1
}

# Activate virtual environment
Write-Host "📦 Activating virtual environment..." -ForegroundColor Yellow
& ".\.venv\Scripts\Activate.ps1"

# Check if pytest is installed
$pytestInstalled = & python -c "import pytest; print('OK')" 2>$null
if ($pytestInstalled -ne "OK") {
    Write-Host "❌ pytest not installed. Run: .\generate.ps1 -Setup" -ForegroundColor Red
    exit 1
}

# Build pytest arguments
$pytestArgs = @($TestFile, "-v")

if ($Coverage) {
    $pytestArgs += "--cov=."
    $pytestArgs += "--cov-report=term-missing"
    $pytestArgs += "--cov-report=html"
    $pytestArgs += "--cov-report=json"
}

if ($Verbose) {
    $pytestArgs += "-vv"
}

if ($FailFast) {
    $pytestArgs += "-x"
}

# Run tests
Write-Host ""
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
Write-Host "Command: pytest $($pytestArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

& python -m pytest @pytestArgs

$exitCode = $LASTEXITCODE

# Display results
Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    
    if ($Coverage) {
        Write-Host ""
        Write-Host "📊 Coverage reports generated:" -ForegroundColor Cyan
        Write-Host "   - HTML: htmlcov/index.html" -ForegroundColor Gray
        Write-Host "   - JSON: coverage.json" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Open HTML report: start htmlcov/index.html" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Tests failed!" -ForegroundColor Red
    exit $exitCode
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
