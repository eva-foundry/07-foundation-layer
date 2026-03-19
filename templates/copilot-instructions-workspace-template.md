# [MANDATORY] BOOTSTRAP CHECKPOINT -- READ THIS FIRST

**CRITICAL: Before reading anything else, answer this question:**

**Did you execute the API bootstrap sequence for this session?**  
- [ ] YES - I called `/health`, `/ready`, `/model/agent-handshake`, `/model/agent-guide`, and `/model/user-guide`, and established `$session` object with live API data  
- [ ] NO - I have not bootstrapped yet

**If NO (or uncertain), execute this NOW before proceeding:**

```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{
    base = $base
    initialized_at = Get-Date
    health = (Invoke-RestMethod "$base/health" -TimeoutSec 10)
    ready = (Invoke-RestMethod "$base/ready" -TimeoutSec 10)
    handshake = (Invoke-RestMethod "$base/model/agent-handshake" -TimeoutSec 10)
    guide = (Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10)
    userGuide = (Invoke-RestMethod "$base/model/user-guide" -TimeoutSec 10)
}
Write-Host "[BOOTSTRAP] Health: $($session.health.status) | Ready: $($session.ready.status) | Store: $($session.ready.store)"
Write-Host "[BOOTSTRAP] Handshake: $($session.handshake.protocol) | Contract: $($session.handshake.contract_version)"
Write-Host "[BOOTSTRAP] Layers available: $($session.guide.layers_available.Count)"
Write-Host "[BOOTSTRAP] Category runbooks loaded: $(@($session.userGuide.category_instructions.PSObject.Properties.Name).Count)"
```

**Bootstrap must complete successfully before reading project files or performing governance operations.**

**Fail-Closed Policy:** If the API is unreachable, governance work stops. Use degraded troubleshooting only for local diagnosis, never for authoritative operations.

---

# AICOE Workspace -- GitHub Copilot Instructions

**Workspace**: {WORKSPACE_PATH}  
**Owner**: {WORKSPACE_OWNER} / EVA AI COE  
**Last Updated**: {TIMESTAMP} (Session {SESSION_NUMBER} - {SESSION_DESCRIPTION})  
**Template Version**: 7.1.0 (Session 71 - authority split alignment)

---

## Workspace Overview

{PROJECT_COUNT} numbered projects ({PROJECT_RANGE} + test-99) implement the EVA architecture: API-first governance, evidence-backed delivery, D3PDCA execution, and reusable operating patterns for local and cloud agents.

**Single source of truth**: Project 37 Data Model API.  
**Live layer count**: `$session.guide.layers_available.Count`  
**Governance runbooks**: `$session.userGuide.category_instructions`

---

## Workspace-Level Skills

Workspace provides these skills via `@skill-name` invocation:

| Skill | Invoke As | Purpose |
|-------|-----------|---------|
| **Paperless Authority Refresh** | `@paperless-authority-refresh` | Refresh the workspace root and Project 07 instruction chain from live onboarding state |
| **EVA Factory Guide** | `@eva-factory-guide` | D3PDCA, data model, evidence, and factory patterns |
| **Foundation Expert** | `@foundation-expert` | Priming, scaffolding, template rollout, workspace repair |
| **Scrum Master** | `@scrum-master` | Sprint planning, progress, velocity, and evidence gates |
| **Workflow Forensics** | `@workflow-forensics-expert` | Audit evidence, metrics, and pipeline behavior |

Projects may add their own skills under `.github/copilot-skills/`.

---

## Workspace Tools

**Workspace-wide scrum tools**:
- `scripts/sprint_activation.py`
- `scripts/sprint_progress.py`
- `scripts/velocity_tracker.py`
- `scripts/sprint_retrospective.py`
- `scripts/verify-sprint-readiness.ps1`
- `scripts/semantic_tree_summarizer.py`
- `scripts/housekeeping_project_planner.py`
- `scripts/housekeeping_packet_executor.py`

**Veritas tools** from Project 48:
- `audit_repo`
- `get_trust_score`
- `sync_repo`
- `export_to_model`
- `dependency_audit`
- `scan_portfolio`

Use these against API-backed governance state, not as a substitute for it.

---

## Agent Bootstrap: The API Entry Point

Every agent session starts with the API bootstrap, then reads workspace and project instructions.

```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$session = @{
    base = $base
    initialized_at = Get-Date
    health = (Invoke-RestMethod "$base/health" -TimeoutSec 10)
    ready = (Invoke-RestMethod "$base/ready" -TimeoutSec 10)
    handshake = (Invoke-RestMethod "$base/model/agent-handshake" -TimeoutSec 10)
    guide = (Invoke-RestMethod "$base/model/agent-guide" -TimeoutSec 10)
    userGuide = (Invoke-RestMethod "$base/model/user-guide" -TimeoutSec 10)
}
```

This gives you:
- transport health and readiness
- deterministic bootstrap contract shape
- query patterns
- write-cycle rules
- common mistakes
- live layer inventory
- category runbooks for common governance workflows

Primary references:
- `37-data-model/USER-GUIDE.md`
- `37-data-model/docs/CATEGORY-RUNBOOK-EXAMPLES.md`
- `37-data-model/docs/PAPERLESS-DPDCA-TUTORIAL.md`

---

## Governance Model

1. Workspace instructions define workspace-wide rules.
2. Project instructions define project-specific contracts.
3. The Data Model API is authoritative for governance state.
4. Local governance files are continuity and working aids, not competing sources of truth.

Treat `GET /model/agent-handshake` as the canonical startup contract before deeper guide or layer calls.

Do not generate project instructions by copying workspace instructions verbatim. Project templates must only hold project-level contract material.

---

## D3PDCA Model

Apply D3PDCA at every level that can be decomposed:

- **Discover**: understand current state, constraints, and evidence
- **Define/Plan**: frame the task and success criteria clearly
- **Do**: execute in small controlled steps
- **Check**: verify each meaningful unit before advancing
- **Act**: record results, update context, and promote stable learnings

Use this at session, feature, component, and operation level when the work justifies it.

---

## Memory Model

Use the three-tier memory stack consistently:

1. `/memories/` for persistent user and workspace patterns
2. `/memories/session/` for active-session checkpoints and handoffs
3. `/memories/repo/` for repository facts and proven local patterns

Project-local `.memories/session/` files are wake-up aids only. They do not replace API-governed truth.

---

## Context Governance

Every agent session enforces context governance as a first-class concern.

**Context Window Reality**: GPT-5.4 may expose up to 400K context, but usable headroom is reduced by system instructions, tool definitions, reserved output, file context, and tool results.

Use adaptive utilization bands rather than hardcoded token mythology:

| Band | Approx. utilization | Action | Notes |
|------|----------------------|--------|-------|
| **GREEN** | <55% | Normal operation | Coherence and retrieval remain strong |
| **YELLOW** | 55-70% | Save session checkpoint | Start recovery discipline early |
| **ORANGE** | 70-85% | Prepare closure or compaction | Reduce exploration, protect policy fidelity |
| **RED** | >85% | Close or safely compact before further complex work | Zero tolerance for governance drift |

Policy guidance:
- optimize for decision quality and recoverability, not maximum token consumption
- checkpoint earlier for policy-heavy, multi-project, or evidence-heavy work
- treat reasoning softening, retrieval drift, or continuity loss as triggers even if visible utilization still looks acceptable

---

## Engineering Standards

All automation and scripts should follow these rules:

1. ASCII-only output and file content unless the target file already requires otherwise.
2. Dual logging: console plus timestamped file output.
3. Evidence artifacts at start, success, and failure.
4. Explicit exit codes: `0` success, `1` business failure, `2` technical failure.
5. Timestamp-prefixed artifact names: `{YYYYMMDD_HHMMSS}-{category}-{descriptor}.{ext}`.
6. Pre-flight checks before mutations, deployment, or long-running operations.

---

## Key References

| Component | Role | Location |
|-----------|------|----------|
| **Project 37** | Data model API and governance truth | `37-data-model/` |
| **Project 07** | Foundation templates and rollout tooling | `07-foundation-layer/` |
| **Project 48** | Veritas MTI and evidence tooling | `48-eva-veritas/` |
| **Project 51** | Mature reference implementation | `51-ACA/` |

Additional references:
- `C:\eva-foundry\.github\best-practices-reference.md`
- `C:\eva-foundry\.github\standards-specification.md`
- `{WORKSPACE_PATH}\18-azure-best\`

---

*This instruction file follows GitHub best practices: repository context only, ≤2 pages, no procedural content. For operational procedures, methodology guides, and API protocol documentation, see project-specific guides.*
