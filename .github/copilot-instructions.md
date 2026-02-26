# GitHub Copilot Instructions - Project 07: Copilot Instructions & Standards Baseline

**Meta-Project Notice**: This is Project 07, which **creates** Copilot instruction templates for other EVA projects.  
**Self-Referential**: When working on Project 07, you are improving the very patterns that guide AI assistance across the EVA ecosystem.

---

### Project Lock

This file is the copilot-instructions for **07-foundation-layer** (Foundation Layer -- patterns and templates source).

The workspace-level bootstrap rule "Step 1 -- Identify the active project from the currently open file path"
applies **only at the initial load of this file** (first read at session start).
Once this file has been loaded, the active project is locked to **07-foundation-layer** for the entire session.
Do NOT re-evaluate project identity from editorContext or terminal CWD on each subsequent request.
Work state and sprint context are read from `STATUS.md` and `PLAN.md` at bootstrap -- not from this file.

---

## Critical: Apply What You Teach

**Pattern #1: Windows Enterprise Encoding Safety** (ALWAYS ENFORCE)
```
[FORBIDDEN] Unicode characters:     [x] [x] ... (cause UnicodeEncodeError)
[REQUIRED] ASCII only: [PASS] [FAIL] [INFO] [WARN] [ERROR]
```

**Pattern #2: Professional Component Architecture**
- DebugArtifactCollector - Evidence at operation boundaries
- SessionManager - Checkpoint/resume capabilities
- StructuredErrorHandler - JSON logging with context
- ProfessionalRunner - Zero-setup execution

**Pattern #3: Evidence Collection**
- Capture pre-state before risky operations
- Capture success state on completion
- Capture error state with full diagnostics
- Use timestamped naming: `{component}_{context}_{YYYYMMDD_HHMMSS}.{ext}`

**Rule 6 -- Never PUT inside a `pwsh -Command` inline string**
JSON escaping is silently mangled. Write a `.ps1` file and run with `pwsh -File`.
```powershell
# WRONG -- JSON body corrupted by shell quoting
pwsh -NoLogo -Command "& { $body=... | ConvertTo-Json; Invoke-RestMethod ... -Body $body }"

# RIGHT
$script | Set-Content "$env:TEMP\put-model.ps1" -Encoding UTF8
pwsh -NoProfile -File "$env:TEMP\put-model.ps1"
```

**Rule 7 -- `get_terminal_output` only accepts IDs from `run_in_terminal(isBackground=true)`**
Never pass `"1"`, `"pwsh"`, or any label. The only valid ID is the opaque string
returned by `run_in_terminal` when `isBackground=true`.

**Rule 8 -- Never call `create_file` on a path that already exists**
`create_file` on an existing file returns a hard error and makes no change.
Always `Test-Path` first; use `replace_string_in_file` for edits to existing files.

---

## Primary Artifacts (What This Project Produces)

### Templates
- **[copilot-instructions-template.md](../02-design/artifact-templates/copilot-instructions-template.md)** - **v3.1.0** (428 lines)
  - PART 1: Universal best practices (encoding safety, professional components, Azure patterns)
  - PART 2: Project-specific placeholder sections (11 categories)
  - Complete working implementations of 4 professional components
  - AI-instructional placeholders with context and examples

- **[template-v2-usage-guide.md](../02-design/artifact-templates/template-v2-usage-guide.md)** - Usage instructions
  - 5-step deployment process
  - Placeholder reference guide
  - Customization examples for RAG/Automation/API/Serverless projects

### Deployment Tools
- **[Apply-Project07-Artifacts.ps1](../02-design/artifact-templates/Apply-Project07-Artifacts.ps1)** - Primer script v1.4.1 (1,300+ lines) -- v3.x regex bugs fixed 2026-02-25
  - Self-demonstrating: Uses the same patterns it deploys
  - Smart PART 2 preservation
  - Project type detection (RAG, Automation, API, Serverless)
  - Compliance validation with remediation steps (8+ checks)
  - Professional components: DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS
  - ASCII-only output throughout

- **[Test-Project07-Deployment.ps1](../02-design/artifact-templates/Test-Project07-Deployment.ps1)** - Test suite v1.0.0 (650+ lines)
  - 60+ test cases covering all patterns
  - Requires Pester 5.x
  - Note: Test suite expansion in progress (see v1.3.0-IMPLEMENTATION-SUMMARY.md)

### Workspace Management Tools (v1.5.0)
- **[Initialize-ProjectStructure.ps1](../02-design/artifact-templates/Initialize-ProjectStructure.ps1)** v1.0.0 - Scaffold projects
  - Reads `.github/supported-folder-structure.json` template
  - Creates folder hierarchy with `.folderinfo` description files
  - Generates navigation README.md
  - DryRun mode for safe preview

- **[Capture-ProjectStructure.ps1](../02-design/artifact-templates/Capture-ProjectStructure.ps1)** v1.0.0 - Snapshot structure
  - Scans current filesystem to configurable depth
  - Outputs to `.github/project-folder-picture.md`
  - Hierarchical tree view with file sizes
  - Statistics (folder/file counts, total size)

- **[Invoke-WorkspaceHousekeeping.ps1](../02-design/artifact-templates/Invoke-WorkspaceHousekeeping.ps1)** v1.0.0 - Enforce organization
  - Compares expected structure vs. actual
  - Detects root directory clutter
  - Identifies missing required folders
  - Generates compliance report with remediation commands
  - AutoOrganize mode (moves misplaced files with confirmation)

- **[supported-folder-structure-rag.json](../02-design/artifact-templates/supported-folder-structure-rag.json)** v1.0.0 - RAG template
  - 20+ required folders for RAG systems
  - Organization rules (Deploy-*.ps1 -> scripts/deployment/)
  - Retention policies (logs 14 days, evidence 30 days)
  - Folder descriptions for AI context

### Documentation
- **[README.md](../README.md)** - Project overview and phase tracking
- **[best-practices-reference.md](../02-design/best-practices-reference.md)** - Comprehensive pattern catalog
- **[standards-specification.md](../02-design/standards-specification.md)** - Technical standards
- **ADRs** in `02-design/architecture-decision-records/` - Design decisions

---

## How to Deploy Project 07 to Other Projects

**Primary Tool**: [Apply-Project07-Artifacts.ps1](../02-design/artifact-templates/Apply-Project07-Artifacts.ps1)

### Quick Deploy
```powershell
# 1. Preview deployment (DryRun)
cd I:\EVA-JP-v1.2\docs\eva-foundry\projects\07-copilot-instructions\02-design\artifact-templates
.\Apply-Project07-Artifacts.ps1 -TargetPath "I:\TargetProject" -DryRun

# 2. Apply with backup and confirmation
.\Apply-Project07-Artifacts.ps1 -TargetPath "I:\TargetProject"

# 3. Validate compliance
.\Apply-Project07-Artifacts.ps1 -TargetPath "I:\TargetProject" -SkipBackup -SkipValidation:$false
```

### Test Deployment
```powershell
# Install Pester 5.x (if not already installed)
Install-Module -Name Pester -MinimumVersion 5.0 -Force -Scope CurrentUser -SkipPublisherCheck

# Run full test suite
Invoke-Pester .\Test-Project07-Deployment.ps1 -Output Detailed
```

**What it does**:
- Analyzes target project (detects RAG/Automation/API/Serverless type)
- Preserves existing PART 2 content (smart merging)
- Applies universal PART 1 (encoding safety, professional components)
- Generates tailored PART 2 template
- Creates timestamped backup
- Validates 8+ compliance checks
- Generates remediation report

**See**: [template-v2-usage-guide.md](../02-design/artifact-templates/template-v2-usage-guide.md) for detailed instructions

---

## Project Structure & Phase Status

```
07-copilot-instructions/
 .github/               [NEW]         - This self-referential copilot instructions
 01-discovery/          [IN PROGRESS] - Broader EVA ecosystem analysis
 02-design/             [COMPLETE]    - Template v2.0.0 production-ready
 03-development/        [COMPLETE]    - Primer + test suite created
 04-testing/            [IN PROGRESS] - Blocked on Pester 5.x upgrade
 05-implementation/     [ON HOLD]     - Waiting for test validation
```

**Current Phase**: Testing (Phase 4) - Manual validation successful, automated tests require Pester upgrade

---

## When Working on Project 07

### Self-Consistency Check
If you're making changes to Project 07 that contradict the patterns in `copilot-instructions-template.md`, you're either:
1. **Discovering a template improvement** -> Update template + create ADR + document in changelog
2. **Making a mistake** -> Align with established patterns

### Pattern Validation Process
Before adding/modifying patterns:
1. **Source**: Identify where pattern comes from (Project 06, EVA-JP-v1.2, other)
2. **Applicability**: Validate across project types (RAG, Automation, API, Serverless)
3. **Document**: Create ADR if architectural decision
4. **Test**: Ensure primer script demonstrates the pattern
5. **Update**: Sync template, usage guide, and README

### Quality Gates
- [x] ASCII-only output in all scripts and documentation
- [x] Professional components used in all automation (primer script demonstrates this)
- [x] Evidence collected at operation boundaries (debug artifacts, session checkpoints)
- [x] Timestamped artifacts for all state captures
- [x] Self-validating: Project 07 code follows its own standards

---

## Key Insights

### Meta-Project Philosophy
- **Self-Demonstrating**: Project 07's code embodies the patterns it teaches
- **Production-Tested**: All patterns extracted from real EVA projects (primarily EVA-JP-v1.2 and Project 06)
- **Template-Driven**: Reusable artifacts > project-specific implementations
- **Evidence-Based**: Every pattern backed by concrete use cases

### Pattern Hierarchy
1. **Universal** (PART 1) - Apply to ALL EVA projects (encoding safety, professional components)
2. **Project-Type** (PART 2) - Tailored to RAG/Automation/API/Serverless
3. **Project-Specific** (PART 2 customization) - Unique to individual projects

### Known Limitations
- Phase 1 discovery incomplete - broader EVA ecosystem analysis needed
- Developer pain point surveys not yet conducted
- Pattern validation limited to Project 06 and EVA-JP-v1.2

---

## Quick Commands

```powershell
# Preview deployment (DryRun mode)
.\02-design\artifact-templates\Apply-Project07-Artifacts.ps1 -TargetPath "I:\TestProject" -DryRun

# Run compliance validation
.\02-design\artifact-templates\Apply-Project07-Artifacts.ps1 -TargetPath "I:\Project" -ValidateOnly

# Deploy to project (with backup + confirmation)
.\02-design\artifact-templates\Apply-Project07-Artifacts.ps1 -TargetPath "I:\Project"

# Run test suite (requires Pester 5.x)
Install-Module -Name Pester -MinimumVersion 5.0 -Force -Scope CurrentUser -SkipPublisherCheck
Invoke-Pester .\02-design\artifact-templates\Test-Project07-Deployment.ps1 -Output Detailed
```

---

## References

### Internal References
- **Template v2.0.0**: [copilot-instructions-template.md](../02-design/artifact-templates/copilot-instructions-template.md)
- **Usage Guide**: [template-v2-usage-guide.md](../02-design/artifact-templates/template-v2-usage-guide.md)
- **Best Practices**: [best-practices-reference.md](../02-design/best-practices-reference.md)
- **ADRs**: [02-design/architecture-decision-records/](../02-design/architecture-decision-records/)

### External References
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot Instructions Best Practices](https://github.com/github/copilot-docs)
- EVA-JP-v1.2 Production Config: `I:\EVA-JP-v1.2\.github\copilot-instructions.md`
- Project 06 Patterns: `I:\EVA-JP-v1.2\docs\eva-foundry\projects\06-JP-Auto-Extraction\`

---

## Success Metrics

### Immediate (Project 07 Internal)
- [x] Template v2.0.0 production-ready (1,200+ lines)
- [x] Deployment automation with professional components (1,200+ lines)
- [x] Comprehensive test suite (650+ lines, 60+ test cases)
- [WARN] Automated test execution (blocked on Pester 5.x)

### Ecosystem-Wide (EVA Projects)
-  Zero Unicode crashes across all EVA projects
-  Pattern consistency (encoding safety applied everywhere)
-  Professional component adoption (evidence collection, session management)
-  Developer satisfaction improvement

---

*This file is intentionally minimal and self-referential. For comprehensive Copilot guidance, see the template and artifacts this project produces.*


---

### Skills in This Project

`powershell
Get-ChildItem ".github/copilot-skills" -Filter "*.skill.md" | Select-Object Name
`

Read `00-skill-index.skill.md` to see what agent skills are available for this project.
Match the user's trigger phrase to the skill, then read that skill file in full.
