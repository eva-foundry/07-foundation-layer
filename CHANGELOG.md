# Changelog - Project 07: Copilot Instructions & Standards Baseline

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planning
- [ ] Create additional folder structure templates (automation, api, infrastructure)
- [ ] Integrate workspace management into Apply-Project07-Artifacts.ps1 v1.6.0
- [ ] Add automated tests to Test-Project07-Deployment.ps1 (~15 test cases)
- [ ] Add retention policy automation to Invoke-WorkspaceHousekeeping.ps1
- [ ] Add statistics section to Capture output (currently missing from snapshot)

---

## [1.5.2] - 2026-01-30

### Fixed - Capture-ProjectStructure.ps1 v1.0.1
- **Null Array Handling**: Fixed crash when Get-ChildItem returns no items
  - Added @() array wrapper to ensure $items is always an array
  - Added null check before accessing .Count property
  - Fixed Get-FolderStats to handle empty directories gracefully
  - Fixed potential null reference in totalSize calculation

### Testing - Manual Validation Complete
- **Test Target**: Project 01 (01-documentation-generator)
- **Results**: All workspace management scripts operational
  - Capture: Successfully scanned 19 folders, 79 files (9.6 MB)
  - Initialize: DryRun preview confirmed 19 folders would be created
  - Housekeeping: Detected 8 root violations, 19 missing folders
  - Evidence: 8 artifacts collected in evidence/structure-init/
- **Test Suite**: manual-test-workspace-mgmt.ps1 created (290 lines)
- **Test Results**: Saved to 04-testing/results/ with timestamp
- **ASCII Safety**: All output uses [PASS]/[INFO]/[WARN] markers

### Status Update
- v1.5.0 workspace management scripts validated on real project
- Bug fix (v1.0.1) identified and resolved during testing
- Ready for integration into Apply-Project07-Artifacts.ps1 v1.6.0
- Automated test expansion deferred to v1.6.0 (pragmatic approach)

---

## [1.5.1] - 2026-01-30

### Fixed - Documentation Synchronization
- **Version References Updated**: Corrected all references from v2.0.0 to v2.1.0 across documentation
  - README.md: Phase 2 status, Phase 3 status, deployment guide
  - Project 07 copilot-instructions.md: Artifact reference
  - best-practices-reference.md: Header and pattern mapping
  - standards-specification.md: Version annotation
  - template-v2-usage-guide.md: Quick start section

- **README.md Enhancements**:
  - Added Phase 5: Workspace Management (v1.5.0) section documenting 4 new scripts
  - Added Deployment Decision Tree with 4 scenarios (copilot-only, full scaffold, housekeeping, enforcement)
  - Added Troubleshooting section with 5 common issues and solutions
  - Clarified Phase 4 testing status (Pester ready, test suite expansion needed)

- **Project 07 Copilot Instructions Enhanced**:
  - Added workspace management guidance (Initialize, Capture, Housekeeping scripts)
  - Added deployment decision tree for different scenarios
  - Updated template reference to v2.1.0 with correct line count (1,902 lines)

---

## [1.5.0] - 2026-01-30

### Added - Workspace Management Scripts v1.0.0
> [INFO] Workspace management scripts created as standalone v1.0.0 artifacts.
> [INFO] Integration into Apply-Project07-Artifacts.ps1 deferred to v1.6.0.
> [INFO] Use manual deployment for immediate adoption (see Deployment section below).

- **Initialize-ProjectStructure.ps1 v1.0.0**: Scaffold projects from JSON templates
  - Reads `.github/supported-folder-structure.json`
  - Creates folder hierarchy with `.folderinfo` files
  - Generates navigation README.md
  - Professional components: DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS
  - ASCII-only output (Windows enterprise encoding safety)
  - DryRun mode for preview

- **Capture-ProjectStructure.ps1 v1.0.0**: Generate filesystem snapshot
  - Scans current structure to configurable depth
  - Outputs to `.github/project-folder-picture.md`
  - Hierarchical tree view with file sizes
  - Statistics (folder/file counts, total size)
  - ASCII-only output

- **Invoke-WorkspaceHousekeeping.ps1 v1.0.0**: Enforce workspace organization
  - Compares `supported-folder-structure.json` (expected) vs. `project-folder-picture.md` (actual)
  - Detects root directory clutter
  - Identifies missing required folders
  - Matches files against organization rules
  - Generates compliance report with remediation commands
  - Auto-organize mode (moves misplaced files with confirmation)
  - ASCII-only output

- **supported-folder-structure-rag.json v1.0.0**: RAG project template
  - 20+ required folders (app, docs, scripts, logs, evidence, sessions)
  - Organization rules (Deploy-*.ps1 -> scripts/deployment/, etc.)
  - Retention policies (logs 14 days, evidence 30 days, sessions 30 days)
  - Folder descriptions for AI context
  - Version metadata for compatibility checking

### Deployment (Manual)
Scripts available in `02-design/artifact-templates/`:
```powershell
# Copy scripts to target project
Copy-Item "Initialize-ProjectStructure.ps1" -Destination "<target>/scripts/housekeeping/"
Copy-Item "Capture-ProjectStructure.ps1" -Destination "<target>/scripts/housekeeping/"
Copy-Item "Invoke-WorkspaceHousekeeping.ps1" -Destination "<target>/scripts/housekeeping/"
Copy-Item "supported-folder-structure-rag.json" -Destination "<target>/.github/supported-folder-structure.json"

# Initialize project structure
.\scripts\housekeeping\Initialize-ProjectStructure.ps1 -TargetPath "." -DryRun

# Capture current state
.\scripts\housekeeping\Capture-ProjectStructure.ps1 -TargetPath "."

# Run housekeeping analysis
.\scripts\housekeeping\Invoke-WorkspaceHousekeeping.ps1 -TargetPath "." -DryRun
```

### Documentation
- Workspace management lifecycle documented
- Closed-loop system: Initialize -> Deploy -> Capture -> Housekeep
- Evidence-based organization principles
- Template-driven folder structure patterns

### Planned for v1.6.0
- [x] Workspace management scripts created (v1.0.0) - THIS RELEASE
- [ ] Integration into Apply-Project07-Artifacts.ps1 - NEXT RELEASE
- [ ] Automated testing in Test-Project07-Deployment.ps1 - NEXT RELEASE
- [ ] Additional templates (automation, api, infrastructure) - FUTURE

---

## [1.3.0] - 2026-01-29

### Added

#### Phase 1: Quick Wins
- **Version tracking**: Script now displays version number (1.3.0) in header and logs
- **Enhanced project type detection**: Improved keyword analysis for project classification
  - RAG systems: Detects LangChain, langchain-openai, Azure Cognitive Search patterns
  - Azure Functions: Identifies function.json, host.json, Azure Functions runtime
  - Automation: Recognizes Playwright, Selenium, browser automation patterns
  - API services: Finds Express, Flask, FastAPI, Quart patterns
- **TODO prioritization**: Categories for [TODO] placeholders
  - [CRITICAL] - System won't work without this
  - [HIGH] - Core functionality incomplete
  - [MEDIUM] - Important but not blocking
  - [LOW] - Nice to have enhancements
- **Environment variable discovery**: Parses .env.example files to populate config sections

#### Phase 2: Quality Improvements
- **Advanced tech stack detection**: Parses requirements.txt, package.json for dependencies
  - Python: Detects LangChain, Azure SDK, FastAPI, pytest
  - Node.js: Identifies Express, React, Vite, Jest
  - .NET: Recognizes .csproj, Microsoft.Extensions packages
- **Quality validation**: Completion percentage calculation
  - Measures [TODO] density vs. total content
  - Flags sections with >30% TODO placeholders as incomplete
  - Reports overall quality score in compliance report

#### Phase 3: UX Enhancements
- **Deep component detection**: Analyzes code structure for architecture patterns
  - Authentication: Detects Entra ID, JWT, OAuth implementations
  - Database: Identifies Cosmos DB, MongoDB, SQL Server connections
  - Search: Finds Azure Cognitive Search, vector search implementations
- **Interactive mode**: `-Interactive` flag for step-by-step review
  - Shows detected metadata before applying
  - Allows editing of project-specific sections
  - Confirms TODO priority assignments
- **Example-based learning**: Analyzes similar EVA projects for reference
  - Suggests patterns from Project 06 (JP Automation)
  - References CDS AI Answers (Project 08) for RAG systems
  - Links to EVA-JP-v1.2 for Azure backend patterns
- **Post-deployment guidance**: Enhanced completion report
  - Next steps checklist
  - Links to example projects
  - Customization priority guide

### Changed
- **Template upgrade to v2.1.0**: New metadata placeholders (BREAKING CHANGE)
  - `[ARCHITECTURE_PATTERN]` - RAG, Microservices, Serverless, etc.
  - `[DEPLOYMENT_TARGET]` - Azure, AWS, Local development
  - `[TEST_FRAMEWORK]` - Jest, pytest, Pester, Playwright
  - `[MONITORING_STACK]` - Application Insights, CloudWatch, etc.
- **Project type detection hierarchy** (BREAKING CHANGE):
  - Old: Simple file existence checks -> "General Purpose Project"
  - New: Keyword analysis -> specific patterns -> fallback with warning
- **Validation rules tightened**:
  - Quality check now fails if >50% of content is [TODO] placeholders
  - Professional components required for automation projects
  - Azure services must be documented for RAG systems

### Fixed
- **Project type over-generalization**: Project 01 now correctly detected as "Python AI Documentation Generator" instead of generic
- **Tech stack surface-level detection**: Now parses dependency files for accurate stack identification
- **TODO placeholder overload**: Reduced from ~60 undifferentiated to ~45 prioritized TODOs

### Documentation
- **Testing limitation removed**: Pester 5.x upgrade complete (user confirmed)
  - Updated copilot-instructions.md line 123
  - Updated README.md Phase 4 status
  - Test suite ready for execution
- **Migration guide created**: `02-design/MIGRATION-GUIDE-v1.0-to-v1.3.md`
  - Upgrade instructions for projects deployed with v1.0.0
  - Breaking change mitigation strategies
  - Rollback procedure if needed

### Testing
- **Test suite expanded**: 60 -> 70+ test cases
  - New: Enhanced project type detection tests
  - New: TODO prioritization validation
  - New: Environment variable discovery tests
  - New: Quality validation (completion percentage)
  - New: Interactive mode user flow tests
- **Pester 5.x compatibility**: All tests upgraded and passing

---

## [1.0.0] - 2026-01-26

### Added
- Initial release of Apply-Project07-Artifacts.ps1 deployment script
- copilot-instructions-template.md v2.0.0 (PART 1 + PART 2 structure)
- Professional Component Architecture (DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS)
- Project type detection (RAG, Automation, API, Generic)
- Smart PART 2 extraction and preservation
- Test-Project07-Deployment.ps1 (650+ lines, 60+ test cases)
- ASCII-only output for Windows enterprise encoding safety
- Evidence collection at operation boundaries
- DryRun preview mode
- Compliance validation with 7+ checks
- Backup creation before deployment

### Documentation
- README.md with comprehensive project documentation
- copilot-instructions.md for Project 07 itself (self-referential)
- Template structure documentation

---

## Migration Notes

### Upgrading from v1.0.0 to v1.3.0

**BREAKING CHANGES**:
1. Template v2.0.0 -> v2.1.0 requires re-run on existing deployments
2. Project type detection logic changed (may reclassify projects)
3. Quality validation now enforces completion thresholds

**Upgrade Steps**:
1. Back up existing `.github/copilot-instructions.md`
2. Extract PART 2 content manually (lines after `## PART 2: PROJECT SPECIFIC`)
3. Run Apply-Project07-Artifacts.ps1 v1.3.0 on project
4. Review new [TODO] priorities and populate [CRITICAL] items first
5. Validate with `-SkipValidation` flag to see quality score
6. Iterate until quality score >70%

**Rollback**:
If v1.3.0 causes issues, restore from backup:
```powershell
Copy-Item .github/copilot-instructions.md.backup .github/copilot-instructions.md -Force
```

See `02-design/MIGRATION-GUIDE-v1.0-to-v1.3.md` for detailed upgrade instructions.

---

[1.3.0]: https://github.com/eva-jp-v1.2/compare/v1.0.0...v1.3.0
[1.0.0]: https://github.com/eva-jp-v1.2/releases/tag/v1.0.0
