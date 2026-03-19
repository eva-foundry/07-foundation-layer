# 40-eva-control-plane RACI Matrix

**Document Version**: 1.0.0  
**Created**: 2026-03-01 08:45 ET  
**Purpose**: Clarify ownership boundaries for EVA Control Plane (runtime evidence spine)

---

## RACI Roles

- **R (Responsible)**: Does the work
- **A (Accountable)**: Final approver, owns the outcome
- **C (Consulted)**: Provides input, must be consulted before decisions
- **I (Informed)**: Kept up-to-date on progress

---

## Component Ownership Matrix

| Component | 07-Foundation | 38-ADO-POC | 40-Control-Plane | 33-Brain-v2 | 31-Faces |
|---|---|---|---|---|---|
| **Runtime API (port 8020)** | I | I | **R/A** | C | I |
| **Evidence Pack Schema** | **A** | C | R | C | I |
| **Runbook Catalog (37-data-model)** | **A** | C | R | I | I |
| **Runbook Execution (GitHub Actions)** | C | I | **R/A** | I | I |
| **Run Records (operational data)** | I | C | **R/A** | I | I |
| **Evidence ID Standard** | **A** | C | R | R | I |
| **Sprint Metrics Collection** | C | **R/A** | C | R | I |
| **Dashboard Data API** | I | C | I | **R/A** | C |
| **Dashboard UI** | I | C | I | C | **R/A** |

---

## Responsibility Breakdown

### **07-Foundation-Layer (Workspace PM/Scrum Master)**

**Accountable for**:
- Evidence pack schema standardization (ensures all projects use same format)
- Runbook catalog structure (cp_agents, cp_skills, runbooks layers in 37-data-model)
- Evidence ID format specification (GH<run>-PR<pr>-<sha> pattern)

**Responsible for**:
- Scaffolding new projects with .github/workflows/ templates
- Deploying runbook templates to projects
- Maintaining runbook catalog schemas in 37-data-model

**Consulted on**:
- Runbook execution patterns (how GitHub Actions workflows should call control-plane API)
- Sprint metrics collection logic (what 38-ADO-POC needs from control-plane)

**Informed on**:
- Runtime API changes (port 8020 endpoint additions/deprecations)
- Evidence pack format updates

### **40-eva-control-plane (Runtime Evidence Spine)**

**Accountable for**:
- Runtime API availability (port 8020, uptime, response time)
- Runbook execution orchestration (triggering workflows, managing step_runs)
- Operational run records (CRUD for runs, step_runs, artifacts)

**Responsible for**:
- Implementing evidence pack schema (defined by 07-foundation-layer)
- Writing runtime data to Cosmos (runs container)
- Exposing GET /evidence/{evidence_id} cross-run view
- Implementing runbook definitions (catalog defined by 07, executed by 40)

**Consulted on**:
- Evidence pack schema changes (07 defines, 40 must implement)
- Sprint metrics requirements (38-ADO-POC needs specific fields)
- Dashboard data needs (33-brain-v2 queries control-plane for metrics)

**Informed on**:
- New projects onboarding (07 scaffolds, 40 inherits their workflows)

### **38-ado-poc (ADO Command Center / Scrum Orchestration)**

**Accountable for**:
- Sprint metrics collection (queries control-plane + WBS, computes velocity)
- ADO work item synchronization (WBS → ADO, ADO → control-plane evidence links)

**Responsible for**:
- Sprint-advance automation (triggers runbooks via control-plane)
- Velocity calculations (FP delivered per sprint)
- ADO Epic/Feature/Story creation from WBS

**Consulted on**:
- Evidence pack schema (needs artifact_uri for ADO attachment)
- Runbook catalog design (which runbooks exist, how to trigger)
- Evidence ID format (must parse for ADO linking)

**Informed on**:
- Runtime API changes (new endpoints for sprint metrics)
- Dashboard UI updates (39-ado-dashboard displays 38's metrics)

### **33-eva-brain-v2 (Backend API / Data Tier)**

**Accountable for**:
- Dashboard data API (/v1/scrum/dashboard)
- Scrum cache container (Cosmos TTL 24h)

**Responsible for**:
- Querying control-plane + WBS for sprint data
- Implementing /v1/scrum/summary for sprint badges
- Evidence ID propagation (writes evidence_id to WBS when run completes)

**Consulted on**:
- Dashboard data schema (39-ado-dashboard specifies requirements)
- Evidence pack schema (must parse artifacts for coverage %)

**Informed on**:
- Runbook executions (control-plane notifies brain when evidence pack ready)

### **31-eva-faces (Frontend / Portal)**

**Accountable for**:
- Dashboard UI rendering (EVA Home, Sprint Board pages)
- User interaction (sprint selector, WI detail drawer)

**Responsible for**:
- Calling /v1/scrum/dashboard from 33-brain-v2
- Displaying sprint badges, velocity charts

**Consulted on**:
- Dashboard data API schema (specifies requirements for 33-brain-v2)

**Informed on**:
- Sprint metrics changes (new fields available)
- Evidence pack updates (new artifact types to display)

---

## Decision Authority

| Decision Type | Authority | Consult | Inform |
|---|---|---|---|
| Evidence pack schema change | 07-Foundation | 40, 38, 33 | All projects |
| Runtime API endpoint addition | 40-Control-Plane | 07, 38, 33 | All projects |
| Evidence ID format change | 07-Foundation | 40, 38, 33 | All projects |
| Sprint metrics calculation logic | 38-ADO-POC | 07, 40, 33 | 31, 39 |
| Runbook catalog schema | 07-Foundation | 40, 38 | All projects |
| Dashboard UI/UX | 31-Faces | 39, 33 | 07, 38, 40 |

---

## Communication Channels

### Weekly Governance Sync (Mondays 10:00 ET)
- **Attendees**: 07, 40, 38 leads
- **Topics**: Evidence schema, runbook catalog, sprint metrics requirements
- **Output**: Decision log, updated RACI if needed

### Sprint Retrospective (End of Sprint)
- **Attendees**: All project leads
- **Topics**: What worked, what broke, metric accuracy
- **Output**: Action items for next sprint

### Ad-Hoc (as needed)
- **Slack**: `#eva-control-plane` for runtime issues
- **Slack**: `#eva-governance` for schema/standard decisions
- **GitHub Discussions**: `eva-foundry/40-eva-control-plane` for design proposals

---

## Change Management

### Evidence Pack Schema Change Process

1. **Proposal**: 07-Foundation creates RFC in `docs/rfcs/evidence-pack-vN.md`
2. **Review**: 40, 38, 33 comment within 3 business days
3. **Decision**: 07 approves or rejects based on feedback
4. **Implementation**: 40 implements new schema version
5. **Rollout**: 07 updates project templates, 38 updates ADO sync logic, 33 updates dashboard API
6. **Verification**: All projects test with new schema in DEV

### Runtime API Change Process

1. **Proposal**: 40 creates PR with new endpoint + OpenAPI spec
2. **Review**: 07, 38, 33 review for breaking changes
3. **Decision**: 40 merges if no breaking changes; escalate to governance sync if breaking
4. **Documentation**: 40 updates README.md + OpenAPI docs
5. **Rollout**: Clients (33, 38) update within 1 sprint
6. **Deprecation**: Old endpoints marked deprecated, removed after 2 sprints

---

## Escalation Path

1. **Level 1 (Team)**: Discuss in project Slack channel (#eva-control-plane)
2. **Level 2 (Governance)**: Raise in weekly governance sync (Mondays)
3. **Level 3 (Architecture)**: ADR proposal in 07-foundation-layer/docs/adrs/
4. **Level 4 (Executive)**: Marco Presta (EVA AI COE lead)

---

## Summary

**07-Foundation-Layer** owns the **standards and schemas** (evidence pack, runbook catalog, evidence ID).

**40-eva-control-plane** owns the **runtime execution** (API, runs, step_runs, artifacts).

**38-ado-poc** owns **sprint metrics and ADO sync** (velocity, WI creation).

**33-eva-brain-v2** owns **dashboard data API** (/v1/scrum).

**31-eva-faces** owns **dashboard UI** (EVA Home, Sprint Board).

**Clear boundaries. No overlap. Deterministic ownership.**
