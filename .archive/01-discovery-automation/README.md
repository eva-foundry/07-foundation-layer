---
**⚠️ DEPRECATED - DO NOT USE**

This directory has been migrated to **Project 01**:  
`docs/eva-foundation/projects/01-documentation-generator/`

**Migration Date**: January 15, 2026

Please use the new location for all future work. This directory is kept only for reference and will be removed in a future release.

See: [projects/01-documentation-generator/PLAN.md](../projects/01-documentation-generator/PLAN.md) for migration details.

---

# EVA Foundation Documentation Generator

## ⚠️ LOCAL-ONLY - DO NOT COMMIT

This automation framework is for **local use only** and should **never be committed to Git**.

## Prerequisites

1. Python 3.10+
2. Azure OpenAI access (infoasst-aoai-hccld2)
3. Valid Azure credentials

## Setup

```powershell
# Create virtual environment
cd docs\eva-foundation\automation
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Configure environment
# Copy .env.example to .env and edit with your credentials
Copy-Item .env.example .env
# Edit .env with your Azure OpenAI credentials
```

## Usage

### Generate All Phases
```powershell
python generate-docs.py --phase all
```

### Generate Specific Phase
```powershell
python generate-docs.py --phase 0
python generate-docs.py --phase 1
```

### Dry Run (No API Calls)
```powershell
python generate-docs.py --phase 0 --dry-run
```

### Skip Validation (Not Recommended)
```powershell
python generate-docs.py --phase 0 --skip-validation
```

### Resume from Checkpoint
```powershell
# Automatically resumes from last completed file
python generate-docs.py --phase all
```

## Output

Generated files are saved to: `docs/eva-foundation/output/`

## State Management

Progress is tracked in: `docs/eva-foundation/generation-state.json`

To reset and start fresh:
```powershell
Remove-Item ..\generation-state.json
```

## Logs

All operations logged to: `eva-foundation-generation.log`

## Troubleshooting

**Issue**: `ModuleNotFoundError: No module named 'langchain'`
**Solution**: Activate virtual environment and run `pip install -r requirements.txt`

**Issue**: `Authentication failed`
**Solution**: Update `.env` with valid Azure OpenAI credentials

**Issue**: Validation failures
**Solution**: Check `eva-foundation-generation.log` for specific issues

## Safety Features

- ✅ All output stays local (not committed to Git)
- ✅ State tracking for resume capability
- ✅ 3-part validation per file
- ✅ Dry run mode for testing
- ✅ Detailed logging

## Important Notes

1. **Never commit automation files** - They're excluded in `.gitignore`
2. **Review all generated content** before committing to repository
3. **Sanitize output** before sharing with teams
4. **Keep .env secure** - Contains API credentials
