# Session 26: Bootstrap Project 7 -- Foundation Layer Governance Scaling

**Initiated**: 2026-03-05 21:42 ET  
**Scope**: Governance plane seeding + bootstrap overhaul + toolchain integration  
**Phase**: DISCOVER (→ PLAN → DO → CHECK → ACT)  
**Owner**: Copilot / EVA Foundation  

---

## DISCOVER Phase: Current State Assessment

### What We Have (✅ Operational)

**Session 7 (March 3) Achievements**:
- Eva-factory.config.yaml (400+ lines) - Configuration-as-Product ✅
- config_loader.py (287 lines) - Portable configuration library ✅
- sync-evidence-all-projects.py (565 lines) - Configuration-driven orchestrator ✅
- DEPLOYMENT-GUIDE.md (800+ lines) - Multi-environment deployment patterns ✅

**Session 25 (March 5) Achievements**:
- Governance Plane deployed to Azure Cloud ✅
- L33 (workspace_config), L34 (project_work), L25 (projects) operational ✅
- REST API endpoints verified (health, /model/workspace_config/, /model/project_work/, /model/projects/) ✅
- Pilot seed deployed: 1 workspace_config + 1 project + 1 project_work ✅
- Data-model-first architecture proven (2 API calls vs. 236 file reads) ✅

**Current Blockers** (from NEXT-STEPS.md):
- [ ] P1: Seed 58 remaining projects into cloud (ready, ~10 min task)
- [ ] P1: Update copilot-instructions.md for data-model-first bootstrap
- [ ] P1: Test bootstrap flow end-to-end

**External Dependency**:
- [ ] P0: ADO epic ID assignment for 6 new projects (34-AIRA, 50-eva-ops, 51-ACA, 52-DA, 53, 54)

---

### What We Need (🔄 In Scope for This Session)

#### 1. **Governance Plane: Complete Seeding (58 Projects)**
   - Task: Seed workspace_config + all 56 projects into Cosmos DB
   - Input: Governance docs (README, PLAN, STATUS, ACCEPTANCE) from each project  
   - Output: All L33 + L25 records populated in cloud
   - Benefit: ANY agent/tool can query workspace governance from API (not files)
   - Complexity: **LOW** - Same pattern as Session 25 pilot
   - Time: **~10 minutes**

#### 2. **Bootstrap Process Overhaul: API-First**
   - Task: Create new bootstrap pattern that queries cloud instead of reading files
   - Current: Agent reads 236 files (README, PLAN, STATUS, ACCEPTANCE across projects)
   - Proposed: Agent queries 2 endpoints (`/model/workspace_config/eva-foundry`, `/model/projects/?workspace=eva-foundry`)
   - Output: Updated copilot-instructions.md with new bootstrap guide
   - Benefit: 10x faster project initialization, single source of truth in cloud
   - Complexity: **MEDIUM** - Design phase + implementation
   - Time: **~20 minutes**

#### 3. **Governance Toolchain Integration**
   - Task: Connect 36, 37, 38, 39, 40, 48 to cloud data model
   - Issues: These projects (red-teaming, data-model, ADO, dashboard, control-plane, veritas) own governance but don't integrate yet
   - Opportunity: They can now READ governance from API + WRITE updates back
   - Complexity: **HIGH** - Requires changes to 6 projects
   - Time: **~2 hours (P2 priority)**

#### 4. **Bi-Directional Sync (File ↔ Cloud)**
   - Task: Enable local files to sync TO cloud (not just cloud downward)
   - Pattern: `export-governance-to-files.py` (cloud → local, nightly backup)
   - Benefit: Cloud is primary, local files stay in sync for backup + tools like grep
   - Complexity: **MEDIUM** - Script + scheduler setup
   - Time: **~1 hour (P2 priority)**

---

### Acceptance Criteria for Session 26

| Gate | Target | Notes |
|------|--------|-------|
| **G1** | All 56 projects in L25 (cloud) | Verify: `GET /model/projects/?workspace=eva-foundry` returns 56 |
| **G2** | workspace_config in L33 (cloud) | Verify: `GET /model/workspace_config/eva-foundry` contains 56 projects + bootstrap rules |
| **G3** | New bootstrap guide documented | File: 07-foundation-layer/.github/BOOTSTRAP-API-FIRST.md |
| **G4** | copilot-instructions.md updated | Reference new API-first pattern + cloud endpoint |
| **G5** | All endpoints tested PASS | 4 endpoints verified: health, L33, L34, L25 |
| **G6** | No regressions in existing patterns | Verify: session 7 config system still works |

---

## PLAN Phase: Proposed Work Breakdown

### P0: Governance Plane Seeding (🔴 CRITICAL PATH)

**P0.1: Create seed-governance-all.py**
- Read: All project governance docs (56 × 4 = 224 files)
- Parse: Extract governance metadata (README, PLAN, STATUS, ACCEPTANCE)
- Transform: Convert to L25/L33 schema (projects[], workspace_config)
- Load: POST to `/model/projects/` + `/model/workspace_config/`
- Validate: All 56 projects returned by GET query
- **Artifact**: `37-data-model/scripts/seed-governance-all.py` (~200 lines)
- **Time**: ~5 minutes to write, ~5 minutes to test

**P0.2: Run seed + verify**
- Execute: `python seed-governance-all.py --workspace=eva-foundry`
- Validate: 56 projects in cloud ✅
- Document: Seeding results in SESSION-26-RESULTS.md
- **Time**: ~5 minutes

**Status**: Ready to execute (no external dependencies)

---

### P1: Bootstrap API-First Guide (🟡 HIGH PRIORITY)

**P1.1: Design API-first bootstrap pattern**
- Current flow: Copilot reads copilot-instructions.md → reads 236 files → bootstraps context
- New flow: Copilot queries cloud → reads 2 endpoints → bootstraps context same result, 10x faster
- Example queries:
  ```
  GET /model/workspace_config/eva-foundry?fields=bootstrap_rules,best_practices
  GET /model/projects/?workspace=eva-foundry&fields=id,status,governance
  ```
- **Artifact**: Documented in BOOTSTRAP-API-FIRST.md
- **Time**: ~10 minutes

**P1.2: Create BOOTSTRAP-API-FIRST.md**
- Content:
  1. Why API-first (performance, single source of truth)
  2. How it works (2-query pattern vs 236 file reads)
  3. When to use (prefer this for any new agent)
  4. Query examples (with curl + Python)
  5. Fallback pattern (if cloud unavailable, use files)
- **Artifact**: 07-foundation-layer/.github/BOOTSTRAP-API-FIRST.md (~200 lines)
- **Time**: ~10 minutes

**P1.3: Update main copilot-instructions.md**
- Add section: "Bootstrap Approach" pointing to BOOTSTRAP-API-FIRST.md
- Update: "Session Bootstrap (MANDATORY)" to reference cloud queries
- Verify: All references to cloud endpoint are current
- **Artifact**: C:\eva-foundry\.github\copilot-instructions.md (update)
- **Time**: ~5 minutes

**Status**: Blocked by P0 (need L33/L25 seeded first so queries work)

---

### P2: End-to-End Bootstrap Test (🟡 HIGH PRIORITY)

**P2.1: Create test-bootstrap-api.py**
- Simulate: New agent joining workspace
- Query: cloud endpoints for governance
- Compare: Results vs. file-based bootstrap
- Metrics: Query time, completeness, data accuracy
- **Artifact**: 07-foundation-layer/tests/test-bootstrap-api.py (~150 lines)
- **Time**: ~10 minutes

**P2.2: Run test + report**
- Execute: test-bootstrap-api.py
- Capture: Query times, result counts, data samples
- Document: Results in SESSION-26-RESULTS.md
- **Time**: ~5 minutes

**Status**: Depends on P0 + P1 passing

---

### P3: Governance Toolchain Integration (🔵 MEDIUM PRIORITY, Separate Session)

**Not in scope for Session 26** -- requires changes to 6 projects.  
Recommend: Session 27 (separate focus on 36/37/38/39/40/48 integration)

---

### P4: Bi-Directional Sync (🔵 MEDIUM PRIORITY, Separate Session)

**Not in scope for Session 26** -- requires scheduler setup.  
Recommend: Session 28 (separate focus on export automation)

---

## Next Steps (User Approval Needed)

**Ready to Execute** (P0):
1. ✅ Create seed-governance-all.py
2. ✅ Run seed + verify (all 56 projects in cloud)
3. ✅ Document results

**Ready Next** (P1, depends on P0):
4. ✅ Design + document API-first bootstrap pattern
5. ✅ Update copilot-instructions.md
6. ✅ Create BOOTSTRAP-API-FIRST.md guide

**Ready Finally** (P2, depends on P0 + P1):
7. ✅ Create + run bootstrap test
8. ✅ Document test results + performance metrics

**Deferred** (P3 + P4, separate sessions):
- Session 27: Toolchain integration (36/37/38/39/40/48)
- Session 28: Bi-directional sync automation

---

## Questions Before We Start DO Phase

**User Input Needed**:

1. **Seeding Query**: When creating seed-governance-all.py, should it:
   - A) Try to parse PLAN.md story IDs from markdown (complex parsing)
   - B) Just extract available governance docs metadata (simpler, faster)
   - *Recommendation*: B for Session 26, can enhance in Session 27

2. **Bootstrap Fallback**: If cloud endpoint times out, should new bootstrap:
   - A) Fall back to file-based immediately (safe, slower)
   - B) Retry with backoff (prefers cloud, graceful degradation)
   - C) Raise error (require cloud always)
   - *Recommendation*: A for stability

3. **Scope Lock**: Should Session 26 include:
   - A) P0 + P1 + P2 (all 3).......→ **~30 minutes, tight**
   - B) P0 + P1 only (skip P2 testing) → **~20 minutes, faster**
   - C) P0 only (seeding first, test later) → **~10 minutes, minimal**
   - *Recommendation*: A (comprehensive) or B (if time-constrained)

---

## Session 26 Timeline (Estimated)

| Phase | Task | Time |
|-------|------|------|
| **DO** | Create seed-governance-all.py | 5 min |
| **DO** | Run seed + verify | 5 min |
| **DO** | Design + document API-first pattern | 10 min |
| **DO** | Create BOOTSTRAP-API-FIRST.md | 10 min |
| **DO** | Update copilot-instructions.md | 5 min |
| **DO** | Create + run bootstrap test | 15 min |
| **CHECK** | Verify all acceptance gates PASS | 5 min |
| **ACT** | Document results + next steps | 5 min |
| **TOTAL** | | **~60 minutes** |

**Compressed (P0 + P1 only)**: ~30 minutes

---

*This document will be updated as Session 26 progresses through PLAN → DO → CHECK → ACT phases.*
