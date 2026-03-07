# Session 26 P3 Scope: Governance Toolchain Integration

**Date**: 2026-03-05  
**Session**: Session 26 (Planning only, execution in Session 27)  
**Scope**: Discover + Plan for integrating 6 projects with cloud API  
**Status**: 🔄 PLANNING (DO phase in Session 27)  

---

## DISCOVER Phase: Current Integration Status

### Project-by-Project Assessment

#### 36-red-teaming (Promptfoo Adversarial Testing)
**Current State**:
- [ ] Unknown - needs assessment
- [ ] Likely reads project files directly
- [ ] No known cloud integration

**Integration Opportunity**:
- Query cloud API for test configurations
- Store adversarial test cases in governance layer (L35 when created)
- Report results back to cloud

**Effort**: 🟡 Medium (1-2 hours)

---

#### 37-data-model (Single Source of Truth)
**Current State**:
- ✅ Already cloud-native (IS the cloud API)
- ✅ Session 27: P0 enhancements DEPLOYED to cloud (10/11 endpoints operational)
- ✅ Enhanced agent-guide endpoint active (5 new sections)

**Session 27 Deployment Status**:
- ✅ Schema introspection endpoints: `/model/{layer}/fields`, `/model/{layer}/example`, `/model/{layer}/count`
- ✅ Universal query support: All 34 layers support `?limit=N`, `?field=value`, operators
- ✅ Aggregation endpoints: `/model/evidence/aggregate`, `/model/sprints/{id}/metrics`, `/model/projects/{id}/metrics/trend`
- ✅ Enhanced agent-guide: 5 new sections (discovery_journey, query_capabilities, terminal_safety, common_mistakes, examples)
- ⚠️ Known issue: `/model/schema-def/{layer}` returns 404 (workaround: use `/model/{layer}/fields`)

**Integration Opportunity**:
- Use new endpoints from deployed P0 enhancements
- Migrate from agent-guide to structured query endpoints
- All downstream projects (39, 38, 48, 36, 40) now have cloud API available

**Effort**: ✅ Complete (P0 DELIVERED and DEPLOYED)

---

#### 38-ado-poc (ADO Command Center)
**Current State**:
- [ ] Unknown - likely reads projects.json locally
- [ ] May sync with ADO directly
- [ ] No known cloud governance integration

**Integration Opportunity**:
- Query cloud API for project governance
- Use governance.acceptance_criteria[] for ADO work item mapping
- Bi-directional: Write ADO status back to cloud

**Effort**: 🟡 Medium (2-3 hours)

---

#### 39-ado-dashboard (EVA Home)
**Current State**:
- 🟡 Likely queries evidence.json locally
- 🟡 Renders sprint/project dashboards
- ❌ No cloud API integration for governance

**Integration Opportunity**:
- Query cloud API for projects + governance
- Use aggregation endpoints from Project 37 P0 (sprint metrics)
- Real-time dashboard feeds from cloud

**Effort**: 🟡 Medium (2 hours)

---

#### 40-eva-control-plane (Runtime Evidence Spine)
**Current State**:
- ❓ Ownership boundaries unclear
- 🟡 Likely partial: owns L31 evidence runtime tracking
- 🟡 May read/write evidence.json

**Integration Opportunity**:
- Query cloud API for current evidence state
- Write runtime decisions to L31 (evidence layer)
- Be source of truth for evidence validation

**Effort**: 🟠 High (3-4 hours, depends on ownership clarification)

---

#### 48-eva-veritas (Requirements Traceability + MTI Gating)
**Current State**:
- 🟡 Reads project governance files (README, PLAN, STATUS)
- 🟡 Audits evidence completeness
- ❌ No cloud API integration

**Integration Opportunity**:
- Query cloud API for project metadata
- Query L33 for bootstrap rules (validation gates)
- Report audit results back to cloud (new L35 or extend L31)

**Effort**: 🟡 Medium (2 hours)

---

## PLAN Phase: Integration Task Breakdown

### P3 Priority Matrix

| Project | Status | Complexity | Duration | Priority |
|---------|--------|-----------|----------|----------|
| **37-data-model** | ✅ DEPLOYED (S27) | Complete | 0h | Done |
| **39-ado-dashboard** | 🔄 Ready to integrate | Medium | 2h | 🔴 P1 |
| **38-ado-poc** | 🔄 Ready to integrate | Medium | 2.5h | 🔴 P1 |
| **48-eva-veritas** | 🔄 Ready to integrate | Medium | 2h | 🟡 P2 |
| **36-red-teaming** | 🔄 Ready to integrate | Medium | 1.5h | 🟡 P2 |
| **40-eva-control-plane** | ⏳ Blocked on ownership | High | 3h | 🟠 P3 |

**Status**: Project 37 API is LIVE and OPERATIONAL as of Session 27  
**Total Remaining**: 6.5-8 hours (for projects 39, 38, 48, 36, then 40)

### P3 Proposed Schedule (Sessions 27-28)

**Session 27 Status**: Project 37 P0 API enhancements DEPLOYED and operational ✅

```
Session 27 (4+ hours, cloud API is ready):
├─ Hour 0: Project 37 P0 DEPLOYED + verified (DONE ✅)
├─ Hour 1: 39-ado-dashboard integration (cloud queries)
├─ Hour 1.5: 38-ado-poc integration (ADO sync)
├─ Hour 1: 48-eva-veritas integration (bootstrap + rules)
└─ Hour 0.5: Start 36-red-teaming (or defer)

Session 28 (optional):
├─ 36-red-teaming integration (1.5h, if not done in S27)
└─ 40-eva-control-plane (3h, after ownership clarified)

Blockers Resolved:
✅ Cloud API is OPERATIONAL (Project 37 deployment complete)
✅ All required endpoints available
⏳ Ownership clarification needed for 40-eva-control-plane (scheduled async)
```

---

## Tasks Per Project

### Task P3.1: 39-ado-dashboard Integration

**Objective**: Migrate queries from ado-dashboard to cloud API

**Current Pattern**:
```python
# Today: Read evidence.json locally
evidence = load_json('.eva/evidence/evidence.json')
projects = load_json('model/projects.json')
```

**New Pattern**:
```python
# Tomorrow: Query cloud API
projects = GET /model/projects/?workspace=eva-foundry
evidence = GET /model/evidence/?phase=D3  # for current phase
metrics = GET /model/evidence/aggregate?group_by=phase  # Project 37 P0
```

**Changes Required**:
- [ ] Update project bootstrap to use cloud API
- [ ] Update dashboard data source (evidence query)
- [ ] Add aggregation endpoint consumption
- [ ] Update refresh rate (real-time vs. periodic)

**Files to Modify**:
- `39-ado-dashboard/src/dashboard-service.py` (query logic)
- `39-ado-dashboard/.github/copilot-instructions.md` (API examples)

**Test Cases**:
- [ ] Dashboard loads from cloud (not local files)
- [ ] Sprint metrics calculate correctly
- [ ] Project governance appears in sidebar
- [ ] Performance: < 5 seconds to render

**Blockers**: None (37 has all needed endpoints)

---

### Task P3.2: 38-ado-poc Integration

**Objective**: Use cloud for project/sprint discovery

**Current Pattern**:
```python
# Today: Read projects.json for discovery
projects_json = load('model/projects.json')
for project in projects_json:
    create_ado_project(project['id'])
```

**New Pattern**:
```python
# Tomorrow: Query cloud API
projects = GET /model/projects/?workspace=eva-foundry 
for project in projects:
    create_ado_project(project)
    # Also write governance to ADO work items
    create_work_items_from(project.governance)
```

**Changes Required**:
- [ ] Replace projects.json read with cloud query
- [ ] Add ADO work item creation from governance info
- [ ] Bi-directional: Write ADO status back to cloud
- [ ] Update discovery loop

**Files to Modify**:
- `38-ado-poc/src/project-discovery.py`
- `38-ado-poc/src/ado-sync-service.py`
- `38-ado-poc/.github/copilot-instructions.md`

**Test Cases**:
- [ ] Cloud query returns all projects
- [ ] ADO project creation from cloud data
- [ ] Work item mapping from acceptance criteria
- [ ] Status sync back to cloud

**Blockers**: None (37 has all needed endpoints)

---

### Task P3.3: 48-eva-veritas Integration

**Objective**: Query cloud API for validation + write audit results

**Current Pattern**:
```bash
# Today: Read README/PLAN/STATUS/ACCEPTANCE files
audit_script=$(cat $(find project -name "README.md" -o -name "PLAN.md"))
```

**New Pattern**:
```powershell
# Tomorrow: Query cloud API for governance
$project = GET /model/projects/{project_id}
$rules = GET /model/workspace_config/eva-foundry?fields=bootstrap_rules
validate_project($project, $rules)
```

**Changes Required**:
- [ ] Replace file reading with cloud queries
- [ ] Use workspace bootstrap_rules from L33
- [ ] Query project governance for AC validation
- [ ] Write audit results to evidence layer (L31)

**Files to Modify**:
- `48-eva-veritas/src/audit-engine.js`
- `48-eva-veritas/src/cloud-api-client.js` (new)
- `48-eva-veritas/.github/copilot-instructions.md`

**Test Cases**:
- [ ] Cloud query returns bootstrap rules
- [ ] Audit validation works with cloud data
- [ ] Results written to evidence layer
- [ ] MTI score calculated from cloud + evidence

**Blockers**: None (37 has all needed endpoints)

---

### Task P3.4: 36-red-teaming Integration

**Objective**: Store/query test configurations in cloud

**Current Pattern**:
```yaml
# Today: Hardcoded test configs
test_cases: [...]
scenarios: [...]
```

**New Pattern**:
```python
# Tomorrow: Query cloud for test governance
governance = GET /model/projects/{project_id}
# Use governance.testing_config (if added to schema)
# Or store in new L36 testing_cases layer
test_config = GET /model/testing_cases/?project_id=X
```

**Changes Required**:
- [ ] Clarify where test configs live (new layer?)
- [ ] Query cloud for test governance
- [ ] Report test results back to evidence layer
- [ ] Integration with 48-eva-veritas for result validation

**Files to Modify**:
- `36-red-teaming/src/test-coordinator.js`
- `36-red-teaming/.github/copilot-instructions.md`

**Test Cases**:
- [ ] Test configurations loaded from cloud (or new layer)
- [ ] Test results written to evidence
- [ ] Integration with veritas validation

**Blockers**: Schema decision (where do test configs live?)

---

### Task P3.5: 40-eva-control-plane Clarification

**Objective**: Clarify ownership boundaries, then integrate

**Current Block**: "Clarify 40-eva-control-plane ownership boundaries (which parts 07 owns)"

**Discovery Needed**:
- [ ] What does 40 own? (all of runtime, just evidence, etc.)
- [ ] Is 40 responsible for L31 evidence writes?
- [ ] What's the relationship between 40 and runtime logging?
- [ ] Does 40 orchestrate other projects?

**Next Steps** (Dependent):
- Once ownership clarified, define integration with cloud API
- Likely queries: projects, evidence, workspace_config
- Likely writes: evidence (L31) and project_work (L34) updates

**Effort**: First clarify ownership (1-2h), then integrate (2-3h)

**Who to Ask**: Marco Presta (Project 40 owner)

---

## Success Criteria for P3

### G3.1: Integration Status Matrix
- [ ] All 6 projects assessed (current state + integration strategy)
- [ ] Decision made for each project (do/defer/clarify)
- [ ] Task breakdown complete (files, test cases, blockers)

### G3.2: Dependency Graph
- [ ] Clear: 37 P0 completes first
- [ ] Clear: 39 + 38 + 48 + 36 can run in parallel
- [ ] Clear: 40 blocked on ownership clarification

### G3.3: Timeline
- [ ] Session 27 can complete 39 + 38 + 48 + 36 (4 projects)
- [ ] Session 28 completes 40 (post-clarification)
- [ ] All 6 done by end of Session 28

---

## Risks & Mitigations

| Risk | Probability | Mitigation |
|------|-------------|-----------|
| Project 37 P0 not done on time | Low | Start P3 + P0 in parallel if needed |
| 40 ownership unclear | Medium | Schedule discovery call with Marco |
| API schema changes | Low | Version endpoints, test compatibility |
| ADO integration (38, 39) complex | Medium | Start simple (read-only), enhance later |

---

## Architecture Diagram (All 6 Projects + Cloud)

```
                    Cloud API (37-data-model)
                    ├─ L33: workspace_config
                    ├─ L25: projects
                    ├─ L31: evidence
                    ├─ L34: project_work
                    └─ [New endpoints from P0]
                         │
            ┌────────────┼────────────┐
            │            │            │
            ▼            ▼            ▼
        39-dash      38-ado         48-veritas
      ├─ Query     ├─ Query        ├─ Query
      │ projects   │ projects      │ workspace config
      ├─ Query     ├─ Query        ├─ Query
      │ evidence   │ evidence      │ evidence
      └─ Query     ├─ Write        └─ Write
        metrics    │ ADO status      results
               36-red-team   40-control-plane
               ├─ Query test   ├─ Query evidence
               │ configs       ├─ Query projects
               └─ Write results └─ Write session data
```

---

## Conclusion (P3 Planning)

**P3 is well-scoped and feasible for Session 27.**

- ✅ 4 projects ready to integrate immediately (37 P0 prerequisite)
- 🔄 1 project (48-veritas) straightforward
- ⚠️ 1 project (40) needs ownership clarification first

**Recommended Execution**: Session 27 focuses on 4 projects, Session 28 adds 40 post-clarification.

**Next**: Execute in Session 27 (DO phase)

---

*Generated: 2026-03-05 by Copilot / EVA Foundation*  
*Reference: SESSION-26-P1-P4-PLAN.md → Scope Documentation*
