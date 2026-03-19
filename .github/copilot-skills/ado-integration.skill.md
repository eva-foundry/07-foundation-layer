# ADO Integration Skill

**Skill Name**: `@ado-integration`  
**Domain**: Azure DevOps Orchestration & Work Item Management  
**Audience**: Project leads, scrum masters, DevOps engineers, workspace administrators  
**Last Updated**: Session 38 (March 7, 2026)  

---

## Overview

This skill provides operational guidance for managing Azure DevOps integration across the EVA workspace. It covers project registration, work item synchronization, DPDCA phase advancement, cost attribution, and troubleshooting.

### When to Use This Skill

**DO use when**:
- Registering a new project in Azure DevOps
- Syncing PLAN.md stories to ADO work items
- Advancing DPDCA phases (D→P→C→A) via ADO WI state transitions
- Updating WI status with evidence (test results, coverage artifacts)
- Troubleshooting ADO sync failures or stale work items
- Querying ADO for active work items across projects
- Setting up cost attribution headers (x-eva-project-id, x-eva-sprint)
- Configuring ADO dashboards for portfolio visibility

**DO NOT use when**:
- Deploying ADO infrastructure (organization/project creation) -- use DevOps runbooks
- Configuring ADO security/permissions -- use Identity team
- Querying Azure subscriptions/resources -- use Azure skills
- Implementing custom ADO extensions -- use ADO extension development docs

---

## 1. Project Registration in ADO

Every new EVA workspace project must be registered in Azure DevOps to enable work item tracking and sprint orchestration.

### Registration Prerequisites

Before registering a project in ADO:
- [ ] Project folder created in eva-foundry (e.g., `51-anotherproject`)
- [ ] PLAN.md exists with at least one EPIC and FEATURE defined
- [ ] `.eva/` directory initialized
- [ ] `ado-artifacts.json` schema file prepared
- [ ] Project 07 approval (workspace governance)

### Automated Registration: ado-onboard-all.ps1

The primary registration method uses the orchestrator script:

```powershell
# Discover all projects and register/sync them
pwsh -File "38-ado-poc/scripts/ado-onboard-all.ps1"

# Output:
# [INFO] Found 57 projects in eva-foundry
# [INFO] Importing project 01-documentation-generator...
# [PASS] Epic 1 created (ID=1)
# [PASS] Feature 1.1 created (ID=2)
# [PASS] PBI 1.1.1 created (ID=3)
# ...
# [SUMMARY] 57 projects registered, 0 errors
```

**What It Does**:
1. Scans eva-foundry for numbered project folders (01-*, 02-*, etc.)
2. Reads each project's `ado-artifacts.json`
3. Calls `ado-import-project.ps1` for each project
4. Creates Epic → Feature → PBI hierarchy in ADO
5. Assigns to current sprint
6. Logs all operations with timestamps

### Manual Registration: ado-import-project.ps1

For a single project:

```powershell
# Import one project (reads from ado-artifacts.json)
pwsh -File "38-ado-poc/scripts/ado-import-project.ps1" `
     -ProjectId "36" `
     -ProjectName "Red-Teaming" `
     -ArtifactsPath "c:\eva-foundry\36-red-teaming\ado-artifacts.json"

# Output:
# [INFO] Reading ado-artifacts.json...
# [PASS] Epic created: 36 - Red-Teaming & Adversarial Testing (EID=29)
# [PASS] Feature 36-01 created (FID=145)
# [PASS] PBI 36-01-001 created (PBID=1024)
# ...
# [SUMMARY] 1 epic, 5 features, 15 PBIs | Import complete (0 errors)
```

### ado-artifacts.json Schema

Every project must have an `ado-artifacts.json` file in its root:

```json
{
  "version": "1.0",
  "project": {
    "id": "36",
    "name": "Red-Teaming",
    "description": "Promptfoo adversarial testing harness",
    "area_path": "eva-foundry\\red-teaming",
    "iteration_path": "eva-poc\\Sprint 2026-Q1"
  },
  "epic": {
    "id": 36,
    "title": "Red-Teaming & Adversarial Testing",
    "description": "MITRE ATLAS + OWASP LLM Top 10 coverage",
    "tags": ["red-teaming", "security", "testing"]
  },
  "features": [
    {
      "id": "36-01",
      "title": "OWASP LLM Top 10 Coverage",
      "description": "Test against all 10 OWASP LLM vulnerabilities",
      "stories": [
        {
          "id": "36-01-001",
          "title": "Test A01 - Prompt Injection",
          "acceptance": [
            "As a red teamer, I can inject adversarial prompts",
            "Then the system detects and blocks injection attempts",
            "Given the AttackFactory provider is configured"
          ]
        }
      ]
    }
  ]
}
```

### Generated vs. Manual Fields

| Field | Auto-Generated | Manual | Required |
|---|---|---|---|
| `project.id` | ❌ | ✅ (from folder number) | Yes |
| `project.name` | ❌ | ✅ (from PLAN.md) | Yes |
| `project.description` | ❌ | ✅ (from README.md) | Yes |
| `epic.title` | ❌ | ✅ (from PLAN.md EPIC header) | Yes |
| `epic.description` | ❌ | ✅ (from PLAN.md epic intro) | No |
| `features[].id` | ✅ | ❌ | Yes (auto-computed) |
| `features[].title` | ❌ | ✅ (from PLAN.md Feature) | Yes |
| `stories[].id` | ✅ | ❌ | Yes (auto-computed) |
| `stories[].title` | ❌ | ✅ (from PLAN.md Story) | Yes |

**Tip**: Use `ado-generate-artifacts.ps1` to auto-generate ado-artifacts.json from PLAN.md and README.md

---

## 2. Work Item Synchronization

Work items in ADO stay synchronized with PLAN.md and evidence records.

### Sync Cycle

```
T0: PLAN.md updated
    ↓
T1: seed-from-plan.py --reseed-model
    (generates .eva/veritas-plan.json + posted to Project 37 API endpoint)
    ↓
T2: ado-import-project.ps1 (reads veritas-plan.json)
    ↓
T3: ADO work item created/updated with story details
    ↓
T4: DPDCA runner executes (reads WI status from ADO)
    ↓
T5: ado-close-wi.ps1 (push results back)
    ↓
T6: Evidence recorded in Project 37 Layer 31 (audit trail)
```

### Sync on Demand

```powershell
# Reseed a project after editing PLAN.md
cd 36-red-teaming
python ../07-foundation-layer/scripts/data-seeding/seed-from-plan.py --reseed-model

# Then sync to ADO
pwsh -File ../38-ado-poc/scripts/ado-import-project.ps1 `
     -ProjectId "36" `
     -ResyncExisting

# Output:
# [INFO] Reading .eva/veritas-plan.json...
# [PASS] 15 stories parsed
# [INFO] Syncing to ADO...
# [UPDATE] PBI 1024: status PASS → ACTIVE (1 new test case)
# [CREATE] PBI 1025: new story detected
# [SUMMARY] 15 stories synced, 1 updated, 1 created
```

### Story UUID Correlation

Each story has a canonical UUID for correlation across systems:

```
PLAN.md Story 36-01-001
    ↓ (seed-from-plan.py)
.eva/veritas-plan.json: {id: "36-01-001", uuid: "efc8a2c1-..."}
    ↓ (ado-import-project.ps1)
ADO PBI tag: "eva-story:36-01-001" (indexed)
    ↓ (ado-close-wi.ps1)
Project 37 Evidence Layer (L31): 
  {story_id: "36-01-001", evidence_uuid: "evc_36_...", correlation: "efc8a2c1-..."}
```

**To find all evidence for a story**:
```powershell
# Query Project 37 Evidence Layer
$story_id = "36-01-001"
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$evidence = Invoke-RestMethod "$base/model/evidence?story_id=$story_id"
```

---

## 3. DPDCA Phase Advancement via ADO

ADO WI state transitions correspond to DPDCA cycle phases.

### Phase Mapping

| ADO WI State | DPDCA Phase | Transition Action | Evidence Required |
|---|---|---|---|
| `New` | **D** (Discover) | Team reviews acceptance criteria | PLAN.md documentation |
| `Active` | **P** (Plan) | Dev/test strategy defined | PLAN updated with tasks |
| `In Progress` | **Do** (Execute) | Implementation underway | Commit/PR opened |
| `Testing` | **C** (Check) | QA validation in progress | Test results, coverage |
| `Done` | **A** (Act) | Ready for production | Validation gate passed |
| `Removed` | **Retire** | Story deferred/cancelled | Justification documented |

### Phase Transition Workflow

```powershell
# Advance phase: In Progress → Testing
pwsh -File "38-ado-poc/scripts/ado-advance-phase.ps1" `
     -WorkItemId 1024 `
     -TargetPhase "Testing" `
     -Evidence @{
        tests_passed = 25
        tests_failed = 0
        coverage_pct = 87.5
        build_log = "https://github.com/microsoft/eva-foundry/actions/runs/12345"
     }

# Output:
# [INFO] WI 1024 (Story 36-01-001): transitioning In Progress → Testing
# [VALIDATE] Acceptance criteria check: PASS (all 3 criteria met)
# [VALIDATE] Evidence check: PASS (coverage >= 80%)
# [UPDATE] ADO WI status → Testing
# [SUBMIT] Evidence to Project 37 Layer 31
#   Evidence ID: evc_36_20260307_093412
#   Correlation: 36-01-001
# [PASS] Phase transition complete
```

### Quality Gate: Testing → Done

Before advancing to **Done**, mandatory checks:

```python
def validate_testing_to_done_gate(work_item_id):
    checks = {
        "acceptance_criteria_met": True,  # All AC tasks completed
        "tests_passing": True,             # test_count > 0 AND test_passed == test_count
        "coverage_threshold": 0.80,        # coverage_pct >= 80%
        "code_review_approved": True,      # GitHub PR has approval +1
        "documentation_complete": True,     # Acceptance.md updated
    }
    
    if all(checks.values()):
        return "APPROVED"  # Can advance to Done
    else:
        missing = [k for k, v in checks.items() if not v]
        return f"BLOCKED: {missing}"  # Cannot advance; list blockers
```

---

## 4. Work Item Status & Metrics Upload

When a DPDCA phase completes, push results back to ADO with evidence.

### ado-close-wi.ps1 Pattern

```powershell
# Mark WI as Done with test results
pwsh -File "38-ado-poc/scripts/ado-close-wi.ps1" `
     -WorkItemId 1024 `
     -Status "Done" `
     -Metrics @{
        total_tests = 25
        passed = 25
        failed = 0
        skipped = 0
        coverage = 87.5
        duration_seconds = 1245
        ci_build_url = "https://github.com/microsoft/eva-foundry/actions/runs/..."
        commit_hash = "a1b2c3d4e5f6"
     }

# Output:
# [INFO] Closing WI 1024 with metrics...
# [UPDATE] ADO WI status → Done
# [UPDATE] WI history: 25 tests passed, 87.5% coverage
# [SUBMIT] Evidence record to Project 37
#   Evidence ID: evc_36_20260307_105432
#   Correlation ID: 36-01-001
# [PASS] WI closed with evidence recorded
```

### Evidence Submission Format

```json
{
  "work_item_id": 1024,
  "story_id": "36-01-001",
  "project_id": "36",
  "phase_transition": "C→A",
  "timestamp": "2026-03-07T10:54:32Z",
  "status": "PASS",
  "metrics": {
    "total_tests": 25,
    "passed": 25,
    "failed": 0,
    "coverage": 87.5,
    "duration_seconds": 1245
  },
  "artifacts": {
    "test_report": "https://...",
    "coverage_report": "https://...",
    "ci_build": "https://...",
    "pr_link": "https://github.com/microsoft/eva-foundry/pull/123"
  }
}
```

---

## 5. Cost Attribution (APIM Integration)

All API calls made by projects are tagged with cost attribution headers for portfolio-level FinOps tracking.

### Cost Attribution Headers

| Header | Value | Example | Owned By |
|---|---|---|---|
| `x-eva-project-id` | Project number | `36` | Project 07 (registering projects) |
| `x-eva-user-id` | User principal | `marco@microsoft.com` | Project 31 (eva-faces) |
| `x-eva-sprint` | Sprint ID | `2026-q1-sprint-2` | Project 38 (ADO) |
| `x-eva-business-unit` | Business unit | `AI COE` | Project 07 (workspace config) |
| `x-eva-client-id` | Client/customer | `internal-r&d` | Project 24 (eva-brain) |
| `x-eva-wi-tag` | Work item correlation | `ADO:1024` | Project 38 (ADO integration) |

### Header Injection Pattern (via APIM)

When a project calls an EVA API:

```python
# Project 36 agent calls Project 37 API
import requests

headers = {
    "x-eva-project-id": "36",           # Project 07 configured
    "x-eva-user-id": "marco@...",       # Project 31 authenticated
    "x-eva-sprint": "2026-q1-s2",       # Project 38 (ADO) provided
    "x-eva-business-unit": "AI COE",    # Project 07 workspace config
    "x-eva-client-id": "internal",      # Project 24 configured
    "x-eva-wi-tag": "36-01-001",        # Project 38 (story ID)
}

response = requests.get(
    "https://marco-sandbox-apim.azure-api.net/37-data-model/model/layers",
    headers=headers
)
```

### Cost Tracking via Project 14 (FinOps)

Project 14 (Azure Cost Optimization) consumes these headers:

```
APIM logs (with x-eva-* headers)
    ↓
Azure Cost Management export
    ↓
Power BI analytics
    ↓
Cost breakdown by:
  - Project (x-eva-project-id)
  - Sprint (x-eva-sprint)
  - Business unit (x-eva-business-unit)
  - Client (x-eva-client-id)
  - Work item (x-eva-wi-tag)
```

---

## 6. Troubleshooting

### Symptom: "ADO import failed - Authentication error"

**Root Cause**: Invalid ADO PAT (Personal Access Token)  
**Resolution**:
```powershell
# Step 1: Set ADO credentials
$env:ADO_ORG = "https://dev.azure.com/marcopresta"
$env:ADO_PROJECT = "eva-poc"
$env:ADO_PAT = "<new-pat-token>"

# Step 2: Verify connection
pwsh -File "38-ado-poc/scripts/ado-verify-connection.ps1"

# Output:
# [INFO] Connecting to ADO organization: $env:ADO_ORG
# [PASS] Authentication successful
# [PASS] Project "eva-poc" accessible
```

### Symptom: "Work item sync incomplete - some stories missing"

**Root Cause**: PLAN.md not updated before sync  
**Resolution**:
```powershell
# Step 1: Update PLAN.md with new stories

# Step 2: Reseed from Plan
cd 36-red-teaming
python ../07-foundation-layer/scripts/data-seeding/seed-from-plan.py --reseed-model

# Step 3: Invoke sync with --ResyncExisting flag
pwsh -File ../38-ado-poc/scripts/ado-import-project.ps1 `
     -ProjectId "36" `
     -ResyncExisting

# [PASS] 15 stories synced (previous: 12, +3 new)
```

### Symptom: "ADO dashboard not updating - stale sprint state"

**Root Cause**: Pipeline hasn't run recent ado-close-wi calls  
**Resolution**:
```powershell
# Manually trigger evidence refresh
pwsh -File "38-ado-poc/scripts/ado-refresh-dashboard.ps1" `
     -Force

# Output:
# [INFO] Refreshing ADO dashboard state...
# [SYNC] Project 36: 15/15 WIs current
# [SYNC] Project 37: 23/23 WIs current
# [UPDATE] Power BI refresh triggered
# [PASS] Dashboard up-to-date
```

---

## 7. Related Skills & Automation

| Skill | Purpose |
|---|---|
| `@data-model-admin` | Data model queries + seeding (upstream of ADO sync) |
| `@ado-dashboard-admin` | ADO dashboard configuration and troubleshooting |
| `seed-from-plan.py` | PLAN.md → veritas-plan.json → ADO orchestration |
| `ado-import-project.ps1` | Shared ADO registration engine |
| `ado-onboard-all.ps1` | Batch orchestrator for all projects |
| `ado-close-wi.ps1` | Push WI completion + evidence submission |

---

## 8. Key Takeaways

✅ **Every project has an ado-artifacts.json** -- defines Epic/Feature/PBI hierarchy  
✅ **Use ado-onboard-all.ps1** -- batch register all projects at once  
✅ **PLAN.md is source of truth** -- ADO stays in sync via seed-from-plan.py + ado-import-project.ps1  
✅ **Cost attribution headers** -- all API calls tagged for portfolio FinOps  
✅ **Evidence submission** -- WI completion triggers Project 37 audit trail recording  
✅ **Quality gates** -- mandate test pass rate, coverage, and code review before Done  

---

## 9. Quick Reference

**Register All Projects**:
```powershell
pwsh -File "38-ado-poc/scripts/ado-onboard-all.ps1"
```

**Sync One Project**:
```powershell
pwsh -File "38-ado-poc/scripts/ado-import-project.ps1" -ProjectId "36"
```

**Close Work Item with Evidence**:
```powershell
pwsh -File "38-ado-poc/scripts/ado-close-wi.ps1" -WorkItemId 1024 -Status "Done" -Metrics @{...}
```

**Query ADO for Active WIs**:
```python
import requests
base = "https://dev.azure.com/marcopresta/eva-poc/_apis/wit/wiql"
query = "SELECT * FROM WorkItems WHERE [System.State] = 'Active' ORDER BY [System.Id]"
results = requests.post(base, json={"query": query})
```

---

**Revision**: 1.0.0 (March 7, 2026)  
**Maintainer**: Project 38 (ADO Command Center) + Project 07 (Foundation Layer)  
**Last Validated**: Session 38
