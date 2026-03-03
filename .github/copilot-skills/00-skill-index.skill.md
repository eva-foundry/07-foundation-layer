---
skill: 00-skill-index
version: 1.0.0
project: 07-foundation-layer
last_updated: February 23, 2026
---

# Skill Index -- Foundation Layer

> This is the skills menu for 07-foundation-layer.
> Read this file first when the user asks: "what skills are available", "what can you do", or "list skills".
> Then read the matched skill file in full before starting any work.

## Project Context

**Goal**: Comprehensive pattern library and standards baseline providing GitHub Copilot instructions and dev standards across the entire EVA ecosystem.
**37-data-model record**: `GET /model/projects/07-foundation-layer`

---

## Available Skills

| # | File | Trigger phrases | Purpose |
|---|------|-----------------|---------|
| 0 | 00-skill-index.skill.md | list skills, what can you do, skill menu | This index |
| 1 | foundation-expert.skill.md | foundation expert, workspace pm, prime workspace, scaffold project, apply governance, eva factory | Complete workspace PM/Scrum Master capabilities: priming, scaffolding, templates, patterns |
| 2 | universal-command-wrapper.skill.md | run command, execute script | Safe command execution wrapper |

---

## Workspace-Level Skills (Available From Any Folder)

| Skill | Location | Purpose |
|-------|----------|---------|
| eva-factory-guide | C:\AICOE\.github\copilot-skills\eva-factory-guide.skill.md | Learn EVA architecture - DPDCA, data model, veritas, patterns |
| foundation-expert | 07-foundation-layer/.github/copilot-skills/foundation-expert.skill.md | Setup & governance - priming, scaffolding, templates (THIS SKILL also) |
| scrum-master | C:\AICOE\.github\copilot-skills\scrum-master.skill.md | Sprint management - advance, reporting, evidence tracking |
| workflow-forensics-expert | C:\AICOE\.github\copilot-skills\workflow-forensics-expert.skill.md | Quality auditor - evidence validation, metrics accuracy, dashboard audit |

---

## Skill Creation Guide

When the project reaches active status and recurring tasks emerge, create task-specific skill files:

`
.github/copilot-skills/
  00-skill-index.skill.md          -- this file (always present)
  01-[task-name].skill.md          -- first recurring task skill
  02-[task-name].skill.md          -- second recurring task skill
  ...
`

Each skill file follows this structure:
`yaml
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
`

---

*Template source*: `C:\AICOE\eva-foundation\07-foundation-layer`
*Skill framework*: `C:\AICOE\eva-foundation\02-poc-agent-skills`
