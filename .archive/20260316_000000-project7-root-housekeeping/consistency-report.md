# Governance Consistency Report

**Generated**: 2026-03-10 07:50:30 ET  
**Workspace**: C:\eva-foundry (instructions) / C:\eva-foundry\eva-foundry (projects)  
**Tool Version**: 1.0.0

---

## Summary

| Status | Count |
|--------|-------|
| [PASS] PASS | 5 |
| [FAIL] FAIL | 2 |
| [WARN] WARN | 0 |
| **Total** | 7 |

---

## Check Results

### Bootstrap

**✅ Complete bootstrap (agent-guide + user-guide)**: PASS
- Details: Both templates reference both endpoints


### Category Runbooks

**✅ All 6 categories documented**: PASS
- Details: All categories present in both templates


### Layer Count

**❌ Consistent layer count references**: FAIL
- Details: 1 layer count issues found
- Remediation: Update files to use: 111 target layers (91 operational + 20 planned)


### Project Coverage

**❌ Copilot instructions in all projects**: FAIL
- Details: 53/60 projects (88.3%) - too low
- Remediation: Run Invoke-PrimeWorkspace.ps1 on workspace root


### Session Docs

**✅ Session summary files exist**: PASS
- Details: Found 10 recent session summaries (latest: Session 41)


### Template Versions

**✅ Version synchronization**: PASS
- Details: Both templates at v4.3.0


### Timestamps

**✅ Workspace instructions freshness**: PASS
- Details: Last updated 1.7 hours ago


