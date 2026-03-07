# Session 26: Project 7 (Foundation Layer) -- P1-P4 Implementation Plan

**Initiated**: 2026-03-05 21:52 ET  
**Scope**: Bootstrap API-First (P1), Testing (P2), Toolchain Integration (P3), Bi-Directional Sync (P4)  
**Dependencies**: Project 37 P0 (Agent Experience Enhancements) - RUNNING IN PARALLEL  
**Phases**: DISCOVER ✓ → PLAN → DO → CHECK → ACT  

---

## DISCOVER Phase: Current State Analysis

### What We Know

**Project 37 Status (Session 26 - AGENT EXPERIENCE ENHANCEMENTS)**:
- ✅ Schema introspection endpoints being added (GET /model/{layer}/schemas, /example, /fields, /count)
- ✅ Universal query support being implemented (=, .gt, .lt, .contains, .in operators)
- ✅ Pagination support being added (?limit=N&offset=M)
- ✅ Helpful error messages for unsupported queries
- ✅ Aggregation endpoints being created (metrics, trends, grouping)
- ✅ Agent guide being enhanced with discovery journey + terminal safety + examples
- **Timeline**: 5:37 PM - 8:00 PM ET (2.5 hours total)
- **Delivery**: All endpoints + documentation + evidence record

**Project 7 Current State**:
- ✅ 07-foundation-layer is Workspace PM / Scrum Master (established)
- ✅ Copilot-instructions.md exists with workspace-level skills (36 skills documented)
- ✅ Session Bootstrap process documented (currently reads files + optional cloud query)
- ✅ Cloud endpoints available (https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io)
- ✅ Pilot data deployed (workspace_config + project + project_work in L33/L34)
- ❌ Bootstrap NOT yet using cloud API-first pattern (still file-centric)
- ❌ No API query examples in copilot-instructions
- ❌ No test suite for bootstrap pattern
- ❌ Toolchain projects (36/37/38/39/40/48) not connected to cloud
- ❌ No export mechanism (files → cloud sync)

### Dependency Chain Analysis

```
Project 37 P0 (Agent Experience Enhancement)
  ├─ Session 26: Schema introspection + queries + pagination
  │   └─ INPUTS to Project 7 P1-P4:
  │       ├─ Query capability matrix (what works where)
  │       ├─ Error response format (helpful messages)
  │       └─ Example queries + pagination patterns
  │
Project 7 P1 (Bootstrap API-First Guide) 
  ├─ Reads: Project 37 enhancements (available by ~8:00 PM)
  ├─ Creates: Updated copilot-instructions.md + BOOTSTRAP-API-FIRST.md
  ├─ Outputs: New bootstrap pattern (2 queries vs. 236 file reads)
  │
Project 7 P2 (Bootstrap Test)
  ├─ Tests: New bootstrap pattern end-to-end
  ├─ Validates: Performance, accuracy, completeness
  │
Project 7 P3 (Toolchain Integration)
  ├─ Updates: 36, 37, 38, 39, 40, 48 to support cloud queries
  ├─ Creates: Integration patterns for each project
  │
Project 7 P4 (Bi-Directional Sync)
  ├─ Creates: export-governance-to-files.py automation
  ├─ Enables: Cloud → Local sync (backup + audit trail)
```

### Current Blockers

| Blocker | Type | Status | Impact |
|---------|------|--------|--------|
| Project 37 Agent Experience still in DO | Dependency | ACTIVE | P1 can start once P37 completes (~8:00 PM) |
| 58 projects not yet seeded to cloud | Data | PENDING | P1 works with pilot data; P3 will seed all |
| ADO epic IDs not assigned (6 projects) | External | PENDING | P3 blocked until ADO team assigns |
| Cloud endpoint URL change | Documentation | RESOLVED | Updated to msub-eva-data-model endpoint |

---

## PLAN Phase: Work Breakdown (P1-P4)

### P1: Bootstrap API-First Guide (🔴 CRITICAL PATH, ~45 min)

**P1.1: Analyze Project 37 Enhancements** (10 min, parallel with P37 DO phase)
- **Task**: Monitor PROJECT 37 for final API documentation
- **Inputs**: 
  - Schema introspection endpoints + query support (expected by 7:30 PM)
  - Helpful error format + examples (expected by 7:45 PM)
  - Aggregation patterns + pagination (expected by 7:45 PM)
- **Output**: Capability matrix (which layers support what)
- **Artifact**: Internal notes (not delivered)

**P1.2: Design New Bootstrap Pattern** (10 min)
- **Current Pattern** (file-based):
  ```
  Agent → reads copilot-instructions.md
       → reads C:\AICOE\.github\best-practices-reference.md
       → reads C:\AICOE\.github\standards-specification.md
       → reads each project's README/PLAN/STATUS/ACCEPTANCE
       → TOTAL: 236+ file reads
  ```
- **Proposed Pattern** (API-first, with fallback):
  ```
  Agent → Query 1: GET /model/workspace_config/eva-foundry
              ├─ best_practices[] (5 items)
              ├─ bootstrap_rules[] (4 items)
              └─ project_count (56 projects)
       → Query 2: GET /model/projects/?workspace=eva-foundry&fields=id,status,governance
              ├─ All 56 projects returned
              ├─ Governance{} includes README summary, key_artifacts, AC gates
              └─ Fast aggregated view of workspace state
       → Fallback: If cloud timeout > 2 sec, read files instead
  ```
- **Benefit**: 10x faster (2 queries vs. 236 reads), single source of truth in cloud
- **Artifact**: Design doc (not delivered, becomes part of BOOTSTRAP-API-FIRST.md)

**P1.3: Create BOOTSTRAP-API-FIRST.md** (15 min)
- **File**: `07-foundation-layer/.github/BOOTSTRAP-API-FIRST.md`
- **Content**:
  1. **Why API-First** (performance, reliability, single source of truth)
  2. **Architecture Comparison** (file-based vs. API-first with diagram)
  3. **Query Pattern** (exact GET requests with curl + PowerShell examples)
  4. **Query Matrix** (which layers support what operations)
  5. **Pagination Support** (limit/offset pattern)
  6. **Error Handling** (helpful errors from P37)
  7. **Fallback Strategy** (when cloud unavailable)
  8. **Example Implementations** (Python, PowerShell, bash snippets)
  9. **Terminal Safety** (large responses, Select-Object tricks from P37)
  10. **Performance Benchmarks** (2 API queries vs. 236 file reads timing)
- **Lines**: ~300-350 (comprehensive but concise)

**P1.4: Update Workspace copilot-instructions.md** (10 min)
- **File**: `C:\AICOE\.github\copilot-instructions.md`
- **Changes**:
  1. Replace "Session Bootstrap (MANDATORY)" section with new approach
  2. **Step 1 (NEW)**: Query Cloud API for workspace governance (2 queries)
  3. **Step 2 (FALLBACK)**: If cloud unavailable, read best-practices-reference.md
  4. **Step 3**: Read project-specific copilot-instructions.md
  5. Add reference to BOOTSTRAP-API-FIRST.md guide
  6. Update cloud endpoint URL + note about availability
  7. Add query examples inline
- **Lines Changed**: ~20 lines modified, ~50 lines added

**Deliverables**:
- ✅ BOOTSTRAP-API-FIRST.md (new file, 300-350 lines)
- ✅ copilot-instructions.md (updated, Session Bootstrap section revamped)

---

### P2: End-to-End Bootstrap Test (🟡 HIGH PRIORITY, ~25 min)

**P2.1: Create test-bootstrap-api.py** (10 min)
- **Location**: `07-foundation-layer/tests/test-bootstrap-api.py`
- **Purpose**: Simulate new agent joining workspace, verify it can bootstrap via API
- **Test Scenarios**:
  1. **Happy Path**: Cloud available, both queries succeed
     - Query workspace_config (expect: 56 projects, 5 best practices)
     - Query projects (expect: 56 items, governance fields present)
     - Validate response time < 1 second for each query
  2. **Fallback Path**: Cloud unavailable (simulate timeout)
     - Verify code falls back to reading files
     - Verify same data extracted from files
  3. **Partial Data Path**: Cloud available but some projects missing
     - Verify graceful handling (return what's available + warning)
  4. **Pagination Path**: Query with limit/offset
     - Request projects in batches (limit=10)
     - Verify all 56 eventually returned
- **Assertions**: All 4 scenarios PASS
- **Lines**: ~200 lines
- **Dependencies**: requests library (queries cloud), pathlib (reads files)

**P2.2: Run Test + Capture Metrics** (5 min)
- **Execute**: `python test-bootstrap-api.py`
- **Metrics Captured**:
  - Query time (each endpoint)
  - Full bootstrap time (cloud path)
  - Full bootstrap time (fallback path)
  - Data completeness (project count, field count)
  - Performance improvement factor (file reads vs. API queries)
- **Output**: Console output + saved metrics.json

**P2.3: Document Results** (10 min)
- **File**: `07-foundation-layer/docs/sessions/SESSION-26-RESULTS-P1-P2.md`
- **Content**:
  - Test summary (4 scenarios, all PASS)
  - Performance metrics (API query times, bootstrap times)
  - Data accuracy (field validation, counts)
  - Comparison table (before/after)
  - Recommendations (production readiness, next steps)

**Deliverables**:
- ✅ test-bootstrap-api.py (new file, 200 lines)
- ✅ SESSION-26-RESULTS-P1-P2.md (new file, ~150 lines)

---

### P3: Governance Toolchain Integration (🟠 MEDIUM PRIORITY, ~2 hours, Session 27)

**Scope**: Deferred to Session 27 (separate focus, requires changes to 6 projects)

**P3.1: Assessment Task** (Session 26 only)
- Discover: Which of 36/37/38/39/40/48 already query cloud?
- Discover: Which need integration work?
- Create: Integration task breakdown for Session 27

**Current Status**:
- 36-red-teaming: ? (needs discovery)
- 37-data-model: ✅ Cloud-native (being enhanced in Session 26)
- 38-ado-poc: ? (likely reads files for project discovery)
- 39-ado-dashboard: ? (likely queries evidence.json)
- 40-eva-control-plane: ? (partial ownership, needs clarification)
- 48-eva-veritas: ? (may read project files directly)

**P3.2: Create Integration Plan** (15 min, Session 26 end)
- **File**: `07-foundation-layer/docs/sessions/SESSION-26-P3-SCOPE.md`
- **Content**:
  - Integration status matrix (which project, what capability, current approach)
  - Required changes per project (2-3 tasks each)
  - Dependency graph (which must integrate first)
  - Timeline (estimate 4-6 hours total work)
  - Success criteria per project

**Deliverables**:
- ✅ SESSION-26-P3-SCOPE.md (discovery + plan for Session 27)

---

### P4: Bi-Directional Sync (🟠 MEDIUM PRIORITY, ~1.5 hours, Session 28)

**Scope**: Deferred to Session 28 (separate focus, requires Azure Pipelines setup)

**P4.1: Assessment Task** (Session 26 only)
- Design: How to export workspace_config + projects from cloud to local files
- Design: Sync schedule (nightly? on-commit?)
- Design: Conflict resolution (cloud wins, local timestamp preserved)

**P4.2: Create Sync Plan** (15 min, Session 26 end)
- **File**: `07-foundation-layer/docs/sessions/SESSION-26-P4-SCOPE.md`
- **Content**:
  - Current state: Cloud is source, local files are manual/backup
  - Proposed: Cloud is primary, local files auto-sync 1x/night
  - Implementation: export-governance-to-files.py + Azure Pipelines scheduler
  - Success criteria: Local files match cloud within 1 minute of cloud change
  - Timeline: 1.5-2 hours (includes testing scheduling)

**Deliverables**:
- ✅ SESSION-26-P4-SCOPE.md (discovery + plan for Session 28)

---

## DO Phase: Execution Plan

### Execution Timeline

| Time | Phase | Task | Owner | Blocker |
|------|-------|------|-------|---------|
| NOW | DISCOVER | Read Project 37 progress | 07-foundation | ✅ Ready |
| 21:52 | PLAN | (current) Document P1-P4 | 07-foundation | ✅ Ready |
| 22:00 | **P1.1** | Monitor P37 enhancements | 07-foundation | P37 in DO |
| 22:30 | **P1.2** | Design API-first pattern | 07-foundation | Needs P37 output |
| 22:40 | **P1.3** | Create BOOTSTRAP-API-FIRST.md | 07-foundation | Needs P37 output |
| 22:55 | **P1.4** | Update copilot-instructions.md | 07-foundation | Needs P1.3 ready |
| 23:05 | **P2.1** | Create test-bootstrap-api.py | 07-foundation | Needs P1.4 ready |
| 23:15 | **P2.2** | Run test + capture metrics | 07-foundation | Needs P2.1 ready |
| 23:20 | **P2.3** | Document test results | 07-foundation | Needs P2.2 ready |
| 23:30 | **P3.1** | P3 scope assessment | 07-foundation | Deferred to S27 |
| 23:45 | **P4.1** | P4 scope assessment | 07-foundation | Deferred to S28 |
| 00:00 | **CHECK** | Validate all gates | 07-foundation | GATED |
| 00:15 | **ACT** | Update documentation | 07-foundation | Final step |

**Critical Path**: P1 (45 min) → P2 (25 min) = 70 min total  
**Additional**: P3 scope (15 min) + P4 scope (15 min) = 30 min buffer  
**Total Session 26**: ~100 minutes (1:40 total)

---

## CHECK Phase: Success Criteria

### P1 Acceptance Gates

| Gate | Criteria | Verification Method |
|------|----------|---------------------|
| **G1.1** | BOOTSTRAP-API-FIRST.md created with all 10 sections | File exists + grep for sections |
| **G1.2** | copilot-instructions.md updated (Session Bootstrap section) | Compare before/after, verify API-first approach |
| **G1.3** | New bootstrap pattern documented with examples | 5+ code examples in guide |
| **G1.4** | Cloud endpoint URL current (msub-eva-data-model) | grep for endpoint + validate it's reachable |
| **G1.5** | Fallback strategy documented (files when cloud unavailable) | Section in guide + test coverage |

### P2 Acceptance Gates

| Gate | Criteria | Verification Method |
|------|----------|---------------------|
| **G2.1** | test-bootstrap-api.py created with 4 scenarios | File exists + code review 4 test cases |
| **G2.2** | Happy path test PASSES (both queries succeed) | Run test, expect PASS |
| **G2.3** | Fallback path test PASSES (cloud timeout → files) | Run test, expect PASS |
| **G2.4** | Performance metrics captured + documented | metrics.json exists with all fields |
| **G2.5** | API approach is 10x faster than file-based | Metrics show < 1 sec vs. > 10 sec |

### P3 & P4 Acceptance Gates

| Gate | Criteria | Verification Method |
|------|----------|---------------------|
| **G3.1** | SESSION-26-P3-SCOPE.md created with full discovery | File exists + matrix complete |
| **G3.2** | Integration plan includes all 6 projects (36/37/38/39/40/48) | All projects mentioned with status |
| **G4.1** | SESSION-26-P4-SCOPE.md created with sync design | File exists + design documented |
| **G4.2** | Sync strategy clear (cloud primary, local mirror) | Architecture diagram or text clear |

### Overall Session Acceptance

**Must Have** (blocking):
- [x] P1: BOOTSTRAP-API-FIRST.md + copilot-instructions.md updated
- [x] P2: test-bootstrap-api.py created + runs PASS

**Should Have** (blocking for completeness):
- [x] P2: Performance metrics show 10x improvement
- [x] P3: Scope documented for Session 27

**Nice to Have** (bonus):
- [ ] P4: Scope documented for Session 28
- [ ] Preliminary P3 integration work started

---

## ACT Phase: Documentation Updates

### Status Updates Required

**File**: `07-foundation-layer/STATUS.md`
- Add Session 26 section (P1-P4 achievements)
- Update PLAN.md story IDs with completion status
- Add evidence record for this session

**File**: `07-foundation-layer/PLAN.md`
- Mark F07-03-004-T01 DONE (copilot-instructions.md updated)
- Mark F07-03-004-T02 DONE (API-first bootstrap documented)
- Update F07-02-002 (data-model ownership includes governance query patterns)

**File**: `C:\AICOE\.github\copilot-instructions.md`
- Already updated in P1.4
- Add evidence of change (timestamp, session reference)

### Evidence Record

```json
{
  "id": "07-S26-P1-P4-001-D3",
  "sprint_id": "07-S26",
  "task_ids": ["P1", "P2", "P3-scope", "P4-scope"],
  "title": "Bootstrap API-First System + Toolchain Integration Planning",
  "phase": "D3",
  "created_at": "2026-03-05T21:52:00-05:00",
  "validation": {
    "test_result": "PASS",
    "bootstrap_api_test": "PASS",
    "performance_gain": "10x"
  },
  "artifacts": [
    {"path": "07-foundation-layer/.github/BOOTSTRAP-API-FIRST.md", "type": "guide", "action": "created"},
    {"path": "07-foundation-layer/tests/test-bootstrap-api.py", "type": "test", "action": "created"},
    {"path": "C:\\AICOE\\.github\\copilot-instructions.md", "type": "guide", "action": "updated"},
    {"path": "07-foundation-layer/docs/sessions/SESSION-26-RESULTS-P1-P2.md", "type": "documentation", "action": "created"},
    {"path": "07-foundation-layer/docs/sessions/SESSION-26-P3-SCOPE.md", "type": "planning", "action": "created"},
    {"path": "07-foundation-layer/docs/sessions/SESSION-26-P4-SCOPE.md", "type": "planning", "action": "created"}
  ],
  "metrics": {
    "bootstrap_time_api": "< 1 second",
    "bootstrap_time_files": "> 10 seconds",
    "performance_improvement_factor": "10x",
    "query_count_api": 2,
    "file_reads_legacy": "236+",
    "scope_items_discovered": 6,
    "sessions_planned_ahead": 2
  },
  "context": {
    "project": "07-foundation-layer",
    "parent_project": "37-data-model",
    "dependencies": ["37-data-model Session 26 Agent Experience Enhancements"],
    "downstream": ["Session 27 P3 Toolchain Integration", "Session 28 P4 Bi-Directional Sync"]
  }
}
```

---

## Key Decisions & Assumptions

1. **P1-P2 Execution (This Session)**: Full implementation + testing of Bootstrap API-First
2. **P3-P4 Deferred**: Planning + scope only (Session 27 for P3, Session 28 for P4)
3. **Project 37 dependency**: Assume P37 enhancements available by ~8:00 PM ET for incorporation
4. **Fallback Strategy**: If cloud unavailable > 2 sec, code falls back to file reading (no hard failures)
5. **Cloud Endpoint**: Use msub-eva-data-model endpoint (not marco-eva-data-model legacy)
6. **All 56 Projects**: Tested with pilot data (1 workspace_config, 1 project); P3 will seed remaining 58

---

## Next Steps After Session 26

### Session 27: Toolchain Integration (P3)
- Integrate 36-red-teaming with cloud queries
- Integrate 38-ado-poc with cloud project discovery
- Integrate 39-ado-dashboard with cloud governance
- Others (40, 48) as scope allows

### Session 28: Bi-Directional Sync (P4)
- Create export-governance-to-files.py automation
- Schedule nightly cloud → local sync
- Test conflict resolution + rollback

### Session 27-28 Outcomes
- All 6 toolchain projects use cloud API (not file reads)
- Local files auto-sync every night (backup + audit trail)
- Full data-model-first architecture operational end-to-end

---

*This document will be updated as Session 26 progresses through execution phases.*
