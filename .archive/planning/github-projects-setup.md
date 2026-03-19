# EVA Foundation Portfolio Project Board
# GitHub Projects v2 Setup Guide

Version: 1.0.0
Created: 2026-03-01
Purpose: Create organization-level portfolio visibility across all 12 active EVA projects
Target URL: https://github.com/orgs/eva-foundry/projects (after setup)

---

## Why GitHub Projects v2

**vs. 39-ado-dashboard**:
- Native GitHub integration (no separate React app)
- Real-time sync with issues/PRs
- Free (included in GitHub Pro)
- Off-platform automation (no Google Sheets dependency)

**vs. GitHub Issues board**:
- Cross-repo visibility (aggregate 12 projects)
- Custom fields (MTI Score, Story ID, Sprint)
- Automation workflows (auto-move cards, update fields)
- Portfolio-level metrics (velocity, completion %)

---

## Step 1: Create the Board (UI)

**Navigate to**: https://github.com/orgs/eva-foundry/projects

**Click**: "New project" (green button)

**Configure**:
- **Name**: EVA Foundation Portfolio
- **Description**: Workspace-level metrics and sprint planning (12 active projects)
- **Template**: Table (for custom fields)
- **Visibility**: Public

**Click**: "Create project"

---

## Step 2: Add Custom Fields

Once the board is created, add these columns/fields:

### Required Fields (Table View)

| Field | Type | Options / Format |
|---|---|---|
| Title | Auto | (issue title) |
| Status | Single Select | Not Started, In Progress, Review, Done, Blocked |
| Project | Single Select | 31-eva-faces, 33-eva-brain-v2, 36-red-teaming, 37-data-model, 38-ado-poc, 39-ado-dashboard, 40-eva-control-plane, 43-spark, 44-eva-jp-spark, 48-eva-veritas, 51-ACA, 07-foundation-layer |
| Story ID | Text | Format: PROJECT-NN-NNN (e.g., ACA-03-006) |
| Sprint | Text | Format: Sprint-NN (e.g., Sprint-07) |
| Size | Single Select | XS, S, M, L, Epic |
| MTI Impact | Single Select | Critical (70+), High (50-69), Medium (30-49), Low (0-29) |
| Test Count | Number | Count of test cases |
| Assignee | User | (auto-populated) |
| Due Date | Date | (auto-populated from issue) |

**How to Add**:
1. Click "+" icon in board header
2. Enter field name, select type
3. Add options (for Single Select fields)
4. Click "Save"

---

## Step 3: Link Issues from All 12 Projects

**Goal**: Aggregate all open issues from eva-foundry/* repos

**Via UI** (manual, one-time):
1. Click "Add items" in project
2. Search: "repo:eva-foundry/51-ACA is:open"
3. Select issues
4. Repeat for each of 12 repos

**Via GraphQL** (automated, recommended):
Create a GitHub Actions workflow to sync issues:

```yaml
name: Sync Issues to Portfolio

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync issues to project
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const query = `
              query {
                organization(login: "eva-foundry") {
                  repositories(first: 100) {
                    nodes {
                      issues(first: 100, states: OPEN) {
                        nodes {
                          id
                          title
                          repository { name }
                          labels { nodes { name } }
                        }
                      }
                    }
                  }
                }
              }
            `;
            
            const result = await github.graphql(query);
            
            // For each issue, add to project via GraphQL mutation
            // (see Step 4 for mutation details)
```

---

## Step 4: Automation Workflows (GitHub Actions)

### Workflow A: Auto-link New Issues

Any issue created in eva-foundry/* repos with label `portfolio` is auto-added to the project.

**File**: `.github/workflows/add-to-portfolio.yml` (in 07-foundation-layer)

```yaml
name: Add to Portfolio Project

on:
  issues:
    types: [opened, labeled]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    if: contains(github.event.issue.labels.*.name, 'portfolio')
    steps:
      - name: Add issue to portfolio project
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: https://github.com/orgs/eva-foundry/projects/1
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Workflow B: Auto-Update Status on PR Changes

When a PR is opened/merged, auto-update project card status.

```yaml
name: Update Portfolio Status

on:
  pull_request:
    types: [opened, closed]

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Update status
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            // When PR opened: move card to "Review"
            // When PR merged: move card to "Done"
            // Logic via GraphQL projectV2Item.fieldValues update
```

### Workflow C: Populate Story ID Field

When issue is created with pattern `[ACA-03-006]` in title, auto-populate Story ID field.

```yaml
name: Extract Story ID

on:
  issues:
    types: [opened]

jobs:
  extract:
    runs-on: ubuntu-latest
    steps:
      - name: Extract and update story ID
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const match = context.payload.issue.title.match(/\[(.*?-\d+-\d+)\]/);
            if (match) {
              const storyId = match[1];
              // Update projectV2Item.fieldValues via GraphQL
            }
```

---

## Step 5: ProjectV2 GraphQL API (Advanced)

For custom automation, use GitHub's ProjectV2 API:

### Get Project ID

```graphql
query {
  organization(login: "eva-foundry") {
    projectV2(number: 1) {
      id
      title
      fields(first: 10) {
        nodes {
          id
          name
          dataType
        }
      }
    }
  }
}
```

### Add Issue to Project

```graphql
mutation {
  addProjectV2ItemById(input: {
    projectId: "PVT_kwDOBxxxxxxxx"
    contentId: "I_xxxxxxxxxxxxx"
  }) {
    item {
      id
    }
  }
}
```

### Update Custom Field

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwDOBxxxxxxxx"
    itemId: "PVTI_xxx"
    fieldId: "PVTF_xxx"  # Story ID field
    value: { text: "ACA-03-006" }
  }) {
    projectV2Item {
      id
    }
  }
}
```

---

## Step 6: Initial Data Population

### Via UI (Quick Start)

1. Open each of 12 repos: 07, 31, 33, 36, 37, 38, 39, 40, 43, 44, 48, 51
2. Go to "Issues" tab
3. Add label `portfolio` to all open issues
4. Issues auto-appear in board (via workflow from Step 4)

### Via Script (Automated)

Create `scripts/populate-portfolio.ps1`:

```powershell
# Login to GitHub
gh auth login --web

# For each project
$projects = "07-foundation-layer", "31-eva-faces", "33-eva-brain-v2", "36-red-teaming", "37-data-model", "38-ado-poc", "39-ado-dashboard", "40-eva-control-plane", "43-spark", "44-eva-jp-spark", "48-eva-veritas", "51-ACA"

foreach ($proj in $projects) {
    Write-Host "Processing eva-foundry/$proj"
    
    # List all open issues
    gh issue list --repo "eva-foundry/$proj" --limit 100 --state open --json title,number,labels | ConvertFrom-Json | ForEach-Object {
        # Add portfolio label
        gh issue edit $_.number --repo "eva-foundry/$proj" --add-label portfolio
    }
}

Write-Host "All issues labeled. Portfolio project will sync via workflow."
```

**Run once**: `pwsh scripts/populate-portfolio.ps1`

---

## Step 7: Verify Board Works

**After setup**, you should see:

1. **Board View**: Kanban board with Status columns (Not Started → In Progress → Review → Done)
2. **Table View**: All fields visible (Story ID, Sprint, Size, MTI Impact, Test Count)
3. **Filter**: can filter by Project, Sprint, Size, Status
4. **Metrics** (bottom right):
   - Item count by Status
   - Average MTI Impact
   - Items by Project (pie chart)

**Test Automation**:
- Create a test issue in 51-ACA with label `portfolio`
- Within 60 sec, should appear in portfolio project
- Edit issue to test field updates

---

## Step 8: Integrate with Veritas + Data Model

**Goal**: Make portfolio board source of truth for sprint metrics

### Data Flow

```
51-ACA GitHub Issue [sprint-task label]
  ↓
sprint-agent.yml fires
  ↓
sprint_agent.py executes + creates PR
  ↓
workflow: add-to-portfolio.yml fires
  ↓
Issue appears in portfolio project
  ↓
workflow: extract-story-id.yml populates Story ID field
  ↓
workflow: update-mti-impact.yml queries veritas, updates MTI field
  ↓
Portfolio board shows real-time sprint metrics
```

### Implementation: MTI Update Workflow

```yaml
name: Update MTI Impact from Veritas

on:
  issues:
    types: [opened, edited]
  schedule:
    - cron: '0 * * * *'  # Hourly

jobs:
  update-mti:
    runs-on: ubuntu-latest
    steps:
      - name: Run veritas audit
        run: |
          node .github/scripts/veritas-cli.js audit --repo . --output veritas.json
      
      - name: Extract MTI score from issue title
        id: extract
        uses: actions/github-script@v7
        with:
          script: |
            const regex = /\[(\w+-\d+-\d+)\]/;
            const match = context.payload.issue.title.match(regex);
            console.log('Story ID:', match[1]);
      
      - name: Update project field via GraphQL
        uses: actions/github-script@v7
        with:
          script: |
            // Query veritas.json for story MTI
            // Update project field: MTI Impact = "Critical" | "High" | "Medium" | "Low"
```

---

## Step 9: Portfolio Dashboard Metrics

**Derived metrics** (calculated from project data):

```
Total Stories: 127
In Progress: 23
Done: 89
Blocked: 3
Completion Rate: 70%

By Project:
- 51-ACA: 30 done / 45 total (67%)
- 31-eva-faces: 25 done / 35 total (71%)
- 37-data-model: 18 done / 20 total (90%)
- ...

By Sprint:
- Sprint 06: 15 items done
- Sprint 07: 8 items in progress

Average MTI Impact: 48 (Medium)
Critical Items: 12 (unblocked: 9, blocked: 3)
```

**Display**: GitHub Projects native (no additional UI needed)

---

## Maintenance

### Weekly Tasks
- Review blocked items (Status = Blocked)
- Update MTI Impact for new stories
- Check completion rate (target: 80%+)

### Monthly Tasks
- Export portfolio metrics to STATUS.md (each project)
- Retrospective: what blocked sprint progress?
- Plan next month's sprints based on capacity

### Quarterly Tasks
- Verify all 12 projects are linked
- Audit custom field usage (are teams using them?)
- Optimize automation workflows (cost, accuracy)

---

## Rollout Timeline

**Phase 7 (Foundation Completion Plan)**:
- Day 1 (2026-03-02): Create board + add custom fields (1h)
- Day 2 (2026-03-02): Link issues from 12 projects (1h)
- Day 3 (2026-03-03): Deploy automation workflows (1h)
- Day 4 (2026-03-03): Verify metrics + test workflows (1h)

**Total**: 4 hours (within Phase 7 time budget)

---

## Reference

- GitHub Projects API: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- ProjectV2 GraphQL: https://docs.github.com/en/graphql/reference/objects#projectv2
- add-to-project action: https://github.com/actions/add-to-project
- github-script action: https://github.com/actions/github-script

