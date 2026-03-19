<!-- eva-primed-organization -->

# {{PROJECT_FOLDER}} -- Organization Standards

**Template Version**: v7.0.0 (Session 71 - API-first local continuity)  
**Primed**: {{PRIME_DATE}} by {{PRIME_ACTOR}}

---

## Root Rules

Keep the project root limited to entry-point and governance files such as:
- `README.md`
- `PLAN.md`
- `STATUS.md`
- `ACCEPTANCE.md`
- manifest files like `requirements.txt`, `package.json`, `pyproject.toml`, `Dockerfile`
- core folders such as `.github/`, `docs/`, `scripts/`, `tests/`, `evidence/`, `logs/`

Do not accumulate disposable outputs in root.

---

## Recommended Structure

```text
docs/
  library/
  sessions/
  architecture/

scripts/
  deployment/
  seed/
  validation/
  sync/
  analysis/
  testing/
  migration/
  admin/

evidence/
logs/

.eva/
  discovery.json
  reconciliation.json
  trust.json

artifacts/
  outputs/

archives/
  backups/
```

Adapt this to the project, but keep purpose-based grouping.

---

## Organization Principles

1. Store session reports under `docs/sessions/`.
2. Group scripts by operational purpose, not by author or date.
3. Put generated outputs under `artifacts/outputs/` or another non-source directory.
4. Put archival backups under `archives/`.
5. Keep `evidence/` for durable proof tied to work, validation, or governance.

---

## D3PDCA Application

Apply D3PDCA at multiple levels when useful:
- project phases
- features
- components
- risky operations or reorganizations

If the work has multiple meaningful sub-steps, check each sub-step before treating the larger unit as complete.

---

## Governance Alignment

This project uses API-first governance.

- local files support continuity and planning
- the Data Model API remains authoritative for governed state
- veritas tooling reads and writes against that model

Do not describe this as hybrid truth. Local files are supporting context, not a second source of authority.

---

## Project-Specific Notes

Use this section to record local structure decisions, naming conventions, and exceptions that matter to this project.

### Architecture Decisions

- {{ARCH_DECISION_1}}
- {{ARCH_DECISION_2}}

### Integration Patterns

- {{INTEGRATION_PATTERN_1}}
- {{INTEGRATION_PATTERN_2}}

### Lessons Learned

- {{LESSON_1}}
- {{LESSON_2}}

---

## Verification Checklist

- [ ] root contains only intentional top-level files and folders
- [ ] scripts are grouped by purpose
- [ ] evidence and logs have clear homes
- [ ] disposable outputs are not stored in root
- [ ] local structure notes reflect actual project behavior
