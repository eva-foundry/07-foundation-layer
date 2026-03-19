# {{PROJECT_ID}} -- Status

**Template Version**: v7.0.0 (Session 71 - API-first local continuity)  
**Last Updated**: {{PRIME_DATE}} by {{PRIME_ACTOR}}  
**Project Record**: `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/{{PROJECT_ID}}`

---

<!-- eva-primed-status -->

## Use This File For

Use this file to summarize the latest verified local understanding of project delivery state.

Do not treat it as authoritative governance truth when the Data Model API says otherwise.

Before updating this file, refresh:

```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
Invoke-RestMethod "$base/health"
Invoke-RestMethod "$base/model/projects/{{PROJECT_ID}}"
```

---

## Current Snapshot

**Phase**: {{CURRENT_PHASE}}  
**Maturity**: {{CURRENT_MATURITY}}  
**Active Work**: {{ACTIVE_WORK}}  
**Blockers**: {{BLOCKER_SUMMARY}}  
**Next Session Focus**: {{NEXT_SESSION_FOCUS}}

---

## Session Log

### {{PRIME_DATE}} -- Initial Prime by {{PRIME_ACTOR}}

**Activity**: Project primed with current foundation governance templates.

**Next Steps**:
- [ ] reconcile local plan with API-backed project state
- [ ] define initial active work in `PLAN.md`
- [ ] customize `ACCEPTANCE.md`
- [ ] capture first validation evidence

---

## Metrics

| Metric | Value | Last Updated |
|--------|-------|--------------|
| Test Coverage | N/A | {{PRIME_DATE}} |
| MTI Score | N/A | {{PRIME_DATE}} |
| Active Stories | 0 | {{PRIME_DATE}} |
| Open Blockers | 0 | {{PRIME_DATE}} |

Refresh governed quality with veritas tooling when needed:
- `get_trust_score`
- `audit_repo`

---

## Known Issues

- none recorded yet

---

## Recent Changes

- {{PRIME_DATE}}: initial local governance scaffold created
