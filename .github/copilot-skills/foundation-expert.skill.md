# Skill: foundation-expert
# EVA-STORY: F07-001

**Version**: v1.0.0 | March 3, 2026
**Project**: 07-foundation-layer
**Triggers**: foundation expert, workspace pm, prime workspace, prime project, scaffold project,
  apply governance, reseed projects, bootstrap project, foundation layer, workspace governance,
  eva factory, project standards, copilot instructions update, template deployment

---

## PURPOSE

This skill makes the **EVA Foundation Layer** (Workspace PM/Scrum Master) available from any 
project folder in the workspace. It provides instant access to:

1. **Project Scaffolding** -- Create new projects with full EVA governance
2. **Workspace Priming** -- Apply governance templates to existing projects
3. **Template Deployment** -- Update copilot-instructions and standards
4. **Pattern Propagation** -- Distribute proven patterns across projects
5. **Evidence Collection** -- Track priming and bootstrap status

---

## CAPABILITIES

### 1. Prime a Single Project

Apply EVA governance templates (PLAN, STATUS, ACCEPTANCE, copilot-instructions) to one project:

```powershell
pwsh -ExecutionPolicy Bypass -File `
  "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Invoke-PrimeWorkspace.ps1" `
  -TargetPath "C:\AICOE\eva-foundry\<project-folder>"
```

**What it does**:
- ✅ Applies copilot-instructions.md (3-part template, preserves PART 2)
- ✅ Creates/updates PLAN.md with eva-primed-plan sentinel
- ✅ Creates/updates STATUS.md with session tracking
- ✅ Creates ACCEPTANCE.md (never overwrites existing)
- ✅ Injects eva-primed header into README.md
- ✅ Writes `.eva/prime-evidence.json` with timestamp

**Idempotent**: Safe to run multiple times. Only updates what's needed.

---

### 2. Prime Entire Workspace

Apply governance templates to ALL numbered projects (##-* pattern):

```powershell
pwsh -ExecutionPolicy Bypass -File `
  "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Invoke-PrimeWorkspace.ps1" `
  -WorkspaceRoot "C:\AICOE\eva-foundry"
```

**Expected**: 59 projects processed in ~5 minutes
**Evidence**: `.eva/prime-evidence.json` in each project folder

---

### 3. Scaffold New Project

Create a brand new project with complete folder structure:

```powershell
# Step 1: Create folder structure
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Initialize-ProjectStructure.ps1" `
  -ProjectRoot "C:\AICOE\eva-foundry\<new-project>" `
  -TemplateFile "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\supported-folder-structure-rag.json"

# Step 2: Prime the new project
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Invoke-PrimeWorkspace.ps1" `
  -TargetPath "C:\AICOE\eva-foundry\<new-project>"
```

**Templates available**:
- `supported-folder-structure-rag.json` -- RAG/AI application structure
- `supported-folder-structure-webapp.json` -- Web application structure
- `supported-folder-structure-api.json` -- API service structure

---

### 4. Deploy Copilot Instructions Only

Update just the copilot-instructions.md file (faster, targeted):

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
  -TargetPath "C:\AICOE\eva-foundry\<project-folder>"
```

**Safe mode**: Backs up existing PART 2, always preserves project-specific customizations

---

### 5. Reseed Active Projects

Update copilot-instructions across all active projects (batch operation):

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\scripts\Reseed-Projects.ps1" -Scope active
```

**Scope options**:
- `active` -- 12 active projects only (default)
- `all` -- All numbered projects
- `foundation` -- Only foundation-owned projects (36-40, 48)

**Expected outcome**: PASS=12 FAIL=0 for active scope

---

### 6. Workspace Housekeeping

Run compliance checks and auto-organize workspace:

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Invoke-WorkspaceHousekeeping.ps1" `
  -WorkspaceRoot "C:\AICOE\eva-foundry"
```

**Checks**:
- ✅ Missing governance files (PLAN, STATUS, ACCEPTANCE)
- ✅ Orphaned evidence files
- ✅ Outdated copilot-instructions versions
- ✅ Projects missing .eva folder
- ✅ Inconsistent naming patterns

---

### 7. Capture Project Structure

Generate a JSON snapshot of current project structure:

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Capture-ProjectStructure.ps1" `
  -ProjectRoot "C:\AICOE\eva-foundry\<project-folder>" `
  -OutputFile ".\captured-structure.json"
```

**Use case**: Create new templates from successful project patterns

---

### 8. Test Foundation Deployment

Run Pester test suite to verify foundation layer health:

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Test-Project07-Deployment.ps1"
```

**Coverage**: 60+ test cases validating templates, scripts, and deployment patterns

---

## GOVERNANCE PATTERNS

### The EVA Factory Architecture

**Process**: DPDCA (Discover, Plan, Do, Check, Act)
**Data**: 37-data-model -- single source of truth (27+ layers)
**Actors**: Agent Skills + GitHub Copilot
**Result**: Predictable, traceable, auditable software delivery

### Foundation-Owned Governance Projects

| Project | Purpose | Status |
|---------|---------|--------|
| 36-red-teaming | Promptfoo adversarial testing harness | Active |
| 37-data-model | Single source of truth API (Cosmos-backed) | Active |
| 38-ado-poc | ADO Command Center (scrum orchestration) | Active |
| 39-ado-dashboard | EVA Home + sprint visualization | Active |
| 40-eva-control-plane | Runtime evidence spine | Partial |
| 48-eva-veritas | Requirements traceability + MTI gating | Active |

---

## TOKEN SUBSTITUTION

Templates support these tokens (auto-replaced during priming):

| Token | Example | Source |
|-------|---------|--------|
| `{{PROJECT_FOLDER}}` | `01-documentation-generator` | Folder name |
| `{{PROJECT_LABEL}}` | `Documentation Generator` | Data model API |
| `{{PROJECT_MATURITY}}` | `active` | Data model API |
| `{{WBS_PREFIX}}` | `F01` | Derived from folder number |
| `{{PRIME_DATE}}` | `2026-03-03` | Current date |
| `{{PRIME_ACTOR}}` | `agent:copilot` | Execution context |
| `{{TARGET_PATH}}` | `C:\AICOE\eva-foundry\...` | Absolute path |

---

## VALIDATION

After any foundation operation, verify success:

```powershell
# Check evidence file exists
Test-Path "C:\AICOE\eva-foundry\<project>\.eva\prime-evidence.json"

# Read evidence
Get-Content "C:\AICOE\eva-foundry\<project>\.eva\prime-evidence.json" | ConvertFrom-Json

# Count primed projects
(Get-ChildItem -Path "C:\AICOE\eva-foundry" -Filter "prime-evidence.json" -Recurse | 
  Where-Object { $_.Directory.Name -eq ".eva" }).Count
```

**Expected evidence structure**:
```json
{
  "primed_at": "2026-03-03T13:04:36-05:00",
  "primed_by": "agent:copilot",
  "template_version": "v3.1.0",
  "dry_run": false,
  "results": {
    "folder": "project-name",
    "steps": [
      "copilot-instructions:PASS",
      "PLAN.md:CREATED",
      "STATUS.md:CREATED",
      "ACCEPTANCE.md:CREATED",
      "README.md:CHECKED"
    ]
  }
}
```

---

## DRY-RUN MODE

Add `-DryRun` to any command to preview without writing files:

```powershell
# Preview workspace priming
pwsh -File "...\Invoke-PrimeWorkspace.ps1" -WorkspaceRoot "C:\AICOE\eva-foundry" -DryRun

# Preview single project
pwsh -File "...\Apply-Project07-Artifacts.ps1" -TargetPath "...\project" -DryRun
```

**Output tokens**: `[DRY]` `[PASS]` `[FAIL]` `[WARN]` `[INFO]` `[SKIP]`

---

## ANTI-PATTERNS

❌ **DON'T**: Manually edit copilot-instructions.md PART 1 or PART 3
✅ **DO**: Edit PART 2 only, reseed to get latest PART 1/3

❌ **DON'T**: Delete `.eva/prime-evidence.json` (breaks audit trail)
✅ **DO**: Re-prime if you need to update evidence timestamp

❌ **DON'T**: Skip dry-run on workspace-wide operations
✅ **DO**: Always preview with `-DryRun` first on bulk operations

❌ **DON'T**: Reseed without checking git status first
✅ **DO**: Commit project work before reseeding templates

❌ **DON'T**: Create projects without using scaffold scripts
✅ **DO**: Use `Initialize-ProjectStructure.ps1` for consistency

---

## QUICK REFERENCE

```powershell
# Foundation layer scripts location
$foundation = "C:\AICOE\eva-foundry\07-foundation-layer"

# Templates directory
$templates = "$foundation\02-design\artifact-templates"

# Scripts directory
$scripts = "$foundation\scripts"

# MCP server
$mcp = "$foundation\mcp-server\foundation-primer"
```

---

## DATA MODEL INTEGRATION

Foundation layer reads project metadata from `37-data-model`:

```powershell
# Example: Get project info
$base = "http://localhost:8010"
$info = Invoke-RestMethod "$base/model/projects/07-foundation-layer"

# Returns:
# {
#   id: "07-foundation-layer",
#   label: "Foundation Layer",
#   maturity: "active",
#   wbs_id: "WBS-007",
#   phase: "production"
# }
```

**Used for**: Token substitution in templates, WBS prefix generation, maturity gating

---

## WHEN TO INVOKE THIS SKILL

**Invoke "foundation-expert" when**:
- User asks to prime workspace or project
- User wants to bootstrap/scaffold new project
- User asks about governance standards
- User mentions copilot-instructions updates
- User asks "what templates are available"
- User wants to update multiple projects at once
- User asks about EVA Factory or DPDCA pattern

**Related skills**:
- `veritas-expert` (48-eva-veritas) -- Requirements traceability
- `sprint-advance` (51-ACA) -- Sprint progression workflow
- `data-model-query` (37-data-model) -- Data model operations

---

**Foundation Layer**: The first touch on every EVA project. 🏭

*Template version*: v3.1.0  
*Last updated*: 2026-03-03 13:58 ET  
*Owner*: Marco Presta / EVA AI COE
