# End-to-End Data Model-Driven Workflow

**Architecture**: Project 37 (Cloud API) as Single Source of Truth  
**Sync**: Bidirectional (Project 37 ↔ ADO) via GitHub Actions + ADO webhooks  
**Agents**: Query Project 37 for all context; update back as work progresses  
**Scrum Master**: Full visibility & control from Project 37 (no scattered tools)

**Date**: 2026-03-07 @ 4:20 PM ET  

---

## Vision: The Unified Workflow

```
README.md (Project Docs)
    ↓
Parse → PLAN.md structure
    ↓
GitHub Actions: Extract stories
    ↓
POST to Project 37 L09 (Project Registry)
    ├─ Feature F07-02
    ├─ Stories S07-02-001 through S07-02-006
    └─ Link to GitHub deliverables (paths, line numbers)
    ↓
ADO Webhook: Detect Project 37 change
    ├─ Auto-create Epic/Feature/Story hierarchy in ADO
    ├─ Bi-directional sync with ADO work items
    └─ Keep ADO as read-only mirror (Scrum Master UI)
    ↓
GitHub Agents: Query Project 37
    ├─ Get full story/task context (acceptance criteria, links, priority)
    ├─ Work on implementation
    ├─ PATCH Project 37 as work progresses (status, evidence, metrics)
    └─ Trigger Veritas audit → updates MTI score in Project 37
    ↓
ADO Webhook: Detect progress updates
    ├─ Reflect status change in ADO (Not Started → In Progress → Done)
    ├─ Update burndown, velocity, MTI badges
    └─ Keep team synchronized
    ↓
Scrum Master (Project 37 Dashboard)
    ├─ View all projects, all sprints, all metrics in one place
    ├─ Manage backlog (edit PLAN.md → syncs auto to 37 + ADO)
    ├─ Plan sprints (assign stories to iteration layer)
    ├─ Track progress (burndown, velocity, MTI trend)
    └─ No manual data entry (everything automatic)
```

---

## Phase 1: Create Stories from README

### Source: Project 07 README.md Structure

```markdown
# 07-foundation-layer

## Feature: Governance Toolchain Ownership [ID=F07-02]

### Story: Own 36-red-teaming [ID=F07-02-001]
- [ ] Document 36-red-teaming in README
- [ ] Create skill: red-teaming-integration.skill.md
- [ ] Add to scaffolding templates

### Story: Own 37-data-model [ID=F07-02-002]
- [ ] Document 37-data-model in README
- [ ] Create skill: data-model-admin.skill.md
- [ ] Document SEED pattern

... (continues for F07-02-003 through F07-02-006)
```

### Execution: Extract via GitHub Actions

**Workflow**: `.github/workflows/parse-readme-to-datamodel.yml`

```yaml
name: "Parse README → Project 37 Data Model"

on:
  push:
    branches: [main, master]
    paths:
      - 'README.md'
      - 'PLAN.md'
      - '.github/workflows/parse-readme-to-datamodel.yml'

jobs:
  extract-and-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "1️⃣ Parse README.md and PLAN.md"
        id: parse
        run: |
          # Extract features and stories using regex
          node scripts/parse-governance-docs.js \
            --readme README.md \
            --plan PLAN.md \
            --output /tmp/extracted-stories.json

      - name: "2️⃣ POST to Project 37: Register Stories"
        env:
          FOUNDRY_TOKEN: ${{ secrets.FOUNDRY_TOKEN }}
          PROJECT_ID: ${{ github.event.repository.name }}
        run: |
          STORIES=$(cat /tmp/extracted-stories.json | jq -c '.features[]')
          
          while IFS= read -r feature; do
            FEATURE_ID=$(echo "$feature" | jq -r '.id')
            FEATURE_TITLE=$(echo "$feature" | jq -r '.title')
            
            # Register feature
            curl -X POST https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/v1/projects/$PROJECT_ID/features \
              -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
              -H "Content-Type: application/json" \
              -d '{
                "feature_id": "'$FEATURE_ID'",
                "title": "'$FEATURE_TITLE'",
                "source": "github",
                "source_url": "https://github.com/${{ github.repository }}/blob/${{ github.sha }}/README.md",
                "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
              }'
            
            # Register each story under the feature
            STORIES=$(echo "$feature" | jq -c '.stories[]')
            while IFS= read -r story; do
              STORY_ID=$(echo "$story" | jq -r '.id')
              STORY_TITLE=$(echo "$story" | jq -r '.title')
              TASKS=$(echo "$story" | jq -c '.tasks')
              
              curl -X POST https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/v1/projects/$PROJECT_ID/features/$FEATURE_ID/stories \
                -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
                -H "Content-Type: application/json" \
                -d '{
                  "story_id": "'$STORY_ID'",
                  "title": "'$STORY_TITLE'",
                  "feature_id": "'$FEATURE_ID'",
                  "tasks": '$TASKS',
                  "status": "not-started",
                  "source": "github",
                  "source_line": "'$(grep -n "$STORY_TITLE" README.md | cut -d: -f1)'",
                  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
                }'
            done <<< "$STORIES"
          done <<< "$STORIES"

      - name: "3️⃣ ADD to PR comment: Extraction summary"
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const stories = JSON.parse(fs.readFileSync('/tmp/extracted-stories.json', 'utf8'));
            const body = `## 📋 Data Model Sync
            
            ✅ Extracted **${stories.features.length}** features
            ✅ Synced **${stories.total_stories}** stories to Project 37
            ✅ Registered **${stories.total_tasks}** tasks
            
            **Data Model**: [View in Project 37](https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/${{ github.event.repository.name }})`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

### Result: Project 37 Layer L09 Updated

```json
{
  "project_id": "07-foundation-layer",
  "features": [
    {
      "feature_id": "F07-02",
      "title": "Governance Toolchain Ownership",
      "status": "in-progress",
      "stories": [
        {
          "story_id": "F07-02-001",
          "title": "Own 36-red-teaming",
          "status": "not-started",
          "tasks": 3,
          "github_source": "https://github.com/...#L45",
          "created_at": "2026-03-07T16:20:00Z"
        },
        { ... }
      ]
    }
  ]
}
```

---

## Phase 2: ADO Webhook Sync (Automatic)

### Trigger: Project 37 Update → ADO Creation

**ADO Webhook Setup** (configured once):

```bash
# Register webhook from Project 37 API to ADO
curl -X POST https://dev.azure.com/{org}/{project}/_apis/hooks/subscriptions \
  -H "Authorization: Basic $(echo -n :{PAT} | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "eventType": "ms.vss.work.work-item-created",
    "resourceVersion": "1.0",
    "consumerId": "project-37-sync",
    "consumerActionId": "httpRequest",
    "consumerInputs": {
      "url": "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/webhooks/ado-workitem-sync"
    },
    "publisherId": "tfs",
    "scope": "all"
  }'
```

### Workflow: Project 37 → ADO Auto-Sync

**Azure Function**: `ADO-SyncFromDataModel.ps1`

```powershell
# Triggered by: Project 37 webhook (new story created)

param(
  [object]$TriggerObject  # From Project 37 API
)

$ProjectId = $TriggerObject.project_id
$FeatureId = $TriggerObject.feature_id
$StoryId = $TriggerObject.story_id

# 1. Create ADO Epic if Feature doesn't exist
$Epic = @{
  op    = "add"
  path  = "/fields/System.Title"
  value = "$FeatureId: $($TriggerObject.feature_title)"
}

$EpicId = az boards work-item create \
  --type Epic \
  --title "$FeatureId: $($TriggerObject.feature_title)" \
  --fields "System.Description=$($TriggerObject.description)" \
           "System.Tags=governance,project-$ProjectId,data-model-synced" \
           "Custom.DataModelId=$FeatureId" \
  --query "id" -o tsv

# 2. Create ADO User Story under Epic
$StoryTitle = "$StoryId: $($TriggerObject.story_title)"
$StoryAdo = az boards work-item create \
  --type "User Story" \
  --title $StoryTitle \
  --fields "System.Description=$($TriggerObject.story_description)" \
           "System.Tags=$ProjectId,$StoryId,data-model-synced" \
           "Custom.DataModelId=$StoryId" \
           "Custom.GitHubSource=$($TriggerObject.github_source)" \
  --query "id" -o tsv

# 3. Link User Story to Epic
az boards work-item relation add \
  --id $StoryAdo \
  --relation-type "Child" \
  --target-id $EpicId

# 4. Create Tasks under User Story
$Tasks = $TriggerObject.tasks
foreach ($task in $Tasks) {
  $TaskAdo = az boards work-item create \
    --type Task \
    --title "$($task.id): $($task.description)" \
    --fields "System.Description=$($task.details)" \
             "Custom.DataModelId=$($task.id)" \
    --query "id" -o tsv
  
  az boards work-item relation add \
    --id $TaskAdo \
    --relation-type "Parent" \
    --target-id $StoryAdo
}

# 5. Return sync confirmation back to Project 37
Invoke-RestMethod -Uri "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/webhooks/ado-sync-complete" \
  -Method POST \
  -Headers @{ Authorization = "Bearer $env:FOUNDRY_TOKEN" } \
  -Body @{
    project_id = $ProjectId
    feature_id = $FeatureId
    story_id = $StoryId
    ado_epic_id = $EpicId
    ado_story_id = $StoryAdo
    timestamp = Get-Date -AsUTC
  } | ConvertTo-Json
```

### Result: ADO Mirrored Automatically

```
ADO Work Items (Auto-Created):
├─ Epic: "F07-02: Governance Toolchain Ownership"
│  ├─ User Story: "F07-02-001: Own 36-red-teaming"
│  │  ├─ Task: "F07-02-001-T01: Document in README"
│  │  ├─ Task: "F07-02-001-T02: Create skill"
│  │  └─ Task: "F07-02-001-T03: Add to scaffolding"
│  ├─ User Story: "F07-02-002: Own 37-data-model"
│  │  ├─ Task: "F07-02-002-T01: Document in README"
│  │  ... (and so on)
```

### Bidirectional Link

```json
[Project 37 Layer L09]
├─ story_id: "F07-02-001"
├─ ado_link: "https://dev.azure.com/.../wit/123456"
└─ sync_status: "in_sync"

[ADO Work Item #123456]
├─ Type: User Story
├─ Title: "F07-02-001: Own 36-red-teaming"
├─ Custom Field "DataModelId": "F07-02-001"
└─ Custom Field "DataModelLink": "https://msub-eva-data-model/.../stories/F07-02-001"
```

---

## Phase 3: GitHub Agent Executes Work

### Context: Agent Queries Project 37 for Full Story

**GitHub Agent Workflow**: `agent-execute-story.yml`

```yaml
name: "Agent: Execute Story (Query → Work → Update)"

on:
  workflow_dispatch:
    inputs:
      story_id:
        description: "Story ID to execute (e.g., F07-02-001)"
        required: true

jobs:
  execute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "1️⃣ Query Project 37: Get Full Story Context"
        id: context
        env:
          FOUNDRY_TOKEN: ${{ secrets.FOUNDRY_TOKEN }}
          STORY_ID: ${{ github.event.inputs.story_id }}
        run: |
          # GET from Project 37: Full story + acceptance criteria + links
          RESPONSE=$(curl -s https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/v1/projects/07-foundation-layer/stories/$STORY_ID \
            -H "Authorization: Bearer ${FOUNDRY_TOKEN}")
          
          echo "STORY_CONTEXT=$(echo $RESPONSE | jq -c .)" >> $GITHUB_OUTPUT
          
          # Extract key fields
          ACCEPTANCE=$(echo "$RESPONSE" | jq -r '.acceptance_criteria')
          DELIVERABLES=$(echo "$RESPONSE" | jq -r '.deliverables[]')
          PRIORITY=$(echo "$RESPONSE" | jq -r '.priority')
          
          echo "Acceptance Criteria: $ACCEPTANCE"
          echo "Deliverables: $DELIVERABLES"
          echo "Priority: $PRIORITY"

      - name: "2️⃣ Update Project 37: Mark In Progress"
        env:
          FOUNDRY_TOKEN: ${{ secrets.FOUNDRY_TOKEN }}
          STORY_ID: ${{ github.event.inputs.story_id }}
        run: |
          curl -X PATCH https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/v1/projects/07-foundation-layer/stories/$STORY_ID \
            -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
            -H "Content-Type: application/json" \
            -d '{
              "status": "in-progress",
              "started_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
              "started_by": "${{ github.actor }}",
              "github_run_id": "${{ github.run_id }}"
            }'

      - name: "3️⃣ Execute Work (Build Implementation)"
        run: |
          # Example: Create README section, skill file, pattern doc
          # (specific implementation depends on story)
          
          STORY_CONTEXT='${{ steps.context.outputs.STORY_CONTEXT }}'
          STORY_ID=$(echo "$STORY_CONTEXT" | jq -r '.story_id')
          
          echo "🚀 Executing $STORY_ID..."
          # ... actual work (create files, run tests, etc.)

      - name: "4️⃣ Collect Metrics & Evidence (Veritas)"
        env:
          FOUNDRY_TOKEN: ${{ secrets.FOUNDRY_TOKEN }}
        run: |
          # Run Veritas audit locally (or via API)
          node 48-eva-veritas/src/cli.js audit --repo 07-foundation-layer > /tmp/veritas-report.json
          
          MTI=$(jq -r '.mti_score' /tmp/veritas-report.json)
          COVERAGE=$(jq -r '.coverage' /tmp/veritas-report.json)
          EVIDENCE=$(jq -r '.evidence' /tmp/veritas-report.json)
          
          echo "MTI_SCORE=$MTI" >> $GITHUB_ENV
          echo "COVERAGE=$COVERAGE" >> $GITHUB_ENV
          echo "EVIDENCE=$EVIDENCE" >> $GITHUB_ENV

      - name: "5️⃣ Update Project 37: Record Completion + Metrics"
        env:
          FOUNDRY_TOKEN: ${{ secrets.FOUNDRY_TOKEN }}
          STORY_ID: ${{ github.event.inputs.story_id }}
        run: |
          curl -X PATCH https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/v1/projects/07-foundation-layer/stories/$STORY_ID \
            -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
            -H "Content-Type: application/json" \
            -d '{
              "status": "complete",
              "completed_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
              "completed_by": "${{ github.actor }}",
              "github_run_id": "${{ github.run_id }}",
              "deliverables": [
                "path/to/README.md",
                "path/to/skill.md",
                "path/to/pattern.md"
              ],
              "metrics": {
                "mti_score": '${{ env.MTI_SCORE }}',
                "coverage_percent": '${{ env.COVERAGE }}',
                "evidence_percent": '${{ env.EVIDENCE }}'
              }
            }'

      - name: "6️⃣ Result: ADO Webhook Auto-Updates"
        run: |
          echo "✅ Story marked complete in Project 37"
          echo "✅ ADO webhook triggered (in-progress → done)"
          echo "✅ Scrum Master sees update in real-time"
```

### Result: Project 37 Updated in Real-Time

```json
{
  "story_id": "F07-02-002",
  "status": "complete",
  "started_at": "2026-03-07T16:15:00Z",
  "completed_at": "2026-03-07T16:35:00Z",
  "duration_minutes": 20,
  "github_run_id": "1234567890",
  "completed_by": "copilot-agent",
  "deliverables": [
    "07-foundation-layer/README.md (lines 100-200)",
    "07-foundation-layer/.github/copilot-skills/data-model-admin.skill.md",
    "07-foundation-layer/SEED-FROM-PLAN-PATTERN.md"
  ],
  "metrics": {
    "mti_score": 95,
    "coverage_percent": 98,
    "evidence_percent": 100,
    "consistency_percent": 97
  }
}
```

---

## Phase 4: ADO Webhook Syncs Progress

### Trigger: Project 37 Change → ADO Status Update

**Azure Function**: `ADO-UpdateFromDataModel.ps1`

```powershell
# Triggered by: Project 37 webhook (story status changed to "complete")

param(
  [object]$WebhookPayload
)

$StoryId = $WebhookPayload.story_id
$NewStatus = $WebhookPayload.status

# 1. Query ADO: Find work item with DataModelId = $StoryId
$ADOWorkItem = az boards work-item list \
  --query "[?CustomField.DataModelId=='$StoryId']" \
  --type "User Story" | ConvertFrom-Json | Select-Object -First 1

if ($ADOWorkItem) {
  $ADOId = $ADOWorkItem.id
  
  # 2. Map Project 37 status → ADO state
  $ADOState = switch ($NewStatus) {
    "not-started" { "New" }
    "in-progress" { "Active" }
    "complete"    { "Closed" }
    default       { "New" }
  }
  
  # 3. Update ADO work item
  az boards work-item update \
    --id $ADOId \
    --state $ADOState \
    --fields "System.CompletedDate=$(Get-Date -Format 'yyyy-MM-dd')" \
             "Custom.DataModelMetrics=$($WebhookPayload.metrics | ConvertTo-Json -Compress)"
  
  # 4. Add comment with deliverables
  $Comment = "✅ Completed via Project 37
  
**Deliverables**:
$($WebhookPayload.deliverables -join "`n")

**Metrics**:
- MTI: $($WebhookPayload.metrics.mti_score)
- Coverage: $($WebhookPayload.metrics.coverage_percent)%
- Evidence: $($WebhookPayload.metrics.evidence_percent)%"

  az boards work-item update \
    --id $ADOId \
    --fields "System.Description=$Comment"
}
```

### Result: ADO In Sync with Project 37

```
ADO Work Item: F07-02-002 (User Story)
├─ Title: "Own 37-data-model"
├─ State: Closed (auto-updated)
├─ CompletedDate: 2026-03-07
├─ Description: [Includes deliverables + metrics]
└─ Custom Field "DataModelMetrics": { mti: 95, coverage: 98, ... }
```

---

## Phase 5: Scrum Master Dashboard (Single Source of Truth)

### Query Project 37 API for Full Portfolio View

**Endpoint**: `GET /v1/projects/{project_id}/portfolio-health`

**Response** (Scrum Master Dashboard):

```json
{
  "workspace": "eva-foundry",
  "generated_at": "2026-03-07T16:20:00Z",
  "features": [
    {
      "feature_id": "F07-02",
      "title": "Governance Toolchain Ownership",
      "status": "in-progress",
      "progress": {
        "stories_total": 6,
        "stories_complete": 2,
        "stories_in_progress": 3,
        "stories_not_started": 1,
        "percent_complete": 33
      },
      "stories": [
        {
          "story_id": "F07-02-001",
          "title": "Own 36-red-teaming",
          "status": "complete",
          "completed_at": "2026-03-07T16:10:00Z",
          "metrics": { "mti": 92, "coverage": 95, "evidence": 100 },
          "ado_link": "https://dev.azure.com/.../wit/123456"
        },
        {
          "story_id": "F07-02-002",
          "title": "Own 37-data-model",
          "status": "complete",
          "completed_at": "2026-03-07T16:35:00Z",
          "metrics": { "mti": 95, "coverage": 98, "evidence": 100 },
          "ado_link": "https://dev.azure.com/.../wit/123457"
        },
        {
          "story_id": "F07-02-003",
          "title": "Own 38-ado-poc",
          "status": "in-progress",
          "started_at": "2026-03-07T16:40:00Z",
          "metrics": null,
          "ado_link": "https://dev.azure.com/.../wit/123458"
        }
      ]
    }
  ],
  "workspace_metrics": {
    "total_features": 12,
    "total_stories": 87,
    "stories_complete": 42,
    "avg_mti_score": 84,
    "avg_velocity_stories_per_day": 2.3,
    "burn_down_percent": 48
  }
}
```

### Scrum Master UI (Query Project 37 Directly)

**Dashboard Features**:

1. **Backlog Management** (Edit README → Auto-sync to Project 37 + ADO)
   - View all features and stories
   - Drag/drop to reorder
   - Edit acceptance criteria
   - Link to GitHub source files

2. **Sprint Planning** (Assign to iteration)
   - Allocate stories to sprints
   - Estimate story points (from Project 37 metadata)
   - View capacity vs. load
   - Generate sprint goals

3. **Progress Tracking** (Real-time burndown)
   - Story completion burndown chart
   - Velocity trend (stories/day)
   - MTI score trend (quality gate)
   - Evidence collection % (Veritas metrics)

4. **Metrics & Reporting**
   - Portfolio health (all 57 projects)
   - Team velocity (stories completed/sprint)
   - Quality trends (MTI scores over time)
   - Risk indicators (low MTI projects)

---

## Full Loop: README → Data Model → ADO → GitHub → Metrics

### Timeline Example: F07-02-002 Story

```
T1: 2026-03-07 @ 09:00 AM ET - README updated
    └─ User adds: "Story: Own 37-data-model [ID=F07-02-002]"
    └─ Push to main branch

T2: 2026-03-07 @ 09:01 AM ET - GitHub Actions: Parse README
    └─ Extract F07-02-002 story
    └─ POST to Project 37 API
    └─ Create F07-02-002 in Layer L09

T3: 2026-03-07 @ 09:02 AM ET - Project 37 Webhook
    └─ Trigger ADO-SyncFromDataModel
    └─ Create ADO User Story #123457: "F07-02-002: Own 37-data-model"

T4: 2026-03-07 @ 09:03 AM ET - Scrum Master Dashboard
    └─ Story visible in backlog
    └─ Ready for sprint assignment
    └─ ADO also shows the story

T5: 2026-03-07 @ 14:00 PM ET - Manual trigger
    └─ GitHub agent: Execute F07-02-002
    └─ Query Project 37 for acceptance criteria
    └─ Create README section + skill + pattern

T6: 2026-03-07 @ 14:35 PM ET - Execution complete
    └─ Run Veritas audit → MTI 95
    └─ PATCH Project 37: status="complete", metrics={...}

T7: 2026-03-07 @ 14:36 PM ET - Project 37 Webhook
    └─ Trigger ADO-UpdateFromDataModel
    └─ Update ADO #123457: State="Closed", CompletedDate="2026-03-07"

T8: 2026-03-07 @ 14:37 PM ET - Scrum Master Dashboard
    └─ Story marked complete ✅
    └─ Burndown chart updates (+1 story)
    └─ Velocity recalculated
    └─ MTI score recorded
```

---

## Architecture Advantages

### 1. Single Source of Truth
```
✅ Project 37 Cloud API is ALWAYS authoritative
❌ No stale data in GitHub/ADO
❌ No manual sync delays (automatic)
```

### 2. Zero Local Services
```
✅ No port 8020 runtime needed
✅ Cloud API handles all queries/updates
✅ Agents are stateless (query → work → update)
✅ No local data cache issues
```

### 3. Bidirectional Sync
```
✅ README → Project 37 (GitHub Actions)
✅ Project 37 → ADO (Webhooks)
✅ ADO → Project 37 (ADO Webhooks, future)
✅ Both ADO + GitHub always in sync
```

### 4. Scrum Master Full Visibility
```
✅ One dashboard (Project 37 API queries)
✅ Manage backlog, sprints, metrics
✅ No manual data entry (all automatic)
✅ Real-time updates (webhook-driven)
```

### 5. Metrics Automatically Collected
```
✅ GitHub Actions collect: execution time, artifacts, status
✅ Veritas: MTI scores, coverage, evidence
✅ ADO: completion date, velocity, burndown
✅ All aggregated in Project 37 Layer L52 (Metrics)
```

---

## Implementation Roadmap

### Now (Session 38)
- ✅ F07-02 documentation delivered
- ⏳ Manual sync: POST F07-02 to Project 37 (Task 1)
- ⏳ Manual sync: Bulk-import F07-02 to ADO (Task 2)

### F07-03 (Next Sprint)
- **F07-03-01**: Implement GitHub Actions: Parse README → Project 37
- **F07-03-02**: Set up ADO Webhooks: Project 37 → ADO sync
- **F07-03-03**: Build Scrum Master Dashboard (Query Project 37)

### F07-04 (Following Sprint)
- **F07-04-01**: Agent workflow: Query → Execute → Update (F07-02-002 pattern)
- **F07-04-02**: ADO Webhooks reverse direction (ADO → Project 37)
- **F07-04-03**: Portfolio health dashboard (all 57 projects)

### F07-05+ (Future)
- **F07-05-01**: Automated sprint planning (AI allocation)
- **F07-05-02**: Predictive velocity (ML forecasting)
- **F07-05-03**: Automated remediation (low MTI → auto-escalate)

---

## Key Design Principles

### 1. Project 37 is the Source
- Never query GitHub directly; query Project 37 API
- Never query ADO directly; sync from Project 37
- All agents update Project 37 as source of truth

### 2. No Local State
- Agents are ephemeral (start → query → work → update → end)
- No local caches (query Project 37 each time)
- No port 8020 runtime needed (cloud API only)

### 3. Webhooks Drive Sync
- GitHub Actions: Detect changes → POST to Project 37
- Webhooks: Project 37 changes → Auto-update ADO
- Result: Both systems always in sync

### 4. Scrum Master Owns the Data Model
- All planning done in Project 37 (or via README)
- Dashboard queries Project 37
- Changes flow: Project 37 → ADO (one-way read)

### 5. Metrics Feed Governance
- Veritas scores: MTI collected during story execution
- Evidence: Automatically linked in Project 37
- Reports: Generated from Project 37 queries

---

## References

- **Project 37 Cloud API**: https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io
- **Layer L09**: Project Registry (features, stories, tasks)
- **Layer L52**: Metrics (burndown, velocity, MTI scores)
- **ADO Integration**: Webhook setup for bidirectional sync
- **GitHub Actions**: parse-readme-to-datamodel.yml (automated)

---

**Architecture Version**: 1.0 (Data Model-Driven, Cloud-First)  
**Updated**: 2026-03-07 @ 4:20 PM ET  
**Status**: Ready for F07-03 Implementation
