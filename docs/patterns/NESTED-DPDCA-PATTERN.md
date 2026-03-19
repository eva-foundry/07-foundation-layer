# Nested DPDCA Pattern: Fractal Governance at Scale

**Status**: Session 45 Part 11 - Framework documentation (March 11, 2026)  
**Version**: 1.0  
**Related**: DPDCA v2.0 enhanced framework, Anti-Infinite-Regress pattern

## Overview

DPDCA (Discover → Plan → Do → Check → Act) is **fractal**: the same cycle applies at every scale level. Understanding nested DPDCA is critical for avoiding the "incomplete work passing validation" anti-pattern that occurred in Session 45 PART 5.

```
Workspace Level (Session 45 DPDCA)
│
├─ PART 1 Level (Content operationalization DPDCA)
│  ├─ DISCOVER: Audit 121 layers
│  ├─ PLAN: Prioritize layer sequence
│  ├─ DO: Operationalize L1-L10
│  ├─ CHECK: Verify layers active + schema validation
│  └─ ACT: Document lessons
│
├─ PART 5 Level (Router reorganization DPDCA)
│  ├─ DISCOVER: Inventory 85 schemas (✅ Complete)
│  ├─ PLAN: Design 12-domain strategy (✅ Complete)
│  ├─ DO: Move schemas + update routing (❌ INCOMPLETE - only dirs created)
│  ├─ CHECK: Verify payload + routing (❌ FAILED - only validated dirs, not schemas)
│  └─ ACT: Commit work (❌ PREMATURE - incomplete work committed)
│
└─ Schema Migration Subtask (File-level DPDCA)
   ├─ DISCOVER: Identify schema files needing move
   ├─ PLAN: Define routing updates
   ├─ DO: Move files + update imports
   ├─ CHECK: Verify paths resolve + tests pass
   └─ ACT: Commit file changes
```

## Problem: Incomplete Nesting

**Session 45 PART 5 RCA revealed the core issue:**

At the **PART 5 level**, all phases appeared complete:
- DISCOVER: ✅ 85 schemas inventoried, 12 domains identified
- PLAN: ✅ 66 assignments designed, 3 conflicts resolved  
- DO: ❌ Only stage-1 delivered (directories created), stage-2 skipped (files not moved)
- CHECK: ❌ Validated stage-1 infrastructure only, didn't check stage-2 payload
- ACT: ❌ Committed incomplete work because CHECK didn't catch stage-2 gap

**Root cause**: PART-level CHECK phase didn't validate sub-task level completion:

```
PART 5 (Orchestration Level)
└─ Schema Migration Subtask (Execution Level)  ← CHECK didn't go here
   ├─ DISCOVER: Identify 85 files ✅
   ├─ PLAN: Map to domains ✅
   ├─ DO: ❌ INCOMPLETE - only created dirs, didn't move files
   ├─ CHECK: ❌ FAILED - didn't detect stage-2 incompleteness
   └─ ACT: ❌ Committed incomplete state
```

## Solution: Explicit Boundary Checks

DPDCA v2.0 requires that **each nesting level verifies nested levels are complete** before advancing.

### Nesting Rule #1: Plan Promises Flow Down

When nesting DPDCA, each parent level's PLAN promises must explicitly map to child level deliverables:

```json
{
  "level": "PART 5 (Orchestration)",
  "dpdca_phase": "PLAN",
  "promises": [
    {
      "id": "P1",
      "description": "Reorganize 85 schemas into 12 domains",
      "child_dpdca_mapping": {
        "level": "Schema Migration Subtask",
        "phases_required": ["DISCOVER", "PLAN", "DO", "CHECK", "ACT"],
        "expected_deliverables": [
          "All 85 schema files physically moved to domain directories",
          "API routing updated to serve by domain",
          "Tests passing for all domain-based queries"
        ]
      }
    }
  ]
}
```

### Nesting Rule #2: Evidence Chains Link Levels

Each parent phase must collect evidence from child phases:

```json
{
  "level": "PART 5",
  "phase": "CHECK",
  "evidence_collection": {
    "infrastructure_check": {
      "level": "PART 5",
      "validated": "12 directories exist"
    },
    "payload_check": {
      "level": "Schema Migration Subtask",
      "source": "evidence/SCHEMA-MIGRATION-DO-*.json",
      "required_fields": ["files_moved_count", "routing_updated", "tests_passing"],
      "validation": "Expected 85 files moved, got 0 → FAIL"
    }
  }
}
```

### Nesting Rule #3: Blocking Decisions Propagate Up

If a child-level DPDCA fails CHECK, the parent-level must block:

```json
{
  "level": "PART 5",
  "phase": "CHECK",
  "blocking_analysis": {
    "child_level_status": {
      "schema_migration": "FAILED - DO incomplete",
      "allows_parent_act": false
    },
    "parent_decision": "CANNOT proceed to ACT - child DPDCA incomplete",
    "required_action": "Loop back to Schema Migration subtask DO phase"
  }
}
```

## Real-World Pattern: PART 5 Should Have Worked

Here's how PART 5 CHECK should have been structured with proper nesting:

```
PART 5.CHECK (Nested DPDCA Validation):
  ├─ Stage 1: Infrastructure Validation
  │  └─ Verify: 12 domain directories exist ✅ PASS
  │
  ├─ Stage 2: Child-Level Validation (Critical!)  ← THIS WAS MISSING
  │  └─ Query: "Has Schema Migration subtask completed all 5 DPDCA phases?"
  │     ├─ DISCOVER: ✅ 85 schemas identified
  │     ├─ PLAN: ✅ 66 assignments planned
  │     ├─ DO: ❌ INCOMPLETE - directories exist, files not moved
  │     ├─ CHECK: ← WOULD HAVE BEEN HERE
  │     └─ ACT: ← NOT YET READY
  │
  ├─ Stage 3: Gap Analysis
  │  └─ Missing: Schema Migration DO phase requires file movement (85 files)
  │     Current: 0 files moved
  │
  └─ Stage 4: Blocking Decision
     └─ Decision: FAIL - Cannot proceed to ACT until Schema Migration DO completes
```

## Pattern: How to Nest DPDCA Correctly

### Level 1: Workspace DPDCA
- **Scope**: Entire Session 45
- **Discover**: What are all PARTs (1-5)?
- **Plan**: What sequence? What dependencies?
- **Do**: Execute PART 1 through PART 5
- **Check**: Did all PARTs complete? Any blockers from child DPDCAs?
- **Act**: Commit Session 45 work, document lessons

### Level 2: PART-Level DPDCA
For each PART (e.g., PART 5 - Router Organization):
- **Discover**: What objects need organizing? How many? Which layers?
- **Plan**: What strategy? What sequence?
- **Do**: Execute sub-tasks (can be multiple iterations)
- **Check**: Did all sub-tasks complete successfully?
- **Act**: Commit PART work

### Level 3: Sub-Task DPDCA  
For each sub-task (e.g., Schema Migration):
- **Discover**: Identify 85 schema files
- **Plan**: Design routing strategy
- **Do**: Move files, update imports, commit changes
- **Check**: Verify all 85 moved, imports resolve, tests pass
- **Act**: Mark sub-task complete

### Level 4: Operation-Level DPDCA (if needed)
For critical operations (e.g., Moving one schema file and its references):
- **Discover**: Identify all files referencing this schema
- **Plan**: Calculate impact, design refactoring
- **Do**: Movement + Reference updates
- **Check**: Verify schema resolves and dependent tests pass
- **Act**: Commit individual file moves

## Evidence Linking

Each evidence file must link to parent and child levels:

```json
{
  "level": 3,
  "phase": "CHECK",
  "scope": "Schema Migration Subtask",
  "parent_context": {
    "level": 2,
    "scope": "PART 5 (Router Organization)",
    "requires": "This subtask CHECK validates parent PART 5 can proceed to ACT"
  },
  "child_context": {
    "level": 4,
    "scope": "Per-Schema Operations",
    "prerequisite": "All 85 operation-level DIE phases must be complete"
  },
  "blocking_link_to_parent": "If this CHECK fails → Parent PART 5 CHECK must also fail",
  "validation_gates": [
    "Did parent PART 5 PLAN promise 'move 85 schemas'?",
    "Did we actually move 85 schemas (not just create directories)?",
    "Can parent DPDCA proceed to ACT with this evidence?"
  ]
}
```

## Anti-Pattern: The Silent Skip

**What went wrong in Session 45 PART 5:**

```
PART 5 PLAN (Promised):
  "Move 85 schemas into domain directories"

PART 5 DO (Actually Done):
  "Created 12 domain directories"

PART 5 CHECK (Should Have Caught This):
  ❌ Only validated: "Do directories exist?" → YES
  ✅ Should have validated: "Did we move the 85 schemas?" → NO (not checked)

Result:
  CHECK passed with incomplete payload
  → ACT committed incomplete work
  → Downstream levels failed or discovered gap later
```

**How v2.0 framework prevents this:**

```json
{
  "phase": "CHECK",
  "promise_vs_delivery": [
    {
      "promised": "Move 85 schemas",
      "delivered": "Created directories",
      "gap": "Schemas still in flat structure",
      "blocker_type": "HARD",
      "decision": "FAIL"
    }
  ],
  "can_proceed_to_act": false
}
```

## Best Practices for Nested DPDCA

1. **Make Nesting Explicit**: Document parent-child relationships in evidence
2. **Plan Flows Down**: Parent PLAN promises must map to child deliverables
3. **Evidence Chains Up**: Parent CHECK must collect child phase evidence
4. **Blockers Propagate Up**: Child failures must block parent ACT
5. **Validate Payload, Not Infrastructure**: Don't confuse "directories exist" with "files moved"
6. **Test at Each Level**: Don't wait for final integration to discover gaps
7. **Version Your Framework**: Reference DPDCA v2.0, not vague "process flow"
8. **Persist Evidence**: Use timestamped JSON, not ephemeral status messages

## When to Nest vs Flatten

**Nest (create child DPDCA)** if:
- Task takes >2 hours
- Multiple people involved
- Depends on intermediate validations
- High risk of incomplete delivery
- Natural dependency tree (e.g., 85 files → 3 groups → organize by domain)

**Flatten (single DPDCA)** if:
- Task < 30 minutes
- Single person, single decision point
- No intermediate validation gates
- Low risk (e.g., "Rename variable X to Y across 5 files")

**Session 45 PART 5** should have been nested because:
- 85 schema files to move (complex, high-risk)
- Natural sub-task: "Schema Migration Subtask"
- Natural sub-sub-task: "Per-schema operations"
- Intermediate gate: After stage-2, verify payload before stage-3 (routing)

## Recursion Termination

DPDCA nesting is **not infinite**. Termination rules:

| Level | Scope | DPDCA Cycle Time | Evidence Format |
|-------|-------|------------------|-----------------|
| 1 | Workspace (entire session) | Days | Session summary JSON |
| 2 | PART (epic/feature) | Hours | PART evidence JSON |
| 3 | Sub-task (module/component) | Minutes-hours | Phase evidence JSON |
| 4 | Operation (file/record) | Seconds-minutes | Operation result JSON |
| 5+ | ❌ STOP - use inline logging | - | Real-time logs only |

Never create DPDCA deeper than Level 4 (operation-level). Use inline logging instead.

## Reference Implementation

See `/memories/workspace/DPDCA-Enhanced-Framework-v2.0.md` for:
- Mandatory CHECK template (7 items)
- Evidence JSON schema (12 required fields)
- Blocking rules (HARD vs SOFT)
- Application rules (all PARTS must follow)

See `ANTI-INFINITE-REGRESS.md` for how nested validation prevents infinite audit recursion.

---

**Document Version**: 1.0  
**Last Updated**: 2026-03-11 (Session 45 Part 11)  
**Related Session**: Session 45 Part 11 - PART 5 RCA and Framework Enhancement  
**Author Note**: This pattern emerged from RCA discovering that PART 5 PLAN promised schema migration, DO delivered only infrastructure, CHECK validated infrastructure only, and ACT committed incomplete work. Nested DPDCA with explicit nesting rules prevents this category of "surface-level completion" defect.
