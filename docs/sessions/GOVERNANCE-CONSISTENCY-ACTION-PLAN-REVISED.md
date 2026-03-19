# Governance Consistency Action Plan (REVISED)

**Date**: March 10, 2026 @ 6:06 AM ET  
**Revision**: 2.0 (Post-Session 43 API Discovery)  
**Methodology**: Fractal DPDCA Applied  
**Context**: Session 43 deployed `/model/user-guide` with 6 category runbooks

---

## DISCOVER Phase Results (Completed @ 7:07 AM ET)

### What Changed in Session 43

**Deployment**: Revision 0000028 @ 04:50 AM ET  
**Key Deliverable**: `/model/user-guide` endpoint with deterministic runbooks

**API Structure Confirmed**:
```json
{
  "status": "ok",
  "source": "data-model-api",
  "paperless": {
    "authority": "data-model-api",
    "bootstrap": ["GET /model/agent-guide", "GET /model/user-guide", ...],
    "write_cycle": {"correct": "PUT /model/project_work/{id}", ...},
    "not_supported": "POST /model/project_work/"
  },
  "category_instructions": {
    "session_tracking": { "layer": "project_work", "id_format": {...}, "query_sequence": [...], "anti_trash_rules": [...], "common_mistakes": [...] },
    "sprint_tracking": { "layer": "sprints", ... },
    "evidence_tracking": { "layer": "evidence", ... },
    "governance_events": { "layer": null (multi-layer), ... },
    "infra_observability": { ... },
    "ontology_domains": { ... }
  }
}
```

**Impact**: Workspace instructions mention these categories exist, but templates DON'T show how to use them.

---

## PLAN Phase: Revised Action Items

### Priority 0: OBSOLETE (Solved by Session 43)

| Original Item | Status | Reason |
|---------------|--------|--------|
| Document Session 43 Deliverables | ✅ SOLVED | `/model/user-guide` IS the deliverable + SESSION-43-DEPLOYMENT-COMPLETE.md exists |
| Add `/model/user-guide` reference | ✅ SOLVED | Endpoint exists with 6 categories |

---

### Priority 1: CRITICAL (Do Now - Session 43 Continuation)

#### 1.1 Fix Layer Count in Templates (5 minutes)
**Issue**: 3 files say "111 operational layers (87 base + 24 execution)"  
**Should Be**: "111 target layers (91 operational + 20 planned)"

**Files to Update**:
- [x] `C:\eva-foundry\.github\copilot-instructions.md` (line 12) - ✅ Already correct
- [ ] `07-foundation-layer/templates/copilot-instructions-workspace-template.md` (line 12)
- [ ] `07-foundation-layer/templates/copilot-instructions-workspace-template.md` (line 102)
- [ ] `07-foundation-layer/templates/copilot-instructions-template.md` (line 22)

**Replacement Pattern**:
```markdown
# WRONG
111 operational layers (87 base + 24 execution)

# CORRECT
111 target layers (91 operational + 20 planned)
```

**Breakdown** (for inline comments):
- 91 operational = 87 base (L1-L51 + 36 organic) + 4 execution Phase 1 (L52-L55)
- 20 planned = 16 execution Phase 2-4 (L56-L70) + 4 strategy (L71-L75)

---

#### 1.2 Update Workspace Instructions Timestamp (1 minute)
**Current**: March 10, 2026 @ 03:15 ET (Session 43)  
**Update To**: March 10, 2026 @ 6:06 AM ET (Session 43 - Governance Consistency Audit)

**File**: `C:\eva-foundry\.github\copilot-instructions.md` (line 5)

---

#### 1.3 Add User-Guide Bootstrap to Templates (15 minutes)
**Issue**: Templates show only `agent-guide` in bootstrap, missing `user-guide`

**Current Bootstrap** (templates):
```powershell
$session = @{ 
    base = $base
    guide = (Invoke-RestMethod "$base/model/agent-guide")
}
```

**Should Be**:
```powershell
$session = @{ 
    base = $base
    guide = (Invoke-RestMethod "$base/model/agent-guide")
    userGuide = (Invoke-RestMethod "$base/model/user-guide")
}
```

**Files to Update**:
- [ ] `07-foundation-layer/templates/copilot-instructions-template.md` (lines 28-44 bootstrap section)
- [ ] `07-foundation-layer/templates/copilot-instructions-workspace-template.md` (lines 76-92 bootstrap section)

**Add After Bootstrap Block**:
```markdown
# You now have access to:
# - $session.guide.query_patterns (how to query safely)
# - $session.guide.write_cycle (validated write sequences)
# - $session.guide.common_mistakes (lessons learned)
# - $session.guide.layers_available (all 111 operational layers)
# - $session.userGuide.category_instructions (6 deterministic runbooks)
```

---

#### 1.4 Document Category Runbooks in Templates (20 minutes)
**Issue**: Templates don't explain how to use the 6 categories

**Add New Section to BOTH Templates** (after bootstrap, before project lock):

```markdown
### Category Runbooks (Use These Patterns)

The `/model/user-guide` endpoint provides deterministic workflows for 6 common scenarios.
**ALWAYS query user-guide first** before writing to these layers.

#### 1. Session Tracking (`session_tracking`)
**Layer**: `project_work`  
**ID Format**: `{project_id}-{YYYY-MM-DD}` (e.g., `37-data-model-2026-03-09`)  
**5-Step Pattern**:
```powershell
# Get the runbook
$session_guide = $session.userGuide.category_instructions.session_tracking

# Step 1: DISCOVER - Verify project exists
GET /model/projects/{project_id}

# Step 2: DISCOVER - Check if session exists
GET /model/project_work/{id}  # 404 OK for first session of day

# Step 3: DO - Create/update session
PUT /model/project_work/{id}
Headers: X-Actor: agent:copilot
Body: { project_id, current_phase, session_summary, tasks, metrics }

# Step 4: CHECK - Verify write succeeded
GET /model/project_work/{id}  # row_version should increment

# Step 5: ACT - Validate model consistency
POST /model/admin/commit
Headers: Authorization: Bearer dev-admin
Body: {}
```

**Anti-Trash Rules** (from user-guide):
- No duplicate dates per project (use PUT to update existing record)
- session_summary must be non-empty dict with completed_tasks and next_steps
- tasks array must have at least one task
- metrics must include: tests_passing, tests_added, files_changed
- current_phase must match project.current_phase unless phase transition documented

**Common Mistakes**:
- Using POST instead of PUT (POST not supported)
- Forgetting X-Actor header (write will fail)
- Not verifying project exists before creating session
- Creating multiple session records for same date
- Not running admin/commit after writes

#### 2. Sprint Tracking (`sprint_tracking`)
**Layer**: `sprints`  
**ID Format**: `{project_id}-sprint-{N}` (e.g., `37-data-model-sprint-41`)  
**Query**: `$session.userGuide.category_instructions.sprint_tracking`

#### 3. Evidence Tracking (`evidence_tracking`)
**Layer**: `evidence` (immutable audit trail)  
**Query**: `$session.userGuide.category_instructions.evidence_tracking`

#### 4. Governance Events (`governance_events`)
**Layers**: `verification_records`, `quality_gates`, `decisions`, `risks`  
**Query**: `$session.userGuide.category_instructions.governance_events`

#### 5. Infrastructure Observability (`infra_observability`)
**Layers**: `infrastructure_events`, `agent_execution_history`, `deployment_records`  
**Query**: `$session.userGuide.category_instructions.infra_observability`

#### 6. Ontology Domains (`ontology_domains`)
**Purpose**: Reason by domain (12 domains), not by layer (111 layers)  
**Query**: `$session.userGuide.category_instructions.ontology_domains`  
**Reference**: [37-data-model/USER-GUIDE.md § 12-Domain Ontology](../../37-data-model/USER-GUIDE.md)

**Workflow**: For ANY data model operation, query the relevant category in user-guide FIRST.
This prevents "trash can" data and follows proven patterns.
```

---

### Priority 2: HIGH (Next Session)

#### 2.1 Synchronize Project Template to v4.3.0 (15 minutes)
**Current**: v4.2.0 (Session 42 - Enhanced API Protocol)  
**Target**: v4.3.0 (Session 43 - Category Runbooks + API-Only Architecture)

**File**: `07-foundation-layer/templates/copilot-instructions-template.md` (line 3)

**Changes**:
- Update version number to 4.3.0
- Add user-guide bootstrap (from 1.3)
- Add category runbooks section (from 1.4)
- Fix layer count (from 1.1)
- Update timestamp to Session 43 completion (March 10, 2026 @ 6:06 AM ET)

---

#### 2.2 Update Project 07 Copilot Instructions (20 minutes)
**File**: `07-foundation-layer/.github/copilot-instructions.md`

**Issues**:
- No API-only policy section
- No Fractal DPDCA reference
- Still references "50 base + 1 metadata" (should be 91 operational)
- Bootstrap expects 51 layers, not 91
- No mention of Session 42/43 updates

**Actions**:
1. Add API-only governance policy section (from workspace instructions)
2. Update layer count references: 51 → 91 operational
3. Add Fractal DPDCA section (from workspace instructions)
4. Reference Session 42 workspace skill promotion
5. Add category runbooks reference
6. Update timestamp to Session 43

---

#### 2.3 Update Session Memory (10 minutes)
**File**: `C:\Users\marco\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\memory-tool\memories\eva-foundry-session-37-context.md`

**Add**:
- Session 42 Part 5 summary (priming engine v2.0.0, API-only policy)
- Session 43 summary (user-guide deployment, 6 category runbooks, revision 0000028)
- Update "Next Phase" section

---

### Priority 3: MEDIUM (This Week)

#### 3.1 Create Governance Consistency Check Tool (45 minutes)
**File**: `07-foundation-layer/scripts/audit-governance-consistency.ps1`

**Checks**:
```powershell
# Layer count consistency
✓ All references say "111 target layers (91 operational + 20 planned)"

# Template version sync
✓ Workspace template = Project template = v4.3.0

# Timestamp freshness
✓ Workspace instructions timestamp < 24 hours old

# Bootstrap completeness
✓ All templates call both /model/agent-guide AND /model/user-guide

# Category runbooks documented
✓ All 6 categories referenced in templates

# Session summaries exist
✓ All recent sessions (last 10) have summary files
✓ Latest session referenced in workspace instructions

# Copilot instructions current
✓ All 57 projects have copilot-instructions.md
✓ All timestamps within 30 days of latest session
```

**Output**: Markdown report with ✅/❌ for each check + remediation actions

---

#### 3.2 Workspace-Wide Template Update (60 minutes)
**Action**: Run priming engine on all 57 projects with updated templates

**Prerequisites**:
- Priority 1 items complete (templates fixed)
- Priority 2.1 complete (template v4.3.0)
- Consistency check passes

**Command**:
```powershell
cd C:\eva-foundry\07-foundation-layer\scripts\deployment
.\Invoke-PrimeWorkspace.ps1 -WorkspaceRoot "C:\eva-foundry\eva-foundry" -Force
```

**Expected**:
- All 57 projects updated to template v4.3.0
- All copilot-instructions.md include category runbooks
- All projects reference user-guide bootstrap
- Evidence: `.eva/prime-evidence.json` in each project

---

### Priority 4: LOW (Future Enhancement)

#### 4.1 Add Category Examples to Data Model Docs
**File**: `37-data-model/docs/CATEGORY-RUNBOOK-EXAMPLES.md` (new)

**Content**:
- Real-world examples for each of 6 categories
- Common patterns and anti-patterns
- Query result screenshots
- Integration with Veritas MCP tools

---

#### 4.2 Create Category Runbook Tutorial
**File**: `37-data-model/docs/tutorials/PAPERLESS-DPDCA-TUTORIAL.md` (new)

**Content**:
- Step-by-step guide to paperless governance
- How to use session_tracking for daily work
- How to use sprint_tracking for velocity
- How to use evidence_tracking for quality gates

---

## DO Phase: Execution Sequence

### Batch 1: Critical Template Fixes (Parallel Execution - 20 minutes total)

```powershell
# 1.1 - Fix layer count in 3 template locations
multi_replace_string_in_file @(
  @{ filePath = "07-foundation-layer/templates/copilot-instructions-workspace-template.md"; 
     oldString = "111 operational layers (87 base + 24 execution)"; 
     newString = "111 target layers (91 operational + 20 planned)" },
  @{ filePath = "07-foundation-layer/templates/copilot-instructions-template.md"; 
     oldString = "111 operational layers (87 base + 24 execution)"; 
     newString = "111 target layers (91 operational + 20 planned)" }
)

# 1.2 - Update workspace timestamp
replace_string_in_file(
  filePath = "C:\eva-foundry\.github\copilot-instructions.md",
  oldString = "March 10, 2026 @ 03:15 ET (Session 43 - API-Only Architecture Hardening + Consistency Fixes)",
  newString = "March 10, 2026 @ 6:06 AM ET (Session 43 - Category Runbooks + Governance Consistency Audit)"
)

# 1.3 - Add user-guide to bootstrap (workspace template)
replace_string_in_file(
  filePath = "07-foundation-layer/templates/copilot-instructions-workspace-template.md",
  oldString = "$session = @{ \n    base = $base\n    guide = (Invoke-RestMethod \"$base/model/agent-guide\")\n}",
  newString = "$session = @{ \n    base = $base\n    guide = (Invoke-RestMethod \"$base/model/agent-guide\")\n    userGuide = (Invoke-RestMethod \"$base/model/user-guide\")\n}"
)

# 1.3 - Add user-guide to bootstrap (project template)
replace_string_in_file(
  filePath = "07-foundation-layer/templates/copilot-instructions-template.md",
  oldString = "try {\n    $session.guide = Invoke-RestMethod \"$base/model/agent-guide\" -TimeoutSec 10",
  newString = "try {\n    $session.guide = Invoke-RestMethod \"$base/model/agent-guide\" -TimeoutSec 10\n    $session.userGuide = Invoke-RestMethod \"$base/model/user-guide\" -TimeoutSec 10"
)

# 1.4 - Add category runbooks section (detailed content to be inserted after bootstrap)
# This requires reading file first to find correct insertion point
```

---

## CHECK Phase: Validation Criteria

### Automated Checks
```powershell
# Layer count consistency (all must match)
$pattern = "111 target layers \(91 operational \+ 20 planned\)"
grep -r "$pattern" C:\eva-foundry\.github\copilot-instructions.md
grep -r "$pattern" 07-foundation-layer/templates/*.md

# Bootstrap includes both endpoints
grep -r "userGuide.*user-guide" 07-foundation-layer/templates/*.md

# Category runbooks section exists
grep -r "Category Runbooks \(Use These Patterns\)" 07-foundation-layer/templates/*.md

# Template versions match
grep "Template Version" 07-foundation-layer/templates/*.md | grep "4.3.0"
```

### Manual Verification
- [ ] Read updated templates end-to-end (no broken markdown, proper formatting)
- [ ] Verify bootstrap code is syntactically correct PowerShell
- [ ] Check category runbooks include all 6 categories with examples
- [ ] Confirm anti_trash_rules copied accurately from API response
- [ ] Test bootstrap pattern in fresh PowerShell session

---

## ACT Phase: Documentation & Lessons Learned

### Files to Create/Update

1. **Session Summary** (if not exists):
   - `37-data-model/docs/sessions/SESSION-43-SUMMARY.md`
   - Content: What user-guide provides, why it matters, how to use it

2. **Session Memory** (update):
   - Add Session 43 to `eva-foundry-session-37-context.md`
   - Document the governance consistency audit findings
   - Reference this action plan

3. **Project 07 STATUS.md** (update):
   - Add "Session 43 Governance Audit" entry
   - Reference revised action plan
   - Note template updates pending

### Lessons Learned

**Lesson 1: API-First Documentation Wins**
- Hardcoded docs go stale quickly
- API-served docs stay current (single source of truth)
- Templates should REFERENCE API, not DUPLICATE content

**Lesson 2: Category Runbooks Prevent "Trash Can" Data**
- ID format patterns enforce consistency
- anti_trash_rules catch common mistakes before they happen
- query_sequence provides step-by-step DPDCA workflow

**Lesson 3: Fractal DPDCA Catches Inconsistencies**
- Systematic DISCOVER reveals staleness
- PLAN phase prioritizes by impact
- CHECK phase ensures nothing slips through

**Lesson 4: Templates Need Maintenance Cadence**
- Review templates after every major session
- Consistency check tool needed (automated)
- Workspace-wide updates should be batched, not ad-hoc

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Original Action Items** | 11 (6 inconsistencies + 5 enhancements) |
| **Items Solved by Session 43** | 2 (user-guide deployment) |
| **Items Still Valid** | 9 (updated based on new context) |
| **New Items Added** | 4 (category runbooks, examples, tutorial, tool) |
| **Total Revised Items** | 13 |
| **Estimated Time** | ~3 hours (Priority 1-2) |
| **Files to Update** | 8 direct, 57 projects (priming) |
| **Validation Checks** | 11 automated, 5 manual |

---

**Status**: ✅ PLAN Phase Complete - Ready for DO Phase Execution  
**Next**: Execute Priority 1 batch (20 minutes) → Verify → Proceed to Priority 2

