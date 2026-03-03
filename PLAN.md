<!-- eva-primed-plan -->

## EVA Ecosystem Tools

- Data model: GET http://localhost:8010/model/projects/07-foundation-layer
- 29-foundry agents: C:\AICOE\eva-foundation\29-foundry\agents\
- 48-eva-veritas audit: run audit_repo MCP tool

---

# Project Plan

<!-- veritas-normalized 2026-03-01 prefix=F07 source=README.md -->

## Feature: Goal [ID=F07-01]

**07-Foundation-Layer is the Workspace PM/Scrum Master** -- the first touch on all new EVA projects.

Core Responsibilities:
1. Project Scaffolding (README, PLAN, STATUS, ACCEPTANCE, skills, data model seeding)
2. Governance Toolchain Ownership (36, 37, 38, 39, 40-partial, 48)
3. Pattern Propagation (template v3.4.0, seeder scripts, workspace tools)

## Feature: Governance Toolchain Ownership [ID=F07-02]

### Story: Own 36-red-teaming (Promptfoo adversarial testing harness) [ID=F07-02-001]

- [ ] Document 36-red-teaming integration in 07 copilot-instructions [ID=F07-02-001-T01]
- [ ] Create skill: red-teaming-integration.skill.md [ID=F07-02-001-T02]
- [ ] Add to scaffolding templates (new projects get red-teaming setup) [ID=F07-02-001-T03]

### Story: Own 37-data-model (Single source of truth API, 27+ layers) [ID=F07-02-002]

- [ ] Document data model ownership in 07 README [ID=F07-02-002-T01]
- [ ] Create skill: data-model-admin.skill.md (seeding, layer management, validation) [ID=F07-02-002-T02]
- [ ] Formalize seed-from-plan.py generalization pattern [ID=F07-02-002-T03]

### Story: Own 38-ado-poc (ADO Command Center, scrum orchestration) [ID=F07-02-003]

- [ ] Document 38-ado-poc ownership in 07 README [ID=F07-02-003-T01]
- [ ] Create skill: ado-integration.skill.md [ID=F07-02-003-T02]
- [ ] Add ADO project creation to scaffolding workflow [ID=F07-02-003-T03]

### Story: Own 39-ado-dashboard (EVA Home + sprint views) [ID=F07-02-004]

- [ ] Document 39-ado-dashboard ownership in 07 README [ID=F07-02-004-T01]
- [ ] Create skill: ado-dashboard-admin.skill.md [ID=F07-02-004-T02]

### Story: Own 40-eva-control-plane (partial: runtime evidence spine) [ID=F07-02-005]

- [ ] Clarify 40-eva-control-plane ownership boundaries (which parts 07 owns) [ID=F07-02-005-T01]
- [ ] Document control-plane integration in 07 README [ID=F07-02-005-T02]

### Story: Own 48-eva-veritas (Requirements traceability + MTI gating) [ID=F07-02-006]

- [ ] Document 48-eva-veritas ownership in 07 README [ID=F07-02-006-T01]
- [ ] Create skill: veritas-admin.skill.md (audit, MTI gates, evidence receipts) [ID=F07-02-006-T02]
- [ ] Add veritas setup to scaffolding workflow (new projects get .eva/ directory) [ID=F07-02-006-T03]

## Feature: 51-ACA Pattern Elevation [ID=F07-03]

### Story: Generalize 3 Core Scripts for Any EVA Project [ID=F07-03-001]

- [ ] Create seed-from-plan.py template (project-agnostic, reads PLAN.md) [ID=F07-03-001-T01]
- [ ] Create reflect-ids.py template (writes IDs inline to PLAN.md) [ID=F07-03-001-T02]
- [ ] Create gen-sprint-manifest.py template (generates sprint manifests) [ID=F07-03-001-T03]
- [ ] Add to 07/scripts/ directory [ID=F07-03-001-T04]
- [ ] Update 07/README.md with usage instructions [ID=F07-03-001-T05]

### Story: Elevate 5 Skills to Workspace Level [ID=F07-03-002]

- [ ] Elevate sprint-advance.skill.md (make project-agnostic) [ID=F07-03-002-T01]
- [ ] Elevate veritas-expert.skill.md (generalize to any project) [ID=F07-03-002-T02]
- [ ] Elevate gap-report.skill.md (remove 51-ACA hardcoding) [ID=F07-03-002-T03]
- [ ] Elevate sprint-report.skill.md (parameterize project_id) [ID=F07-03-002-T04]
- [ ] Elevate progress-report.skill.md (make project-agnostic) [ID=F07-03-002-T05]
- [ ] Add to C:\AICOE\.github\copilot-skills\ (workspace level) [ID=F07-03-002-T06]

### Story: Create Scaffolding Templates [ID=F07-03-003]

- [ ] Create DPDCA-WORKFLOW.md template (5-phase loop documentation) [ID=F07-03-003-T01]
- [ ] Create sprint manifest template (.github/sprints/sprint-NN-name.md) [ID=F07-03-003-T02]
- [ ] Create GitHub Actions workflow template (sprint-agent.yml) [ID=F07-03-003-T03]
- [ ] Create scripts/ directory seed structure template [ID=F07-03-003-T04]
- [ ] Add to 07/02-design/artifact-templates/ [ID=F07-03-003-T05]

### Story: Document One-Line Governance Pattern [ID=F07-03-004]

- [ ] Add to workspace copilot-instructions.md (gh issue create pattern) [ID=F07-03-004-T01]
- [ ] Document GitHub Copilot cloud agent integration [ID=F07-03-004-T02]
- [ ] Add to template copilot-instructions-template.md (reference workspace) [ID=F07-03-004-T03]

## Feature: Key Discovery Findings [ID=F07-04]

### Story: **?? CRITICAL Pattern #1: Windows Enterprise Encoding Safety** [ID=F07-02-001]

### Story: **? Pattern #2: Professional Component Architecture** [ID=F07-02-002]

### Story: **? Pattern #3: Zero-Setup Execution** [ID=F07-02-003]

### Story: **?? Patterns Pending Broader Validation** [ID=F07-02-004]

## Feature: Project Phases [ID=F07-03]

### Story: Phase 1: Discovery (?? IN PROGRESS) [ID=F07-03-001]

- [ ] Create project structure [ID=F07-03-001-T01]
- [ ] Analyze Project 06 (JP Auto-Extraction) patterns thoroughly [ID=F07-03-001-T02]
- [ ] Extract Professional Component Architecture from Project 06 [ID=F07-03-001-T03]
- [ ] Identify Windows Enterprise Encoding Safety critical issues [ID=F07-03-001-T04]
- [ ] Document Evidence Collection Infrastructure patterns [ID=F07-03-001-T05]
- [ ] Create initial pattern documentation based on Project 06 analysis [ID=F07-03-001-T06]
- [ ] Analyze current EVA-JP-v1.2 Copilot configuration effectiveness [ID=F07-03-001-T07]
- [ ] Survey existing Copilot configurations across other EVA projects [ID=F07-03-001-T08]
- [ ] Validate Project 06 patterns against different project types (RAG vs automation) [ID=F07-03-001-T09]
- [ ] Interview/survey developers about current Copilot pain points [ID=F07-03-001-T10]
- [ ] Test extracted patterns on non-JP projects for broader applicability [ID=F07-03-001-T11]
- [ ] Document gaps between Project 06 patterns and EVA-wide needs [ID=F07-03-001-T12]
- [ ] `01-discovery/artifacts-inventory.md` - Comprehensive catalog [ID=F07-03-001-T13]
- [ ] `01-discovery/current-state-assessment.md` - Analysis of existing configuration [ID=F07-03-001-T14]
- [ ] `01-discovery/gap-analysis.md` - Identification of missing elements [ID=F07-03-001-T15]
- [ ] Initial pattern extraction from Project 06 (documented in 02-design/ as drafts) [ID=F07-03-001-T16]
- [ ] **PENDING**: Broader EVA ecosystem analysis and pattern validation [ID=F07-03-001-T17]
- [ ] **PENDING**: Developer pain point survey results [ID=F07-03-001-T18]
- [ ] **PENDING**: Cross-project pattern applicability validation [ID=F07-03-001-T19]

### Story: Phase 2: Design (complete - January 29, 2026) [ID=F07-03-002]

- [ ] Document Project 06 patterns as initial design templates [ID=F07-03-002-T01]
- [ ] Create Professional Component Architecture specification [ID=F07-03-002-T02]
- [ ] Define Windows Enterprise Encoding Safety standards [ID=F07-03-002-T03]
- [ ] Extract Evidence Collection Infrastructure requirements [ID=F07-03-002-T04]
- [ ] Document dependency management strategy [ID=F07-03-002-T05]
- [ ] Create initial Copilot instructions template [ID=F07-03-002-T06]
- [ ] **COMPLETED**: Enhanced template v2.0.0 with complete production patterns (January 29, 2026) [ID=F07-03-002-T07]
- [ ] **COMPLETED**: Migrated 1,000+ lines from EVA-JP-v1.2 production copilot-instructions.md [ID=F07-03-002-T08]
- [ ] **COMPLETED**: Added comprehensive Table of Contents with GitHub-style anchors [ID=F07-03-002-T09]
- [ ] **COMPLETED**: Included complete working implementations of 4 professional components [ID=F07-03-002-T10]
- [ ] **COMPLETED**: Added Quick Reference section, AI Context Management, Workspace Housekeeping [ID=F07-03-002-T11]
- [ ] **COMPLETED**: Implemented semantic versioning (v2.0.0) with Release Notes [ID=F07-03-002-T12]
- [ ] **COMPLETED**: Created template-v2-usage-guide.md with comprehensive usage instructions [ID=F07-03-002-T13]
- [ ] `02-design/standards-specification.md` - Standards based on Project 06 [ID=F07-03-002-T14]
- [ ] `02-design/artifact-templates/copilot-instructions-template.md` - **v2.1.0 production-ready** (1,902 lines) [ID=F07-03-002-T15]
- [ ] `02-design/artifact-templates/professional-runner-template.py` - Runner implementation [ID=F07-03-002-T16]
- [ ] `02-design/architecture-decision-records/ADR-004-*.md` - ADRs documented [ID=F07-03-002-T17]
- [ ] `02-design/best-practices-reference.md` - Comprehensive patterns [ID=F07-03-002-T18]
- [ ] `02-design/artifact-templates/template-v2-usage-guide.md` - **NEW**: Complete usage guide for template v2.1.0 [ID=F07-03-002-T19]

### Story: Phase 5: Workspace Management (? TESTED - v1.5.2 - January 30, 2026) [ID=F07-03-003]

- [ ] Created Initialize-ProjectStructure.ps1 v1.0.0 - Scaffold projects from JSON templates [ID=F07-03-003-T01]
- [ ] Created Capture-ProjectStructure.ps1 v1.0.1 - Generate filesystem snapshots (bug fixed) [ID=F07-03-003-T02]
- [ ] Created Invoke-WorkspaceHousekeeping.ps1 v1.0.0 - Enforce workspace organization [ID=F07-03-003-T03]
- [ ] Created supported-folder-structure-rag.json v1.0.0 - RAG project template [ID=F07-03-003-T04]
- [ ] Implemented professional components in all scripts (DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS) [ID=F07-03-003-T05]
- [ ] Enforced ASCII-only output throughout (Windows enterprise encoding safety) [ID=F07-03-003-T06]
- [ ] Added DryRun modes for safe preview [ID=F07-03-003-T07]
- [ ] Integrated compliance reporting with remediation commands [ID=F07-03-003-T08]
- [ ] **TESTED**: Manual validation on Project 01 (01-documentation-generator) [ID=F07-03-003-T09]
- [ ] **BUG FIXED**: Capture v1.0.1 - Fixed null array crash [ID=F07-03-003-T10]
- [ ] **DOCUMENTED**: Comprehensive test results (test-results-workspace-mgmt-v1.0.0.md) [ID=F07-03-003-T11]
- [ ] `02-design/artifact-templates/Initialize-ProjectStructure.ps1` v1.0.0 (370 lines) [ID=F07-03-003-T12]
- [ ] `02-design/artifact-templates/Capture-ProjectStructure.ps1` v1.0.1 (237 lines, bug fixed) [ID=F07-03-003-T13]
- [ ] `02-design/artifact-templates/Invoke-WorkspaceHousekeeping.ps1` v1.0.0 (530 lines) [ID=F07-03-003-T14]
- [ ] `02-design/artifact-templates/supported-folder-structure-rag.json` v1.0.0 [ID=F07-03-003-T15]
- [ ] `04-testing/manual-test-workspace-mgmt.ps1` - Test suite (290 lines) [ID=F07-03-003-T16]
- [ ] `04-testing/test-results-workspace-mgmt-v1.0.0.md` - Test results documentation [ID=F07-03-003-T17]
- [ ] Integrate workspace management into Apply-Project07-Artifacts.ps1 [ID=F07-03-003-T18]
- [ ] Add automated tests to Test-Project07-Deployment.ps1 (~15 test cases) [ID=F07-03-003-T19]
- [ ] Create additional templates (automation, api, infrastructure) [ID=F07-03-003-T20]
- [ ] Add retention policy automation to housekeeping script [ID=F07-03-003-T21]

### Story: Phase 3: Development (? COMPLETE - January 29, 2026) [ID=F07-03-004]

- [ ] Created Apply-Project07-Artifacts.ps1 (1,200+ lines) - Self-demonstrating primer script [ID=F07-03-004-T01]
- [ ] Implemented PowerShell professional components (DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS) [ID=F07-03-004-T02]
- [ ] Added project type detection (RAG, Automation, API, Serverless) [ID=F07-03-004-T03]
- [ ] Implemented smart content preservation (extracts and preserves existing PART 2) [ID=F07-03-004-T04]
- [ ] Added backup creation with timestamped safety [ID=F07-03-004-T05]
- [ ] Created Test-DeploymentCompliance validation function [ID=F07-03-004-T06]
- [ ] Implemented compliance reporting with remediation steps [ID=F07-03-004-T07]
- [ ] Added DryRun mode for preview [ID=F07-03-004-T08]
- [ ] Ensured ASCII-only output (Windows enterprise encoding safety) [ID=F07-03-004-T09]
- [ ] Evidence collection at all operation boundaries [ID=F07-03-004-T10]
- [ ] `02-design/artifact-templates/Apply-Project07-Artifacts.ps1` - Production-ready primer (1,200+ lines) [ID=F07-03-004-T11]
- [ ] `02-design/artifact-templates/Test-Project07-Deployment.ps1` - Pester 5.x test suite (650+ lines) [ID=F07-03-004-T12]
- [ ] Comprehensive inline documentation with usage examples [ID=F07-03-004-T13]
- [ ] Professional component implementations demonstrating Project 07 patterns [ID=F07-03-004-T14]

### Story: Phase 4: Testing (? READY - Pester 5.x Upgraded) [ID=F07-03-005]

- [ ] Test suite created with comprehensive coverage (60+ test cases) [ID=F07-03-005-T01]
- [ ] Professional Component Architecture tests (DebugArtifactCollectorPS, SessionManagerPS, StructuredErrorHandlerPS) [ID=F07-03-005-T02]
- [ ] Encoding Safety Compliance tests (Unicode detection, ASCII validation) [ID=F07-03-005-T03]
- [ ] Standards Validation tests (PART 1/PART 2, professional components, compliance reporting) [ID=F07-03-005-T04]
- [ ] Evidence Collection tests (operation boundaries, checkpoints) [ID=F07-03-005-T05]
- [ ] Project Type Detection tests (RAG, Automation, API, tech stack) [ID=F07-03-005-T06]
- [ ] File Operation Safety tests (backup, preservation, DryRun) [ID=F07-03-005-T07]
- [ ] **COMPLETED**: Pester 5.x upgrade complete, test suite ready for execution [ID=F07-03-005-T08]
- [ ] Execute full test suite with Pester 5.x [ID=F07-03-005-T09]
- [ ] Integration tests (ready to execute) [ID=F07-03-005-T10]

### Story: Phase 5: Implementation (?? ON HOLD - Waiting for Testing) [ID=F07-03-006]

## Feature: Project Structure [ID=F07-04]

## Feature: Success Criteria [ID=F07-05]

### Story: **Primary Success Metrics** [ID=F07-05-001]

### Story: **Secondary Success Metrics** [ID=F07-05-002]

## Feature: Deploying Project 07 to Other Projects [ID=F07-06]

### Story: Quick Deployment Guide [ID=F07-06-001]

### Story: Deployment Decision Tree [ID=F07-06-002]

### Story: What Gets Deployed [ID=F07-06-003]

### Story: Supported Project Types [ID=F07-06-004]

## Feature: Troubleshooting [ID=F07-07]

### Story: Common Issues [ID=F07-07-001]

## Feature: References [ID=F07-08]

### Story: Deployment Tools [ID=F07-08-001]

### Story: Documentation [ID=F07-08-002]

## Feature: Change Log [ID=F07-09]
