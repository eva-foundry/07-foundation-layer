# EVA Foundation Automation - Quick Start

## ⚠️ IMPORTANT - LOCAL-ONLY
**All files in this automation framework are LOCAL-ONLY and excluded from Git.**

Never commit:
- `.env` files
- `output/` directory
- `.venv/` directory
- `generation-state.json`
- `*.log` files

---

## 🚀 Quick Start (3 Steps)

### Step 1: Setup Environment
```powershell
cd docs\eva-foundation\automation
.\generate.ps1 -Setup
```

### Step 2: Configure Credentials
Edit `.env` file with your Azure OpenAI credentials:
```bash
AZURE_OPENAI_ENDPOINT=https://infoasst-aoai-hccld2.openai.azure.com/
AZURE_OPENAI_API_KEY=<your-key-here>
AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o
```

### Step 3: Generate Documentation
```powershell
# Dry run first (no API calls)
.\generate.ps1 -Phase 0 -DryRun

# Generate Phase 0 for real
.\generate.ps1 -Phase 0

# Generate all phases
.\generate.ps1 -Phase all
```

---

## 📋 Common Commands

```powershell
# Setup (one-time)
.\generate.ps1 -Setup

# Generate specific phase
.\generate.ps1 -Phase 0
.\generate.ps1 -Phase 1
.\generate.ps1 -Phase 2

# Dry run (test without API calls)
.\generate.ps1 -Phase 0 -DryRun

# Skip validation (not recommended)
.\generate.ps1 -Phase 0 -SkipValidation

# Generate all phases
.\generate.ps1 -Phase all

# Resume from checkpoint
.\generate.ps1 -Phase all  # Automatically skips completed files

# Reset state (start fresh)
Remove-Item ..\generation-state.json
.\generate.ps1 -Phase all
```

---

## 📁 Output Structure

```
docs/eva-foundation/
├── automation/              # Scripts (local-only)
│   ├── .env                # Your credentials (gitignored)
│   ├── .venv/              # Python environment (gitignored)
│   ├── generate.ps1        # PowerShell launcher
│   ├── generate-docs.py    # Main Python script
│   └── validators.py       # Validation logic
├── output/                  # Generated docs (gitignored)
│   ├── 00-overview/
│   │   ├── executive-summary.md
│   │   ├── scope-in-out.md
│   │   └── glossary-acronyms.md
│   ├── 01-architecture/
│   ├── 02-platform-components/
│   ├── 03-data-and-ai/
│   ├── 04-security-and-compliance/
│   └── 05-operations-conops/
└── generation-state.json    # Progress tracker (gitignored)
```

---

## 🔍 Monitoring Progress

### Check State
```powershell
Get-Content ..\generation-state.json | ConvertFrom-Json | Format-List
```

### View Logs
```powershell
Get-Content ..\eva-foundation-generation.log -Tail 50
```

### Check Output
```powershell
Get-ChildItem ..\output -Recurse -Filter *.md
```

---

## ⚙️ Configuration

All settings are in `.env`:

```bash
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=<your-endpoint>
AZURE_OPENAI_API_KEY=<your-key>
AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# Generation
MAX_RETRIES=3              # Retry attempts per file
TEMPERATURE=0.3            # LLM temperature (0-1)
MAX_TOKENS=4000           # Max tokens per response
```

---

## 🛠️ Troubleshooting

### Issue: "Python not found"
**Solution**: Install Python 3.10+ from python.org

### Issue: "Virtual environment not found"
**Solution**: Run `.\generate.ps1 -Setup`

### Issue: "Authentication failed"
**Solution**: 
1. Check `.env` file has correct credentials
2. Verify Azure OpenAI endpoint is accessible
3. Test with: `az account show`

### Issue: "Validation failures"
**Solution**: 
1. Check logs: `Get-Content ..\eva-foundation-generation.log -Tail 50`
2. Review specific issues
3. Fix manually or let retry logic handle

### Issue: "Module not found"
**Solution**: 
```powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

---

## 📊 Validation Checks

Each generated file goes through 3-part validation:

### Part 1: YAML Front Matter
- ✅ All required fields present
- ✅ Correct format and structure

### Part 2: AI-Consumability
- ✅ Markdown tables for comparisons
- ✅ Code blocks with language tags
- ✅ No ambiguous references
- ✅ Full file paths for links

### Part 3: Requirement Traceability
- ✅ v0.2 requirement IDs present (INF01, ACC03, etc.)
- ✅ References to src-v02 source files
- ✅ Traceability section included

---

## 🔐 Security Notes

1. **Never commit `.env`** - Contains API credentials
2. **Never commit `output/`** - Review and sanitize first
3. **Review before sharing** - Contains implementation details
4. **Use separate credentials** - Don't use production keys

---

## 💡 Tips

1. **Start with dry run** - Test without API costs
2. **Generate phase by phase** - Easier to review
3. **Use state management** - Resume from failures
4. **Review warnings** - May indicate quality issues
5. **Save good outputs** - Copy to separate folder before regenerating

---

## 📞 Support

**Issues with automation**: Check logs and troubleshooting section
**Issues with content**: Review validation results
**Issues with Azure**: Verify credentials and permissions

---

## ✅ Pre-Commit Checklist

Before committing generated documentation to Git:

- [ ] Review all generated content for accuracy
- [ ] Sanitize any sensitive information
- [ ] Verify all links and references
- [ ] Check formatting and consistency
- [ ] Validate against v0.2 requirements
- [ ] Get peer review
- [ ] Copy from `output/` to proper locations
- [ ] Do NOT commit anything from `automation/` directory

---

Generated: 2026-01-14
