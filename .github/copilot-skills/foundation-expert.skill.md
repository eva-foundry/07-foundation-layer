# Skill: foundation-expert

**EVA-STORY**: F07-001

**Version**: v2.0.0 | March 15, 2026
**Project**: 07-foundation-layer
**Triggers**: foundation expert, prime workspace, prime project, scaffold project, reseed projects,
  bootstrap project, template rollout, workspace governance, memory priming, project standards

---

## PURPOSE

This skill exposes the EVA Foundation Layer operating toolkit from anywhere in the workspace.

Use it when you need to:

1. scaffold a new project structure
2. prime or re-prime governance files
3. update project instruction contracts safely
4. standardize local memory wake-up checkpoints
5. propagate validated patterns across projects
6. hand off deeper residue cleanup to the dedicated housekeeping skill when the task shifts from priming to archive-first cleanup

---

## CURRENT MODEL

Foundation now separates **workspace authority** from **project authority**.

- Workspace policy lives in `C:\eva-foundry\.github\copilot-instructions.md`
- Project policy lives in each project's `.github\copilot-instructions.md`
- Project templates are not copies of workspace instructions
- Reseed operations preserve the `Project-Owned Context` block in project instruction files
- Governance truth lives in the Project 37 Data Model API

Local files support continuity and delivery, but they do not replace API-backed governance state.

---

## CAPABILITIES

### 1. Prime A Single Project

```powershell
pwsh -ExecutionPolicy Bypass -File \
  "C:\eva-foundry\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1" \
  -TargetPath "C:\eva-foundry\<project-folder>"
```

What it does:

- applies or refreshes project governance templates
- writes or updates local governance files
- writes `.eva/prime-evidence.json`
- keeps the operation idempotent where possible

### 2. Prime The Workspace

```powershell
pwsh -ExecutionPolicy Bypass -File \
  "C:\eva-foundry\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1" \
  -WorkspaceRoot "C:\eva-foundry"
```

Use `-DryRun` first for bulk operations.

### 3. Scaffold A New Project

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\utilities\Initialize-ProjectStructure.ps1" \
  -ProjectRoot "C:\eva-foundry\<new-project>" \
  -TemplateFile "C:\eva-foundry\07-foundation-layer\templates\supported-folder-structure-rag.json"

pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1" \
  -TargetPath "C:\eva-foundry\<new-project>"
```

### 4. Refresh Project Instructions Only

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\deployment\Apply-Project07-Artifacts.ps1" \
  -TargetPath "C:\eva-foundry\<project-folder>"
```

Use this when you only need to refresh instruction or governance artifacts.

### 5. Reseed Projects In Batch

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\deployment\Reseed-Projects.ps1" -Scope active
```

Behavior:

- refreshes the managed foundation contract
- preserves `Project-Owned Context`
- converts legacy PART-based files forward when encountered

### 6. Initialize Workspace Memory Checkpoints

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\Initialize-WorkspaceMemorySystem.ps1" \
  -WorkspaceRoot "C:\eva-foundry" \
  -PhaseToActive 1
```

This creates local wake-up checkpoints under `.memories/session/` without creating local sprint truth.

### 7. Workspace Housekeeping And Analysis

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\utilities\Invoke-WorkspaceHousekeeping.ps1" \
  -WorkspaceRoot "C:\eva-foundry"

pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\utilities\Capture-ProjectStructure.ps1" \
  -ProjectRoot "C:\eva-foundry\<project-folder>" \
  -OutputFile ".\captured-structure.json"
```

For deeper cleanup passes, prefer the dedicated workspace skill `@eva-housekeeping`. Use `foundation-expert` to understand active surfaces and priming behavior, then use `@eva-housekeeping` to execute one-folder-at-a-time archive decisions.

### 8. Test Foundation Deployment

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\testing\Test-Project07-Deployment.ps1"
```

---

## VALIDATION

After a foundation operation, verify evidence and outputs explicitly:

```powershell
Test-Path "C:\eva-foundry\<project>\.eva\prime-evidence.json"
Get-Content "C:\eva-foundry\<project>\.eva\prime-evidence.json" | ConvertFrom-Json
```

For memory priming, verify `.memories/session/` and the managed kickoff checkpoint exist.

---

## DRY RUN

Use `-DryRun` for bulk or high-impact operations before writing files.

Typical commands:

```powershell
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1" -WorkspaceRoot "C:\eva-foundry" -DryRun
pwsh -File "C:\eva-foundry\07-foundation-layer\scripts\deployment\Reseed-Projects.ps1" -Scope active -DryRun
```

---

## ANTI-PATTERNS

- Do not treat project instructions as copies of workspace instructions.
- Do not manually reintroduce legacy multi-section template assumptions into current project templates.
- Do not overwrite project-owned context blindly during reseed.
- Do not generate local sprint truth when running memory priming.
- Do not skip API bootstrap or dry-run checks for bulk rollout work.

---

## QUICK REFERENCE

```powershell
$foundation = "C:\eva-foundry\07-foundation-layer"
$templates = "$foundation\templates"
$deployment = "$foundation\scripts\deployment"
$utilities = "$foundation\scripts\utilities"
$testing = "$foundation\scripts\testing"
```

---

## WHEN TO INVOKE THIS SKILL

Invoke `foundation-expert` when the user needs project priming, template rollout, workspace cleanup, local memory checkpoint setup, or safe propagation of Project 07 standards across the workspace.

If the user explicitly wants deeper housekeeping, archive-first cleanup, or one-folder semantic cleanup, invoke `@eva-housekeeping` and pair it with `bob-semantic-filter` for dense file-content reduction.

Typical triggers:

- User asks about EVA Factory or DPDCA pattern

**Related skills**:

- `veritas-expert` (48-eva-veritas) -- Requirements traceability
- `sprint-advance` (51-ACA) -- Sprint progression workflow
- `data-model-query` (37-data-model) -- Data model operations

---

**Foundation Layer**: The first touch on every EVA project.

*Template version*: v7.0.0  
*Last updated*: 2026-03-15 11:20 UTC  
*Owner*: Marco Presta / EVA AI COE
