<!-- eva-primed-plan -->

## EVA Ecosystem Tools

- Data model: GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/07-foundation-layer
- 48-eva-veritas audit: run audit_repo MCP tool
- 18-azure-best: C:\eva-foundry\18-azure-best\ (32 entries: WAF, security, AI, IaC, cost optimization)
- 37-data-model: API at https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io (111 target layers, 6 category runbooks)

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
- [ ] Add to C:\eva-foundry\.github\copilot-skills\ (workspace level) [ID=F07-03-002-T06]

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

## Feature: Deployment Verification System [ID=F07-05]

**Status**: ⏳ PARTIALLY BLOCKED - 1/3 prerequisites resolved (March 12, 2026 @ Session 46)

**Context**: Session 44 discovered critical trust failure in Project 37 - agent fabricated deployment metrics (claimed 91 layers deployed, API had 51). This feature defines the multi-layer verification system to prevent future false claims using GitHub Copilot coding agents and automated evidence collection.

**Prerequisites**:
1. ✅ **RESOLVED (March 10, 2026)**: Project 37 completed actual layer deployment (51 → 91 operational + 20 planned = 111 target layers)
   - 12-domain architecture implemented
   - Execution Engine Phases 1-6 complete (24 layers: L52-L75)
   - 5,796 records deployed to Cosmos DB
   - 6 category runbooks operational
2. ❌ **REMAINS**: Project 37 must implement evidence-based GitHub Actions workflow (4 components: pre-merge gate, monitor agent, post-deployment validator, doc sync agent)
3. ❌ **REMAINS**: Pattern must be validated in Project 37 before workspace propagation

**Pattern to Propagate**: After validation in Project 37, this becomes the standard deployment verification pattern for all EVA projects with cloud deployments.

### Story: Pre-Merge Evidence Gate (GitHub Actions) [ID=F07-05-001]

**Objective**: Block PR merge unless deployment claims are proven with evidence-before/evidence-after comparison.

- [ ] Create workflow template: `verify-deployment-claims.yml` [ID=F07-05-001-T01]
- [ ] Implement evidence-before capture (query API, save layer counts, record counts) [ID=F07-05-001-T02]
- [ ] Implement evidence-after capture (same queries after deployment) [ID=F07-05-001-T03]
- [ ] Create comparison logic (fail if evidence-before == evidence-after AND PR claims deployment) [ID=F07-05-001-T04]
- [ ] Generate PR comment with evidence diff table [ID=F07-05-001-T05]
- [ ] Upload evidence artifacts (evidence-before.json, evidence-after.json, evidence-diff.json) [ID=F07-05-001-T06]
- [ ] Configure as required status check (blocks merge on failure) [ID=F07-05-001-T07]
- [ ] Test on fake deployment PR (should FAIL with no evidence change) [ID=F07-05-001-T08]
- [ ] Test on real deployment PR (should PASS with evidence change) [ID=F07-05-001-T09]
- [ ] Document in deployment runbook [ID=F07-05-001-T10]

**Deliverable**: `.github/workflows/verify-deployment-claims.yml` (required status check)

**Success Criteria**: 
- ✅ Blocks merge when documentation claims deployment but API unchanged
- ✅ Allows merge when API evidence shows actual change
- ✅ Evidence artifacts downloadable for audit

### Story: Continuous Monitor Agent (GitHub Copilot Coding Agent) [ID=F07-05-002]

**Objective**: Persistent cloud agent that monitors API vs documentation drift every 6 hours, creates alert issues when mismatch detected.

- [ ] Create persistent GitHub issue template: "[MONITOR] Data Model API Health Check" [ID=F07-05-002-T01]
- [ ] Define monitoring task specification (queries, comparisons, alert conditions) [ID=F07-05-002-T02]
- [ ] Create scheduled workflow: `monitor-agent.yml` (runs every 6 hours) [ID=F07-05-002-T03]
- [ ] Implement workflow trigger (posts comment to monitoring issue, invokes @copilot) [ID=F07-05-002-T04]
- [ ] Define alert issue template (drift detection with evidence links) [ID=F07-05-002-T05]
- [ ] Assign monitoring issue to @copilot agent [ID=F07-05-002-T06]
- [ ] Test manual workflow trigger [ID=F07-05-002-T07]
- [ ] Test with injected fake drift (verify alert issue created) [ID=F07-05-002-T08]
- [ ] Configure notification routing (Slack/Teams/email) [ID=F07-05-002-T09]
- [ ] Document in PROJECT-ORGANIZATION.md (Observability section) [ID=F07-05-002-T10]

**Deliverables**: 
- `.github/workflows/monitor-agent.yml` (scheduled trigger)
- Persistent GitHub issue #[N]: [MONITOR] Data Model API Health Check (assigned to @copilot)

**Success Criteria**:
- ✅ Monitors run every 6 hours without manual intervention
- ✅ Health check comments posted when API matches docs
- ✅ Alert issues automatically created when drift detected
- ✅ Time-to-detect drift: <6 hours

### Story: Post-Deployment Validator (GitHub Actions Extension) [ID=F07-05-003]

**Objective**: After Azure Container Apps deployment completes, automatically verify API reflects expected changes.

- [ ] Extend `deploy-hardened.yml` with validation step [ID=F07-05-003-T01]
- [ ] Add 30-second stabilization wait after ACA deployment [ID=F07-05-003-T02]
- [ ] Run count-source-records.py (expected records from model/ directory) [ID=F07-05-003-T03]
- [ ] Run count-cosmos-records.py (actual records from API) [ID=F07-05-003-T04]
- [ ] Run verify-deployment.py (comparison logic) [ID=F07-05-003-T05]
- [ ] Upload evidence/ files as workflow artifacts [ID=F07-05-003-T06]
- [ ] Parse verification results (layers_expected, layers_actual, match true/false) [ID=F07-05-003-T07]
- [ ] Post commit comment with deployment summary and evidence links [ID=F07-05-003-T08]
- [ ] Exit 1 if verification fails (red X on commit) [ID=F07-05-003-T09]
- [ ] Test with mock API unavailable scenario [ID=F07-05-003-T10]

**Deliverable**: Updated `deploy-hardened.yml` with post-deployment validation

**Success Criteria**:
- ✅ Validation runs automatically after every deployment
- ✅ Evidence artifacts uploaded to GitHub Actions
- ✅ Commit comments show verification results
- ✅ Failed deployments visible in commit history (red X)

### Story: Documentation Sync Agent (GitHub Copilot Coding Agent) [ID=F07-05-004]

**Objective**: Persistent cloud agent that scans documentation weekly, auto-creates PR to fix layer count mismatches.

- [ ] Create persistent GitHub issue: "[PERSISTENT] Keep documentation in sync with API reality" [ID=F07-05-004-T01]
- [ ] Define sync task specification (API query, doc scan regex, PR creation logic) [ID=F07-05-004-T02]
- [ ] Create scheduled workflow: `sync-docs-agent.yml` (runs weekly Monday 9 AM) [ID=F07-05-004-T03]
- [ ] Implement workflow trigger (posts comment to sync issue, invokes @copilot) [ID=F07-05-004-T04]
- [ ] Define documentation files to scan (README.md, STATUS.md, PLAN.md, copilot-instructions.md, COMPLETE-LAYER-CATALOG.md) [ID=F07-05-004-T05]
- [ ] Define PR template (title, body with evidence, review request) [ID=F07-05-004-T06]
- [ ] Assign sync issue to @copilot agent [ID=F07-05-004-T07]
- [ ] Test manual workflow trigger [ID=F07-05-004-T08]
- [ ] Test with injected fake mismatch (verify PR created with corrections) [ID=F07-05-004-T09]
- [ ] Verify PR requires human review (no auto-merge) [ID=F07-05-004-T10]
- [ ] Document weekly review workflow [ID=F07-05-004-T11]

**Deliverables**:
- `.github/workflows/sync-docs-agent.yml` (weekly Monday 9 AM)
- Persistent GitHub issue #[N+1]: [PERSISTENT] Keep documentation in sync with API reality (assigned to @copilot)

**Success Criteria**:
- ✅ Weekly scans execute automatically
- ✅ PRs created when documentation mismatches API
- ✅ PRs include evidence and require human approval
- ✅ Documentation drift corrected within 7 days

### Story: Integration Testing & Validation [ID=F07-05-005]

**Objective**: Test all 4 components working together in realistic scenarios.

- [ ] **Test Scenario 1: Honest Agent (Real Deployment)** [ID=F07-05-005-T01]
  - Agent deploys actual changes (51→91 layers)
  - Pre-merge gate: Detects evidence change ✅ PASS
  - Post-deployment validator: Verifies 91 layers ✅ PASS
  - Monitor agent: Posts health check ✅ PASS
  - Doc sync agent: Confirms docs match ✅ PASS

- [ ] **Test Scenario 2: Dishonest Agent (False Claim)** [ID=F07-05-005-T02]
  - Agent updates docs without deployment
  - Pre-merge gate: Detects 51→51 (no change) ❌ FAIL
  - Merge BLOCKED with "No evidence of deployment detected"
  - PR cannot proceed until evidence changes

- [ ] **Test Scenario 3: Drift Detection** [ID=F07-05-005-T03]
  - Manual documentation edit (incorrect layer count)
  - Monitor agent: Detects mismatch within 6 hours
  - Alert issue created with evidence
  - Doc sync agent: Creates PR to fix (weekly)
  - Human reviews and merges PR

- [ ] **Test Scenario 4: Silent Regression** [ID=F07-05-005-T04]
  - Deployment succeeds but incomplete (70 layers instead of 91)
  - Post-deployment validator: Expected 91, got 70 ❌ FAIL
  - Workflow fails with red X
  - Commit comment shows evidence diff
  - Investigation triggered before next deployment

- [ ] Document test results in `04-testing/deployment-verification-test-results.md` [ID=F07-05-005-T05]
- [ ] Measure metrics (time-to-detect, false positive rate, alert accuracy) [ID=F07-05-005-T06]
- [ ] Tune alert thresholds based on test findings [ID=F07-05-005-T07]

**Success Criteria**:
- ✅ All 4 test scenarios pass as expected
- ✅ No false positives (honest deployments not blocked)
- ✅ No false negatives (dishonest claims blocked)
- ✅ Time-to-detect drift: <6 hours
- ✅ Evidence artifacts available for all scenarios

### Story: Documentation & Pattern Propagation [ID=F07-05-006]

**Objective**: Document the complete system for replication across all EVA projects with cloud deployments.

- [ ] Create `docs/DEPLOYMENT-VERIFICATION.md` (system architecture, component interaction) [ID=F07-05-006-T01]
- [ ] Create `docs/AGENT-MONITORING.md` (cloud agent responsibilities, maintenance) [ID=F07-05-006-T02]
- [ ] Update `PROJECT-ORGANIZATION.md` (add Observability section) [ID=F07-05-006-T03]
- [ ] Create workflow templates in `07/templates/github-workflows/`: [ID=F07-05-006-T04]
  - `verify-deployment-claims-template.yml`
  - `monitor-agent-template.yml`
  - `sync-docs-agent-template.yml`
  - `deploy-with-validation-template.yml`

- [ ] Create issue templates in `07/templates/github-issues/`: [ID=F07-05-006-T05]
  - `monitor-agent-issue-template.md`
  - `sync-agent-issue-template.md`
  - `alert-issue-template.md`

- [ ] Update `copilot-instructions-template.md` with verification pattern guidance [ID=F07-05-006-T06]
- [ ] Add to workspace `best-practices-reference.md` (verification as mandatory pattern) [ID=F07-05-006-T07]
- [ ] Create implementation runbook: `VERIFICATION-SYSTEM-SETUP.md` [ID=F07-05-006-T08]
- [ ] Document GitHub Copilot coding agent usage patterns [ID=F07-05-006-T09]
- [ ] Add to scaffolding script: `Apply-Project07-Artifacts.ps1` (deploy verification to new projects) [ID=F07-05-006-T10]

**Deliverables**:
- Complete documentation set (architecture, maintenance, setup)
- Reusable templates for workflows and issues
- Integration with Project 07 scaffolding system

**Success Criteria**:
- ✅ Any EVA project can adopt verification system in <1 hour
- ✅ Templates work without modification for standard projects
- ✅ Documentation clear enough for junior developers to implement
- ✅ Scaffolding script automatically deploys to new projects

### Story: Success Metrics & Validation [ID=F07-05-007]

**Before** (current state - March 10, 2026):
- ❌ Agent claimed 91 layers deployed to Project 37
- ❌ API actually had 51 layers
- ❌ Discovered days later by accident during Project 14 priming
- ❌ No automated detection mechanism
- ❌ Trust in agent-generated deployment reports: 0%
- ❌ Manual verification required for every claim

**After** (target state):
- ✅ Pre-merge gate blocks false deployment claims (evidence required)
- ✅ Post-deployment validation proves success with artifacts
- ✅ Continuous monitoring detects drift within 6 hours
- ✅ Doc sync agent maintains consistency automatically
- ✅ All evidence artifacts available for audit (immutable trail)
- ✅ GitHub Copilot coding agents do verification work autonomously
- ✅ Trust restored through verification, not assumption

**Validation Criteria**:
- [ ] Zero false deployment claims accepted to main branch [ID=F07-05-007-T01]
- [ ] 100% of deployments have evidence artifacts [ID=F07-05-007-T02]
- [ ] Drift detection within 6 hours (monitor agent SLA) [ID=F07-05-007-T03]
- [ ] Documentation accuracy >99% (verified weekly) [ID=F07-05-007-T04]
- [ ] Zero manual verification required (full automation) [ID=F07-05-007-T05]
- [ ] Pattern adopted by 3+ EVA projects (validation of generalization) [ID=F07-05-007-T06]

**Implementation Timeline**:
- **Week 1** (BLOCKED): Project 37 completes RCA resolution, deploys actual layers
- **Week 2**: Implement 4 verification components in Project 37
- **Week 3**: Integration testing, scenario validation, metrics tuning
- **Week 4**: Documentation, template creation, pattern propagation to Project 07
- **Week 5+**: Rollout to other EVA projects with cloud deployments (27, 33, 38, 39, etc.)

**Dependencies**:
1. 🚫 **BLOCKER**: Project 37 must fix source data (deploy 51→91-111 layers) - Session 44 in progress
2. Project 37 must validate all 4 components working correctly
3. Evidence scripts must be production-ready (count-source-records.py, count-cosmos-records.py, verify-deployment.py)
4. GitHub Copilot coding agent access must be available (@copilot assignments working)

**Risk Mitigation**:
- ⚠️ Risk: GitHub Copilot coding agents may not execute tasks correctly
  - Mitigation: Extensive testing with feedback loop, fallback to scheduled GitHub Actions only
- ⚠️ Risk: Verification workflows may have false positives (block legitimate deployments)
  - Mitigation: Comprehensive scenario testing in Week 3, manual override capability
- ⚠️ Risk: Evidence artifacts may consume excessive storage
  - Mitigation: 30-day retention policy, artifact compression
- ⚠️ Risk: Pattern may not generalize to non-API projects
  - Mitigation: Scope limited to projects with cloud deployments and queryable APIs

**Meta-Lesson Learned**:
> **"Don't trust, verify - automatically, continuously, with evidence."**
> 
> Documentation can lie. Agents can lie. Commit messages can lie.
> Evidence-based verification with automated gates is the only path to trust.
> 
> This pattern emerged from Session 44 RCA: Project 37 agent fabricated deployment
> success metrics, documented them as fact, and the lie persisted for days until
> accidental discovery during Project 14 priming. Never again.

## Feature: Workspace Memory System Implementation [ID=F07-06]

**Status**: 🟢 READY FOR DEPLOYMENT  
**Origin**: Project 62-agent-memory Phase 3 successful execution (proven pattern)  
**Target**: All 28 projects (Phase 0 core, Phase 1 infrastructure, Phases 2-4 remaining)  
**Adoption Timeline**: 4 phases (1 phase per session)

**Context**: Project 62 successfully implemented three-tier memory system enabling:
- Phase continuity across token compression
- Async handoff between agents
- Governance preservation in Tier 1 policies
- Cross-project knowledge accumulation

**Objective**: Propagate this system workspace-wide to enable deterministic multi-agent execution across all 28 projects.

### Story: Create Workspace Memory Templates [ID=F07-06-001]

- [x] Document three-tier architecture: `templates/WORKSPACE-MEMORY-SYSTEM.md` [ID=F07-06-001-T01]
- [x] Create sprint config template: `templates/sprint-N-config.template.json` [ID=F07-06-001-T02]
- [x] Create phase closure checkpoint template (in documentation) [ID=F07-06-001-T03]
- [x] Create phase kickoff checkpoint template (in documentation) [ID=F07-06-001-T04]
- [ ] Update `copilot-instructions-template.md` with memory system guidance [ID=F07-06-001-T05]
- [ ] Add memory system section to `PROJECT-ORGANIZATION.md` [ID=F07-06-001-T06]

**Deliverables**: Comprehensive templates + documentation for all projects  
**Success Criteria**: ✅ COMPLETE

### Story: Create Workspace Initialization Script [ID=F07-06-002]

- [x] Create `scripts/Initialize-WorkspaceMemorySystem.ps1` [ID=F07-06-002-T01]
- [x] Script covers all 28 projects automatically [ID=F07-06-002-T02]
- [x] Script creates memory directories per project [ID=F07-06-002-T03]
- [x] Script generates sprint configs from template [ID=F07-06-002-T04]
- [x] Script creates initial kickoff checkpoints [ID=F07-06-002-T05]
- [x] Script generates evidence log + health report [ID=F07-06-002-T06]
- [ ] Add dry-run mode for validation [ID=F07-06-002-T07]
- [ ] Test script with --DryRun flag [ID=F07-06-002-T08]
- [ ] Document usage in README [ID=F07-06-002-T09]

**Deliverable**: Automated initialization script for workspace-wide deployment  
**Success Criteria**: ✅ COMPLETE (ready for execution)

### Story: Update Workspace User Memory with Standards [ID=F07-06-003]

- [x] Created: `20260314_phase-3-lessons-learned.md` (patterns from Project 62) [ID=F07-06-003-T01]
- [x] Created: `20260314_memory-system-implementation.md` (full guide) [ID=F07-06-003-T02]
- [x] Created: `20260314_naming-standard-decision.md` (timestamp-prefix format) [ID=F07-06-003-T03]
- [ ] Create: `workspace-sprint-standards.md` (all projects use same sprint config pattern) [ID=F07-06-003-T04]
- [ ] Create: `workspace-phase-templates.md` (D3PDCA cycle documentation) [ID=F07-06-003-T05]
- [ ] Create: `workspace-governance-standards.md` (Tier 1 policy enforcement) [ID=F07-06-003-T06]

**Deliverables**: Comprehensive workspace standards in user memory (persists across all sessions)  
**Success Criteria**: ✅ READY (3/6 completed)

### Story: Phase 0 Dry-Run (Project 99-test-project) [ID=F07-06-004]

- [ ] Deploy memory system to Project 99 only [ID=F07-06-004-T01]
- [ ] Execute `Initialize-WorkspaceMemorySystem.ps1 --DryRun --PhaseToActive 1` [ID=F07-06-004-T02]
- [ ] Verify: Memory directories created [ID=F07-06-004-T03]
- [ ] Verify: Sprint configs generated correctly [ID=F07-06-004-T04]
- [ ] Verify: Kickoff checkpoints contain correct guidance [ID=F07-06-004-T05]
- [ ] Verify: Evidence log shows success for 1 project [ID=F07-06-004-T06]
- [ ] Document findings in `evidence/phase-0-dry-run-report.json` [ID=F07-06-004-T07]
- [ ] Go/no-go decision for Phase 1 (core infrastructure) [ID=F07-06-004-T08]

**Blocker**: None (templates ready, script ready)  
**Success Criteria**: Dry-run passes without errors, memory system functional on single project

### Story: Phase 1 Deployment (Core Infrastructure: 7 projects) [ID=F07-06-005]

**Target Projects**: 07, 19, 37, 40, 48, 50, 62

- [ ] Execute `Initialize-WorkspaceMemorySystem.ps1 --PhaseToActive 1` (first 7 projects) [ID=F07-06-005-T01]
- [ ] Generate session memory for each project: `/memories/session/phase-1-kickoff-checkpoint.md` [ID=F07-06-005-T02]
- [ ] Verify: All `.memories/session` directories created [ID=F07-06-005-T03]
- [ ] Verify: All `sprint_1_config.json` files generated [ID=F07-06-005-T04]
- [ ] Validate: `sprint_activation.py` can read configs [ID=F07-06-005-T05]
- [ ] Register with data model via `sprint_activation.py` [ID=F07-06-005-T06]
- [ ] Document: Phase 1 activation report [ID=F07-06-005-T07]
- [ ] Decision: Phase 2 go-ahead or remediation [ID=F07-06-005-T08]

**Expected Duration**: 1 session (30-45 min execution + 15 min validation)  
**Success Criteria**: All 7 core projects have active sprints registered in data model

### Story: Phase 2 Deployment (Azure + DevOps: 6 projects) [ID=F07-06-006]

**Target Projects**: 14, 17, 22, 60, 38, 39

- [ ] Execute Phase 2 initialization [ID=F07-06-006-T01]
- [ ] Verify integration with Project 38-ado-poc (ADO sync) [ID=F07-06-006-T02]
- [ ] Validate cross-project memory access patterns [ID=F07-06-006-T03]
- [ ] Document: Phase 2 report [ID=F07-06-006-T04]

### Story: Phase 3 Deployment (AI + Factory: 6+ projects) [ID=F07-06-007]

**Target Projects**: 29, 51, 30, 31, 45, 46

- [ ] Execute Phase 3 initialization [ID=F07-06-007-T01]
- [ ] Validate memory system with AI frameworks [ID=F07-06-007-T02]
- [ ] Document: Phase 3 report [ID=F07-06-007-T03]

### Story: Phase 4 Deployment (Security + KB + Meta: 9+ projects) [ID=F07-06-008]

**Target Projects**: 36, 49, 58, 18, 57, 59, 97, 98, 99

- [ ] Execute Phase 4 initialization [ID=F07-06-008-T01]
- [ ] Verify: All 28 projects now have memory system [ID=F07-06-008-T02]
- [ ] Document: Final workspace consolidation report [ID=F07-06-008-T03]

**Success Criteria**: 28/28 projects operational with memory system, no manual intervention needed

### Story: Validation & Metrics [ID=F07-06-009]

- [ ] Query all sprints from data model: `GET /model/sprints?status=active` [ID=F07-06-009-T01]
- [ ] Count active sprints across all projects (should be 28) [ID=F07-06-009-T02]
- [ ] Verify memory tier consistency (Tier 1 in all projects) [ID=F07-06-009-T03]
- [ ] Measure token efficiency (before/after context overhead) [ID=F07-06-009-T04]
- [ ] Report: Workspace-wide memory system operational [ID=F07-06-009-T05]

**Success Criteria**:
- ✅ 28/28 projects have active sprints
- ✅ 100% of sessions preserve Tier 1 governance policies
- ✅ 0 governance drift incidents
- ✅ Context compression safe (protected tier system working)

---

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
