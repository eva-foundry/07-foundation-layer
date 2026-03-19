# Project 40 (EVA Control Plane) - Ownership Boundary Clarification

**Document**: Control Plane Ownership Boundaries (F07-02-005-T01)  
**Context**: Project 40 is a two-plane system (37=catalog, 40=runtime). Clarifying which parts Project 07 owns.  
**Status**: Formalized (Session 38)  
**Decision Required**: Leadership approval before implementing integration patterns  

---

## Overview

Project 40 (EVA Control Plane) provides the **runtime layer** for capturing and correlating evidence across DPDCA cycle execution. The challenge is determining where Project 07's governance scope ends and where Project 40's infrastructure scope begins.

### Current Ambiguity

**What is clear:**
- Project 37 (data-model) is the *catalog* -- describes WHAT exists
- Project 40 (control-plane) is the *runtime* -- records WHAT HAPPENED
- Evidence correlation ID (`GH<run>-PR<pr>-<sha>`) links PR checks → deployments → ADO WIs → Cosmos runs

**What is unclear:**
- Does Project 07 own the *instrumentation patterns* (how to hook into Project 40)?
- Does Project 07 own the *integration with Veritas* (how trust scores read from control plane)?
- Does Project 07 own *quality gates* (blocking phase transitions if evidence is missing)?
- Or is all of that Project 40's responsibility?

---

## Two-Plane Evidence Architecture

```
┌─ Data Model (Catalog) ─────────────────────┐
│  Project 37: Slow-change configuration     │
│  - Services, endpoints, agents             │
│  - Runbooks (RB-001, RB-002, etc.)         │
│  - Policies, workflows                     │
│  Port: 8010 (read-only API)                │
└─────────────────────────────────────────────┘

         ↓ (instrumentation)

┌─ Control Plane (Runtime) ───────────────────┐
│  Project 40: High-write operational layer   │
│  - Runs (PR → Build → Test → Deploy)        │
│  - Step runs (individual step executions)   │
│  - Artifacts (test results, coverage, etc.) │
│  - Evidence packs (assembled periodically)  │
│  Port: 8020 (CRUD API)                      │
└─────────────────────────────────────────────┘

         ↓ (correlation)

┌─ Quality Gates & Auditing ──────────────────┐
│  Project 07/48: Governance layer           │
│  - Evidence validation (tests passed?)      │
│  - Compliance auditing (Veritas)            │
│  - Phase transition gating                  │
│  - Remediation automation                   │
└─────────────────────────────────────────────┘
```

---

## Proposed Boundary: Layer 1 Only (Conservative)

### Project 07 Owns

1. **Evidence Instrumentation Patterns** (how to hook into Project 40)
   - Hook points: PR checks, deployments, test runs, coverage reports
   - How to submit evidence to `/runs` and `/artifacts` endpoints
   - Correlation ID format and propagation
   - Evidence pack assembly workflow
   - **Scope**: Documentation + skill + templates

2. **Evidence Submission API Patterns**
   - How to call Project 40's `/runs` endpoint to register new run
   - How to call `/artifacts` endpoint to register test results, coverage
   - How to extract correlation ID and pass to downstream systems (ADO, Veritas)
   - Error handling and retry logic
   - **Scope**: Code patterns + skill + examples

3. **Integration with Project 37 (Catalog)**
   - How to read runbook definitions from Project 37 `/model/runbooks`
   - How to verify that RB-001 matches the actual GitHub Actions workflow
   - How to update catalog if RB definitions change
   - **Scope**: Sync patterns + governance rules

### Project 40 Owns (Infrastructure)

- FastAPI runtime (port 8020)
- Cosmos DB schemas (runs, step_runs, artifacts)
- Data retention / archival policies
- Performance optimization (indexing, query patterns)
- Backup / recovery procedures
- Scale-out strategy for high-write workloads

### Project 48 (Veritas) Owns (Quality Assessment)

- Reading evidence from Project 40 via `/evidence/{evidence_id}`
- Computing trust scores based on evidence
- Enforcing quality gates (e.g., "coverage >= 80% before allow phase transition")
- Generating audit reports
- Compliance scoring (MTI: Maturity-Trust-Integrity)

### Example Workflow (Clarifying Boundaries)

```
User updates 36-red-teaming PLAN.md
    ↓ (Project 07: ado-integration skill)
seed-from-plan.py generates stories
    ↓ (Project 07: seed-from-plan pattern)
ado-artifacts.json created
    ↓ (Project 38: ADO registration)
ADO Epic/Features/PBIs created
    ↓ (ADO: work item tracking)
Developer creates PR
    ↓ (GitHub: PR opened)
    ├─ RB-001 (PR CI Evidence) workflow triggered
    │   ├─ Run tests
    │   ├─ Compute coverage
    │   ├─ (Project 07 instrumentation pattern)
    │   └─ Call Project 40 `/runs` to register run
    │       └─ Evidence ID assigned: GH1234-PR56-abc1234
    │
    ├─ PR check passed → evidence-pack.json created
    │   (Project 40: pack-evidence.py)
    │
    └─ PR merged
        ↓ (Project 07: ado-close-wi skill)
        Call Project 48 to validate phase transition
            ↓ (Project 48: Veritas)
            Read Project 40 /evidence/{evidence_id}
            Compute trust score
            Gate decision: OK to move to Done? YES
        ↓
        Call Project 38 ado-close-wi
            ↓ (Project 38)
            Update ADO WI → Done
            Submit evidence to Project 37 L31
```

---

## Proposed Boundary: Layer 1 + Layer 2 (Moderate)

### Additionally, Project 07 Owns

4. **Quality Gate Enforcement** (coordinate with Veritas)
   - Define which acceptance gates require evidence (AC-4 coverage requirement)
   - Define which phases require gates (C→A transition needs tests)
   - Provide templates for gate automation (e.g., "If coverage < 80%, auto-create bug")
   - **Scope**: Governance rules + Project 48 coordination

---

## Proposed Boundary: Layer 1 + Layer 2 + Layer 3 (Expansive)

### Additionally, Project 07 Owns

5. **Control Plane Instrumentation Automation**
   - Auto-inject evidence hooks into new projects during scaffolding
   - Add RB-001 / RB-002 GitHub Actions templates to all new projects
   - Pre-configure correlation ID propagation (GH run → PR → ADO)
   - Auto-register projects with Project 40 API
   - **Scope**: Scaffolding integration + automation

6. **Evidence Remediation Workflows**
   - Auto-triage failed evidence (tests failing, coverage dropping)
   - Auto-create ADO bugs for failing gates
   - Auto-block phase transitions if gaps detected
   - **Scope**: Automation + governance

---

## Recommendation: Choose a Boundary

### Option A: Layer 1 Only (Recommended for Session 38)
**Risk**: Low complexity, clear ownership, easy to maintain  
**Benefit**: Project 07 documents + skills + patterns; Project 40 owns infrastructure  
**Timeline**: Can complete F07-02-005 quickly; defer advanced automation to F07-04  

### Option B: Layer 1 + 2 (Moderate)
**Risk**: Moderate complexity, coordination required with Project 48  
**Benefit**: Quality gates enforced at workspace level  
**Timeline**: Requires Project 48 integration; adds 1-2 days work  

### Option C: Layer 1 + 2 + 3 (Expansive)
**Risk**: High complexity, many dependencies, automation complexity  
**Benefit**: Fully automated, self-service evidence collection  
**Timeline**: 5+ days work; should be in F07-03 phase, not F07-02  

---

## Recommendation Decision

**For Session 38 (F07-02-005)**: Implement **Option A (Layer 1 Only)**

**Rationale**:
- Clear boundary: Project 07 = patterns + documentation; Project 40 = infrastructure
- Unblocks other governance stories (F07-02-004 complete, F07-02-006 dependent on clarity)
- Quality gates can be added in F07-03-003 (Pattern Elevation phase)
- Allows Project 40 team to focus on runtime stability
- Aligns with DPDCA principle: Discover (clarify boundaries) → Plan (design patterns)

**Deliverables for F07-02-005**:
1. **T01**: This document (boundary clarification + recommendation)
2. **T02**: README update with Layer 1 integration patterns + skill for project instrumentation

**Future Work (F07-03-003)**:
- F07-03-003-T01: Elevate instrumentation to workspace-level skill
- F07-03-003-T02: Add quality gate enforcement (Veritas coordination)
- F07-03-003-T03: Auto-inject evidence hooks in project scaffolding

---

## What F07-02-005 Will Deliver (Final Form)

### T01 Output (This Document)
- Clarification of two-plane architecture
- Boundary options with risk/benefit analysis
- Recommendation: Option A (Layer 1)
- Future roadmap for Layers 2 & 3

### T02 Output (README + Skill)
Based on Layer 1 only:
- How to instrument a project for evidence collection
- How to call Project 40 `/runs` endpoint
- How to propagate correlation IDs
- Example: RB-001 (PR → Evidence Pack) walkthrough
- Troubleshooting: evidence not appearing, correlation ID missing

---

## Approval & Sign-Off

**Project 07 Foundation Lead**: ___________________  
**Project 40 Control Plane Lead**: ___________________  
**Project 48 Veritas Lead**: ___________________  

**Boundary Decision**: ☐ Option A (Layer 1) | ☐ Option B (Layer 1+2) | ☐ Option C (Layer 1+2+3)

**Date**: ___________________

---

## References

- **Project 40 README**: [40-eva-control-plane/README.md](../../40-eva-control-plane/README.md)
- **Two-Plane Architecture**: Evidence spine linking catalog (37) → runtime (40) → governance (07/48)
- **Evidence Correlation**: GH<run>-PR<pr>-<sha> format across GitHub/Azure/ADO
- **Related Skills**: `@data-model-admin`, `@ado-integration` (upstream dependencies)

---

**Status**: Ready for approval  
**Next Step**: After approval, proceed with F07-02-005-T02 (documentation)

