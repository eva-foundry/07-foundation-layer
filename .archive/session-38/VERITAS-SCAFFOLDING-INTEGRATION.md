# Veritas Scaffolding Integration Pattern

**Document**: Veritas (MTI) Setup Integration  
**Task**: F07-02-006-T03 - Add Veritas setup to scaffolding workflow  
**Status**: Formalized (Session 38)  
**Applicability**: All new EVA projects during scaffolding  

---

## Overview

When a new project is scaffolded using Project 07's `Initialize-ProjectStructure.ps1` or `Apply-Project07-Artifacts.ps1`, the scaffolding workflow should automatically:

1. Create `.eva/` directory structure for evidence storage
2. Generate initial `veritas-plan.json` (normalized plan for Veritas)
3. Create acceptance gate template with MTI ≥ 70 threshold
4. Configure source tagging guidelines in README
5. Set up Veritas audit hook in CI/CD workflows

This document formalizes the Veritas integration pattern and ensures all new projects are governance-ready from day 1.

---

## Pattern: Veritas Scaffolding Integration Flow

### Execution Sequence (After ADO Registration)

```
Step 1: Create folder structure
    └── Initialize-ProjectStructure.ps1
        └── Creates required folders (scripts/, docs/, tests/, eval/, evidence/, .eva/)

Step 2: Apply Project 07 Copilot Instructions
    └── Apply-Project07-Artifacts.ps1
        ├── Deploy copilot-instructions.md
        └── Generate debug/ folder

Step 3: Register Project in ADO
    └── Invoke-ADO-Registration.ps1
        └── Create Epic, Features, PBIs

Step 4: [NEW] Generate Veritas Configuration
    └── Initialize-VeritasSetup.ps1 (proposed)
        ├── Create .eva/ directory structure
        ├── Generate veritas-plan.json from PLAN.md
        ├── Generate .eva/.veritasignore (exclude patterns)
        └── Copy evidence receipt templates

Step 5: [NEW] Create Acceptance Gate Template
    └── Generate-Acceptance-Gate.ps1 (proposed)
        ├── Parse project ID
        ├── Create ACCEPTANCE.md with MTI ≥ 70 gate
        ├── Add Veritas audit command
        └── Add gate action (pass/fail logic)

Step 6: [NEW] Configure Source Tagging Guidelines
    └── Update README.md
        ├── Add "Evidence Tagging" section
        ├── Show EVA-STORY tag examples
        └── Link to veritas-admin.skill.md
```

---

## Step 4: Generate Veritas Configuration

### Function: Initialize-VeritasSetup

**Purpose**: Create `.eva/` directory structure and initial Veritas configuration.

**Inputs**:
- `$ProjectPath`: Path to project root
- `$ProjectId`: Project identifier (e.g., "36-red-teaming")
- `$PLAN_MD`: Content of PLAN.md (if available)

**Outputs**:
- `.eva/` directory created
- `.eva/veritas-plan.json` generated
- `.eva/.veritasignore` created
- `.eva/evidence-receipts/` folder created

**Implementation Pattern**:

```powershell
function Initialize-VeritasSetup {
    param(
        [string]$ProjectPath,
        [string]$ProjectId,
        [string]$PlanMdPath
    )

    Write-Host "📊 Setting up Veritas governance..." -ForegroundColor Cyan

    # Create .eva directory structure
    $evaDir = Join-Path $ProjectPath ".eva"
    $null = New-Item -ItemType Directory -Path $evaDir -Force
    $null = New-Item -ItemType Directory -Path (Join-Path $evaDir "evidence-receipts") -Force
    $null = New-Item -ItemType Directory -Path (Join-Path $evaDir "audit-reports") -Force

    Write-Host "✅ Created .eva/ directory structure" -ForegroundColor Green

    # Generate veritas-plan.json from PLAN.md
    if (Test-Path $PlanMdPath) {
        $planContent = Get-Content -Raw -Path $PlanMdPath
        $veritisPlan = ConvertTo-VeritisPlan -MarkdownContent $planContent -ProjectId $ProjectId
        $veritisPlanPath = Join-Path $evaDir "veritas-plan.json"
        $veritisPlan | ConvertTo-Json -Depth 10 | Out-File -Path $veritisPlanPath -Encoding UTF8
        Write-Host "✅ Generated veritas-plan.json" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PLAN.md not found; skipping veritas-plan.json generation" -ForegroundColor Yellow
    }

    # Create .veritasignore (exclude patterns)
    $veritasIgnore = @(
        "# Veritas scan ignore patterns"
        "node_modules/"
        "venv/"
        ".git/"
        "dist/"
        "build/"
        "__pycache__/"
        ".pytest_cache/"
        "coverage/"
        ".env"
        ".env.local"
        "*.log"
    ) -join "`n"
    
    $veritasIgnorePath = Join-Path $evaDir ".veritasignore"
    $veritasIgnore | Out-File -Path $veritasIgnorePath -Encoding UTF8
    Write-Host "✅ Created .eva/.veritasignore" -ForegroundColor Green

    # Create evidence receipt templates
    $receiptTemplate = @{
        "evidence_type" = "template"
        "correlation_id" = "GH<run>-PR<pr>-<sha>"
        "artifact_type" = "junit|json|text|xml"
        "metadata" = @{
            "description" = "Use this structure when submitting evidence to Project 40"
        }
    }
    
    $receiptPath = Join-Path $evaDir "evidence-receipts" "template.json"
    $receiptTemplate | ConvertTo-Json -Depth 5 | Out-File -Path $receiptPath -Encoding UTF8
    Write-Host "✅ Created evidence receipt template" -ForegroundColor Green

    # Create initial audit report stub
    $auditStub = @{
        "project_id" = $ProjectId
        "mti_score" = $null
        "coverage" = 0
        "evidence" = 0
        "consistency" = 0
        "status" = "ungoverned"
        "message" = "Run 'node 48-eva-veritas/src/cli.js audit --repo .' to compute first MTI score"
        "timestamp" = (Get-Date -AsUTC).ToString("o")
    }
    
    $auditPath = Join-Path $evaDir "audit-reports" "latest.json"
    $auditStub | ConvertTo-Json -Depth 5 | Out-File -Path $auditPath -Encoding UTF8
    Write-Host "✅ Created initial audit report stub" -ForegroundColor Green

    Write-Host "✅ Veritas setup complete`n" -ForegroundColor Green
}

# Helper: Convert PLAN.md to Veritas format
function ConvertTo-VeritisPlan {
    param(
        [string]$MarkdownContent,
        [string]$ProjectId
    )

    # Parse PLAN.md using regex
    # Extract:
    #   ## Feature: Title [ID=F01-01]
    #   ### Story: Title [ID=F01-01-001]
    #   #### Task: Title [ID=F01-01-001-T01]

    $patterns = @{
        Feature  = '##\s+Feature:\s+(.+?)\s+\[ID=([A-Z0-9-]+)\]'
        Story    = '###\s+Story:\s+(.+?)\s+\[ID=([A-Z0-9-]+)\]'
        Task     = '####\s+Task:\s+(.+?)\s+\[ID=([A-Z0-9-]+)\]'
    }

    $features = @()
    $lines = $MarkdownContent -split "`n"
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        if ($line -match $patterns.Feature) {
            $features += @{
                type = "Feature"
                title = $Matches[1]
                id = $Matches[2]
                stories = @()
            }
        } elseif ($line -match $patterns.Story) {
            if ($features.Count -gt 0) {
                $features[-1].stories += @{
                    type = "Story"
                    title = $Matches[1]
                    id = $Matches[2]
                    tasks = @()
                }
            }
        } elseif ($line -match $patterns.Task) {
            if ($features.Count -gt 0 -and $features[-1].stories.Count -gt 0) {
                $features[-1].stories[-1].tasks += @{
                    type = "Task"
                    title = $Matches[1]
                    id = $Matches[2]
                }
            }
        }
    }

    return @{
        project_id = $ProjectId
        generated_at = (Get-Date -AsUTC).ToString("o")
        features = $features
    }
}
```

### .eve/directory structure generated:

```
.eva/
├── .veritasignore           # Patterns to skip during scan
├── veritas-plan.json        # Normalized plan (auto-generated from PLAN.md)
├── evidence-receipts/
│   └── template.json        # Template for evidence submission
└── audit-reports/
    └── latest.json          # Latest audit result (stub on init)
```

### Sample veritas-plan.json:

```json
{
  "project_id": "36-red-teaming",
  "generated_at": "2026-03-07T14:32:00Z",
  "features": [
    {
      "type": "Feature",
      "title": "Red Team Engine",
      "id": "RTE-01",
      "stories": [
        {
          "type": "Story",
          "title": "Implement jailbreak detector",
          "id": "RTE-01-001",
          "tasks": [
            {
              "type": "Task",
              "title": "Create detector module",
              "id": "RTE-01-001-T01"
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Step 5: Create Acceptance Gate Template

### Function: Generate-Acceptance-Gate

**Purpose**: Create `ACCEPTANCE.md` with MTI ≥ 70 gate for PRs and deployments.

**Implementation Pattern**:

```powershell
function Generate-Acceptance-Gate {
    param(
        [string]$ProjectPath,
        [string]$ProjectId
    )

    Write-Host "🚪 Creating acceptance gate template..." -ForegroundColor Cyan

    $acceptanceMdContent = @"
# Acceptance Criteria

**Project**: $ProjectId  
**Foundation**: [07-foundation-layer](../../07-foundation-layer/)  
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')  

---

## Gate 1: MTI Trust Score (PRs Required)

**Rule**: Project must achieve MTI ≥ 70 to merge to \`main\`.

**Verification Command**:
\`\`\`bash
cd $ProjectId
node ../../48-eva-veritas/src/cli.js audit --repo . > .eva/audit-reports/pre-merge.json
MTI=\$(jq -r '.mti_score' .eva/audit-reports/pre-merge.json)
test \$(echo "\$MTI >= 70" | bc) -eq 1 || exit 1
\`\`\`

**Pass Criteria**:
- ✅ MTI score ≥ 70
- ✅ Coverage ≥ 70%
- ✅ Evidence ≥ 80% (stories tagged in code)
- ✅ Consistency ≥ 90% (planned stories matched)
- ✅ Exit code: 0

**Fail Criteria**:
- ❌ MTI < 70 → Merge blocked; review gaps in .eva/audit-reports/pre-merge.json
- ❌ Missing PLAN.md → Add plan before proceeding
- ❌ No evidence tags → Add \`// EVA-STORY: ID\` tags to source files

**Note**: First-time projects may need to adjust thresholds; contact governance team (Project 07) for exception.

---

## Gate 2: Source Tagging (PRs Required)

**Rule**: All new artifacts must include evidence tags when they implement declared stories.

**Verification**:
\`\`\`bash
# Check if new code contains EVA-STORY tags
git diff main... | grep -E '^\+.*EVA-STORY|^\+.*EVA-FEATURE' || exit_code=1

# Allowed: Files with tags
# Blocked: Implementation without tags
\`\`\`

**Pass Criteria**:
- ✅ New code files tagged with \`EVA-STORY: <story-id>\`
- ✅ New test files tagged with \`EVA-STORY: <story-id>-T<N>\`

---

## Gate 3: No Undeclared Code (Deployment Required)

**Rule**: Production deployments require no undeclared artifacts (code without PLAN.md story).

**Verification**:
\`\`\`bash
node ../../48-eva-veritas/src/cli.js audit --repo . --check-undeclared
# Exit 0 = no undeclared artifacts
# Exit 1 = undeclared artifacts found; update PLAN.md
\`\`\`

---

## Acceptance Sign-Off

| Role | Criterion | Signature |
|------|-----------|-----------|
| **Developer** | All gates pass locally | ☐ |
| **Reviewer** | Code review + gates approved | ☐ |
| **Governance** | MTI score appropriate for change | ☐ |

---

## Evidence Tagging Guidelines

### JavaScript/TypeScript
\`\`\`javascript
// EVA-STORY: $ProjectId-01-001
// EVA-FEATURE: $ProjectId-01
export class MyHandler {
  // implementation
}
\`\`\`

### Python
\`\`\`python
# EVA-STORY: $ProjectId-01-001
# EVA-FEATURE: $ProjectId-01
def my_handler():
    pass
\`\`\`

### Test Files
\`\`\`javascript
// EVA-STORY: $ProjectId-01-001-T01  // Link to implementation task
describe('MyHandler', () => {
  it('should handle input', () => {
    // test
  });
});
\`\`\`

---

## Troubleshooting

| Issue | Solution |
|---|---|
| MTI < 70 | Review gaps in .eva/audit-reports/pre-merge.json; add code or tests |
| No PLAN.md | Create PLAN.md or contact Project 07 for template |
| Tags not found | Run \`node 48-eva-veritas/src/cli.js generate-plan --repo .\` to auto-create |
| Coverage too low | Add test cases; use \`npm test -- --coverage\` to measure |

---

## References

- **Veritas Admin Skill**: [07-foundation-layer/.github/copilot-skills/veritas-admin.skill.md](../../07-foundation-layer/.github/copilot-skills/veritas-admin.skill.md)
- **Project 48 Veritas**: [48-eva-veritas/README.md](../../48-eva-veritas/README.md)
- **Project 37 Evidence Layer**: [37-data-model/README.md](../../37-data-model/README.md)
- **Project 07 Governance**: [07-foundation-layer/README.md](../../07-foundation-layer/README.md)

---

**Document Version**: 1.0.0 (Session 38)  
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')  
**Scope**: Veritas MTI gating; quality gate enforcement via acceptance criteria
"@

    $acceptancePath = Join-Path $ProjectPath "ACCEPTANCE.md"
    $acceptanceMdContent | Out-File -Path $acceptancePath -Encoding UTF8 -Force
    Write-Host "✅ Created ACCEPTANCE.md with MTI gate" -ForegroundColor Green
}
```

---

## Step 6: Configure Source Tagging Guidelines

### Update README.md

Add this section to every new project's README.md:

```markdown
---

## Evidence & Governance

**Tagging Source Files for Veritas Audit**

This project uses **Veritas** (Project 48) to compute trust scores (MTI) for acceptance gates.

To enable governance scoring:

1. **Tag source files** with `EVA-STORY: <id>` comments:
   ```javascript
   // EVA-STORY: F36-01-001
   export class MyHandler { }
   ```

2. **Tag test files** with implementation task IDs:
   ```javascript
   // EVA-STORY: F36-01-001-T01
   describe('MyHandler', () => { });
   ```

3. **Keep PLAN.md updated** – story IDs must match code tags exactly

4. **Run audit locally** before pushing:
   ```bash
   node ../../48-eva-veritas/src/cli.js audit --repo .
   ```

**See Also**:
- [Evidence Tagging Guide](../../07-foundation-layer/.github/copilot-skills/veritas-admin.skill.md)
- [Acceptance Criteria](ACCEPTANCE.md)
- [Project 48 Veritas](../../48-eva-veritas/README.md)
```

---

## Integration with CI/CD Workflows

### GitHub Actions Pre-Merge Hook

**File**: `.github/workflows/veritas-gate.yml`

```yaml
name: "Veritas MTI Gate"

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  veritas-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "Setup Node"
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: "Veritas: Audit repository"
        run: |
          node ../../48-eva-veritas/src/cli.js audit --repo . > .eva/audit-reports/pr-check.json

      - name: "Veritas: Extract MTI score"
        id: mti
        run: |
          MTI=$(jq -r '.mti_score' .eva/audit-reports/pr-check.json)
          echo "mti=$MTI" >> $GITHUB_OUTPUT
          echo "📊 MTI Score: $MTI"

      - name: "Veritas: Gate check (MT ≥ 70)"
        run: |
          MTI=${{ steps.mti.outputs.mti }}
          if (( $(echo "$MTI >= 70" | bc -l) )); then
            echo "✅ Gate passed: MTI $MTI ≥ 70"
            exit 0
          else
            echo "❌ Gate failed: MTI $MTI < 70"
            cat .eva/audit-reports/pr-check.json
            exit 1
          fi

      - name: "Report: Comment on PR"
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('.eva/audit-reports/pr-check.json', 'utf8'));
            const body = `## 📊 Veritas MTI Report
            - **Score**: ${report.mti_score || 'N/A'}
            - **Coverage**: ${report.coverage || 0}%
            - **Evidence**: ${report.evidence || 0}%
            - **Consistency**: ${report.consistency || 0}%
            - **Status**: ${report.status}`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

---

## Verification Checklist

When scaffolding is complete, verify:

- ✅ `.eva/` directory created
- ✅ `veritas-plan.json` generated from PLAN.md
- ✅ `.eva/.veritasignore` created
- ✅ Evidence receipt templates in place
- ✅ Audit report stub exists
- ✅ `ACCEPTANCE.md` created with MTI ≥ 70 gate
- ✅ Source tagging guidelines in project README
- ✅ CI/CD veritas-gate.yml workflow configured
- ✅ Project team trained on tagging convention

---

## Next Steps

1. **Immediate**: Add `Initialize-VeritasSetup` and `Generate-Acceptance-Gate` functions to Project 07 scaffolding tools
2. **Session 38**: Test scaffolding on next new project
3. **F07-03**: Automate gate enforcement in acceptance workflows

---

## References

- **Veritas Admin Skill**: `07-foundation-layer/.github/copilot-skills/veritas-admin.skill.md`
- **ADO Scaffolding Pattern**: `ADO-SCAFFOLDING-INTEGRATION.md`
- **Project 07 Scaffolding Tools**: `07-foundation-layer/02-design/artifact-templates/`
- **Project 48 CLI**: `48-eva-veritas/src/cli.js`

---

**Document Version**: 1.0.0 (Session 38)  
**Status**: Formalized – Ready for implementation  
**Owner**: Marco Presta / EVA Foundation Team  
**Last Updated**: 2026-03-07
