# Workspace Copilot Instructions Template -- Project 07 Guide

**File**: `copilot-instructions-workspace-template.md`  
**Location**: `C:\eva-foundry\07-foundation-layer\templates\`  
**Version**: 7.0.0 (authority split alignment)  
**For**: Project 07 workspace distribution and maintenance

---

## Overview

This template generates the workspace-level `C:\eva-foundry\.github\copilot-instructions.md` file.

It is a full workspace authority template, not a source for project-level instruction generation. Project templates are maintained separately and must contain only project-level contract material.

---

## Current Principles

1. Workspace template defines workspace-wide policy and bootstrap.
2. Project template defines project-level contract and preserved project-owned context.
3. Governance truth lives in the Data Model API.
4. Project 07 rollout tooling must not collapse workspace and project authority into one document model.

---

## Template Variables

Replace these before writing the workspace file:

| Variable | Example |
|----------|---------|
| `{WORKSPACE_PATH}` | `C:\eva-foundry` |
| `{WORKSPACE_OWNER}` | `Marco Presta` |
| `{TIMESTAMP}` | `2026-03-15 14:15 UTC` |
| `{SESSION_NUMBER}` | `71` |
| `{SESSION_DESCRIPTION}` | `authority split alignment` |
| `{PROJECT_COUNT}` | `61` |
| `{PROJECT_RANGE}` | `01-62` |

---

## Recommended Workflow

```powershell
$templatePath = "C:\eva-foundry\07-foundation-layer\templates\copilot-instructions-workspace-template.md"
$outputPath = "C:\eva-foundry\.github\copilot-instructions.md"

$template = Get-Content $templatePath -Raw
$expanded = $template `
    -replace '{WORKSPACE_PATH}', 'C:\eva-foundry' `
    -replace '{WORKSPACE_OWNER}', 'Marco Presta' `
    -replace '{TIMESTAMP}', (Get-Date -Format 'yyyy-MM-dd HH:mm UTC') `
    -replace '{SESSION_NUMBER}', '71' `
    -replace '{SESSION_DESCRIPTION}', 'authority split alignment' `
    -replace '{PROJECT_COUNT}', '61' `
    -replace '{PROJECT_RANGE}', '01-62'

Set-Content $outputPath -Value $expanded -Encoding utf8
```

Validate that no placeholder tokens remain before writing or committing.

---

## Where This Fits

```text
Project 07 template
  -> workspace authority file
  -> project authority template
  -> governance templates
  -> rollout scripts
```

Only the workspace authority file is generated from this document.

---

## Maintenance Triggers

Update this template when:
- bootstrap requirements change
- workspace-wide skills or tools change
- governance policy changes
- the memory model changes materially
- Project 37 API bootstrap or runbook assumptions change

Do not update it merely to reflect project-specific delivery details.

---

## Validation Checklist

- [ ] workspace placeholders expanded
- [ ] no project-only instructions leaked into workspace template
- [ ] bootstrap block still calls both `agent-guide` and `user-guide`
- [ ] references point to current Project 07 and Project 37 paths
- [ ] template still reflects API-first governance and D3PDCA

---

*Workspace template guide v7.0.0 | Project 07 automation support*
