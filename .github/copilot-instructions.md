<!-- eva-primed-copilot -->

# GitHub Copilot Instructions -- 07-foundation-layer

**Last Updated**: 2026-03-20T10:12:37Z  
**Project**: 07-foundation-layer | Path: C:\eva-foundry\07-foundation-layer\  
**Role**: Workspace foundation, priming, template, and governance-tooling owner

---

## Bootstrap First

Before changing templates, priming scripts, or workspace governance artifacts, make sure the workspace bootstrap has run and the Project 37 API is reachable:

```powershell
Write-Host "[BOOTSTRAP-CHECK] Health: $($session.health.status) | Ready: $($session.ready.status) | Store: $($session.ready.store)"
Write-Host "[BOOTSTRAP-CHECK] Handshake: $($session.handshake.protocol) | Contract: $($session.handshake.contract_version)"
Write-Host "[BOOTSTRAP-CHECK] Layers: $($session.guide.layers_available.Count)"
Invoke-RestMethod "$($session.base)/model/agent-handshake" -TimeoutSec 10
Invoke-RestMethod "$($session.base)/health" -TimeoutSec 10
Invoke-RestMethod "$($session.base)/ready" -TimeoutSec 10
Invoke-RestMethod "$($session.base)/model/projects/07-foundation-layer"
```

If bootstrap or health fails, stop. Foundation changes must respect the workspace fail-closed governance model.

If the handshake call fails or advertises an unexpected protocol version, stop. Project 07 should not continue on inferred bootstrap behavior.

---

## Project Role

Project 07 owns the workspace priming system and the reusable governance/template artifacts applied across numbered projects.

Treat this repo as authoritative for:
- Workspace priming and reseeding scripts
- Template safety and rendering behavior
- Governance scaffolding for new or repaired projects
- Protection against placeholder leakage and encoding corruption

Current operational priority:
- Maintain the workspace scrum-master toolchain in approved paperless execution mode against the live Data Model API.
- Preserve governance-rights, telemetry, metrics, and authority-refresh surfaces so the data model stays authoritative and disk remains alignment or export only.
- Keep Project 37 operational completeness, Project 19 kernel persistence, and Project 60 downstream handoff in bounded maintenance after the March 20 paperless approval.
- Keep Sprint 9 check and act for `57-FKTE` explicit while the broader workspace cutover stays approved and data-model-first.
- Drive Veritas-style numbered-project backlog audits so repo-side ideas are either captured in the data model or explicitly classified as residue.
- Refresh the workspace root and Project 07 instruction chain on every numbered-project onboarding cycle, using the active cycle correlation ID as the operator-visible join key.
- Keep the active numbered-project cycle aligned to `paperless-onboarding-20260318T041500Z` unless a newer governed cycle is explicitly issued.
- Treat GitHub Projects automation as an active Project 07 certification surface: the live board population path now runs through `97-workspace-notes/scripts/populate-project-boards.ps1`, all five org boards are populated, and instruction refresh work must keep that route aligned with the active cycle correlation ID and paperless governance posture.
- Treat `GET /model/agent-handshake` as the canonical startup contract for workspace agents and templates: health and readiness prove transport, handshake proves shape, `domain-views` proves ontology-first orientation, and only then should deeper guides or layer queries run.
- Treat the `61-GovOps` blank-id residue as a closed runtime proof point after the Project 37 promotion passed live GET/DELETE recovery verification, promoted-runtime `project_work` sprint/countdown query verification, and `GET /model/domain-views`; keep any remaining Project 60 registration-path follow-up explicitly separate from that resolved gate.
- Ensure the canonical `61-GovOps` paperless record stays aligned to that closed posture while preserving the dormant OAS planning set as retained context, not active execution authority.
- Treat the promoted Project 37 runtime proof for sparse `project_work` sprint/countdown filtering and `GET /model/domain-views` as established closure input for the GovOps remediation lane and Sprint 9 promotion gate; public L112-L120 route completeness is now also proven live on the promoted ACA revision, and the remaining Project 37 certification work is downstream handoff proof and acceptance for Project 60 plus audit-grade evidence discipline.
- Treat the current cloud inventory as an explicit certification metric: the live API now proves 122 layers plus queryable workflow-definition, run, signal, transition, gate-result, and preflight records, so the next gate is not route availability but whether the workflow plane is complete enough to support a paperless basic-engine go-live claim without audit or handoff gaps.
- Treat the Project 19 kernel engine as a live cloud dependency that is now available and reachable through `/health`, `/ready`, workflow routes, and signal routes; the remaining certification question is end-to-end persistence and fail-closed behavior, not basic deployment reachability.
- Treat the deterministic Project 19 GitHub workflow as a separate certification surface from raw ACA reachability: remote main now carries the repaired ACA FQDN plus `/api/v1` callback routes and the follow-on repo-side signal fixes through commit `f9bc2b8`, workflow run `23317407539` proved the repaired entrypoint, but later runs `23317577525` and `23317816738` still failed at first signal emission with `504 stream timeout`, so the remaining blocker is stale runtime promotion rather than workflow YAML drift.
- Treat Project 19 deployment credential sourcing as an explicit certification gate: deploy runs `23317567533` and `23317812400` failed at `Login to ACR` with `Username and password required`, and the current operator posture is that the required GitHub deployment credentials exist in Key Vault and must be wired into the governed deploy path before Project 19 cloud certification can close.
- Treat Project 37 Sprint 11 as an active downstream-enablement packet, not a ready-only packet: Project 07 should plan around explicit Project 60 handoff closure rather than reopening either the resolved GovOps runtime gate or the now-proven public route contract.
- Require a deterministic Sprint 9 promotion gate for `57-FKTE`: clean baseline, current Sprint 8 closure evidence, no authority drift, and no higher-priority dependency remediation emerging from Discover.
- Publish and maintain one operator-readable audit closure matrix for the four mandatory paperless audits so cutover readiness can be checked objectively.
- Require packet-level operational metrics for governed onboarding: activation-to-closure duration, rerun count, failed workflow step classification, and authority-refresh drift count.
- Use the first successful governed onboarding workflow run for `37-data-model` as the certification baseline for Sprint 2 execution targeting `07-foundation-layer`.
- Certify the Project 19 onboarding workflow as an active execution path, confirming that Sprint 2 artifacts, summaries, and any later cloud-agent handoff preserve the active cycle correlation ID.
- Treat the corrected non-dry-run `07-foundation-layer` packet, the bounded non-dry-run `19-ai-gov` packet, and the bounded non-dry-run `48-eva-veritas` packet as completed certification gates.
- Keep Project 37 and Project 19 live runtime health in scope during certification, but treat `POST /model/admin/commit` recovery and kernel-engine reachability as proven; remaining checks should focus on end-to-end field, signal, workflow, and preflight persistence, Project 60 handoff acceptance, audit evidence discipline, no disk-authority leakage, and successful Key Vault-backed deployment credential handoff into the Project 19 GitHub deploy path.

When the live model needs a genuinely new concept, create a new layer or managed artifact rather than peg-adapting an existing one.

This project should not blindly overwrite project-specific content once a repository has its own authoritative instructions.

---

## Core Rules

1. Preserve user-managed files. Do not overwrite project-specific instructions, README, PLAN, STATUS, or ACCEPTANCE without an explicit managed-artifact rule.
2. All generated markdown and text outputs must be UTF-8 safe.
3. Timestamped artifacts must use the workspace prefix standard: `YYYYMMDD_HHMMSS-{category}-{descriptor}.{ext}`.
4. Priming changes must be validated with dry-run behavior before broad rollout.
5. Prefer repair scopes that target managed artifacts only when remediating generated fallout.
6. Keep template changes minimal and make placeholder substitution deterministic.
7. Shared instructions and script examples must not reintroduce localhost-first API guidance or legacy underscore-based artifact naming.
8. During governance refresh work, prioritize active authorities, templates, and execution-path scripts; skip backups, archives, generated caches, and one-off artifacts unless they are the subject of the fix.
9. When workspace scrum-tool authorities change, refresh the workspace instruction chain, Project 07 instruction chain, and the active registry/tooling docs together so operational status does not drift.
10. For housekeeping, work one folder at a time under nested D3PDCA: baseline, classify, archive, validate, summarize.
11. Prefer `@eva-housekeeping` for filesystem cleanup and `bob-semantic-filter` for single-file semantic reduction.
12. Archive into timestamped buckets; do not hard-delete residue unless the user explicitly asks for deletion.
13. Paperless-certification work now operates under the approved March 20 cutover posture: governance truth lives in the API path, and disk artifacts may exist for evidence, cache, export, or operator convenience, but not as the authoritative state transition mechanism.
14. Scrum-tool certification must verify three things explicitly: live API read/write contract correctness, timestamp-prefix evidence/log discipline, and no hidden dependency on repo-local governance files for runtime decisions.
15. When evaluating dashboards or ADO integration, distinguish between operational telemetry persisted in the data model and external-system synchronization that can be rebuilt from the governed API state.
16. For numbered-project onboarding, every cycle must carry one shared correlation ID in the form `paperless-onboarding-YYYYMMDDTHHMMSSZ` across the live `project_work` packet, linked stories, evidence files, instruction refresh notes, GitHub workflow runs, and cloud-agent executions.
17. Project 07 must treat correlation-ID propagation as part of certification: if workflow logs, evidence, or instruction refreshes cannot be tied back to the active onboarding packet, the cycle is not fully governed.
18. Treat workflow intake certification as a distinct gate from workflow execution certification: the first gate proves governed dispatch, artifact capture, and correlation continuity before any broader autonomous action is approved.
19. Treat dry-run execution proof as a distinct gate from non-dry-run onboarding closure: the `07-foundation-layer` gate closed under workflow run `23246825920`, Sprint 3 for `19-ai-gov` closed under workflow run `23248103118`, Sprint 4 for `48-eva-veritas` closed under workflow run `23249582741`, Sprint 5 for `50-eva-ops` closed under workflow run `23252326729`, Sprint 6 for `62-agent-memory` closed under workflow run `23253213262`, Sprint 7 for `59-performance` closed under workflow run `23253719737`, Sprint 8 for `58-cybersec` closed under corrected non-dry-run workflow run `23255692804`, Sprint 9 is now active for `57-FKTE` with governed dry-run workflow run `23272454604` successful, and no later packet beyond Sprint 9 is active.
20. Use task-scoped GitHub PAT secrets from Key Vault for execution surfaces: `github-pat-dev` for routine GitHub operations, `github-pat-projects` for Project v2 GraphQL automation, `github-pat-admin-org` only for org-governance changes, and treat `github-pat` as a temporary compatibility alias rather than an authority surface.
21. When a governed workflow, template, or model surface needs a genuinely new concept, create a new layer or managed artifact rather than peg-adapting a semantically mismatched existing one. Priming convenience does not justify ontology drift.

---

## Validation Pattern

For changes to workspace priming or templates, validate in this order:
1. Static script parse validation
2. Targeted dry-run against a representative repo
3. Managed-artifact repair-only validation where applicable
4. Representative file inspection after render

If a rollout affects many repos, validate against at least one stable repo and one previously damaged repo before wider execution.

For housekeeping in Project 07, validate after each folder-level pass with `scripts/testing/Test-Project07-Deployment.ps1` whenever the cleanup touched active docs, `.github`, `.eva`, templates, or execution-path scripts.

For scrum-tool certification and paperless readiness work, validate in this order:
1. Live API bootstrap and health
2. Focused tool tests for contract handling and artifact output
3. One end-to-end paperless execution path against the live API
4. Evidence review confirming no disk-bound governance dependency
5. Correlation-ID continuity across live packet, evidence note, refreshed instructions, and any workflow or agent execution touched in the cycle

For the current cycle `paperless-onboarding-20260318T041500Z`, apply nested D3PDCA explicitly:
1. `D1 Discover`: confirm Sprint 8 is closed for `58-cybersec`, treat `61-GovOps` as a closed runtime proof point, and verify `57-FKTE` still presents one clean active onboarding baseline
2. `P1 Plan`: keep Sprint 9 explicit as the next bounded packet for `57-FKTE`, satisfy its promotion gate, and keep the audit-closure, packet-metrics, and canonical-record surfaces current
3. `D2 Do`: Sprint 9 is now promoted under the same correlation ID and governed dry-run workflow run `23272454604` completed successfully; keep the canonical 61-GovOps paperless record synchronized to its closed posture in the meantime
4. `C1 Check`: preserve Sprint 8 evidence, Sprint 9 dry-run evidence, correlation continuity, no disk-authority leakage, and current packet metrics before any bounded non-dry-run decision
5. `A1 Act`: either continue Sprint 9 through explicit check/act decisions or hold the wave at active Sprint 9 posture and document whether the unmet condition is audit closure, packet metrics, Project 60 downstream dependency, or another explicit hardening gate
6. If a source-side fix depends on deployment, re-check the live runtime before marking the certification packet complete; local proof of the Project 37 `project_work` sprint/countdown query contract is necessary but not sufficient for closure, and the current live checkpoint now also requires explicit downstream handoff acceptance plus workflow-plane field, signal, and preflight validation after route completeness is proven

When scoping a refresh, start with the active authority chain:
1. `C:\eva-foundry\.github\copilot-instructions.md`
2. `07-foundation-layer/.github/copilot-instructions.md`
3. Active templates and priming scripts actually used in current rollout paths

Do not spend time normalizing stale copies in low-value or dormant assets unless they are still referenced by those active authorities.

---

## High-Risk Areas

Take extra care when editing:
- `scripts/deployment/Invoke-PrimeWorkspace.ps1`
- `templates/copilot-instructions-template.md`
- `templates/copilot-instructions-workspace-template.md`
- Governance templates that write README, PLAN, STATUS, or ACCEPTANCE files

When touching these surfaces, assume workspace-wide blast radius until proven otherwise.

High-value refresh targets include active registry and tooling documents referenced by workspace instructions. Backup files such as `*.backup-*`, ad hoc debug outputs, and caches are not refresh targets.

For deeper cleanup work, classify surfaces in this order:
1. active authorities and validators
2. referenced live artifacts
3. durable evidence and logs
4. generated or one-off residue

Do not treat duplicate-looking files as residue until reference checks prove they are not part of the active operator path.

The current workspace scrum-master toolbox has five operational tools in `97-workspace-notes/scripts`: `sprint_activation.py`, `sprint_progress.py`, `velocity_tracker.py`, `sprint_retrospective.py`, and `verify-sprint-readiness.ps1`. Foundation refresh work must keep instruction examples aligned with that active set.

The current certification target is not just tool presence. Project 07 must confirm that these tools operate correctly against live `project_work`, `evidence`, `risks`, `decisions`, telemetry-bearing records, and downstream ADO synchronization expectations without falling back to repo-local governance state.

---

## Data Model Integration

Project 07 depends on Project 37 for workspace governance truth, but foundation logic must not hardcode layer counts or stale ontology assumptions.

Use live API context:

```powershell
Invoke-RestMethod "$($session.base)/model/agent-handshake"
Invoke-RestMethod "$($session.base)/model/agent-guide"
Invoke-RestMethod "$($session.base)/model/domain-views"
Invoke-RestMethod "$($session.base)/model/projects/07-foundation-layer"
```

For deterministic bootstrap-sensitive tooling, prefer this order:
1. `GET /health`
2. `GET /ready`
3. `GET /model/agent-handshake`
4. `GET /model/domain-views`
5. `GET /model/agent-guide`
6. `GET /model/user-guide`

## Current Live Alignment

- Workspace bootstrap must resolve `GET /model/agent-handshake` before any deeper guide or layer query.
- The active numbered-project cycle is `paperless-onboarding-20260318T041500Z` unless a newer governed cycle is explicitly published.
- Workspace paperless certification is approved under `paperless-certification-20260320T012158Z`: all 62 projects are Level 4 certified, and disk governance files remain alignment or export surfaces only.
- Sprint 9 remains active for `57-FKTE`; do not advance later packets until check and act are explicit.
- `61-GovOps` is closed as a runtime proof point, and Project 60 remains a separate downstream handoff dependency.
- If the model needs a genuinely new concept, add a new layer instead of forcing a semantically mismatched existing one.

---

## Before Commit

- Confirm dry-run or targeted validation was executed for priming/template changes
- Inspect rendered output, not just source templates
- Record evidence when automation or repair work is performed
- Keep workspace instructions, templates, and generator behavior aligned in the same change set when they affect one another

---

## References

- Workspace authority: `C:\eva-foundry\.github\copilot-instructions.md`
- Project 37 API rules: `C:\eva-foundry\.github\instructions\data-model.instructions.md`
- Foundation README: `C:\eva-foundry\07-foundation-layer\README.md`
- Priming engine: `C:\eva-foundry\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1`
- Housekeeping skill: `C:\eva-foundry\.github\skills\eva-housekeeping\SKILL.md`

This file is authoritative for Project 07 project-level behavior. Do not replace it with a generic scaffold.
