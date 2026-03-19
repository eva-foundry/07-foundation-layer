# D3PDCA Agent Operating System Blueprint

**Date**: 2026-03-15
**Owner**: 07-foundation-layer
**Status**: Proposed operating blueprint for local and cloud agents
**Purpose**: Reduce repeated agent guesswork, rework, drift, and policy loss by turning D3PDCA and the memory stack into a deterministic operating system.

---

## 1. Problem Statement

Agents are strongest when they can:

- reason over a clear problem definition
- operate inside explicit boundaries
- use trusted tools and runbooks
- validate outcomes against known gates

Agents waste time when they must repeatedly figure out:

- which instruction file is authoritative
- which endpoint, command, or template is current
- which docs are durable versus historical
- which checks are mandatory before and after execution
- what evidence must be produced
- how to recover after partial failure or context loss

The operating-system goal is simple:

**Make the correct path the default path.**

---

## 2. Operating Principle

The EVA agent operating system is not one file and not one script.

It is a layered control system made of:

- authoritative instructions
- deterministic templates
- execution contracts
- runbooks and skills
- validation and drift detection
- evidence and recovery
- protected memory tiers

This is what lets local and cloud agents spend less time discovering basic operating facts and more time delivering high-value work.

---

## 3. D3PDCA Applied Fractally

### 3.1 Levels of Application

D3PDCA must run at five nested levels:

1. **Workspace level**
   Discover workspace authority, Define policy model, Plan standards, Do propagation, Check drift, Act by updating templates and controls.

2. **Mission level**
   Discover the real problem, Define scope and success criteria, Plan workstreams, Do execution, Check acceptance gates, Act by recording lessons and updating contracts.

3. **Repository level**
   Discover repo role and current state, Define repo-specific boundaries, Plan file-level work, Do targeted changes, Check repo-native validation, Act by updating governance and evidence.

4. **Work packet level**
   Discover impacted files and interfaces, Define exact deliverable, Plan the smallest safe change, Do the edit, Check behavioral outcome, Act by closing the packet or escalating.

5. **Operation level**
   Discover preconditions, Define expected result, Plan one command or one write, Do it, Check direct output, Act immediately on pass or fail.

### 3.2 Why This Matters

This prevents two common failure modes:

- solving the wrong problem efficiently
- passing a parent CHECK while a child D3PDCA loop is incomplete

---

## 4. Memory Stack Applied Operationally

### 4.1 Tier Model

The memory stack supports D3PDCA by preserving the right context at the right durability level.

#### Tier 1: Critical, Never Compress

- workspace authority
- project authority
- current phase workflow
- active acceptance criteria

#### Tier 2: High, Refresh at Boundaries

- active mission state
- current workstream status
- validation results
- blockers and approvals

#### Tier 3: Medium, Compressible

- recent implementation history
- prior phase summaries
- supporting rationale already captured in docs or evidence

#### Tier 4: Low, Discard First

- exploratory chatter
- dead ends
- transient debugging noise

### 4.2 Purpose

The memory stack exists to ensure that:

- policy survives context pressure
- execution state survives long sessions
- recovery is possible without re-learning the workspace
- agents do not lose the distinction between authoritative and exploratory context

---

## 5. The Seven Operating Layers

### Layer 1: Authority Layer

This layer answers: *What is binding?*

It should contain exactly three authority classes:

- **Workspace authority**: root workspace instructions and supporting reusable instruction files
- **Project authority**: repo-level copilot instructions for local role and boundaries
- **Governance authority**: PLAN, STATUS, ACCEPTANCE, PROJECT-ORGANIZATION templates and policies

Rules:

- one source of truth per concern
- no duplicate universal prose across workspace and project templates
- historical files cannot outrank active authority files

### Layer 2: Bootstrap Layer

This layer answers: *How does an agent start safely?*

It must provide:

- bootstrap sequence
- endpoint contract
- fail-closed rules
- minimum health checks
- read order
- local versus cloud execution guidance

Rules:

- local and cloud agents use the same logical startup contract
- environment-specific details are injected, not improvised
- bootstrap failure blocks governance work

### Layer 3: Mission Contract Layer

This layer answers: *What exactly is the agent being asked to do?*

Each mission or task packet should define:

- objective
- scope
- non-goals
- target files or surfaces
- required validations
- evidence required
- escalation rules

Rules:

- no ambiguous mission starts
- no broad execution without an explicit success contract
- Discover must produce a grounded problem frame before Define or Plan

### Layer 4: Execution Layer

This layer answers: *How do agents execute without re-inventing process?*

It must provide:

- task-specific scripts
- runbooks
- reusable skills
- standard commands
- safe edit patterns
- deterministic naming and output rules

Rules:

- scripts should encode recurring procedure, not force agents to remember it
- skills should point to current script paths and current contracts
- templates should generate usable defaults, not placeholders that require rediscovery

### Layer 5: Validation Layer

This layer answers: *How do we know the work is actually complete?*

It must provide:

- template conformance tests
- instruction consistency checks
- repo-native validation hooks
- drift detection
- post-prime verification

Rules:

- CHECK must validate the actual promised deliverable, not just intermediate scaffolding
- validation must block propagation when shared artifacts drift
- parent loops cannot pass if child loops are incomplete

### Layer 6: Evidence Layer

This layer answers: *What is the audit trail?*

It must provide:

- deterministic evidence files
- logs
- validation outputs
- write-back evidence where applicable
- session checkpoints

Rules:

- evidence is produced at operation boundaries, not only at session close
- evidence names are deterministic and sortable
- high-risk automation work must emit machine-readable proof

### Layer 7: Recovery Layer

This layer answers: *How do we resume safely?*

It must provide:

- session checkpointing
- known-good templates
- rollback boundaries
- restart procedure
- drift and fallout repair modes

Rules:

- recovery must be cheaper than rediscovery
- failed propagation must support targeted repair, not broad overwrite
- local and cloud agents should resume from the same evidence and authority model

---

## 6. Local and Cloud Agent Roles

### 6.1 Local Agents Should Excel At

- repo inspection
- precise code edits
- deterministic validation
- file-system aware repair
- running bounded commands and tests

### 6.2 Cloud Agents Should Excel At

- broad discovery across large surface areas
- synthesis across many repos or data sources
- mission-scale analysis
- backlog generation
- portfolio-level consistency assessment

### 6.3 Shared Requirement

Both must consume the same operating contracts:

- same authority hierarchy
- same mission packet format
- same validation gates
- same evidence model
- same recovery model

This prevents split-brain behavior between local and cloud execution.

---

## 7. What Must Stop

The operating system should explicitly eliminate these anti-patterns:

- agents discovering current endpoints from stale project instructions
- templates embedding stale operational facts
- skills referencing obsolete script paths
- broad priming runs without drift checks
- validation that checks scaffolding but not delivered behavior
- recovery that depends on reading many old docs again
- multiple files trying to be universal authority at once

---

## 8. Production-Grade Control Objectives

For enterprise and government use, the operating system should optimize for:

- determinism
- auditability
- least privilege
- repeatability
- bounded failure
- recovery speed
- policy coherence under scale
- low operator surprise

Translated into concrete standards:

- fail-closed for governance-critical operations
- explicit authority hierarchy
- deterministic filenames and evidence
- reproducible bootstrap
- no silent fallback to stale local assumptions
- contract tests for templates and instructions
- repair-only mode for generated artifact fallout

---

## 9. Immediate Project 07 Remediation Backlog

### D1. Discover and Baseline

- inventory all Project 07 templates, scripts, and skills that participate in priming
- classify each artifact as authority, generator, validator, or historical
- identify stale operational facts, stale paths, and duplicated governance prose

### D2. Define the Contract Model

- define workspace authority contract
- define project authority contract
- define governance template contract
- define mission packet contract for local and cloud agents

### P1. Rebuild Templates

- make the workspace template the render source for workspace instructions
- rebuild the project template from thin project-authority exemplars
- simplify governance templates so they contain structure and durable rules, not stale workspace narrative

### P2. Rebuild Script Behavior

- make `Invoke-PrimeWorkspace.ps1` the primary priming engine
- retire or quarantine legacy `Apply-Project07-Artifacts.ps1` behavior unless refactored to current contracts
- replace stale consistency checks with live-contract conformance checks
- ensure repair mode targets managed artifacts only

### P3. Rebuild Skills and Runbooks

- update `foundation-expert.skill.md` to current paths and current responsibilities
- ensure skills describe current scripts, not archived layouts
- add explicit local/cloud mission packet guidance

### C1. Conformance and Drift Detection

- add tests that compare templates, rendered artifacts, and live authority rules
- fail if templates embed stale endpoint, stale layer count, or unresolved placeholders
- fail if skills point to obsolete script paths

### A1. Act and Institutionalize

- publish the operating model as Project 07 policy
- use it to refactor priming safely
- use the new contracts to repair damaged project instructions incrementally

---

## 10. Definition of Done for the Operating System

The operating system is ready when:

- workspace authority is validated and renderable from one template source
- project authority template is thin, correct, and reusable
- governance templates are homogenized and free of stale workspace detail
- priming scripts enforce current contracts instead of legacy assumptions
- skills point to current scripts and current runbooks
- conformance tests catch drift before propagation
- local and cloud agents can start from a shared mission packet and shared evidence model

---

## 11. Guiding Rule

The goal is not to make agents smarter by forcing them to remember more.

The goal is to make the system smarter so agents can spend their intelligence on delivery, not on re-deriving the operating environment.

That is the difference between an agent toolkit and an agent operating system.
