# Python Dependency Management - EVA Projects
## Solving the "Multi .venv and Requirements Mess"

**Problem**: ESDC internal pip repository (`aar-raa.prv/repos/pip`) often lacks required packages  
**Impact**: Repeated failed installs, multiple `.venv` folders, "ModuleNotFoundError" across all projects  
**Solution**: Offline package download pattern using elevated account or DevBox

**Last Updated**: 2026-01-30  
**Author**: Marco Framework (based on Project 14 Azure FinOps learnings)

---

## Table of Contents

1. [The Problem](#the-problem)
2. [Universal Solution Pattern](#universal-solution-pattern)
3. [Download-Offline-Packages Script Template](#download-offline-packages-script-template)
4. [Project-Specific Examples](#project-specific-examples)
5. [Virtual Environment Best Practices](#virtual-environment-best-practices)
6. [Troubleshooting](#troubleshooting)

---

## The Problem

**Scenario**: You're setting up a new EVA project (or any project with Python dependencies)

```powershell
cd I:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops
pip install -r requirements.txt
```

**What Happens**:
```
Looking in links: https://aar-raa.prv/repos/pip
ERROR: Could not find a version that satisfies the requirement azure-mgmt-costmanagement>=4.0.0
ERROR: No matching distribution found for azure-mgmt-costmanagement>=4.0.0
```

**Result**: 
- ❌ Can't install packages from ESDC internal repo
- ❌ Can't use public PyPI directly (blocked by firewall)
- ❌ Multiple failed attempts create multiple `.venv` folders
- ❌ Different Python versions create incompatible environments
- ❌ Hours wasted troubleshooting the same issue across projects

---

## Universal Solution Pattern

**Strategy**: Download packages from public PyPI on elevated machine, then install offline in restricted environment

### Phase 1: Download Packages (Elevated Account or DevBox)

**Requirements**:
- Internet access to public PyPI
- Elevated permissions OR DevBox access
- Python with pip installed

**Steps**:
1. Use `Download-Offline-Packages.ps1` script (template below)
2. Downloads `.whl` files for all packages + dependencies
3. Creates offline package cache (~10-50 MB)
4. Generates installation instructions

### Phase 2: Install from Offline Cache (Restricted Environment)

**Works in**:
- Regular ESDC workstation (no admin)
- Disconnected environments
- Virtual environments with package restrictions

**Steps**:
1. Transfer `offline-packages/` folder to project
2. Run `Install-Offline.ps1` script
3. Packages install from local `.whl` files
4. Zero network dependency

---

## Download-Offline-Packages Script Template

**Location**: Save as `scripts/Download-Offline-Packages.ps1` in each project

```powershell
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Download Python packages for offline installation

.DESCRIPTION
    Downloads packages from public PyPI as .whl files for offline installation
    in restricted environments (ESDC internal network).

.PARAMETER OutputDir
    Directory to store downloaded .whl files (default: .\offline-packages)

.PARAMETER PythonVersion
    Python version for compatibility (default: 3.10)

.EXAMPLE
    .\Download-Offline-Packages.ps1
    
.EXAMPLE
    .\Download-Offline-Packages.ps1 -OutputDir "C:\packages" -PythonVersion "3.11"

.NOTES
    Run this script on a machine WITH internet access (elevated account or DevBox).
    Then transfer the offline-packages folder to the restricted machine.
#>

param(
    [string]$OutputDir = ".\offline-packages",
    [string]$PythonVersion = "3.10"
)

# Create output directory
$OfflineDir = Join-Path $PSScriptRoot $OutputDir
if (-not (Test-Path $OfflineDir)) {
    New-Item -Path $OfflineDir -ItemType Directory -Force | Out-Null
    Write-Host "[INFO] Created output directory: $OfflineDir" -ForegroundColor Green
}

# ===================================================================
# CUSTOMIZE THIS SECTION FOR YOUR PROJECT
# ===================================================================
# List all packages from requirements.txt
$packages = @(
    "package-name>=1.0.0",
    "another-package>=2.0.0",
    "third-package>=3.0.0"
)
# ===================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Python Offline Package Downloader" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[INFO] Target Python version: $PythonVersion" -ForegroundColor Yellow
Write-Host "[INFO] Output directory: $OfflineDir" -ForegroundColor Yellow
Write-Host "[INFO] Packages to download:" -ForegroundColor Yellow
$packages | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
Write-Host ""

# Check if pip is available
try {
    $pipVersion = python -m pip --version 2>&1
    Write-Host "[PASS] pip available: $pipVersion" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] pip not found. Install Python first." -ForegroundColor Red
    exit 1
}

# Download packages
Write-Host "`n[INFO] Downloading packages (this may take 2-5 minutes)..." -ForegroundColor Yellow
Write-Host "[WARN] Temporarily bypassing enterprise pip restrictions..." -ForegroundColor Yellow

# Override enterprise pip config by setting environment variables
$env:PIP_NO_INDEX = "false"
$env:PIP_INDEX_URL = "https://pypi.org/simple/"
$env:PIP_TRUSTED_HOST = "pypi.org files.pythonhosted.org"

# Force public PyPI to bypass enterprise repo restrictions
$downloadCmd = "python -m pip download --dest `"$OfflineDir`" --only-binary=:all: --no-cache-dir " + ($packages -join " ")

Write-Host "[CMD] $downloadCmd" -ForegroundColor Gray

try {
    Invoke-Expression $downloadCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[PASS] Download complete!" -ForegroundColor Green
        
        # Count downloaded files
        $whlFiles = Get-ChildItem -Path $OfflineDir -Filter "*.whl"
        $tarFiles = Get-ChildItem -Path $OfflineDir -Filter "*.tar.gz"
        $totalFiles = $whlFiles.Count + $tarFiles.Count
        
        Write-Host "[INFO] Downloaded $totalFiles files:" -ForegroundColor Cyan
        Write-Host "  - .whl files: $($whlFiles.Count)" -ForegroundColor White
        Write-Host "  - .tar.gz files: $($tarFiles.Count)" -ForegroundColor White
        
        # Calculate total size
        $totalSize = ($whlFiles + $tarFiles | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($totalSize / 1MB, 2)
        Write-Host "  - Total size: $sizeMB MB" -ForegroundColor White
        
    } else {
        Write-Host "`n[FAIL] Download failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n[FAIL] Error during download: $_" -ForegroundColor Red
    exit 1
}

# Generate installation instructions
$instructionsFile = Join-Path $OfflineDir "INSTALLATION-INSTRUCTIONS.txt"
$instructions = @"
========================================
OFFLINE INSTALLATION INSTRUCTIONS
========================================

1. TRANSFER FILES
   Copy the entire 'offline-packages' folder to the restricted machine.

2. INSTALL PACKAGES
   Open PowerShell in the offline-packages directory and run:

   # Option A: Install all packages at once
   pip install --no-index --find-links . package-name another-package third-package

   # Option B: Install from requirements.txt (if available)
   pip install --no-index --find-links . -r ..\requirements.txt

3. VERIFY INSTALLATION
   python -c "import package_name; print('Success!')"

4. ACTIVATE VIRTUAL ENVIRONMENT (if using)
   .\.venv\Scripts\Activate.ps1
   pip install --no-index --find-links offline-packages -r requirements.txt

========================================
TROUBLESHOOTING
========================================

Issue: "Could not find a version that satisfies the requirement"
Solution: Ensure Python version matches (this package was downloaded for Python $PythonVersion)

Issue: "Access denied"
Solution: Run PowerShell as Administrator or use --user flag:
          pip install --user --no-index --find-links . package-name

Issue: "No module named 'package_name'"
Solution: Activate virtual environment first:
          .\.venv\Scripts\Activate.ps1

========================================
PACKAGE CONTENTS
========================================

Downloaded on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Python version: $PythonVersion
Total files: $totalFiles
Total size: $sizeMB MB

========================================
"@

Set-Content -Path $instructionsFile -Value $instructions -Encoding UTF8
Write-Host "`n[INFO] Installation instructions saved to:" -ForegroundColor Green
Write-Host "       $instructionsFile" -ForegroundColor White

# Create a simple installation script
$installScriptFile = Join-Path $OfflineDir "Install-Offline.ps1"
$installScript = @"
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install packages from offline cache
#>

`$ErrorActionPreference = "Stop"

Write-Host "`n[INFO] Installing packages from offline cache..." -ForegroundColor Yellow

try {
    # Install packages (customize package names)
    pip install --no-index --find-links . ``
        package-name ``
        another-package ``
        third-package

    if (`$LASTEXITCODE -eq 0) {
        Write-Host "`n[PASS] Installation complete!" -ForegroundColor Green
    } else {
        Write-Host "`n[FAIL] Installation failed" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n[FAIL] Error: `$_" -ForegroundColor Red
    exit 1
}
"@

Set-Content -Path $installScriptFile -Value $installScript -Encoding UTF8
Write-Host "[INFO] Quick install script created:" -ForegroundColor Green
Write-Host "       $installScriptFile" -ForegroundColor White

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DOWNLOAD COMPLETE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[NEXT STEPS]" -ForegroundColor Yellow
Write-Host "1. Transfer folder to restricted machine:" -ForegroundColor White
Write-Host "   $OfflineDir" -ForegroundColor Gray
Write-Host ""
Write-Host "2. On restricted machine, run:" -ForegroundColor White
Write-Host "   cd offline-packages" -ForegroundColor Gray
Write-Host "   .\Install-Offline.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Verify installation:" -ForegroundColor White
Write-Host "   python -c `"import package_name; print('Success!')`"" -ForegroundColor Gray
Write-Host ""

Write-Host "[INFO] See INSTALLATION-INSTRUCTIONS.txt for detailed steps" -ForegroundColor Cyan
Write-Host ""
```

---

## Project-Specific Examples

### Example 1: Project 14 (Azure FinOps)

**Location**: `I:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops\scripts\Download-AzureSDK-Offline.ps1`

**Packages**:
```powershell
$packages = @(
    "azure-mgmt-costmanagement>=4.0.0",
    "azure-mgmt-resource>=23.0.0",
    "azure-identity>=1.15.0",
    "pandas>=2.0.0"
)
```

**Usage**:
```powershell
# On elevated account or DevBox
cd I:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops\scripts
.\Download-AzureSDK-Offline.ps1

# On restricted workstation
cd offline-packages
.\Install-Offline.ps1

# Verify
python -c "import azure.mgmt.costmanagement; print('[PASS] Azure SDK ready')"
```

**Result**: 25 packages, 29.92 MB, <2 minutes download time

### Example 2: Project 06 (JP Automation)

**Packages**:
```powershell
$packages = @(
    "playwright>=1.40.0",
    "pandas>=2.0.0",
    "requests>=2.31.0",
    "pytest>=7.4.0"
)
```

**Special Consideration**: Playwright requires browser installation after package install:
```powershell
python -m playwright install chromium
```

### Example 3: EVA-JP-v1.2 (RAG System)

**Packages**:
```powershell
$packages = @(
    "quart>=0.19.0",
    "azure-search-documents>=11.4.0",
    "azure-storage-blob>=12.19.0",
    "openai>=1.3.0",
    "aiohttp>=3.9.0"
)
```

---

## Virtual Environment Best Practices

### Pattern 1: One .venv Per Project Root

**DO THIS**:
```
EVA-JP-v1.2/
├── .venv/                           # ✅ Single venv at root
├── app/backend/
├── app/frontend/
└── docs/eva-foundation/projects/
    ├── 14-az-finops/
    │   └── scripts/
    └── 23-ei-dsst-rewrite/
        └── scripts/
```

**DON'T DO THIS**:
```
EVA-JP-v1.2/
├── .venv/                           # ❌ Multiple venvs
├── app/backend/.venv/               # ❌ Duplicate
├── docs/eva-foundation/projects/
    ├── 14-az-finops/.venv/          # ❌ Isolated
    └── 23-ei-dsst-rewrite/.venv/    # ❌ Wasted space
```

### Pattern 2: Project-Specific .venv (When Needed)

**When to use**: Project has unique dependencies incompatible with main .venv

**Example**: Project 14 needs Azure SDK, EVA-JP-v1.2 needs RAG libraries

```
14-az-finops/
├── .venv/                           # ✅ Project-specific for Azure SDK
├── scripts/
│   ├── extract_costs_sdk.py
│   └── Download-AzureSDK-Offline.ps1
└── offline-packages/                # ✅ Offline cache for portability
```

**Activation**:
```powershell
cd I:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops
.\.venv\Scripts\Activate.ps1
python scripts\extract_costs_sdk.py
```

### Pattern 3: Offline Package Cache (Portable)

**Best Practice**: Keep `offline-packages/` folder alongside `.venv` for reproducibility

**Structure**:
```
project/
├── .venv/                           # Virtual environment (gitignored)
├── offline-packages/                # Offline cache (can commit or gitignore)
│   ├── *.whl                        # All dependency wheels
│   ├── Install-Offline.ps1          # Installation script
│   └── INSTALLATION-INSTRUCTIONS.txt
├── scripts/
│   └── Download-Offline-Packages.ps1
└── requirements.txt
```

**Benefits**:
- ✅ Reproducible: Anyone can recreate .venv from offline-packages
- ✅ Portable: Transfer to DevBox/restricted machine
- ✅ Version-locked: Exact versions preserved as .whl files
- ✅ Fast: No network dependency for installation

### Pattern 4: .gitignore Configuration

```gitignore
# Python
.venv/
*.pyc
__pycache__/

# Optional: Exclude offline packages if large (>50 MB)
# offline-packages/*.whl

# Keep installation scripts
!offline-packages/Install-Offline.ps1
!offline-packages/INSTALLATION-INSTRUCTIONS.txt
```

---

## Troubleshooting

### Issue 1: "pip download" Fails with SSL Certificate Error

**Symptom**:
```
SSLError: HTTPSConnectionPool(host='files.pythonhosted.org', port=443)
```

**Solution**: Add certificate environment variable
```powershell
$env:PIP_CERT = "C:\ProgramData\Anaconda3\govcan.cer"
python -m pip download --dest offline-packages azure-mgmt-costmanagement
```

**Alternative**: Use `--trusted-host` flag
```powershell
python -m pip download --dest offline-packages --trusted-host pypi.org --trusted-host files.pythonhosted.org azure-mgmt-costmanagement
```

### Issue 2: "Bearer token authentication is not permitted for non-TLS protected URLs"

**Symptom**: Packages install correctly but Azure SDK fails with non-HTTPS error

**Cause**: Enterprise proxy redirecting HTTPS to HTTP

**Solution**: Check Azure SDK endpoint configuration
```python
# In your script
from azure.identity import AzureCliCredential
from azure.mgmt.costmanagement import CostManagementClient

# Ensure using HTTPS
credential = AzureCliCredential()
client = CostManagementClient(
    credential=credential,
    base_url="https://management.azure.com"  # Explicit HTTPS
)
```

### Issue 3: Multiple Python Versions Installed

**Symptom**: 
```powershell
python --version  # Returns 3.10.5
pip --version     # Shows Python 3.13.5
```

**Cause**: Multiple Python installations (Anaconda, python.org, Windows Store)

**Solution**: Use `python -m pip` consistently
```powershell
# DON'T: Use standalone pip command
pip install package-name

# DO: Use python -m pip to match Python version
python -m pip install package-name

# DO: Verify version match
python --version
python -m pip --version
```

### Issue 4: "ModuleNotFoundError" After Successful Install

**Symptom**:
```powershell
pip install azure-mgmt-costmanagement  # Installs successfully
python -c "import azure.mgmt.costmanagement"  # ModuleNotFoundError
```

**Cause**: Package installed in different Python environment

**Solution**: Use virtual environment consistently
```powershell
# Create venv
python -m venv .venv

# Activate (CRITICAL - do this every time)
.\.venv\Scripts\Activate.ps1

# Install in venv
pip install -r requirements.txt

# Verify venv active
python -c "import sys; print(sys.prefix)"  # Should show .venv path
```

### Issue 5: "Access Denied" During pip install

**Symptom**:
```
ERROR: Could not install packages due to an OSError: [WinError 5] Access is denied
```

**Solution 1**: Install to user directory (no admin required)
```powershell
pip install --user package-name
```

**Solution 2**: Use virtual environment (recommended)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install package-name  # Installs in .venv, no admin needed
```

**Solution 3**: Run PowerShell as Administrator (last resort)

---

## Quick Reference Commands

### Create Virtual Environment
```powershell
python -m venv .venv
```

### Activate Virtual Environment
```powershell
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Windows CMD
.venv\Scripts\activate.bat

# Linux/Mac
source .venv/bin/activate
```

### Download Packages Offline
```powershell
# From elevated account or DevBox
.\scripts\Download-Offline-Packages.ps1

# Output: offline-packages/ folder with .whl files
```

### Install from Offline Cache
```powershell
# On restricted workstation
cd offline-packages
.\Install-Offline.ps1

# Or manually
pip install --no-index --find-links . -r ../requirements.txt
```

### Verify Installation
```powershell
python -c "import package_name; print('[PASS] Package working')"
```

### Deactivate Virtual Environment
```powershell
deactivate
```

---

## Integration with Copilot Instructions

**Add to PART 1 of all project copilot-instructions.md**:

```markdown
### Python Dependency Management

**Pattern**: Offline package download for ESDC restricted environments

**Problem**: ESDC internal pip repository lacks many packages  
**Solution**: Download from public PyPI on elevated machine, install offline

**Script Location**: `scripts/Download-Offline-Packages.ps1`

**Quick Commands**:
```powershell
# On elevated account/DevBox (one-time)
.\scripts\Download-Offline-Packages.ps1

# On restricted workstation (repeatable)
cd offline-packages
.\Install-Offline.ps1

# Verify
python -c "import package_name; print('Success!')"
```

**See**: [Python Dependency Management Guide](../../eva-foundation/best-practices/PYTHON-DEPENDENCY-MANAGEMENT.md)
```

---

## Maintenance

**When to Update This Document**:
- New package installation pattern discovered
- Enterprise pip repository changes
- New Python version introduces breaking changes
- Additional troubleshooting scenarios identified

**Version History**:
- **2026-01-30**: Initial version based on Project 14 (Azure FinOps) learnings
- Future updates tracked in git commit history

---

## Related Documentation

- [Workspace Housekeeping Principles](../workspace-notes/WORKSPACE-ORGANIZATION-ANALYSIS.md)
- [Professional Component Architecture](../projects/07-foundation-layer/02-design/best-practices-reference.md)
- [Project 14 - Azure FinOps README](../projects/14-az-finops/README.md)

---

**For questions or updates, contact**: Marco Presta (marco.presta@hrsdc-rhdcc.gc.ca)
