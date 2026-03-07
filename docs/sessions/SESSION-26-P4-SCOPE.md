# Session 26 P4 Scope: Bi-Directional Sync (Cloud ↔ Files)

**Date**: 2026-03-05  
**Session**: Session 26 (Planning only, execution in Session 28)  
**Scope**: Design + Plan for cloud ↔ local file synchronization  
**Status**: 🔄 PLANNING (DO phase in Session 28)  

---

## DISCOVER Phase: Current State

### Architecture Today

```
Local Workspace Files
├─ model/projects.json (source of truth)
├─ .eva/evidence/
├─ [56 projects]/README.md, PLAN.md, STATUS.md, ACCEPTANCE.md
└─ [manual updates]
        │
        └─ NO SYNC ─────┐
                       │
                       ▼
        Cloud API (Cosmos DB)
        ├─ L33: workspace_config
        ├─ L25: projects
        ├─ L31: evidence
        └─ L34: project_work
        └─ [Read-only for now]
```

**Problem**: 
- Cloud is updated manually (Session 25 pilot)
- Local files are source of truth
- No automatic sync
- Risk: Divergence over time

---

## PLAN Phase: Proposed Solution

### Architecture After P4

```
Local Workspace Files          Azure Pipelines Scheduler
├─ model/projects.json         (nightly, 02:00 UTC)
├─ .eva/evidence/                   │
├─ [manual updates]                 │
        │                           │
        ├─ Local Priority            │
        │  (humans edit files)       │
        │                           │
        └────────────┬──────────────┘
                     │
                 export-governance-
                  to-files.py
                     (reads cloud,
                      writes files)
                     │
                     ▼
        Cloud API (Cosmos DB) ←─── Users/Scripts
        ├─ L33: workspace_config      (via API)
        ├─ L25: projects              (read+write)
        ├─ L31: evidence
        └─ L34: project_work
        └─ [Primary source of truth]
```

**Benefits**:
- Cloud is primary (always current)
- Local files are automatic backup (nightly)
- Script update local files from cloud
- No manual sync needed
- Audit trail of all changes

---

## Sync Strategy: Local → Cloud → Local

### Scenario 1: Human Updates Local File

```
Human edits:
  model/projects.json (add new project)
        │
        ├─ Next scheduled sync → Pushed to cloud (how?)
        │  RFD: Manual push? Auto-watch? Git commit?
        │
        ▼
  Cloud API Updated (L25)
        │
        ├─ Next nightly export (02:00 UTC)
        │
        ▼
  Local files updated with cloud copy
```

**Question**: Should we auto-push local changes to cloud, or only export on schedule?

**Recommendation**: Conservative approach (Session 28):
- Only export cloud → local (no auto-push)
- Humans push to cloud via API directly (or via 38-ado-poc/39-dash)
- This avoids local file conflicts

---

### Scenario 2: Cloud API Updates (Normal Case)

```
User/Script calls:
  PUT /model/projects/07-foundation-layer (update governance)
        │
        ▼
  Cloud API Updated (Cosmos DB)
        │
        ├─ Next nightly export (02:00 UTC)
        │  export-governance-to-files.py
        │  ├─ GET /model/projects/?workspace=eva-foundry
        │  ├─ GET /model/workspace_config/eva-foundry
        │  └─ GET /model/evidence/?project_id=X
        │
        ▼
  Local files updated
  ├─ model/projects.json (complete refresh)
  ├─ .eva/evidence/ (refreshed)
  └─ Per-project governance (extracted to README changes?)
```

**Advantage**: Simple, one-way, no conflicts

---

## Implementation Design

### Script: export-governance-to-files.py

**Location**: `37-data-model/scripts/export-governance-to-files.py`

**Purpose**: Query cloud API, write local governance files (nightly)

**Queries**:
```python
# Query 1: All projects with governance
projects = GET /model/projects/?workspace=eva-foundry

# Query 2: All evidence data
evidence = GET /model/evidence/?workspace=eva-foundry

# Query 3: Workspace config
workspace = GET /model/workspace_config/eva-foundry
```

**Writes**:
```
For each project:
├─ Update projects.json (complete refresh)
│  └─ Write: [updated list of all 56 projects]
│
└─ For project with governance metadata:
   ├─ Create/Update .eva/governance/{project_id}.json
   │  └─ governance{}, acceptance_criteria[]
   │
   └─ Extract to project README (optional:
      └─ Append governance summary section
```

**Idempotent**: Safe to run multiple times (overwrites with same data)

**Rollback**: Local files are backed up before overwrite (timestamp suffix)

---

### Scheduler: Azure Pipelines

**Location**: `37-data-model/.github/workflows/export-governance.yml` (Azure Pipelines)

**Schedule**: Nightly at 02:00 UTC

**Trigger**:
```yaml
schedules:
- cron: '0 2 * * *'  # 2 AM UTC = 9 PM ET (previous day)
  displayName: Nightly governance export
  always: false      # Skip if no change in last 24h
```

**Steps**:
1. Checkout eva-foundry/37-data-model
2. Run: `python scripts/export-governance-to-files.py`
3. Commit changes (if any) to main branch
4. Auto-commit message: `[AUTO] Sync governance from cloud (S26 P4)`

**Notifications**:
- Success: Silent (expected)
- Failure: Alert (governance export failed)

---

## Conflict Resolution Strategy

### Scenario: Human Edited Local File + Cloud Changed

```
Local file: model/projects.json (human added new project)
Cloud: Projects layer (same new project added via API)

Options:
A) Cloud wins (recommend)
   └─ Nightly export overwrites local with cloud
   └─ Human change lost
   └─ Human must push to cloud via API instead

B) Local wins (complex)
   └─ Check-in local changes to git
   └─ Merge with cloud data
   └─ Push merged result back to cloud
   └─ Complex conflict resolution needed

C) Three-way merge (complex)
   └─ Keep backup of previous cloud state
   └─ Compare: local vs. previous cloud vs. current cloud
   └─ Merge intelligently
   └─ Risk: Incorrect merge
```

**Recommendation (P4)**: **Option A** (Cloud Wins)
- Simple to implement
- Safe (no data loss, just re-publish to cloud)
- Clear workflow: Humans use cloud API to make changes
- Local files are backup/audit trail, not edit source

**Future (Session 29+)**: Could enhance to Option C (advanced)

---

## Timeline & Tasks (Session 28)

### Phase 1: Design Finalization (1 hour)
- [ ] Decide: Cloud wins on conflict (confirm above)
- [ ] Decide: Azure Pipelines vs. GitHub Actions
- [ ] Define: Backup file naming + retention
- [ ] Define: Git commit message + branch strategy

### Phase 2: Implementation (2 hours)
- [ ] Create export-governance-to-files.py (~150 lines)
  - Queries cloud (3 endpoints)
  - Writes local JSON files
  - Handles UTF-8 encoding safely
  - Timestamp backups
- [ ] Create scheduler workflow
  - Azure Pipelines YAML (or GitHub Actions)
  - Nightly trigger (2:00 UTC)
  - Auto-commit on change
  - Error notification

### Phase 3: Testing (1 hour)
- [ ] Manual test: Run export script locally
- [ ] Verify: Files created/updated correctly
- [ ] Verify: Encoding safety (no Unicode)
- [ ] Verify: Backup files created
- [ ] Dry-run scheduling (run manually, verify commit)

### Phase 4: Documentation (30 min)
- [ ] Document sync architecture
- [ ] Document operational runbook (what to do if sync fails)
- [ ] Document retention policy (how long to keep backups)
- [ ] Update project README with sync info

**Total Session 28**: ~4.5 hours

---

## Acceptance Criteria for P4

| Gate | Criteria | Target Session |
|------|----------|---|
| **G4.1** | Design complete (cloud wins, Azure Pipelines chosen) | 28 |
| **G4.2** | export-governance-to-files.py created + tested | 28 |
| **G4.3** | Scheduler configured + manual dry-run PASS | 28 |
| **G4.4** | Documentation complete (architecture, runbook) | 28 |
| **G4.5** | First nightly export successful (files updated) | 28+1 |

---

## Success Metrics

**Operational**:
- Nightly export succeeds 99%+ of the time
- Export completes in < 30 seconds
- Local files never diverge from cloud > 24 hours
- Zero data loss from sync process

**Developer Experience**:
- Developers never need to manually sync files
- Can independently query cloud API or read files (both current)
- Backup files provide audit trail
- No git conflicts from auto-exported files

**Risk Mitigation**:
- Backup files preserved (timestamp suffix) for manual recovery
- Dry-run mode available (test without commit)
- Rollback plan (revert auto-commit if issues)
- Error notifications on failures

---

## Related Sessions

| Session | Scope | Dependency |
|---------|-------|-----------|
| 26 P1-P2 | Bootstrap API-first | ✅ Done |
| 26 P3 | Toolchain integration | 🔄 Session 27 |
| 26 P4 | Bi-directional sync | ⏳ Session 28 |
| 27 P3 | Execute toolchain integration | ← Depends on 26 P3 Plan |
| 28 P4 | Execute sync automation | ← Depends on 26 P4 Plan |

---

## Lessons Learned (Planning)

1. **Cloud-Primary is Cleaner**: Treating cloud as primary source of truth avoids merge conflicts.

2. **Local Files as Backup**: Nightly export creates automatic backup for audit/recovery.

3. **Simple > Complex**: One-way sync (cloud → local) is easier to maintain than bidirectional.

4. **Timing Matters**: 02:00 UTC (9 PM ET) is good for nightly export (outside work hours, avoids conflicts).

5. **Idempotency is Key**: Script must be safe to run multiple times (no duplicates, no data loss).

---

## Next Steps

1. **Immediate (Session 27)**: Execute P3 (Toolchain Integration)
2. **Short-term (Session 28)**: Execute P4 (Bi-Directional Sync)
3. **Long-term (Session 29+)**: Monitor sync health, enhance if needed

---

## Files to Create (Session 28)

| File | Purpose | Location |
|------|---------|----------|
| `export-governance-to-files.py` | Sync script | `37-data-model/scripts/` |
| `export-governance.yml` | Scheduler workflow | `37-data-model/.github/workflows/` |
| `P4-SYNC-IMPLEMENTATION.md` | Session 28 results | `07-foundation-layer/docs/sessions/` |

---

## Appendix: Full Export Script Pseudocode

```python
#!/usr/bin/env python3
"""
Export governance from cloud API to local files (nightly).

Queries cloud API, updates local backup files with latest governance.
Safe idempotent operation - can run multiple times without issues.
"""

def main():
    # 1. Query cloud for current state
    workspace = query_cloud('/model/workspace_config/eva-foundry')
    projects = query_cloud('/model/projects/?workspace=eva-foundry')
    evidence = query_cloud('/model/evidence/?workspace=eva-foundry')
    
    # 2. Backup existing local files (with timestamp)
    backup_local_files(timestamp=now())
    
    # 3. Write new files from cloud data
    write_json('model/projects.json', projects)
    
    for project in projects:
        if project.get('governance'):
            path = f'.eva/governance/{project["id"]}.json'
            write_json(path, project['governance'])
    
    # 4. Commit if changed
    if has_changes():
        git_commit('Cloud governance sync', auto_timestamp=True)
    
    # 5. Return status
    return {'status': 'success', 'projects_synced': len(projects)}

def query_cloud(endpoint):
    """Query cloud API with error handling."""
    try:
        resp = requests.get(f"{CLOUD_BASE}{endpoint}", timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        log_error(f"Cloud query failed: {e}")
        raise

def write_json(filepath, data):
    """Write JSON safely with UTF-8 encoding."""
    pathlib.Path(filepath).parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=True)  # ASCII-safe

def backup_local_files(timestamp):
    """Create timestamped backup of all governance files."""
    for file in glob('model/projects.json', '.eva/governance/*.json'):
        backup_path = f"{file}.backup.{timestamp}"
        shutil.copy(file, backup_path)

def git_commit(message, auto_timestamp=True):
    """Commit changes to git with automation context."""
    msg = f"[AUTO] {message} ({timestamp})" if auto_timestamp else message
    os.system(f'git add model/ .eva/governance/')
    os.system(f'git commit -m "{msg}"')
    os.system(f'git push origin main')
```

---

## Conclusion (P4 Planning)

**P4 is well-scoped and feasible for Session 28.**

- ✅ Design is simple and safe (cloud-primary)
- ✅ Script is straightforward (~150 lines Python)
- ✅ Scheduler is standard (Azure Pipelines)
- ✅ No external dependencies or complex logic

**Recommended Execution**: Session 28 focuses entirely on P4 implementation + testing.

---

*Generated: 2026-03-05 by Copilot / EVA Foundation*  
*Reference: SESSION-26-P1-P4-PLAN.md → Scope Documentation*
