# Copilot Instructions Template v2.1.0 - Usage Guide

**Template Version**: 2.1.0  
**Guide Created**: January 29, 2026  
**Guide Updated**: January 30, 2026  
**Author**: Project 07 - Copilot Instructions & Standards Baseline

---

## Overview

This guide explains how to use the copilot-instructions-template.md v2.1.0 to create production-ready GitHub Copilot instructions for any EVA project. The template contains 1,902 lines of battle-tested patterns from EVA-JP-v1.2, with AI-instructional placeholders and 11 project-specific categories.

---

## Quick Start

### 5-Step Process

1. **Copy template** to your project's `.github/` directory
2. **Replace all placeholders** with project-specific values
3. **Customize Part 2** based on your project type
4. **Validate** against quality gates
5. **Test** with actual Copilot usage

---

## Placeholder Reference

### Required Placeholders

All placeholders use `{UPPERCASE_WITH_UNDERSCORES}` format:

#### Project Identity
- `{PROJECT_NAME}` - Project identifier (e.g., "EVA-JP-v1.2", "CDS-AI-Answers")
- `{PROJECT_TYPE}` - System type (e.g., "RAG System", "Automation", "API", "Data Pipeline")
- `{PROJECT_DESCRIPTION}` - Brief system description (1-2 sentences)
- `{SOURCE_PATH}` - Path to complete working system

#### Azure Configuration (if applicable)
- `{AZURE_ACCOUNT_DETAILS}` - Azure subscription information
- `{PROFESSIONAL_EMAIL}` - Professional account email
- `{PERSONAL_SUBSCRIPTION_NAME}` - Personal/sandbox subscription name
- `{PERSONAL_SUBSCRIPTION_ID}` - Personal subscription GUID
- `{DEV_SUBSCRIPTION_NAME}` - Development subscription name
- `{DEV_SUBSCRIPTION_ID}` - Development subscription GUID
- `{PROD_SUBSCRIPTION_NAME}` - Production subscription name
- `{PROD_SUBSCRIPTION_ID}` - Production subscription GUID
- `{TENANT_ID}` - Azure AD tenant GUID
- `{AZURE_OPENAI_ENDPOINT}` - Azure OpenAI endpoint URL

#### Components & Architecture
- `{COMPONENT_1_NAME}` - First major component name
- `{COMPONENT_1_PATH}` - Path to component 1
- `{COMPONENT_1_DESCRIPTION}` - What component 1 does
- `{COMPONENT_2_NAME}` - Second component name (repeat pattern)
- `{CRITICAL_PATTERN_DESCRIPTION}` - Key architectural pattern

#### Development Workflows
- `{COMPONENT_1_START_COMMAND}` - Command to start component 1
- `{RESTART_COMMAND}` - Quick restart command
- `{TEST_COMMAND}` - Test execution command
- `{DEPLOY_COMMAND_1}` - Primary deployment command

#### Configuration Files
- `{BACKEND_CONFIG_FILE}` - Path to backend config
- `{ENV_VAR_1}` - Environment variable name (repeat as needed)

#### Testing
- `{TEST_TYPE_1}` - Test category (e.g., "Functional Tests")
- `{TEST_PATH_1}` - Path to test files
- `{TEST_COMMAND_1}` - Test execution command

#### Troubleshooting
- `{ISSUE_1_NAME}` - Common issue name
- `{ISSUE_1_SYMPTOM}` - How issue manifests
- `{ISSUE_1_CAUSE}` - Root cause explanation
- `{ISSUE_1_SOLUTION}` - Resolution steps

---

## Step-by-Step Usage

### Step 1: Copy Template

```powershell
# Copy template to your project
Copy-Item "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md" `
          "I:\YourProject\.github\copilot-instructions.md"
```

### Step 2: Replace Placeholders

#### Using VS Code Find & Replace

1. Open copilot-instructions.md in VS Code
2. Press `Ctrl+H` to open Find & Replace
3. Enable regex mode (icon: `.*`)
4. Find: `\{([A-Z_]+)\}`
5. Review each match and replace with actual values

#### Using PowerShell Script

```powershell
# Create replacement script
$replacements = @{
    '{PROJECT_NAME}' = 'YourProject'
    '{PROJECT_TYPE}' = 'RAG System'
    '{PROJECT_DESCRIPTION}' = 'Document Q&A system with Azure OpenAI'
    '{PROFESSIONAL_EMAIL}' = 'your.email@company.com'
    # Add all your replacements...
}

$file = "I:\YourProject\.github\copilot-instructions.md"
$content = Get-Content $file -Raw

foreach ($key in $replacements.Keys) {
    $content = $content -replace [regex]::Escape($key), $replacements[$key]
}

Set-Content $file $content
```

### Step 3: Customize Part 2

#### For RAG Systems

Keep these sections:
- Architecture Overview (customize with your RAG components)
- Critical Code Patterns (add RAG-specific patterns)
- Azure Service Dependencies (list your Azure resources)
- Performance Optimization (RAG-specific optimizations)

Add these sections:
- Document Processing Pipeline
- Embedding Generation Strategy
- Vector Search Configuration
- Retrieval Quality Metrics

#### For Automation Systems

Keep these sections:
- Development Workflows
- Evidence Collection (critical for automation)
- Session Management (for long-running operations)
- Troubleshooting

Add these sections:
- Browser Automation Patterns
- Retry Logic with Exponential Backoff
- Data Extraction Strategies
- Validation Rules

#### For API Systems

Keep these sections:
- Architecture Overview
- Critical Code Patterns
- Testing
- Performance Optimization

Add these sections:
- API Endpoint Documentation
- Request/Response Schemas
- Rate Limiting Strategy
- Error Response Formats

#### For Data Pipelines

Keep these sections:
- Architecture Overview
- Azure Service Dependencies (especially Functions, Blob Storage)
- CI/CD Pipeline

Add these sections:
- Event Trigger Configuration
- Pipeline Monitoring
- Data Validation Rules
- Idempotency Guarantees

### Step 4: Validate Against Quality Gates

#### Pre-Deployment Checklist

```markdown
- [ ] All `{PLACEHOLDER}` values replaced
- [ ] No Unicode characters in code examples (✓ → [PASS])
- [ ] Project-specific examples added to Part 2
- [ ] Azure subscription IDs updated (if applicable)
- [ ] All component paths verified
- [ ] Test commands validated
- [ ] Deployment commands tested
- [ ] Troubleshooting section populated with real issues
```

#### Content Validation

Run these checks:

```powershell
# Check for remaining placeholders
Select-String -Path "I:\YourProject\.github\copilot-instructions.md" -Pattern "\{[A-Z_]+\}"

# Check for Unicode characters
Select-String -Path "I:\YourProject\.github\copilot-instructions.md" -Pattern "[^\x00-\x7F]"

# Verify file size (should be 800-1,500 lines)
(Get-Content "I:\YourProject\.github\copilot-instructions.md").Count
```

### Step 5: Test with Copilot

#### Test Scenarios

1. **Ask for Component Creation**:
   - "Create a new component following professional architecture"
   - Verify: Copilot generates DebugArtifactCollector, SessionManager, etc.

2. **Ask for Error Handling**:
   - "Add error handling to this function"
   - Verify: Copilot uses ASCII-only output, structured logging

3. **Ask for Batch Script**:
   - "Create a Windows batch file to run this"
   - Verify: Includes `set PYTHONIOENCODING=utf-8`

4. **Ask for Retry Logic**:
   - "Add retry with evidence preservation"
   - Verify: Captures state before/after each attempt

5. **Ask Project-Specific Question**:
   - "How do I deploy {YourProject}?"
   - Verify: Copilot references your deployment commands from Part 2

---

## Customization Examples

### Example 1: RAG System (EVA-JP-v1.2 Style)

```markdown
## PART 2: MY-RAG-PROJECT PROJECT SPECIFIC

### Architecture Overview

**System Type**: Retrieval Augmented Generation (RAG)

**Core Components**:
1. **Backend** (`app/backend/app.py`) - Python/Quart async API with RAG
2. **Frontend** (`app/frontend/`) - React/TypeScript/Vite SPA
3. **Document Pipeline** (`functions/`) - Azure Functions (OCR, chunking, embedding)

**Critical Architecture Pattern - Fallback for Secure Mode**:
- Primary: Private endpoint access to Azure AI Services
- Fallback: Gracefully degrade to text-only search
- Configure via `OPTIMIZED_KEYWORD_SEARCH_OPTIONAL=true`
```

### Example 2: Automation System (JP Auto-Extraction Style)

```markdown
## PART 2: JP-AUTOMATION PROJECT SPECIFIC

### Architecture Overview

**System Type**: Browser Automation for Data Extraction

**Core Components**:
1. **Main Automation** (`scripts/run_jp_batch.py`) - Batch processing engine
2. **Authentication** (`scripts/authenticate_jp.py`) - Session management
3. **Evidence Collection** (`debug/`) - Screenshots, HTML dumps, traces

**Critical Architecture Pattern - Long-Running Operations**:
- Checkpoint every 10 items processed
- Session restoration on failure
- Evidence collection at operation boundaries
- Retry with exponential backoff
```

### Example 3: API System

```markdown
## PART 2: MY-API PROJECT SPECIFIC

### Architecture Overview

**System Type**: RESTful API with Azure Integration

**Core Components**:
1. **API Server** (`src/api/server.ts`) - Express/TypeScript
2. **Azure Integration** (`src/services/azure/`) - Azure SDK clients
3. **Database Layer** (`src/data/`) - Cosmos DB repository pattern

**Critical Architecture Pattern - Connection Pooling**:
- Singleton Azure clients (never create per-request)
- Connection pool sizing based on load
- Health checks on startup
- Graceful shutdown with drain period
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Leaving Placeholders

**Problem**: Forgetting to replace `{PLACEHOLDER}` values

**Impact**: Copilot generates generic code instead of project-specific implementations

**Solution**: Run placeholder validation script before committing

### ❌ Mistake 2: Removing Universal Patterns

**Problem**: Deleting Part 1 sections thinking they're not needed

**Impact**: Lose critical patterns like Windows encoding safety, professional components

**Solution**: Keep ALL of Part 1, only customize Part 2

### ❌ Mistake 3: Adding Unicode to Examples

**Problem**: Using ✅ ❌ in added code examples

**Impact**: Code crashes in enterprise Windows environments

**Solution**: Always use ASCII: `[PASS]`, `[FAIL]`, `[ERROR]`

### ❌ Mistake 4: Not Testing with Copilot

**Problem**: Assuming template works without validation

**Impact**: Copilot may not follow instructions correctly

**Solution**: Run all 5 test scenarios after customization

### ❌ Mistake 5: Incomplete Part 2

**Problem**: Leaving Part 2 sections as generic templates

**Impact**: Copilot lacks project-specific context for accurate suggestions

**Solution**: Add real examples, actual file paths, tested commands

---

## Maintenance & Updates

### When to Update Instructions

1. **New Major Component**: Add to Part 2 Architecture Overview
2. **New Pattern Discovered**: Document in Critical Code Patterns
3. **Troubleshooting Issue Resolved**: Add to Troubleshooting section
4. **Deployment Process Changes**: Update Development Workflows
5. **Azure Resources Added/Removed**: Update Azure Service Dependencies

### Version Control

Track major changes in Release Notes section:

```markdown
## Release Notes

### Version 2.1.0 (Date)
- Added new authentication pattern
- Updated deployment commands for production
- Enhanced troubleshooting with 3 new common issues

### Version 2.0.0 (January 29, 2026)
- Initial project-specific customization from template v2.0.0
```

---

## Success Criteria

Your copilot-instructions.md is ready when:

✅ **Completeness**
- [ ] Zero remaining `{PLACEHOLDER}` values
- [ ] All Part 2 sections have project-specific content
- [ ] Real examples, not generic templates

✅ **Quality**
- [ ] No Unicode characters in code sections
- [ ] All file paths verified to exist
- [ ] All commands tested successfully

✅ **Effectiveness**
- [ ] Copilot generates project-correct code
- [ ] Copilot follows professional component architecture
- [ ] Copilot uses ASCII-only output
- [ ] Copilot references project-specific patterns

---

## Support & Resources

### Template Files
- **Template v2.0.0**: `docs/eva-foundation/projects/07-copilot-instructions/02-design/artifact-templates/copilot-instructions-template.md`
- **This Guide**: `docs/eva-foundation/projects/07-copilot-instructions/02-design/artifact-templates/template-v2-usage-guide.md`
- **Best Practices**: `docs/eva-foundation/projects/07-copilot-instructions/02-design/best-practices-reference.md`

### Example Implementations
- **EVA-JP-v1.2** (RAG System): `.github/copilot-instructions.md`
- **Project 06** (Automation): `docs/eva-foundation/projects/06-JP-Auto-Extraction/`

### Questions?
Refer to Project 07 documentation or EVA-JP-v1.2 production implementation for examples.

---

**Template v2.0.0 Usage Guide** - Updated January 29, 2026  
**Project 07**: Copilot Instructions & Standards Baseline
