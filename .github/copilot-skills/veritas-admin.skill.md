# Skill: EVA Veritas Administration

**Scope**: Trust scoring (MTI), evidence verification, gap analysis, acceptance gating  
**Audience**: Project leads, governance admins, release managers, portfolio analysts  
**Layer**: Core (MTI gating + evidence verification powers ALL acceptance gates)

**See Also**:
- Project 48 README – Veritas engine details
- Project 37 Evidence Layer L31 – Where correlation IDs live
- Project 40 Control Plane – Evidence source (runs, artifacts)
- [ACCEPTANCE.md gate examples](ACCEPTANCE.md)

---

## Overview: The Veritas Evidence Plane

**The Problem**: Projects declare what they've done in PLAN.md but actually ship different code.

**The Solution**: Veritas cross-references declarations against reality:
```
  declared (PLAN.md)     actual (code scan)
  └─ Feature O-01        └─ src/handlers.js // EVA-STORY: O-01
  └─ Story O-01-001      └─ tests/handlers.test.js
     └─ Task O-01-001-T01
        ⏱️ MATCH → Evidence + Coverage ✅
        ❌ MISMATCH → Gap + Risk ⚠️
```

**Output**: MTI Score (0-100) that gates deployment:
```
MTI = (Coverage * 0.5) + (Evidence * 0.2) + (Consistency * 0.3)

Examples:
  80% coverage + 100% evidence + 100% consistency = MTI 80 ✅ review-approval gate
  60% coverage + 50% evidence + 80% consistency    = MTI 63 ❌ no-deploy gate
```

---

## Part 1: MTI Score & Gating Model

### MTI Formula Breakdown

| Component | Weight | Computes | Range |
|---|---|---|---|
| **Coverage** | 50% | Test code coverage % | 0-100% |
| **Evidence** | 20% | Fraction of stories with test evidence | 0-100% |
| **Consistency** | 30% | Fraction of declared stories matched by code | 0-100% |
| **Result** | 100% | (Cov*0.5) + (Ev*0.2) + (Con*0.3) | 0-100 |

### Decision Thresholds

| MTI Range | Decision | Allowed Actions | Example Scenario |
|---|---|---|---|
| **90-100** | ✅ Trusted | deploy, merge, release | Feature complete + full tests + high coverage |
| **70-89** | ⚠️ Review | test, review, merge-with-approval | Core functionality done, edge cases pending |
| **50-69** | ❌ Low Trust | review-required, no-deploy | >50% implemented, suspicious gaps |
| **0-49** | 🚫 Unsafe | block, investigate | <50% of plan covered; high risk |
| **null** | ❓ Ungoverned | add-governance | No PLAN.md; project ungoverned |

### Implementation: Gate in ACCEPTANCE.md

```markdown
# Acceptance Criteria

## Gate: MTI Trust Score

**Rule**: Project must achieve MTI ≥ 70 to merge to main.

**Verification**:
```bash
node 48-eva-veritas/src/cli.js audit --repo . > /tmp/veritas-report.json
MTI=$(jq -r '.mti_score' /tmp/veritas-report.json)
test "$MTI" -ge 70 || exit 1
```

**Pass Criteria**:
- Coverage ≥ 70%
- Evidence ≥ 80% (test annotations present)
- Consistency ≥ 90% (most stories matched to code)
- Exit code: 0

**Fail Criteria**:
- Any component < threshold
- Missing PLAN.md
- Untagged code artifacts
```

---

## Part 2: Evidence Collection & Receipts

### Evidence Receipt Pattern

Every artifact submitted to Project 40 becomes verifiable evidence.

**1. Test Results Receipt**
```json
{
  "evidence_type": "test-results",
  "correlation_id": "GH1234-PR56-abc1234def5",
  "artifact_type": "junit",
  "metadata": {
    "test_count": 156,
    "passed": 154,
    "failed": 2,
    "skipped": 0,
    "framework": "jest",
    "duration_ms": 32450
  }
}
```

**2. Coverage Receipt**
```json
{
  "evidence_type": "coverage",
  "correlation_id": "GH1234-PR56-abc1234def5",
  "artifact_type": "json",
  "metadata": {
    "lines_percent": 78.5,
    "branches_percent": 65.2,
    "functions_percent": 81.0,
    "statements_percent": 78.9,
    "generator": "nyc"
  }
}
```

**3. Security Scan Receipt**
```json
{
  "evidence_type": "sast-report",
  "correlation_id": "GH1234-PR56-abc1234def5",
  "artifact_type": "json",
  "metadata": {
    "tool": "npm-audit",
    "vulnerabilities": {
      "critical": 0,
      "high": 1,
      "medium": 3,
      "low": 5
    },
    "exit_code": 1  // Non-zero = passed audit check (found and reported vulns)
  }
}
```

**4. Build Log Receipt**
```json
{
  "evidence_type": "build-log",
  "correlation_id": "GH1234-PR56-abc1234def5",
  "artifact_type": "text",
  "metadata": {
    "size_bytes": 45678,
    "warnings": 3,
    "errors": 0,
    "compiler": "tsc",
    "exit_code": 0
  }
}
```

### Receipt Verification Workflow

```
Project 40 Artifacts
    ├─ run_id: GH1234-PR56-abc1234def5
    ├─ test-results.xml
    ├─ coverage.json
    └─ build.log
        ↓
    Project 48 audit_repo
        ├─ Step 1: Fetch artifacts from Project 40 (/runs/{id}/artifacts)
        ├─ Step 2: Validate each artifact format + metadata
        ├─ Step 3: Compute metrics (coverage %, test count, etc.)
        ├─ Step 4: Cross-reference with PLAN.md stories
        ├─ Step 5: Tag matched stories as Evidence ✅
        └─ Step 6: Generate MTI score
        ↓
    Output: veritas-report.json
        ├─ coverage: 78.5
        ├─ evidence: 85.0 (15 of 17 stories have evidence)
        ├─ consistency: 94.0 (16 of 17 declared stories matched)
        └─ mti_score: 82
```

---

## Part 3: Gap Analysis & Remediation

### Gap Types

| Gap Type | Meaning | Remediation |
|---|---|---|
| **Implementation Gap** | Story declared in PLAN.md but no code tagged with `EVA-STORY:` | Code artifact (add tag or new file) |
| **Evidence Gap** | Code exists but no test file / test is untagged | Test file with `EVA-STORY:` tag |
| **Coverage Gap** | Tests exist but coverage is low | Increase test coverage (edge cases, error paths) |
| **Consistency Gap** | Story in PLAN.md but code doesn't reference it | Update code tags or PLAN.md |

### Gap Report Example

```json
{
  "project_id": "36-red-teaming",
  "total_stories": 17,
  "matched_stories": 16,
  "coverage": {
    "lines_percent": 78.5,
    "branches_percent": 65.2
  },
  "gaps": [
    {
      "id": "RTE-01-003",
      "type": "implementation_gap",
      "declared": "Story: Implement jailbreak detector [ID=RTE-01-003]",
      "actual": "No code artifact found with EVA-STORY: RTE-01-003 tag",
      "remediation": "Create src/jailbreak-detector.ts with // EVA-STORY: RTE-01-003 tag"
    },
    {
      "id": "RTE-02-001",
      "type": "evidence_gap",
      "declared": "Story: Generate test vectors [ID=RTE-02-001]",
      "actual": "Code found in src/test-vectors.ts but no test file tagged",
      "remediation": "Create tests/test-vectors.test.ts with // EVA-STORY: RTE-02-001-T01 tag"
    }
  ]
}
```

### Two-Way Gap Detection

**Direction 1: Declared but Missing (Code Gap)**
```
PLAN.md declares: Feature F01-01: Story S01
Scan finds:      ✅ src/handlers.js tagged EVA-STORY: S01
Result:          ✅ IMPLEMENTED
```

**Direction 2: Code Exists but Undeclared (Spec Gap)**
```
PLAN.md declares: (nothing about S99)
Scan finds:      ⚠️ src/utils.js has // EVA-STORY: S99 tag
Result:          ⚠️ UNDECLARED -- update PLAN.md or remove tag
```

---

## Part 4: Evidence Tagging Convention

### Tag Format

**JavaScript / TypeScript**:
```javascript
// EVA-STORY: RTE-01-001        // Link to story
// EVA-FEATURE: RTE-01          // (optional) Link to feature
// EVA-PRIORITY: P1             // (optional)
class JailbreakDetector {
  // Implementation ...
}
```

**Python**:
```python
# EVA-STORY: RTE-01-001
# EVA-FEATURE: RTE-01
# EVA-PRIORITY: P1
class JailbreakDetector:
    pass
```

**PowerShell**:
```powershell
# EVA-STORY: RTE-01-001
# EVA-FEATURE: RTE-01
function Invoke-JailbreakDetector {
    # Implementation ...
}
```

**Markdown** (NOT tagged):
- Markdown files are the _declared_ layer (parsed by PLAN.md reader)
- Scanning them for tags would catch code examples in READMEs as false positives
- Use `.js`, `.ts`, `.py`, `.ps1` for evidence files, not `.md`

### Tag Placement Rules

✅ **Correct**:
```javascript
// EVA-STORY: RTE-01-001
function criticalHandler() { }

// EVA-STORY: RTE-01-002
function secondaryHandler() { }

// EVA-STORY: RTE-01-001
export class JailbreakDetector { }
```

❌ **Incorrect**:
```javascript
// This is a comment about EVA-STORY: RTE-01-001  ← Not at top
function handler() { }

/* EVA-STORY: RTE-01-001 */ // Can't find because multi-line comment ← Multi-line not supported
function handler() { }

// EVA-STORY: RTE-01-001 and RTE-01-002  ← Only one ID per tag
function handler() { }
```

---

## Part 5: Audit Command Walkthrough

### Basic Audit (Single Project)

```bash
# Run Veritas audit on current project
cd 36-red-teaming
node ../../48-eva-veritas/src/cli.js audit --repo .

# Output in terminal:
# ✅ Audit complete
# 📊 MTI Score:  82
# 📈 Coverage:   78.5%
# 📋 Evidence:   85.0% (17/20 stories)
# 🎯 Consistency: 94.0% (16/17 matched)
#
# [IMPL] RTE-01-001: code + tests found ✅
# [IMPL] RTE-01-002: code + tests found ✅
# [FAIL] RTE-02-001: missing_implementation ❌
# [FAIL] RTE-02-002: missing_evidence ❌
#
# 🚨 Actions: test, review, merge-with-approval (MTI 82 = review gate)
#
# Report saved to .eva/veritas-report.json
```

### Output Parsing

```bash
# Extract MTI score for use in acceptance gates
MTI=$(jq -r '.mti_score' .eva/veritas-report.json)
if (( $(echo "$MTI >= 70" | bc -l) )); then
  echo "✅ Gate passed: MTI $MTI ≥ 70"
  exit 0
else
  echo "❌ Gate failed: MTI $MTI < 70"
  exit 1
fi
```

### Audit with Plan Source Override

```bash
# If PLAN.md format is non-standard, generate normalized version first
node ../../48-eva-veritas/src/cli.js generate-plan --repo . --prefix F36

# Then audit using normalized plan
node ../../48-eva-veritas/src/cli.js audit --repo .

# Supported source formats:
#   - ## Phase N - title
#   - ## Sprint N
#   - ## Feature: title [ID=]
#   - ### Story:
#   - #### Task:
#   - - [ ] checklist items
```

---

## Part 6: Portfolio Scanning

### Scan All Projects

```bash
# Audit all 57 projects in workspace
cd C:\eva-foundry\eva-foundry
node 48-eva-veritas/src/cli.js scan-portfolio --portfolio .

# Output:
# Scanning 57 projects...
# ✅ 01-documentation-generator: MTI 76
# ✅ 02-poc-agent-skills: MTI 84
# ⚠️  03-poc-enhanced-docs: MTI 68 (review-required)
# ❌ 04-os-vnext: MTI 45 (block)
# ...
# 
# Portfolio Summary:
#   Total projects: 57
#   Healthy (≥70): 42
#   At risk (50-69): 12
#   Unsafe (<50): 3
#   Portfolio MTI: 74 (medium trust)
#
# Action: Review 15 at-risk projects; block 3 unsafe projects
```

### Portfolio Report

```json
{
  "portfolio_mti": 74,
  "timestamp": "2026-03-07T14:32:00Z",
  "projects": [
    {
      "project_id": "36-red-teaming",
      "mti_score": 82,
      "coverage": 78.5,
      "evidence": 85.0,
      "consistency": 94.0,
      "status": "proceed-with-review"
    },
    {
      "project_id": "37-data-model",
      "mti_score": 45,
      "coverage": 42.0,
      "evidence": 50.0,
      "consistency": 48.0,
      "status": "block-unsafe"
    }
  ],
  "distribution": {
    "healthy_count": 42,
    "at_risk_count": 12,
    "unsafe_count": 3
  }
}
```

---

## Part 7: ADO Integration & Export

### Export Gaps as ADO Work Items

```bash
# Generate CSV of gap stories for sprint backlog
cd 36-red-teaming
node ../../48-eva-veritas/src/cli.js generate-ado --repo . --gaps-only

# Output: .eva/ado.csv
# Format: Epic > Feature > User Story > Task
```

**Generated CSV format**:
```csv
Epic Type,Epic Title,Feature Type,Feature Title,Story Type,Story Title,Task Type,Task Title,Gap Type,Priority
Epic,36-red-teaming,Feature,RTE-02,User Story,RTE-02-001,"Implement detector pattern",,implementation_gap,P1
Epic,36-red-teaming,Feature,RTE-02,User Story,RTE-02-002,"Add test vectors",,evidence_gap,P1
```

### Import into ADO (via CLI)

```bash
# Requires Azure DevOps CLI + credentials
az boards work-item create \
  --title "Implement RTE-02-001: Detector Pattern" \
  --type "Task" \
  --description "Gap detected by Veritas audit; add EVA-STORY: RTE-02-001 tag to code" \
  --fields "System.AssignedTo=<team>" \
              "System.AreaPath=36-red-teaming" \
              "System.IterationPath=<sprint>"
```

---

## Part 8: Integration with Project 37

### Submit Audit Results to Evidence Layer L31

```bash
# After audit completes, POST correlation + gap inventory to Project 37

AUDIT_ID="audit-$(date +%s)"
REPORT=$(cat .eva/veritas-report.json | base64 -w 0)

curl -X POST https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/evidence-layer/audit-results \
  -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "audit_id": "'"${AUDIT_ID}"'",
    "project_id": "36-red-teaming",
    "mti_score": 82,
    "coverage": 78.5,
    "evidence": 85.0,
    "consistency": 94.0,
    "gap_count": 2,
    "gaps": [
      {
        "id": "RTE-02-001",
        "type": "implementation_gap",
        "remediation": "Add source file with EVA-STORY tag"
      }
    ],
    "audit_report": "'"${REPORT}"'",
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }'
```

---

## Part 9: Integration with Project 38 (ADO Command Center)

### Push Gap Stories Back to ADO

This closes the feedback loop:
```
Project 48 (Veritas) detects gaps
    ↓
Exports gap list as ADO CSV
    ↓
Project 38 (ADO Command Center) imports CSV
    ↓
Creates work items in ADO backlog
    ↓
Team prioritizes and fixes
    ↓
Next Veritas audit shows closure
```

**Workflow**:
```bash
# 1. Run audit
node 48-eva-veritas/src/cli.js audit --repo 36-red-teaming

# 2. Export gaps to ADO format
node 48-eva-veritas/src/cli.js generate-ado --repo 36-red-teaming --gaps-only

# 3. Feed result to Project 38 bulk-import
node 38-ado-poc/scripts/bulk-import-gaps.ps1 \
  --gap-csv ".eva/ado.csv" \
  --ado-org "https://dev.azure.com/your-org" \
  --project "EVA-Portfolio"

# 4. Team fixes gaps (tags code, adds tests)

# 5. Re-run audit to verify closure
node 48-eva-veritas/src/cli.js audit --repo 36-red-teaming
```

---

## Part 10: Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| **MTI score is null** | No PLAN.md found | Create PLAN.md or use `generate-plan` to auto-create from docs |
| **"0 stories matched"** | No code has EVA-STORY tags | Add comments like `// EVA-STORY: RTE-01-001` to source files |
| **Coverage not computed** | Test artifacts not found | Ensure `npm test -- --coverage` runs; save to coverage/coverage-final.json |
| **"Connection refused" to Project 37** | Token invalid or endpoint down | Verify FOUNDRY_TOKEN; check https://msub-eva-data-model... endpoint |
| **Audit hangs on large repos** | Scanning 1000s of files is slow | Add `.veritasignore` file (like .gitignore) to skip large dirs |
| **Gap marked as "undeclared"** | Code tag doesn't match any story ID | Check PLAN.md story IDs vs. code tags; they must match exactly |

---

## Best Practices

### 1. Always Tag Source Files First

```bash
# Bad workflow:
npm test && node audit  # ❌ No stories tagged yet

# Good workflow:
# 1. Add EVA-STORY tags to source files
# 2. Add EVA-STORY tags to test files
# 3. npm test
# 4. node audit
```

### 2. Use Consistent ID Format

```bash
# Choose format early and stick with it:
#   - F36-01-001 (Project 36, Feature 01, Story 001)
#   - RTE-01-001 (Red-Team-Engine, Feature 01, Story 001)
#   - S01 (Simple: Story 01)

# Once chosen, ALL stories must follow it:
PLAN.md:       Feature: O-01, Story: O-01-001          ✅
Code tags:     // EVA-STORY: O-01-001                  ✅
Test tags:     # EVA-STORY: O-01-001-T01               ✅
```

### 3. Review Gap Reports Before Merging

```bash
# Integrate into pre-merge workflow:
git pre-commit-hook:
  node 48-eva-veritas/src/cli.js audit --repo .
  MTI=$(jq -r '.mti_score' .eva/veritas-report.json)
  if (( $(echo "$MTI < 70" | bc -l) )); then
    echo "❌ MTI $MTI below 70; review gaps in .eva/veritas-report.json"
    exit 1
  fi
```

### 4. Schedule Portfolio Scans

```bash
# Weekly portfolio health check (add to cron or Azure Pipelines)
schedule:
  - cron: '0 2 * * 1'  # Monday 2 AM
  
jobs:
  portfolio-scan:
    steps:
      - name: Scan all projects
        run: |
          node 48-eva-veritas/src/cli.js scan-portfolio --portfolio C:\eva-foundry\eva-foundry > portfolio-report.json
      
      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: portfolio-health-${{ github.run_id }}
          path: portfolio-report.json
      
      - name: Alert if unsafe projects detected
        run: |
          UNSAFE=$(jq '.distribution.unsafe_count' portfolio-report.json)
          test "$UNSAFE" -eq 0 || echo "ALERT: $UNSAFE unsafe projects detected"
```

---

## Next Steps

1. **Immediate (F07-02-006-T02)**: Integrate Veritas into projects as acceptance gates
2. **Session 38**: Add MT-driven gating to new projects (F07-02-006-T03)
3. **F07-03-003**: Quality gate enforcement + Veritas scoring layer integration with Projects 37 & 48

---

## References

- **Project 48 README**: `48-eva-veritas/README.md`
- **MTI Scoring**: `48-eva-veritas/src/compute-trust.js`
- **Audit Engine**: `48-eva-veritas/src/audit-repo.js`
- **Project 37 Evidence Layer**: `37-data-model/README.md` (Layer L31)
- **Project 40 Artifacts**: `40-eva-control-plane/api/server.py` (/artifacts endpoint)
- **Portfolio Examples**: `C:\eva-foundry\portfolio-health-reports/`

---

**Skill Version**: 1.0.0 (Session 38, Core MTI gating layer)  
**Last Updated**: 2026-03-07  
**Scope**: Complete evidence verification + MTI scoring; quality gate enforcement deferred to F07-03-003
