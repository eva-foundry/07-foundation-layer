# EVA Foundation Automation - Pre-Flight Check
# Validates all files before execution

param(
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "EVA Foundation Automation - Pre-Flight Check" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$checks = @()
$passed = 0
$failed = 0

# Check 1: Python version
Write-Host "[1/10] Checking Python version..." -NoNewline
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -ge 3 -and $minor -ge 10) {
            Write-Host " ✅" -ForegroundColor Green
            $passed++
            if ($Verbose) { Write-Host "   $pythonVersion" -ForegroundColor Gray }
        } else {
            Write-Host " ❌" -ForegroundColor Red
            Write-Host "   Python 3.10+ required, found $pythonVersion" -ForegroundColor Red
            $failed++
        }
    }
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Python not found. Install Python 3.10+: https://python.org" -ForegroundColor Red
    $failed++
}

# Check 2: Required Python files exist
Write-Host "[2/10] Checking Python files..." -NoNewline
$requiredFiles = @("generate-docs.py", "validators.py", "evidence.py", "test_generator.py")
$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}
if ($missingFiles.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Missing files: $($missingFiles -join ', ')" -ForegroundColor Red
    $failed++
}

# Check 3: PowerShell scripts exist
Write-Host "[3/10] Checking PowerShell scripts..." -NoNewline
$requiredScripts = @("generate.ps1", "run-tests.ps1")
$missingScripts = @()
foreach ($script in $requiredScripts) {
    if (-not (Test-Path $script)) {
        $missingScripts += $script
    }
}
if ($missingScripts.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Missing scripts: $($missingScripts -join ', ')" -ForegroundColor Red
    $failed++
}

# Check 4: Config files exist
Write-Host "[4/10] Checking config files..." -NoNewline
$requiredConfigs = @("requirements.txt", "pytest.ini", ".coveragerc", ".env.example")
$missingConfigs = @()
foreach ($config in $requiredConfigs) {
    if (-not (Test-Path $config)) {
        $missingConfigs += $config
    }
}
if ($missingConfigs.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Missing configs: $($missingConfigs -join ', ')" -ForegroundColor Red
    $failed++
}

# Check 5: Virtual environment
Write-Host "[5/10] Checking virtual environment..." -NoNewline
if (Test-Path ".venv") {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   Virtual environment not found. Run: .\generate.ps1 -Setup" -ForegroundColor Yellow
}

# Check 6: .env file
Write-Host "[6/10] Checking .env file..." -NoNewline
if (Test-Path ".env") {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
    
    # Check for required variables
    $envContent = Get-Content ".env" -Raw
    $requiredVars = @("AZURE_OPENAI_ENDPOINT", "AZURE_OPENAI_API_KEY", "AZURE_OPENAI_DEPLOYMENT")
    $missingVars = @()
    foreach ($var in $requiredVars) {
        if ($envContent -notmatch $var) {
            $missingVars += $var
        }
    }
    if ($missingVars.Count -gt 0 -and $Verbose) {
        Write-Host "   ⚠️ Missing variables: $($missingVars -join ', ')" -ForegroundColor Yellow
    }
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   .env file not found. Run: .\generate.ps1 -Setup" -ForegroundColor Yellow
}

# Check 7: Framework files exist
Write-Host "[7/10] Checking framework files..." -NoNewline
$frameworkFiles = @(
    "../README.,md",
    "../_marco-workflow.md",
    "../_marco-filegen-1-order.md",
    "../_marco-filegen-2-oneliner.md"
)
$missingFramework = @()
foreach ($file in $frameworkFiles) {
    if (-not (Test-Path $file)) {
        $missingFramework += $file
    }
}
if ($missingFramework.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Missing framework files: $($missingFramework -join ', ')" -ForegroundColor Red
    $failed++
}

# Check 8: v0.2 source files exist
Write-Host "[8/10] Checking v0.2 source files..." -NoNewline
$v02Dir = "../src-v02"
if (Test-Path $v02Dir) {
    $v02Files = Get-ChildItem "$v02Dir\*.md" -ErrorAction SilentlyContinue
    if ($v02Files.Count -ge 7) {
        Write-Host " ✅" -ForegroundColor Green
        $passed++
        if ($Verbose) { Write-Host "   Found $($v02Files.Count) source files" -ForegroundColor Gray }
    } else {
        Write-Host " ⚠️" -ForegroundColor Yellow
        Write-Host "   Only $($v02Files.Count) source files found (expected 7+)" -ForegroundColor Yellow
    }
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "   Directory not found: $v02Dir" -ForegroundColor Red
    $failed++
}

# Check 9: Output directory structure
Write-Host "[9/10] Checking output directories..." -NoNewline
$outputDir = "../output"
$evidenceDir = "../evidence"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}
if (-not (Test-Path $evidenceDir)) {
    New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null
}
Write-Host " ✅" -ForegroundColor Green
$passed++

# Check 10: .gitignore protection
Write-Host "[10/10] Checking .gitignore protection..." -NoNewline
$gitignorePath = "../../.gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    if ($gitignoreContent -match "eva-foundation/automation/.env" -and 
        $gitignoreContent -match "eva-foundation/output/") {
        Write-Host " ✅" -ForegroundColor Green
        $passed++
        if ($Verbose) { Write-Host "   Git protection verified" -ForegroundColor Gray }
    } else {
        Write-Host " ⚠️" -ForegroundColor Yellow
        Write-Host "   .gitignore may not have complete protection" -ForegroundColor Yellow
    }
} else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    Write-Host "   .gitignore not found at $gitignorePath" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "   Passed: $passed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "   Failed: $failed" -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

if ($failed -eq 0) {
    Write-Host "✅ All critical checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "   1. .\generate.ps1 -Setup      (if .venv not found)" -ForegroundColor Gray
    Write-Host "   2. Edit .env                  (configure Azure OpenAI)" -ForegroundColor Gray
    Write-Host "   3. .\run-tests.ps1            (validate framework)" -ForegroundColor Gray
    Write-Host "   4. .\generate.ps1 -Phase 0    (generate Phase 0)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "❌ Some checks failed. Fix issues above before proceeding." -ForegroundColor Red
    Write-Host ""
    exit 1
}
