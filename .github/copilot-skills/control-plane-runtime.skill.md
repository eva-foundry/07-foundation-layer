# Skill: Control Plane Runtime Instrumentation

**Scope**: How projects instrument evidence collection via Project 40 (EVA Control Plane)  
**Audience**: Project leads, CI/CD engineers, evidence architects  
**Layer**: Layer 1 (Instrumentation patterns only; gates/automation deferred to F07-03-003)

**See Also**:
- [CONTROL-PLANE-OWNERSHIP-BOUNDARY.md](../../CONTROL-PLANE-OWNERSHIP-BOUNDARY.md) – Architecture decision
- Project 40 README – Control Plane runtime implementation
- Project 37 Evidence Layer L31 – Correlation ID storage
- Project 48 Veritas – Trust scoring + gate enforcement (future)

---

## Overview: Two-Plane Evidence System

**Project 37 (Catalog)**: Slow-changing, authoritative definitions
```
Runbooks (RB-*)
  ├─ RB-001: PR → Build → Test → Evidence
  ├─ RB-002: Merge → Stage → Evidence
  └─ RB-003: Release → Production → Evidence
Workflows
  ├─ test-run-report
  ├─ coverage-gates
  └─ artifact-chain
Policies (e.g., "min 80% coverage")
```

**Project 40 (Runtime)**: High-write, ephemeral execution records
```
Runs (one per PR/commit/release)
  ├─ app_id: "36-red-teaming"
  ├─ status: "in-progress" | "passed" | "failed"
  ├─ correlation_id: "GH1234-PR56-abc1234def5"
  └─ created_at: 2026-03-07T14:32:00Z
Step Runs (granular steps)
  ├─ step_name: "lint"
  ├─ duration_ms: 2340
  └─ exit_code: 0
Artifacts (evidence)
  ├─ test-results.xml (captured)
  ├─ coverage.json (computed)
  ├─ build.log (streamed)
  └─ sast-report.json (uploaded)
```

---

## Integration Pattern 1: Registering a Run

### Use Case
A project's PR CI workflow (`rb-001-pr-ci-evidence.yml`) needs to start a run record.

### Pattern
```bash
#!/bin/bash
# In .github/workflows/rb-001-pr-ci-evidence.yml
set -e

# 1. Calculate correlation ID from GitHub context
RUN_ID="${{ github.run_id }}"
PR_NUM="${{ github.event.pull_request.number }}"
COMMIT_SHA="${{ github.sha }}"
SHORT_SHA="${COMMIT_SHA:0:7}"
CORRELATION_ID="GH${RUN_ID}-PR${PR_NUM}-${SHORT_SHA}"

echo "📊 Correlation ID: $CORRELATION_ID"

# 2. Register run with Project 40 runtime
RESPONSE=$(curl -s -X POST http://40-eva-control-plane:8020/runs \
  -H "Content-Type: application/json" \
  -d @- << EOF
{
  "app_id": "36-red-teaming",
  "run_name": "PR-${PR_NUM} CI (${SHORT_SHA})",
  "runbook_id": "RB-001",
  "status": "in-progress",
  "correlation_id": "${CORRELATION_ID}",
  "metadata": {
    "github_run_url": "https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}",
    "pr_number": "${PR_NUM}",
    "branch": "${{ github.ref }}"
  }
}
EOF
)

RUN_ID_RESPONSE=$(echo "$RESPONSE" | jq -r '.id')
echo "✅ Run registered: $RUN_ID_RESPONSE"
```

### Key Fields
| Field | Purpose | Example |
|---|---|---|
| `app_id` | Project identifier | `36-red-teaming` |
| `run_name` | Human-readable name | `PR-56 CI (abc1234def5)` |
| `runbook_id` | Which runbook is executing | `RB-001` |
| `status` | Current state | `in-progress` |
| `correlation_id` | Unique evidence ID (see below) | `GH1234-PR56-abc1234def5` |
| `metadata` | Context links + info | `github_run_url`, `pr_number`, `branch` |

---

## Integration Pattern 2: Submitting Artifacts

### Use Case
After running tests, capture test results, coverage, and logs as evidence.

### Pattern
```bash
#!/bin/bash
# Still in rb-001-pr-ci-evidence.yml, after tests run

# 1. Run tests and generate artifacts
npm test -- --coverage --reporters=default,junit
  # Produces: coverage/coverage-final.json, junit.xml

# 2. Upload test results artifact
TEST_ARTIFACT=$(base64 -w 0 < junit.xml)
curl -X POST http://40-eva-control-plane:8020/artifacts \
  -H "Content-Type: application/json" \
  -d '{
    "run_id": "'"${RUN_ID_RESPONSE}"'",
    "artifact_name": "test-results",
    "artifact_type": "junit",
    "content": "'"${TEST_ARTIFACT}"'",
    "metadata": {
      "test_count": 156,
      "passed": 154,
      "failed": 2
    }
  }'

# 3. Upload coverage artifact
COVERAGE=$(base64 -w 0 < coverage/coverage-final.json)
curl -X POST http://40-eva-control-plane:8020/artifacts \
  -H "Content-Type: application/json" \
  -d '{
    "run_id": "'"${RUN_ID_RESPONSE}"'",
    "artifact_name": "coverage",
    "artifact_type": "json",
    "content": "'"${COVERAGE}"'",
    "metadata": {
      "lines": 78.5,
      "branches": 65.2,
      "functions": 81.0
    }
  }'

# 4. Upload build log
BUILD_LOG=$(base64 -w 0 < build.log)
curl -X POST http://40-eva-control-plane:8020/artifacts \
  -H "Content-Type: application/json" \
  -d '{
    "run_id": "'"${RUN_ID_RESPONSE}"'",
    "artifact_name": "build-log",
    "artifact_type": "text",
    "content": "'"${BUILD_LOG}"'",
    "metadata": {
      "size_bytes": 45678,
      "warnings": 3,
      "errors": 0
    }
  }'

echo "✅ All artifacts submitted"
```

### Supported Artifact Types
| Type | Format | Use Case |
|---|---|---|
| `junit` | Base64 XML | Test results from xunit runners |
| `json` | Base64 JSON | Coverage, metrics, structured data |
| `text` | Base64 plain | Build logs, transcripts |
| `xml` | Base64 XML | SAST reports, scan results |
| `binary` | Base64 binary | Screenshots, binaries (optional) |

---

## Integration Pattern 3: Correlation ID Propagation

### Use Case
Pass evidence correlation ID through ADO work items and Project 37 so Veritas can fetch evidence later.

### Pattern A: ADO Work Item Tag
```bash
# After all evidence submitted, tag the ADO work item
# (requires ADO CLI or REST API)

WI_ID="12345"  # The linked ADO work item
TAG_VALUE="eva-evidence:${CORRELATION_ID}"

az boards work-item update \
  --id "${WI_ID}" \
  --fields "System.Tags=ci-ready;${TAG_VALUE}" \
  --org "https://dev.azure.com/your-org" \
  --project "your-project"
```

### Pattern B: Project 37 Evidence Layer L31 (REST API)
```bash
# Submit correlation ID to Project 37 Evidence Layer L31
# (for Veritas lookup, trust scoring)

curl -X POST https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/evidence-layer \
  -H "Authorization: Bearer ${FOUNDRY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "correlation_id": "'"${CORRELATION_ID}"'",
    "evidence_type": "github-pr-ci",
    "project_id": "36-red-teaming",
    "pr_number": '"${PR_NUM}"',
    "run_url": "https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}",
    "evidence_ref": "Project40:/runs/'"${RUN_ID_RESPONSE}"'",
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }'
```

### Pattern C: Add to Commit Message (for audit trail)
```bash
# At end of workflow, create a summary commit/PR comment

cat > /tmp/evidence-summary.md << EOF
## 📊 Evidence Pack Summary

**Correlation ID**: \`${CORRELATION_ID}\`

**Artifacts**:
- ✅ Test results: 154/156 passed
- ✅ Coverage: 78.5% lines, 65.2% branches
- ✅ Build log: captured

**Submitted to**:
- ✅ Project 40 runtime ($RUN_ID_RESPONSE)
- ✅ ADO work item ($WI_ID)
- ✅ Project 37 Evidence Layer

**Next**: Veritas trust scoring will process this evidence within 5 minutes.
EOF

gh pr comment ${{ github.event.pull_request.number }} -F /tmp/evidence-summary.md
```

---

## Integration Pattern 4: RB-001 Walkthrough

### Full Workflow Example: `rb-001-pr-ci-evidence.yml`

```yaml
name: "RB-001: PR → Build → Test → Evidence"

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      # ============ SETUP ============
      - uses: actions/checkout@v4
      
      - name: "setup: calculate correlation ID"
        id: corr-id
        run: |
          RUN_ID="${{ github.run_id }}"
          PR_NUM="${{ github.event.pull_request.number }}"
          COMMIT_SHA="${{ github.sha }}"
          SHORT_SHA="${COMMIT_SHA:0:7}"
          CORRELATION_ID="GH${RUN_ID}-PR${PR_NUM}-${SHORT_SHA}"
          echo "CORRELATION_ID=${CORRELATION_ID}" >> $GITHUB_OUTPUT
          echo "📊 Evidence Correlation ID: ${CORRELATION_ID}"

      # ============ REGISTER RUN ============
      - name: "evidence: register run with Project 40"
        id: register-run
        run: |
          RUN_RESPONSE=$(curl -s -X POST http://40-eva-control-plane:8020/runs \
            -H "Content-Type: application/json" \
            -d '{
              "app_id": "36-red-teaming",
              "run_name": "PR-${{ github.event.pull_request.number }} CI (${{ steps.corr-id.outputs.CORRELATION_ID }})",
              "runbook_id": "RB-001",
              "status": "in-progress",
              "correlation_id": "${{ steps.corr-id.outputs.CORRELATION_ID }}",
              "metadata": {
                "github_run_url": "https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}",
                "pr_number": ${{ github.event.pull_request.number }},
                "branch": "${{ github.ref }}"
              }
            }')
          RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.id')
          echo "RUN_ID=${RUN_ID}" >> $GITHUB_OUTPUT
          echo "✅ Run registered: ${RUN_ID}"

      # ============ BUILD ============
      - name: "build: install dependencies"
        run: npm ci

      - name: "build: lint & compile"
        run: npm run lint && npm run build

      - name: "build: capture build log"
        if: always()
        run: |
          npm run build > build.log 2>&1 || true  # Capture even on error

      # ============ TEST ============
      - name: "test: run unit tests + coverage"
        run: npm test -- --coverage --reporters=default,junit

      - name: "test: security scan (SAST)"
        run: npm audit --audit-level=moderate > sast-report.json 2>&1 || true

      # ============ SUBMIT EVIDENCE ============
      - name: "evidence: submit test results"
        if: always()
        run: |
          TEST_ARTIFACT=$(base64 -w 0 < junit.xml)
          curl -X POST http://40-eva-control-plane:8020/artifacts \
            -H "Content-Type: application/json" \
            -d '{
              "run_id": "${{ steps.register-run.outputs.RUN_ID }}",
              "artifact_name": "test-results",
              "artifact_type": "junit",
              "content": "'"${TEST_ARTIFACT}"'",
              "metadata": {
                "test_count": 156,
                "passed": 154,
                "failed": 2
              }
            }'

      - name: "evidence: submit coverage"
        if: always()
        run: |
          COVERAGE=$(base64 -w 0 < coverage/coverage-final.json)
          curl -X POST http://40-eva-control-plane:8020/artifacts \
            -H "Content-Type: application/json" \
            -d '{
              "run_id": "${{ steps.register-run.outputs.RUN_ID }}",
              "artifact_name": "coverage",
              "artifact_type": "json",
              "content": "'"${COVERAGE}"'",
              "metadata": {
                "generator": "nyc",
                "lines_percent": 78.5,
                "branches_percent": 65.2,
                "functions_percent": 81.0
              }
            }'

      - name: "evidence: submit build log"
        if: always()
        run: |
          BUILD_LOG=$(base64 -w 0 < build.log)
          curl -X POST http://40-eva-control-plane:8020/artifacts \
            -H "Content-Type: application/json" \
            -d '{
              "run_id": "${{ steps.register-run.outputs.RUN_ID }}",
              "artifact_name": "build-log",
              "artifact_type": "text",
              "content": "'"${BUILD_LOG}"'",
              "metadata": {
                "size_bytes": 45678,
                "warnings": 3,
                "errors": 0
              }
            }'

      # ============ PROPAGATE CORRELATION ID ============
      - name: "correlation: tag ADO work item"
        if: always()
        env:
          ADO_ORG: ${{ secrets.ADO_ORG }}
          ADO_PROJECT: ${{ secrets.ADO_PROJECT }}
          ADO_PAT: ${{ secrets.ADO_PAT }}
        run: |
          # Requires az CLI + Azure DevOps extension
          WI_ID="12345"  # Retrieved from PR/commit metadata
          TAG="eva-evidence:${{ steps.corr-id.outputs.CORRELATION_ID }}"
          
          az boards work-item update \
            --id "${WI_ID}" \
            --fields "System.Tags=ci-ready;${TAG}" \
            --org "https://dev.azure.com/${ADO_ORG}" \
            --project "${ADO_PROJECT}"

      - name: "correlation: post to PR comment"
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 📊 Evidence Pack\n\n**Correlation ID**: \`${{ steps.corr-id.outputs.CORRELATION_ID }}\`\n\n✅ Submitted to Project 40 runtime\n✅ Tagged ADO work item\n✅ Evidence ready for Veritas trust scoring`
            })

      # ============ FINAL STATUS ============
      - name: "evidence: mark run complete"
        if: always()
        run: |
          EXIT_CODE=$?
          STATUS=$( [ $EXIT_CODE -eq 0 ] && echo "passed" || echo "failed" )
          
          curl -X PATCH http://40-eva-control-plane:8020/runs/${{ steps.register-run.outputs.RUN_ID }} \
            -H "Content-Type: application/json" \
            -d '{
              "status": "'"${STATUS}"'",
              "exit_code": '"${EXIT_CODE}"',
              "completed_at": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
            }'
```

---

## Best Practices

### 1. Idempotency
- Always check if run already exists before registering
- Use `correlation_id` as unique key to avoid duplicate runs

```bash
EXISTING=$(curl -s "http://40-eva-control-plane:8020/runs?correlation_id=${CORRELATION_ID}")
if [ "$(echo "$EXISTING" | jq '.count')" -gt 0 ]; then
  RUN_ID=$(echo "$EXISTING" | jq -r '.runs[0].id')
  echo "⚠️  Run already exists: $RUN_ID"
else
  # Register new run
fi
```

### 2. Error Handling
```bash
# Capture Project 40 errors and retry
RETRY_COUNT=0
MAX_RETRIES=3

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://40-eva-control-plane:8020/runs \
    -H "Content-Type: application/json" \
    -d @run.json)
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | head -n -1)
  
  if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Success: $(echo "$BODY" | jq -r '.id')"
    break
  elif [ "$HTTP_CODE" = "503" ] || [ "$HTTP_CODE" = "429" ]; then
    RETRY_COUNT=$((RETRY_COUNT + 1))
    WAIT_TIME=$((2 ** RETRY_COUNT))
    echo "⚠️  Retry-able error ($HTTP_CODE), waiting ${WAIT_TIME}s..."
    sleep $WAIT_TIME
  else
    echo "❌ Unrecoverable error ($HTTP_CODE): $(echo "$BODY" | jq -r '.message')"
    exit 1
  fi
done
```

### 3. Large Artifacts
For artifacts > 5MB, stream to Project 40 instead of inline:
```bash
# DON'T: base64 large file into JSON
LARGE_FILE=$(base64 -w 0 < large-coverage.json)  # ❌ 50MB in memory

# DO: Use multipart form upload (Project 40 supports this)
curl -X POST http://40-eva-control-plane:8020/artifacts/upload \
  -F "run_id=$RUN_ID" \
  -F "artifact_name=coverage" \
  -F "artifact_type=json" \
  -F "file=@large-coverage.json"
```

### 4. Metadata Richness
Always include actionable metadata:
```json
{
  "artifact_name": "test-results",
  "artifact_type": "junit",
  "metadata": {
    "test_count": 156,
    "passed": 154,
    "failed": 2,
    "skipped": 0,
    "duration_ms": 32450,
    "framework": "jest",
    "categories": ["unit", "integration"],
    "timestamp": "2026-03-07T14:32:00Z"
  }
}
```

---

## Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| **"Connection refused" to Project 40** | Runtime not running (port 8020) | Check Project 40 deployment status; verify port forwarding if local |
| **"correlation_id conflicts"** | Re-run same PR multiple times | Use UUIDs or add timestamp: `GH${RUN_ID}-PR${PR_NUM}-${SHORT_SHA}-${EPOCH}` |
| **Artifacts not appearing in Veritas** | Correlation ID not propagated to Project 37 | Run Pattern 3B (POST to L31) after all artifacts submitted |
| **"401 Unauthorized" to Project 37** | Invalid/expired auth token | Refresh FOUNDRY_TOKEN; check token scope includes Evidence Layer |
| **Timeouts when uploading large artifacts** | Large file > 30s upload time | Use multipart upload (see Best Practice #3) |
| **Evidence appears in Project 40 but not Project 37** | Async sync delay | Wait 5-10 seconds; check Project 40 → Project 37 replication status |

---

## Next Steps

1. **Immediate (F07-02)**: Use this skill to add instrumentation patterns to your project's `.github/workflows/rb-001-pr-ci-evidence.yml`
2. **Session 38**: Deploy RB-001 workflow; submit first evidence pack
3. **F07-03-003**: Quality gate enforcement layer (Veritas integration; requires Project 48 coordination)

---

## References

- **Two-Plane Architecture**: [CONTROL-PLANE-OWNERSHIP-BOUNDARY.md](../../CONTROL-PLANE-OWNERSHIP-BOUNDARY.md)
- **Project 40 Runtime**: `40-eva-control-plane/api/server.py`
- **Project 37 Evidence Layer L31**: `37-data-model/README.md` (Layers section)
- **Project 48 Veritas**: Trust scoring + gate enforcement (future F07-03)
- **RB-001 Reference**: `40-eva-control-plane/.github/workflows/rb-001-pr-ci-evidence.yml`

---

**Skill Version**: 1.0.0 (Session 38, Layer 1 instrumentation only)  
**Last Updated**: 2026-03-07  
**Scope**: May expand to Layer 2 (gates) + Layer 3 (automation) in F07-03 phase
