# Workspace Memory Priming Deployment Guide

**Version**: 2.0  
**Date**: March 14, 2026  
**Scope**: Agent wake-up priming for numbered project folders  
**Authority**: Data Model API remains the source of truth

---

## Quick Start

### Step 1: Dry-Run On Project 99

```powershell
cd c:\eva-foundry

. 07-foundation-layer\scripts\Initialize-WorkspaceMemorySystem.ps1 `
  -WorkspaceRoot "c:\eva-foundry" `
  -ProjectIds "99-test-project" `
  -PhaseToActive 1 `
  -DryRun
```

Expected result:

- API health check passes
- project 99 is discovered
- `.memories/session/` would be created
- managed kickoff checkpoint would be created or refreshed
- no `sprint_1_config.json` is produced

### Step 2: Apply On Project 99

```powershell
. 07-foundation-layer\scripts\Initialize-WorkspaceMemorySystem.ps1 `
  -WorkspaceRoot "c:\eva-foundry" `
  -ProjectIds "99-test-project" `
  -PhaseToActive 1
```

### Step 3: Roll Out To Core Projects

```powershell
. 07-foundation-layer\scripts\Initialize-WorkspaceMemorySystem.ps1 `
  -WorkspaceRoot "c:\eva-foundry" `
  -ProjectIds "07-foundation-layer","19-ai-gov","37-data-model","40-eva-control-plane","48-eva-veritas","50-eva-ops","62-agent-memory" `
  -PhaseToActive 1
```

### Step 4: Discover And Prime All Numbered Projects

```powershell
. 07-foundation-layer\scripts\Initialize-WorkspaceMemorySystem.ps1 `
  -WorkspaceRoot "c:\eva-foundry" `
  -PhaseToActive 1
```

This automatically targets folders matching `^\d{2}-`.

---

## What Gets Created

### Project Structure

```text
PROJECT/
└── .memories/
    └── session/
        └── phase-1-kickoff-checkpoint.md
```

### Kickoff Checkpoint Contents

The generated checkpoint includes:

- governance refresh steps
- API health and bootstrap snippets
- authoritative query examples for `projects`, `project_work`, `sprints`, and `evidence`
- reconciliation rule: API truth overrides local notes
- WS06 learning-loop reminders
- session opening checklist for the next agent

### Evidence Output

- `logs/{timestamp}-workspace-memory-init.log`
- `evidence/{timestamp}-workspace-memory-init-evidence.json`

The evidence file records discovered projects, per-project results, total runtime, and overall status.

---

## What No Longer Gets Created

The priming workflow does not create:

- `sprint_N_config.json`
- local sprint definitions
- local copies of `project_work` truth
- local copies of evidence truth

If you need sprint governance work, do it through the Data Model runbooks and the API-backed workflow.

---

## Validation Checklist

### After The Project 99 Pilot

- [ ] `.memories/session/` exists in project 99
- [ ] `phase-1-kickoff-checkpoint.md` exists
- [ ] checkpoint contains both `agent-guide` and `user-guide`
- [ ] checkpoint states that the Data Model API is authoritative
- [ ] no `sprint_1_config.json` was generated
- [ ] log and evidence artifacts were written

### After Core Rollout

- [ ] all target projects have `.memories/session/`
- [ ] all target projects have managed kickoff checkpoints
- [ ] unmanaged local notes were not overwritten
- [ ] no local sprint config files were created by priming
- [ ] evidence file shows only PASS, SKIP, or expected WARN outcomes

### After Workspace Rollout

- [ ] all discovered numbered projects were evaluated
- [ ] missing targets were skipped safely
- [ ] API health passed before rollout
- [ ] evidence file lists all discovered numbered projects

---

## Troubleshooting

### API Health Failure

Cause: Data Model API unavailable or not backed by Cosmos.

Action:

```powershell
Invoke-RestMethod "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/health" -TimeoutSec 10
```

Priming is fail-closed. Fix API availability before retrying.

### Unmanaged File Skipped

Cause: A kickoff file already exists but does not match the managed checkpoint patterns.

Action:

- inspect the existing file manually
- decide whether to merge or replace it
- rerun priming after cleanup if desired

### Project Missing

Cause: A requested `ProjectIds` entry does not exist.

Action:

- verify the folder name
- rerun with the correct project id

The script records this as a skip, not a technical failure.

---

## Post-Deployment Use

When a new session starts inside a primed project:

1. read the local kickoff checkpoint
2. load workspace and project governance files
3. bootstrap `agent-guide` and `user-guide`
4. query authoritative state from the API
5. read any local blockers or handoff notes
6. begin the next D3PDCA cycle

If the agent needs sprint or project execution truth, it should query the API rather than invent local state.

---

## Recommended Rollout Sequence

| Stage | Targets | Goal |
|-------|---------|------|
| Pilot | 99-test-project | Verify managed checkpoint behavior |
| Core | 07, 19, 37, 40, 48, 50, 62 | Confirm API-first wake-up model on critical projects |
| Full | All numbered folders | Standardize local wake-up continuity across workspace |

---

## References

- `07-foundation-layer/templates/WORKSPACE-MEMORY-SYSTEM.md`
- `37-data-model/USER-GUIDE.md`
- `19-ai-gov/docs/missions/deterministic-orchestration/BREAKTHROUGH-WS06-ADAPTIVE-REFLEXION-20260314.md`

---

## Success Criteria

Deployment is complete when:

1. target projects have local wake-up checkpoints
2. those checkpoints direct agents back to the API for truth
3. priming no longer generates local sprint config artifacts
4. evidence confirms the rollout result clearly

**Status**: READY FOR PROJECT 99 PILOT
