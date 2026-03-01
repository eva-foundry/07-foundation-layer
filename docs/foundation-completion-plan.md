# Foundation Completion Plan

**Document Version**: 1.0.0  
**Created**: 2026-03-01 08:55 ET  
**Purpose**: Complete the EVA Factory Foundation and test deterministic behavior

---

## Mission

**Transform 07-Foundation-Layer from template seeder to fully operational Workspace PM/Scrum Master**, capable of scaffolding new projects with complete DPDCA automation, data-driven execution, and dashboard integration.

---

## Success Criteria

1. **Any new EVA project** can be scaffolded in < 10 minutes with:
   - README, PLAN, STATUS, ACCEPTANCE, CHANGELOG
   - Copilot instructions (PART 1/2/3)
   - 5 automation skills (sprint-advance, veritas-expert, gap-report, sprint-report, progress-report)
   - 3 core scripts (seed-from-plan.py, reflect-ids.py, gen-sprint-manifest.py)
   - DPDCA-WORKFLOW.md
   - GitHub Actions workflow (sprint-agent.yml)
   - WBS seeded in 37-data-model

2. **One-line sprint execution**: `gh issue create` → agent executes → PR opened → tests pass → merged

3. **Deterministic behavior validated**: No hallucinated IDs, routes, schemas (agent queries data model)

4. **Dashboard integration working**: Sprint data flows → metrics calculated → displayed in 39-ado-dashboard

5. **Template v3.5.0 reseeded** to 12 active projects

---

## Phase 1: Generalize 51-ACA Scripts (3 hours)

**Status**: [COMPLETE] @ 2026-03-01 16:55 ET

Generalized 51-ACA DPDCA foundation scripts to work for ANY EVA project.

### Completion Summary

**Deliverables**:
- [x] seed-from-plan.py (362 lines) -- Project-agnostic parser with PROJECT_ID auto-detection
- [x] reflect-ids.py (205 lines) -- Project-agnostic annotator with idempotence validation
- [x] gen-sprint-manifest.py (231 lines) -- Project-agnostic manifest generator
- [x] 99-test-project validation scaffold (12-story test vehicle with TEST prefix)
- [x] PHASE-1-COMPLETION.md validation report

### Key Achievements

**1. PROJECT_PREFIX Auto-Detection** (Removes all "ACA-" hardcoding)
```python
project_id = detect_project_id(args.project_id)  # Supports:
  1. Explicit: --project-id "TEST"
  2. Environment: PROJECT_ID="TEST"
  3. Folder: /99-test-project -> inferred
  4. PLAN.md: Scan EPIC headers for context
```

**2. Flexible PLAN.md Parsing** (No separator dependency)
- Line-by-line parsing handles any PLAN.md format
- Supports old-format (Story N.M.K) and new-format (Story PROJECT-NN-NNN)
- Epic headers matched anywhere in file (not just at section start)

**3. Full Idempotence Validation**
```
[PASS] reflect-ids.py: 12 stories annotated (first run)
[PASS] reflect-ids.py: 0 stories annotated (second run -> no duplicates)
```

**4. ASCII-Only Output** (Production-ready encoding)
- All generated files use ASCII-safe UTF-8
- No emoji, no Unicode >U+007F
- Safe for GitHub, data model APIs, CI/CD systems

### Validation Results (99-test-project)

| Test | Status | Evidence |
|---|---|---|
| reflect-ids.py annotation | PASS | 12 stories -> [TEST-NN-NNN] format |
| seed-from-plan.py parsing | PASS | 12 stories -> veritas-plan.json |
| gen-sprint-manifest.py generation | PASS | Valid JSON embedded in markdown |
| PROJECT_ID auto-detection | PASS | Explicit --project-id TEST works |
| Idempotence (re-run safety) | PASS | Second run: 0 changes |
| ASCII encoding validation | PASS | All output UTF-8 safe |

### Commits

- **07-foundation-layer**: 0e99cfe (3 generalized scripts + templates)
- **99-test-project**: Validation scaffold with 12 stories
- **Documentation**: PHASE-1-COMPLETION.md (full report)

### Timeline

- **Planned**: 3 hours
- **Actual**: 3.5 hours (includes debugging regex parsing and test validation)
- **Status**: [COMPLETE] with full validation evidence

### Next: Phase 2 - Elevate Skills

After Phase 1 validation, Phase 2 will:
1. Create workspace skills directory (.github/copilot-skills)
2. Generalize 5 core skills (sprint-advance, veritas-expert, gap-report, sprint-report, progress-report)
3. Add PROJECT_ID parameter block to each skill
4. Test on real project (31-eva-faces or 33-eva-brain-v2)

---

## Phase 2: Elevate 5 Skills to Workspace (2 hours)

### Task 2.1: Create Workspace Skills Directory

```powershell
New-Item -ItemType Directory -Path "C:\AICOE\.github\copilot-skills" -Force
```

### Task 2.2: Generalize sprint-advance.skill.md

**Changes**:
- Replace `51-ACA` hardcoding → `{PROJECT_ID}` variable
- Replace `ACA-NN-NNN` pattern → `{PROJECT_PREFIX}-NN-NNN` pattern
- Replace hardcoded repo paths → use `$PWD` or `$repo` parameter
- Replace localhost:8055 references → ACA data model URL (workspace standard)
- Add parameter block at top:
  ```yaml
  parameters:
    project_id: string  # e.g., "51-ACA", "33-eva-brain-v2"
    project_prefix: string  # e.g., "ACA", "EVA"
    repo_path: string  # e.g., "C:\AICOE\eva-foundry\51-ACA"
    data_model_url: string  # ACA URL or local
  ```

**Deliverable**: `C:\AICOE\.github\copilot-skills\sprint-advance.skill.md`

### Task 2.3: Generalize veritas-expert.skill.md

**Changes**: Same pattern as 2.2

**Deliverable**: `C:\AICOE\.github\copilot-skills\veritas-expert.skill.md`

### Task 2.4: Generalize gap-report.skill.md

**Deliverable**: `C:\AICOE\.github\copilot-skills\gap-report.skill.md`

### Task 2.5: Generalize sprint-report.skill.md

**Deliverable**: `C:\AICOE\.github\copilot-skills\sprint-report.skill.md`

### Task 2.6: Generalize progress-report.skill.md

**Deliverable**: `C:\AICOE\.github\copilot-skills\progress-report.skill.md`

### Task 2.7: Create Skill Index

**Deliverable**: `C:\AICOE\.github\copilot-skills\00-skill-index.skill.md`

Content:
```markdown
# Workspace-Level Skills Index

Version: 1.0.0
Last Updated: 2026-03-01 ET

## Automation Skills (DPDCA Loop Support)

| Skill | Triggers | Purpose |
|---|---|---|
| sprint-advance | "sprint 2", "next sprint", "advance sprint" | 5-phase sprint closure + planning |
| veritas-expert | "veritas", "MTI", "trust score" | Audit, gaps, evidence receipts |
| gap-report | "gap report", "blockers", "missing evidence" | Critical path analysis |
| sprint-report | "sprint report", "velocity", "metrics" | Sprint summary, velocity chart |
| progress-report | "progress", "where are we", "epic status" | Project status, epic completion |

## Usage Pattern

1. Agent reads workspace copilot-instructions (bootstrap)
2. Agent reads project copilot-instructions (project-specific context)
3. User triggers skill via natural language phrase
4. Agent reads matching skill from workspace `.github/copilot-skills/`
5. Agent parameterizes skill (replaces {PROJECT_ID}, {PROJECT_PREFIX}, etc.)
6. Agent executes skill instructions
```

---

## Phase 3: Create Scaffolding Templates (2 hours)

### Task 3.1: DPDCA-WORKFLOW.md Template

**Source**: `C:\AICOE\eva-foundry\51-ACA\.github\DPDCA-WORKFLOW.md` (238 lines)

**Changes**:
- Generalize project references
- Add placeholder sections for project-specific customization
- Add version header (v1.0.0)

**Deliverable**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\DPDCA-WORKFLOW.md`

### Task 3.2: Sprint Manifest Template

**Deliverable**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\sprint-manifest-template.md`

Content:
```markdown
# Sprint {SPRINT_NUMBER}: {SPRINT_NAME}

Generated: {TIMESTAMP}
Project: {PROJECT_ID}
Prefix: {PROJECT_PREFIX}

## Sprint Stories

{STORY_LIST}

## SPRINT_MANIFEST

```json
{
  "sprint_id": "{PROJECT_ID}-sprint-{SPRINT_NUMBER}",
  "sprint_name": "{SPRINT_NAME}",
  "project_id": "{PROJECT_ID}",
  "stories": [
    {
      "id": "{PROJECT_PREFIX}-NN-NNN",
      "title": "Story title",
      "size": "M",
      "estimated_fp": 3
    }
  ],
  "total_fp": 8,
  "files_to_create": [],
  "acceptance": [],
  "implementation_notes": ""
}
```

## TODO: Fill these sections

- [ ] files_to_create: List paths the agent should write
- [ ] acceptance: Concrete testable criteria
- [ ] implementation_notes: Context for agent

```

### Task 3.3: GitHub Actions Workflow Template

**Deliverable**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\sprint-agent.yml`

Content:
```yaml
name: Sprint Agent Executor

on:
  issues:
    types: [labeled]

jobs:
  execute-sprint:
    if: contains(github.event.issue.labels.*.name, 'sprint-task')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Extract SPRINT_MANIFEST
        id: manifest
        run: |
          # Parse JSON block from issue body
          # Set outputs: sprint_id, story_ids, total_fp
      
      - name: Execute Sprint
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          DATA_MODEL_URL: https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io
        run: |
          python scripts/sprint_agent.py \
            --manifest "${{ steps.manifest.outputs.manifest_json }}" \
            --data-model-url "$DATA_MODEL_URL"
      
      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: "[SPRINT-${{ steps.manifest.outputs.sprint_number }}] ${{ steps.manifest.outputs.sprint_name }}"
          body: |
            Sprint execution complete.
            Stories: ${{ steps.manifest.outputs.story_ids }}
            Total FP: ${{ steps.manifest.outputs.total_fp }}
          branch: sprint/${{ steps.manifest.outputs.sprint_number }}-${{ steps.manifest.outputs.sprint_name }}
```

### Task 3.4: Docker Image for sprint-agent (NEW)

**Source**: 51-ACA Dockerfile + build-sprint-agent.yml workflow

**Goal**: Pre-built environment for GitHub Actions (30 sec startup vs 5 min pip install)

**Deliverables**:
1. `C:\AICOE\eva-foundry\51-ACA\Dockerfile` (for 51-ACA)
2. `C:\AICOE\eva-foundry\51-ACA\.github\workflows\build-sprint-agent.yml` (for 51-ACA)
3. Templates:
   - `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Dockerfile.template`
   - `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\build-sprint-agent.yml.template`

**Image Details**:
- Base: `python:3.12-slim` (~150MB)
- Dependencies: openai, pytest, ruff, httpx, github-cli
- Size: ~600MB (compressed)
- Registry: ghcr.io/eva-foundry/{PROJECT_SLUG}-sprint-agent
- Tags: latest, main-{commit-sha}, {branch-name}

**How to Use** (in sprint-agent.yml):

```yaml
jobs:
  execute-sprint:
    container:
      image: ghcr.io/eva-foundry/51-aca-sprint-agent:latest
    runs-on: ubuntu-latest
    steps:
      - name: Run sprint agent
        run: python3 .github/scripts/sprint_agent.py --issue "$ISSUE_NUM"
```

**Startup Comparison**:
| Step | Without Docker | With Docker |
|---|---|---|
| Setup runner | 30 sec | 30 sec |
| Install dependencies | 4 min 30 sec | (pre-built in image) |
| Run sprint agent | 1 min | 1 min |
| **Total** | **6 min** | **1.5 min** |

**Rollout**:
- 51-ACA: Commit Dockerfile + build workflow (immediate)
- Phase 3 complete: Template available for all 12 projects
- Phase 6 (Reseed): Deploy templates via Apply-Project07-Artifacts.ps1

### Task 3.5: scripts/ Directory Seed Template

**Deliverable**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\scripts-seed-structure.json`

Content:
```json
{
  "template_version": "1.0.0",
  "description": "Scripts directory structure for new EVA projects",
  "folders": [
    "scripts"
  ],
  "files": [
    {
      "path": "scripts/seed-from-plan.py",
      "source": "C:\\AICOE\\eva-foundry\\07-foundation-layer\\scripts\\seed-from-plan.py",
      "description": "Parse PLAN.md, assign canonical IDs, seed WBS layer"
    },
    {
      "path": "scripts/reflect-ids.py",
      "source": "C:\\AICOE\\eva-foundry\\07-foundation-layer\\scripts\\reflect-ids.py",
      "description": "Write [PROJECT-NN-NNN] inline into PLAN.md"
    },
    {
      "path": "scripts/gen-sprint-manifest.py",
      "source": "C:\\AICOE\\eva-foundry\\07-foundation-layer\\scripts\\gen-sprint-manifest.py",
      "description": "Generate sprint manifest from undone stories"
    }
  ]
}
```

---

## Phase 4: Test Deterministic Behavior (2 hours)

### Task 4.1: Create Test Project (99-test-project)

```powershell
# Create minimal test project
$testProj = "C:\AICOE\eva-foundry\99-test-project"
New-Item -ItemType Directory -Path $testProj -Force
cd $testProj
git init
```

### Task 4.2: Scaffold Test Project

```powershell
# Deploy 07 foundation artifacts
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\Apply-Project07-Artifacts.ps1" `
     -TargetPath $testProj

# Create minimal PLAN.md
@"
# Project Plan

## Feature: Test Epic [ID=F99-01]

### Story: Test Story 1 [ID=F99-01-001]
As a test user I want to validate DPDCA so that the loop is deterministic

### Story: Test Story 2 [ID=F99-01-002]
As the system I need data model integration so that agents don't hallucinate
"@ | Out-File "$testProj\PLAN.md" -Encoding UTF8
```

### Task 4.3: Seed WBS Layer

```powershell
python "C:\AICOE\eva-foundry\07-foundation-layer\scripts\seed-from-plan.py" --reseed-model --project-id "99-test-project"
# Expected: [PASS] 2 stories seeded

python "C:\AICOE\eva-foundry\07-foundation-layer\scripts\reflect-ids.py"
# Expected: [PASS] Annotated 2 story lines in PLAN.md
git diff PLAN.md
# Verify: [TEST-01-001] and [TEST-01-002] inserted correctly
```

### Task 4.4: Generate Sprint Manifest

```powershell
python "C:\AICOE\eva-foundry\07-foundation-layer\scripts\gen-sprint-manifest.py" --sprint 01 --name "foundation-test" --stories TEST-01-001,TEST-01-002 --sizes TEST-01-001=XS,TEST-01-002=XS
# Expected: [PASS] .github/sprints/sprint-01-foundation-test.md created
cat .github/sprints/sprint-01-foundation-test.md
# Verify: SPRINT_MANIFEST JSON block present, story IDs correct
```

### Task 4.5: Validate Deterministic Behavior

**Test 1: Agent queries data model (no hallucination)**

```powershell
# Agent should query: GET /model/projects/99-test-project
$base = "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io"
Invoke-RestMethod "$base/model/projects/99-test-project"
# Expected: project record returned (or 404 if not seeded yet)
```

**Test 2: Veritas audit recognizes IDs**

```powershell
node "C:\AICOE\eva-foundry\48-eva-veritas\src\cli.js" audit --repo $testProj --warn-only
# Expected: Recognizes TEST-01-001, TEST-01-002 from veritas-plan.json
# Expected: No orphan tags (all IDs match plan)
```

**Test 3: Sprint manifest parseable**

```powershell
$manifest = Get-Content "$testProj\.github\sprints\sprint-01-foundation-test.md" | ConvertFrom-Markdown
$json = ($manifest | Select-String -Pattern '```json(.*?)```' -AllMatches).Matches[0].Groups[1].Value | ConvertFrom-Json
$json.stories.Count
# Expected: 2
$json.stories[0].id
# Expected: "TEST-01-001"
```

---

## Phase 5: Document One-Line Governance (1 hour)

### Task 5.1: Add to Workspace Copilot Instructions

**Location**: `C:\AICOE\.github\copilot-instructions.md`

**Content** (add after DPDCA section):

```markdown
### One-Line Sprint Governance (GitHub Copilot Cloud Agent)

**Pattern**: Single command triggers complete sprint execution via GitHub Actions + GitHub Copilot cloud.

**Workflow**:

1. **Generate Sprint Manifest** (local):
   ```powershell
   python scripts/gen-sprint-manifest.py --sprint 02 --name "api-foundation" --stories PROJECT-NN-NNN,PROJECT-NN-NNN
   git add .github/sprints/sprint-02-api-foundation.md
   git commit -m "chore: sprint 02 manifest"
   git push origin main
   ```

2. **Create GitHub Issue** (triggers agent):
   ```powershell
   gh issue create \
     --repo eva-foundry/{PROJECT_FOLDER} \
     --title "[SPRINT-02] api-foundation" \
     --body-file .github/sprints/sprint-02-api-foundation.md \
     --label "sprint-task"
   ```

3. **GitHub Actions Fires** (sprint-agent.yml):
   - Parses SPRINT_MANIFEST JSON from issue body
   - Loads project context (copilot-instructions, PLAN.md, STATUS.md, data model)
   - For each story:
     - Queries data model for implementation context (endpoints, screens, containers)
     - Calls GitHub Copilot cloud agent (gpt-4o for M/L, gpt-4o-mini for XS/S)
     - Agent writes code with correct EVA-STORY tags
     - Commits: `feat(PROJECT-NN-NNN): description`
   - Opens PR

4. **Check Gate** (automated):
   - pytest must exit 0
   - Veritas MTI >= threshold (30 Sprint 2, 70 Sprint 3+)
   - EVA-STORY tag coverage (every modified file has matching ID)

5. **Merge** (human approval):
   - Reviewer approves PR
   - Merge to main
   - Status updated: stories marked done in WBS

**Models Available**:
- `gpt-4o` (M/L stories: 3+ FP)
- `gpt-4o-mini` (XS/S stories: 1-2 FP)
- Accessed via: `models.inference.ai.azure.com` (GitHub token auth)

**Why This Works**:
- Agent has full project context (data model + copilot-instructions)
- Agent queries data model for EXACT schemas/routes (zero hallucination)
- EVA-STORY tags ensure veritas audit awards coverage points
- Sprint manifest specifies EXACT story IDs (no invented IDs)
```

### Task 5.2: Add to Template

**Location**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md`

**Content** (add reference to workspace section):

```markdown
### 2.2. One-Line Sprint Governance

> **See workspace copilot-instructions** section "One-Line Sprint Governance" for the complete pattern.

Quick reference:
1. Generate manifest: `python scripts/gen-sprint-manifest.py --sprint NN --name "sprint-name" --stories PROJECT-NN-NNN,...`
2. Create issue: `gh issue create --label "sprint-task" --body-file .github/sprints/...`
3. GitHub Actions fires → agent writes code → opens PR
4. Review → merge → done
```

---

## Phase 6: Reseed Active Projects (1 hour)

### Task 6.1: Update Template Version

**File**: `C:\AICOE\eva-foundry\07-foundation-layer\02-design\artifact-templates\copilot-instructions-template.md`

**Change**: Header shows "Template Version: 3.5.0"

Already done in session 5.

### Task 6.2: Run Reseed Script

```powershell
pwsh -File "C:\AICOE\eva-foundry\07-foundation-layer\scripts\Reseed-Projects.ps1" -Scope active
# Expected: PASS=12 FAIL=0
```

### Task 6.3: Verify PART 2 Preserved

Check 2-3 projects manually:

```powershell
# Example: 33-eva-brain-v2
$p33 = "C:\AICOE\eva-foundry\33-eva-brain-v2\.github\copilot-instructions.md"
Select-String -Path $p33 -Pattern "## PART 2" -Context 5
# Verify: PART 2 section preserved, PART 1 updated to v3.5.0
```

---

## Phase 7: Dashboard Integration + Portfolio Board Setup (2 hours)

### Task 7.1: Create GitHub Projects Portfolio Board (NEW)

**Purpose**: Organization-level portfolio visibility cross-linked to all 12 active EVA projects

**URL**: https://github.com/orgs/eva-foundry/projects

**Setup Steps** (reference: docs/github-projects-setup.md):

1. **Create Board** (UI, 10 min):
   - Navigate to eva-foundry organization
   - Click "New project"
   - Name: "EVA Foundation Portfolio"
   - Template: "Table"
   - Visibility: Public

2. **Add Custom Fields** (UI, 15 min):
   - Status (Single Select: Not Started, In Progress, Review, Done, Blocked)
   - Project (Single Select: 12 projects)
   - Story ID (Text: PROJECT-NN-NNN format)
   - Sprint (Text: Sprint-NN format)
   - Size (Single Select: XS, S, M, L, Epic)
   - MTI Impact (Single Select: Critical, High, Medium, Low)
   - Test Count (Number)

3. **Link Issues** (Script + Automation, 15 min):
   - Add label `portfolio` to all open issues in 12 repos
   - Deploy automation workflow: add-to-portfolio.yml
   - Workflow: auto-adds issues with `portfolio` label to project

4. **Verify Board Works** (Testing, 10 min):
   - Check portfolio project displays issues from all 12 repos
   - Test: Create issue in 51-ACA with label `portfolio`
   - Verify: Within 60 sec, appears in portfolio project
   - Test custom field updates (manually set Story ID, MTI Impact)

**Expected Result**:
- Portfolio board shows real-time sprint status across all projects
- Kanban view: Not Started → In Progress → Review → Done
- Custom fields: Can filter by Sprint, Project, Size, MTI Impact
- Automation: New issues auto-appear in board (via workflow)

**Integration with Veritas**:
- Workflow: update-mti-impact.yml queries veritas audit, updates MTI field
- Portfolio board = single source of truth for sprint metrics (replaces/complements 39-ado-dashboard)

**Reference Documentation**:
- Full setup guide: `C:\AICOE\eva-foundry\07-foundation-layer\docs\github-projects-setup.md`
- GraphQL API queries (advanced automation)
- Maintenance schedule (weekly, monthly, quarterly tasks)

### Task 7.2: Seed Test Project in Data Model

```powershell
$base = "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io"

# Register project
$proj = @{
    id = "99-test-project"
    label = "Test Project"
    maturity = "poc"
    tech_stack = "Python / FastAPI"
    notes = "Foundation test project"
} | ConvertTo-Json
Invoke-RestMethod "$base/model/projects/" -Method POST -ContentType "application/json" -Body $proj

# Seed WBS (done via seed-from-plan.py in Phase 4)
# Seed sprint record
$sprint = @{
    id = "99-test-project-sprint-01"
    project_id = "99-test-project"
    label = "Sprint 01"
    status = "active"
    started_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
} | ConvertTo-Json
Invoke-RestMethod "$base/model/sprints/" -Method POST -ContentType "application/json" -Body $sprint
```

### Task 7.3: Query Dashboard API

```powershell
# Query brain-v2 /v1/scrum/dashboard
Invoke-RestMethod "http://localhost:8000/v1/scrum/dashboard?project=99-test-project&sprint=Sprint-01"
# Expected: Returns WBS stories for Sprint 01
```

### Task 7.4: Verify 39-ado-dashboard Display

Open EVA Home in browser:
- http://localhost:3000/ (if 31-eva-faces running)
- Verify: 99-test-project tile shows "Sprint 01" badge
- Verify: Badge status = "Active"

---

## Rollout Schedule

| Phase | Duration | Dependencies | Owner |
|---|---|---|---|
| 1. Generalize Scripts | 3 hours | None | 07-Foundation |
| 2. Elevate Skills | 2 hours | Phase 1 | 07-Foundation |
| 3. Create Templates + Docker | 3 hours | Phase 1, 2 | 07-Foundation |
| 4. Test Deterministic | 2 hours | Phase 1, 2, 3 | 07-Foundation |
| 5. Document Governance | 1 hour | Phase 1, 2, 3 | 07-Foundation |
| 6. Reseed Projects | 1 hour | Phase 3 | 07-Foundation |
| 7. Dashboard + Portfolio | 2 hours | Phase 4 | 07-Foundation + 33-Brain |

**Total**: 14 hours (~2 days)

**Target Completion**: 2026-03-04 EOD (Tuesday, extended 1 day for Docker + Portfolio)

---

## Success Validation

### Milestone 1: Scripts Generalized
- [ ] seed-from-plan.py works on 99-test-project
- [ ] reflect-ids.py annotates PLAN.md correctly
- [ ] gen-sprint-manifest.py generates parseable manifest
- [ ] All 3 scripts have --help documentation

### Milestone 2: Skills Elevated
- [ ] 5 skills deployed to `C:\AICOE\.github\copilot-skills\`
- [ ] Skill index created
- [ ] Project-specific references removed (parameterized)

### Milestone 3: Templates Created
- [ ] DPDCA-WORKFLOW.md template
- [ ] Sprint manifest template
- [ ] sprint-agent.yml workflow template
- [ ] scripts-seed-structure.json

### Milestone 4: Deterministic Validated
- [ ] 99-test-project scaffolded
- [ ] WBS seeded in data model
- [ ] IDs reflected in PLAN.md (no invented IDs)
- [ ] Veritas audit passes (no orphan tags)
- [ ] Sprint manifest parseable

### Milestone 5: Governance Documented
- [ ] Workspace copilot-instructions has "One-Line Governance" section
- [ ] Template references workspace section
- [ ] GitHub Actions workflow template documented

### Milestone 6: Projects Reseeded
- [ ] Reseed script run: PASS=12 FAIL=0
- [ ] PART 2 preserved in all 12 projects
- [ ] Template v3.5.0 deployed

### Milestone 7: Dashboard Integration
- [ ] 99-test-project appears in dashboard API
- [ ] EVA Home shows test project tile
- [ ] Sprint badge displays correctly

### Milestone 8: Docker Image Built (NEW)
- [ ] Dockerfile created for 51-ACA
- [ ] build-sprint-agent.yml workflow committed
- [ ] Image builds successfully: ghcr.io/eva-foundry/51-aca-sprint-agent:latest
- [ ] Docker image startup: 30 sec (vs 5 min without container)
- [ ] Templates available for all 12 projects

### Milestone 9: Portfolio Project Board Live (NEW)
- [ ] EVA Foundation Portfolio board created: https://github.com/orgs/eva-foundry/projects/X
- [ ] Custom fields configured (Story ID, Sprint, Size, MTI Impact, Test Count)
- [ ] Issues linked from all 12 active projects
- [ ] Automation workflow deployed (add-to-portfolio.yml)
- [ ] Portfolio board shows cross-project sprint metrics
- [ ] Integration with Veritas audit validates (MTI field auto-populated)

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Script generalization breaks 51-ACA | HIGH | Keep 51-ACA scripts as-is; new scripts in 07 separate |
| Skills elevation removes project context | MEDIUM | Parameterize instead of remove; test on 99-test-project |
| Reseed overwrites PART 2 customizations | HIGH | Reseed-Projects.ps1 already preserves PART 2 (tested v3.2.0) |
| Dashboard API not ready | LOW | 33-brain-v2 already has /v1/scrum/dashboard (active) |
| GitHub Actions workflow requires secrets | MEDIUM | Document required secrets in template README |
| Docker image build fails in public registry | MEDIUM | Test build with GitHub Actions cache before deploying to 12 projects |
| Portfolio board GraphQL mutations fail | MEDIUM | Add error handling in automation workflows; fallback to manual sync |

---

## Next Steps (Immediate)

1. **Commit Phase 3 updates** (Docker image tasks, timeline changes)
2. **Commit Phase 7 updates** (Portfolio board setup tasks)
3. **Start Phase 1 OR Phase 3.4** (Docker image is ready now, can start in any order)
4. **Create 99-test-project** folder structure for Phase 4 validation

**Ready to begin implementation?**
