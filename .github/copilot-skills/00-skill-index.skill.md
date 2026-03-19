---
skill: 00-skill-index
version: 2.0.0
project: 07-foundation-layer
last_updated: March 10, 2026 (Session 44)
---

# Skill Index -- Foundation Layer

> This is the skills menu for 07-foundation-layer.
> Read this file first when the user asks: "what skills are available", "what can you do", or "list skills".
> Then read the matched skill file in full before starting any work.

## Project Context

**Goal**: Workspace PM/Scrum Master providing governance toolchain, scaffolding, and pattern propagation across 57 EVA projects.  
**Role**: Central admin hub for cross-project operations (data model, veritas, ADO, control plane)  
**37-data-model record**: `GET /model/projects/07-foundation-layer`

---

## Available Skills (10 Total)

### Core Foundation Skills

| # | File | Trigger phrases | Purpose |
| --- | --- | --- | --- |
| 0 | 00-skill-index.skill.md | list skills, what can you do, skill menu | This index |
| 1 | foundation-expert.skill.md | foundation expert, workspace pm, prime workspace, scaffold project, apply governance, eva factory | Complete workspace PM capabilities: priming, scaffolding, templates, patterns |
| 2 | universal-command-wrapper.skill.md | run command, execute script, terminal output missing | Safe command execution wrapper for debugging |
| 9 | @eva-housekeeping (workspace skill) | housekeeping, cleanup, archive residue, folder-by-folder cleanup, semantic cleanup | Conservative one-folder-at-a-time cleanup with archive-first behavior and validation |

### Admin Skills (Operations for Other Projects)

| # | File | Project | Trigger phrases | Purpose |
| --- | --- | --- | --- | --- |
| 3 | data-model-admin.skill.md | 37 | data model admin, seed project, query model, api safety | Project 37 API operations, seeding, layer management |
| 4 | veritas-admin.skill.md | 48 | veritas admin, trust score, mti gate, evidence verification | Project 48 MTI scoring, gap analysis, acceptance gates |
| 5 | ado-integration.skill.md | 38 | ado integration, work item sync, azure devops | Project 38 ADO synchronization, work item management |
| 6 | ado-dashboard-admin.skill.md | 39 | ado dashboard, metrics dashboard | Project 39 dashboard operations |
| 7 | control-plane-runtime.skill.md | 40 | control plane, evidence instrumentation | Project 40 runtime instrumentation patterns |
| 8 | red-teaming-integration.skill.md | 36 | red teaming, security testing | Project 36 red team integration |

---

## Workspace-Level Skills (Available From Any Folder)

| Skill | Location | Purpose |
| --- | --- | --- |
| eva-factory-guide | C:\eva-foundry\.github\copilot-skills\eva-factory-guide.skill.md | Learn EVA architecture - DPDCA, data model, veritas, patterns |
| foundation-expert | 07-foundation-layer/.github/copilot-skills/foundation-expert.skill.md | Setup & governance - priming, scaffolding, templates (THIS SKILL also) |
| eva-housekeeping | C:\eva-foundry\.github\skills\eva-housekeeping\SKILL.md | Folder-level live-vs-archive cleanup with nested D3PDCA and validator-first discipline |
| scrum-master | C:\eva-foundry\.github\copilot-skills\scrum-master.skill.md | Sprint management - advance, reporting, evidence tracking |
| workflow-forensics-expert | C:\eva-foundry\.github\copilot-skills\workflow-forensics-expert.skill.md | Quality auditor - evidence validation, metrics accuracy, dashboard audit |

---

## Skill Creation Guide

When the project reaches active status and recurring tasks emerge, create task-specific skill files:

```text
.github/copilot-skills/
  00-skill-index.skill.md          -- this file (always present)
  01-[task-name].skill.md          -- first recurring task skill
  02-[task-name].skill.md          -- second recurring task skill
  ...
```

Each skill file follows this structure:

```yaml
---
skill: [skill-name]
version: 1.0.0
triggers:
- "[trigger phrase 1]"
- "[trigger phrase 2]"
---

# Skill: [Name]

## Context

## Steps

## Validation

## Anti-patterns
```

---

*Template source*: `C:\eva-foundry\07-foundation-layer`
*Skill framework*: Workspace skills at `C:\eva-foundry\.github\copilot-skills` and `C:\eva-foundry\.github\skills`
