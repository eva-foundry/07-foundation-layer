# Workspace Memory Priming Template

**Status**: Refactored for paperless governance  
**Sources**: Project 62 local memory model, Project 37 API-first governance, Project 19 WS06 adaptive reflexion  
**Target**: Any numbered project folder in the workspace

---

## Purpose

Foundation priming no longer seeds local sprint plans. It prepares an agent to wake up inside a project, recover continuity quickly, and return to the Data Model API for authoritative state.

Local priming exists to support:
- Phase continuity
- Async handoff
- Governance refresh
- WS06 learning-loop reminders

Local priming must never become a second source of truth for:
- `project_work`
- `sprints`
- `evidence`
- `risks`
- `decisions`

---

## Separation Of Concerns

### 1. Shared Memory

Use the platform memory tiers for reusable patterns and session continuity:

- `/memories/` for persistent user/workspace notes
- `/memories/session/` for current-session notes
- `/memories/repo/` for repository facts

### 2. Project-Local Priming

Use project-local files only for fast wake-up and handoff:

```text
PROJECT/
└── .memories/
    └── session/
        ├── phase-N-kickoff-checkpoint.md
        ├── phase-N-blockers.md
        └── phase-N-handoff-summary.md
```

These files are helper artifacts. They are not governance records.

### 3. Authoritative Governance

All live governance state stays in the Data Model API:

- `projects`
- `project_work`
- `sprints`
- `evidence`
- `verification_records`
- `quality_gates`
- `decisions`
- `risks`

If local files and the API disagree, the API wins.

---

## Agent Wake-Up Contract

Every primed project should let a new agent follow this order:

1. Load workspace and project governance files.
2. Verify API health.
3. Bootstrap `agent-guide` and `user-guide`.
4. Query authoritative project state from the API.
5. Read local continuity files in `.memories/session/`.
6. Reconcile local notes against API truth.
7. Start the next D3PDCA loop with explicit tasks and evidence targets.

---

## Managed Checkpoint Template

Foundation writes a managed kickoff file per project phase:

```markdown
<!-- foundation-memory-checkpoint -->
# [Project] Agent Wake-Up Checkpoint

**Purpose**: Local continuity aid only. Governance truth lives in the Data Model API.

## Wake-Up Order
1. Load governance files.
2. Bootstrap the API guides.
3. Query `projects`, `project_work`, `sprints`, and `evidence`.
4. Review local continuity notes.
5. Trust API state when conflicts exist.
6. Start D3PDCA execution.

## Governance Refresh
```powershell
$workspacePolicies = Get-Content ".github/copilot-instructions.md" -Raw
$projectPlan = Get-Content "PLAN.md" -Raw -ErrorAction SilentlyContinue
$projectStatus = Get-Content "STATUS.md" -Raw -ErrorAction SilentlyContinue
```

## API Bootstrap
```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{
    base = $base
    initialized_at = Get-Date
    guide = Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10
    userGuide = Invoke-RestMethod "$base/model/user-guide" -TimeoutSec 10
}
```
```

---

## Local Files To Keep

Recommended local continuity files:

- `phase-N-kickoff-checkpoint.md`
- `phase-N-blockers.md`
- `phase-N-handoff-summary.md`

Allowed content:

- concise blockers
- next-session reminders
- unresolved questions
- pointers to API records and evidence

Forbidden content:

- full sprint definitions
- canonical work item lists
- authoritative acceptance results
- duplicated evidence payloads
- local replacements for `project_work` or `sprints`

---

## WS06 Reflexion Alignment

Priming must support the deterministic-orchestration learning loop:

- execution events should be recorded as durable evidence in the governed workflow
- local notes should only capture short handoff context for the next wake-up
- reusable successful patterns should be promoted into shared memory or Foundation docs
- repeated failure patterns should feed future planning and scheduler behavior

Priming does not implement the learning loop by itself. It teaches the next agent where that loop belongs.

---

## Initialization Behavior

The Foundation initializer should do exactly this:

1. Discover numbered project folders automatically.
2. Verify API health before any priming.
3. Create `.memories/session/` if missing.
4. Create or refresh the managed kickoff checkpoint.
5. Write logs and evidence for the priming run.

The initializer should not:

1. create `sprint_N_config.json`
2. activate sprints
3. write project governance truth locally
4. infer sprint status from local files

---

## Validation Checklist

- [ ] `.memories/session/` exists
- [ ] kickoff checkpoint contains governance refresh steps
- [ ] kickoff checkpoint bootstraps both `agent-guide` and `user-guide`
- [ ] checkpoint clearly states API authority
- [ ] no `sprint_N_config.json` is created by memory priming
- [ ] priming run produces log and evidence artifacts

---

## Adoption Path

### Phase 0: Pilot

- Run priming on `99-test-project`
- Verify checkpoint content matches the wake-up contract
- Confirm no sprint config is generated

### Phase 1: Core Projects

Projects: 07, 19, 37, 40, 48, 50, 62

- Roll out the checkpoint model
- Verify API-first recovery flow
- Check that local notes stay short and non-authoritative

### Phase 2: Remaining Numbered Projects

- Run on all discovered numbered folders
- Skip missing or unmanaged targets safely
- Capture evidence for each rollout batch

---

## Expected Benefits

| Benefit | Mechanism |
|---------|-----------|
| Faster wake-up | Managed kickoff checkpoint points the agent to the right files and queries |
| Less governance drift | API authority is explicit in every local checkpoint |
| Cleaner local state | No duplicated sprint truth in repo files |
| Better handoff quality | Local notes stay short, current, and actionable |
| WS06 readiness | Priming reminds agents to route durable learning into the governed loop |

---

**Owner**: Foundation Layer  
**Status**: READY FOR PILOT AND ROLLOUT
