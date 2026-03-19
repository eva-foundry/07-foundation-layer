# {{PROJECT_ID}} -- Acceptance Criteria

**Template Version**: v7.0.0 (Session 71 - API-first local continuity)  
**Created**: {{PRIME_DATE}} by {{PRIME_ACTOR}}  
**Last Updated**: {{PRIME_DATE}}

---

<!-- eva-primed-acceptance -->

## Summary

| Gate | Criteria | Status |
|------|----------|--------|
| AC-1 | Project record can be resolved from the API | PENDING |
| AC-2 | Project instruction contract exists and is ASCII-clean | PASS |
| AC-3 | Planned work is reflected in `PLAN.md` | PENDING |
| AC-4 | Status is updated after material work | PENDING |
| AC-5 | Repo-native validation passes | PENDING |
| AC-6 | Evidence exists for automation or verification work | PENDING |
| AC-7 | Veritas quality check is run when governance quality is impacted | PENDING |
| AC-8 | Primary project outcome is operational | PENDING |

---

## AC-1: API Record Available

**Criteria**: `GET /model/projects/{{PROJECT_ID}}` returns a valid project object.

**Verification**:

```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
Invoke-RestMethod "$base/model/projects/{{PROJECT_ID}}"
```

---

## AC-2: Project Instruction Contract Present

**Criteria**: `.github/copilot-instructions.md` exists, is ASCII-clean, and contains project-level contract content.

**Verification**:
- confirm the file exists
- confirm it contains the project-owned context section
- scan for unexpected non-ASCII content if the project does not require Unicode

---

## AC-3: Plan Reflects Current Work

**Criteria**: `PLAN.md` identifies active focus, delivery structure, and current backlog.

---

## AC-4: Status Reflects Latest Verified State

**Criteria**: `STATUS.md` is updated after meaningful changes to scope, delivery state, or blockers.

---

## AC-5: Repo-Native Validation Passes

**Criteria**: The project's actual test, lint, build, or smoke validation commands complete successfully.

**Verification**:
- discover the real commands from repo files
- run the smallest relevant validation set for the change

---

## AC-6: Evidence Exists When Needed

**Criteria**: If automation, verification, or synchronization work was performed, evidence is saved under `evidence/` and logs under `logs/`.

---

## AC-7: Governed Quality Checked When Needed

**Criteria**: Run `get_trust_score` or `audit_repo` when the task materially affects governed delivery quality or traceability.

---

## AC-8: Primary Outcome Operational

**Criteria**: The primary intended project outcome for the current work scope is implemented and verifiable.

---

## Release Readiness

- [ ] active acceptance items are marked PASS
- [ ] validation evidence exists where applicable
- [ ] local docs and API-backed state are reconciled
- [ ] known blockers are documented explicitly
