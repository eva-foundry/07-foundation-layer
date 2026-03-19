<!-- eva-primed-plan -->
<!-- Template Version: v7.0.0 (Session 71 - API-first local continuity) -->

# {{PROJECT_ID}} -- Plan

**Created**: {{PRIME_DATE}} by {{PRIME_ACTOR}}  
**Governance Authority**: Data Model API  
**Project Record**: `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/{{PROJECT_ID}}`

---

## How To Use This File

This file is a local planning aid. It helps agents and humans understand intended scope, sequencing, and delivery notes.

Use the API for authoritative governance state such as sessions, sprints, evidence, risks, decisions, and quality gates.

Before editing this plan:
- complete workspace bootstrap
- query the project record and relevant runbook category
- reconcile local notes with live API state

---

## Active Focus

### Objective

Describe the current objective for this project in one concise paragraph.

### Current Scope

- in scope: {{CURRENT_SCOPE_1}}
- in scope: {{CURRENT_SCOPE_2}}
- out of scope: {{OUT_OF_SCOPE_1}}

### Dependencies

- {{DEPENDENCY_1}}
- {{DEPENDENCY_2}}

---

## Delivery Structure

Use feature and story identifiers when traceability is required.

## Feature: [PLANNED] Feature Name [ID={{PROJECT_PREFIX}}-01]

### Story: [PLANNED] Story Description [ID={{PROJECT_PREFIX}}-01-001]

**Acceptance**:
- [ ] Criterion 1
- [ ] Criterion 2

**Implementation Notes**:
1. Step 1
2. Step 2

---

## Backlog

### Next

- {{NEXT_ITEM_1}}
- {{NEXT_ITEM_2}}

### Later

- {{LATER_ITEM_1}}
- {{LATER_ITEM_2}}

### Technical Debt

- {{DEBT_ITEM_1}}
- {{DEBT_ITEM_2}}

---

## Verification And Evidence

When work in this plan is executed:
- store evidence in `evidence/`
- store logs in `logs/`
- use timestamp-prefixed artifact names
- run veritas tooling when governed quality or traceability is affected

Useful checks:
- `audit_repo`
- `get_trust_score`
- `sync_repo`

Traceability pattern:

```python
# EVA-STORY: {{PROJECT_PREFIX}}-01-001
# EVA-FEATURE: {{PROJECT_PREFIX}}-01
```

---

## Planning Notes

- last reconciled with API: {{PRIME_DATE}}
- next review trigger: after material scope, risk, or delivery changes
- related local files: `README.md`, `STATUS.md`, `ACCEPTANCE.md`
