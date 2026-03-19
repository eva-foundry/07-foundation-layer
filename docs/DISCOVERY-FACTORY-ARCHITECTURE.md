# Discovery Factory Architecture
## Automating Sense-Making with Cloud Agents

**Version**: 1.0.0  
**Date**: March 13, 2026  
**Status**: Reference Design (not yet implemented in workspace)

---

## Executive Summary

The **Discovery Factory** is an automated sense-making layer that runs **before, during, and after** mission execution.

Instead of humans doing discovery manually (weeks), cloud agents do it continuously (hours/days) using:

- **Parallel sensors** (logs, metrics, APIs, data models)
- **Pattern detection** (anomalies, trends, risks, opportunities)
- **Stakeholder synthesis** (interviews, surveys, consensus)
- **Intelligence preparation** (context maps, assumption registries, threat models)

**Result**: Every mission starts with evidence-grounded problem framing, not guesswork.

---

## Layer 0: Continuous Sensors (The "Brain's Senses")

```
┌──────────────────────────────────────────────────┐
│         DISCOVERY FACTORY - Layer 0              │
│                                                  │
│  Sensors Running Continuously (24/7)            │
│  └─ These feed every mission definition        │
└──────────────────────────────────────────────────┘
         ↓
    ┌────────────────────────────┐
    │ Governance Sensor          │
    │ └─ Project status, MTI     │
    │    scores, compliance      │
    └────────────────────────────┘
    ┌────────────────────────────┐
    │ Infrastructure Sensor      │
    │ └─ Costs, performance,     │
    │    resource utilization    │
    └────────────────────────────┘
    ┌────────────────────────────┐
    │ Security Sensor            │
    │ └─ Vulnerabilities,        │
    │    access anomalies        │
    └────────────────────────────┘
    ┌────────────────────────────┐
    │ Data Sensor                │
    │ └─ Quality, lineage,       │
    │    schema changes          │
    └────────────────────────────┘
    ┌────────────────────────────┐
    │ Stakeholder Sensor         │
    │ └─ Priority changes,       │
    │    feedback, satisfaction  │
    └────────────────────────────┘
         ↓
    DATA LAKE: discover/evidence.json
    (Continuously enriched, never deleted)
         ↓
    ┌──────────────────────────────────────────────┐
    │  ANALYSIS: Pattern Detection + Synthesis     │
    │  ├─ Trend analysis                          │
    │  ├─ Anomaly detection                       │
    │  ├─ Opportunity scoring                     │
    │  └─ Risk rollup                             │
    └──────────────────────────────────────────────┘
         ↓
    ┌──────────────────────────────────────────────┐
    │  OUTPUTS: Feeds Discovery → Define → Mission │
    │  ├─ context-map (updated daily)             │
    │  ├─ assumptions (with violation flags)      │
    │  ├─ risks (with exposure scores)            │
    │  ├─ opportunities (ranked by impact)        │
    │  └─ recommendations (next missions)         │
    └──────────────────────────────────────────────┘
```

---

## Concrete Example: Governance Discovery Factory

**Use case**: Discover governance compliance gaps across all 57 projects

### Sensors (24/7)

```powershell
# Governance Sensor runs automatically
Sensor-Governance.ps1:
  ├─ Query all 57 projects' PLAN.md / STATUS.md
  ├─ Run MTI audits (via Project 48 - Veritas)
  ├─ Check template versions (are they v5.0.0?)
  ├─ Scan for ACCEPTANCE gate violations
  ├─ Collect stakeholder feedback (if available)
  └─ Write evidence to discover/evidence.json
  
# Run every: 6 hours
# Output: Raw compliance metrics
```

### Analysis (Nightly)

```powershell
# Analysis runs after sensors complete
Analyze-GovernanceDiscovery.ps1:
  ├─ Aggregate 57 projects' data
  ├─ Detect patterns:
  │   ├─ Which projects have MTI < 70?
  │   ├─ How many use template v5.0.0?
  │   ├─ Which have overdue ACCEPTANCE approvals?
  │   └─ What are top 3 compliance risks?
  ├─ Compute opportunity scores:
  │   ├─ "Upgrade 12 projects to v5.0.0" = HIGH impact
  │   ├─ "Fix 8 failed quality gates" = MEDIUM impact
  │   └─ "Implement API-first governance" = HIGH/LONGTERM
  └─ Output: context-map.md, assumptions.md, risks.md, opportunities.md
```

### Discovery > Define > Mission

```
discovers/governance-compliance-20260315/:
├── context-map.md
│   └─ "12/57 projects have MTI < 70"
│      "Top blockers: old template, no API sync"
│      "Stakeholders: PM, architects, team leads"
│
├── assumptions.md
│   ├─ HIGH: "Projects want to upgrade to v5.0.0"
│   ├─ MEDIUM: "Template v5.0.0 is stable"
│   └─ MEDIUM: "Upgrade will take < 4 hours per project"
│
├── risks.md
│   ├─ "Parallelizing upgrades might cause conflicts"
│   ├─ "Stakeholders might not have time to review"
│   └─ "API might be unreachable during sync"
│
└── opportunities.md
    ├─ "Automate template migration (MCP tool)"
    ├─ "Batch API pre-flight checks"
    └─ "Create upgrade checklist for teams"

↓

docs/MISSION-GOVERNANCE-UPGRADE-20260315.md
├─ Problem: "12 projects out of compliance (MTI < 70)"
├─ Root cause: "Old governance templates + no API sync"
├─ Success criteria: "All 12 projects upgraded + MTI ≥ 70"
├─ Scope: "Limited to 12 priority projects"
├─ Dependencies: "Cloud agent, MCP tools, 4-hour window"
└─ Discovery grounding: "Signed by PM + architect"

↓ (Cloud agent mission launches)

✅ Results: All 12 upgraded, MTI improved, compliance registered
```

---

## Sensors: Core Types

### 1. Governance Sensor

**Purpose**: Monitor compliance, template versions, MTI scores

```powershell
Sensor-Governance.ps1
├─ Read PLAN.md from all 57 projects
├─ Scan for template version (v5.0.0?)
├─ Run MTI audit via eva audit_repo
├─ Check ACCEPTANCE gate status
├─ Query Data Model API for project_work layer
└─ Output: compliance-metrics.json
  ├─ project | version | mti_score | gates_passed | last_updated
  ├─ 01-doc | v4.2.0  | 62       | 3/5          | 2026-03-10
  └─ ... (57 rows)
```

### 2. Infrastructure Sensor

**Purpose**: Detect cost anomalies, performance issues, resource contention

```powershell
Sensor-Infrastructure.ps1
├─ Query Azure billing API
├─ Scan container logs for errors
├─ Check deployment success rates
├─ Identify unused resources
└─ Output: infra-metrics.json
  ├─ service | cost_daily | errors_24h | cpu_avg | status
  ├─ data-model | $42 | 0 | 15% | HEALTHY
  └─ ... (ACA, DB, etc.)
```

### 3. Security Sensor

**Purpose**: Track vulnerabilities, IAM anomalies, access patterns

```powershell
Sensor-Security.ps1
├─ Scan for exposed secrets (in public repos)
├─ Enumerate IAM permissions (compare to least-privilege)
├─ Detect failed login patterns
├─ Check dependency for known CVEs
└─ Output: security-findings.json
  ├─ finding_type | severity | affected_resource | mitigation
  ├─ exposed_secret | HIGH | 06-jp-auto-extraction | rotate immediately
  └─ ... (all findings)
```

### 4. Data Sensor

**Purpose**: Monitor data quality, schema drift, lineage breaks

```powershell
Sensor-Data.ps1
├─ Query Data Model API for schema changes
├─ Validate foreign key constraints
├─ Check for null inflation (data quality)
├─ Detect schema version mismatches
└─ Output: data-findings.json
  ├─ layer | version | fk_violations | null_pct | status
  ├─ L25   | v2.1    | 0           | 0.1%    | OK
  └─ ... (111 layers)
```

### 5. Stakeholder Sensor

**Purpose**: Capture priorities, satisfaction, emerging needs

```powershell
Sensor-Stakeholder.ps1
├─ Query ADO work item updates (priority changes)
├─ Scan GitHub issues for sentiment (frustration signals)
├─ Check PR review velocity (engagement)
├─ Run monthly pulse survey (if configured)
└─ Output: stakeholder-findings.json
  ├─ stakeholder | priority_change | satisfaction | top_concern
  ├─ Marco       | governance++    | 8/10        | "template parity"
  └─ ... (team leads, PMs, architects)
```

---

## Analysis Engine: Pattern Detection

After sensors collect data, analysis engine produces discovery outputs:

### Context Map (From Sensor Synthesis)

```markdown
# Governance Context Map (Auto-Generated)

## Primary Stakeholders
- Marco Presta (Owner) - governance priority
- 12 project leads - template adoption friction
- Platform team - API maintenance

## Key Systems
- 57 projects (target: all at v5.0.0)
- Project 37 Data Model (source of truth)
- Project 48 Veritas (MTI scoring)
- Project 07 Foundation (templates)

## System Relationships
```
Project 07 (Templates) ──→ 57 Projects (adoption)
                        └─→ Compliance gaps (12 projects MTI<70)
                        └─→ Data Model (governance source of truth)
```

## Known Constraints
- 6-hour upgrade window per project
- Must maintain backward compatibility
- API must be available 99.9%
- Stakeholder review required for v5.x changes
```

### Assumption Registry (From Sensor Validation)

```markdown
# Governance Assumptions Registry

## HIGH Confidence (90%+ factual)
- v5.0.0 template exists and is stable ✅ (verified via repo)
- 12 projects currently < compliance ✅ (MTI audit confirms)
- API endpoint is operational ✅ (health check passes)

## MEDIUM Confidence (60-89% likely)
- Projects can upgrade in 4 hours (assumption: based on Project 51 baseline)
- Stakeholders will prioritize template adoption (assumption: based on survey feedback)
- No hidden security debt blocking upgrades (assumption: security sensor shows OK, but not deeply scanned)

## LOW Confidence (< 60% certain)
- Blue-green deployment will work for all 12 projects (assumption: not tested at scale)
- Parallel upgrades won't cause API contention (assumption: no load test done)

## Risk Exposure Per Assumption
If "Projects can upgrade in 4h" is WRONG:
  → Cost: 8h lost per project × 12 = 96 hours = HIGH
  → Mitigation: Run pilot on 2 projects first

If "Stakeholders will prioritize" is WRONG:
  → Cost: Mission delays (schedule slip)
  → Mitigation: Get executive sponsorship before launch
```

### Risk Register (From Sensor + Expert Analysis)

```markdown
# Governance Mission Risks

## HIGH Severity
1. **API Becomes Unavailable During Sync**
   - Impact: Mission fails (no governance persistence)
   - Probability: 5% (based on 99.9% SLA, 4-hour window)
   - Mitigation: Health check pre/post, circuit breaker, rollback plan

2. **Template v5.0.0 Has Breaking Change We Didn't Catch**
   - Impact: Adopted template fails downstream tools
   - Probability: 10% (new template, limited testing)
   - Mitigation: Upgrade pilot first (2 projects), monitor for 48h before full rollout

## MEDIUM Severity
3. **Stakeholder Review Bottleneck Blocks Mission**
   - Impact: Compliance deadline missed
   - Probability: 30% (stakeholder availability risk)
   - Mitigation: Async approval via GitHub PR review, 24h max SLA

4. **Dependency Conflict: Project X Uses Custom Template**
   - Impact: Upgrade fails for 1-2 projects
   - Probability: 20% (some customization likely)
   - Mitigation: Pre-flight audit discovers custom templates, plan workaround

## LOW Severity
5. **Logging Becomes Verbose, Clutters Evidence**
   - Impact: Archive size grows (not serious)
   - Probability: 50% (technical debt, not critical)
   - Mitigation: Log compression, archive cleanup
```

### Opportunity Registry (From Trend Analysis)

```markdown
# Governance Opportunities (Ranked by Impact × Effort)

## HIGH Impact / LOW Effort
- **Automate template migration** (discovery → proposal for new MCP tool)
  Impact: Reduce manual effort from 48h to 4h (12× improvement)
  Effort: 8h dev + 4h testing
  ROI: 10×

- **Pre-flight API check in mission template**
  Impact: Prevent 90% of mid-mission failures
  Effort: 2h
  ROI: High (reliability++

- **Batch governance audits**
  Impact: Run all 57 project audits in 1h vs 48h
  Effort: 4h to parallelize eva audit_repo
  ROI: 12×

## MEDIUM Impact / MEDIUM Effort
- **Implement continuous compliance dashboard**
  Impact: Catch drift before it becomes a crisis
  Effort: 16h to build
  ROI: 4× (prevention value vs crisis response)

## Strategic (HIGH Impact / HIGH Effort)
- **Implement API-first governance across all 57 projects**
  Impact: Full paperless DPDCA (eliminates doc sync)
  Effort: 40h (cross-project coordination needed)
  ROI: 3× (ongoing, reduces governance toil)
```

---

## Implementation: 4 Steps to Activate Discovery Factory

### Step 1: Deploy Sensors (Week 1)

```powershell
# Create sensor scripts
mkdir -p sensors/
cp Sensor-Governance.ps1 sensors/
cp Sensor-Infrastructure.ps1 sensors/
cp Sensor-Security.ps1 sensors/
# ... etc

# Schedule with Windows Task Scheduler (or cron)
New-ScheduledTask -TaskName "DiscoveryFactory-Governance" -Trigger (New-ScheduledTaskTrigger -Every 6 -Period Hours) -Action (New-ScheduledTaskAction -Script "Sensor-Governance.ps1")
```

### Step 2: Create Analysis Engine (Week 1)

```powershell
# Create analysis script
Analyze-DiscoveryFactory.ps1:
  ├─ Read all sensor outputs (evidence.json)
  ├─ Run pattern detection (trends, anomalies, opportunities)
  ├─ Generate discovery outputs (context-map, assumptions, risks, opportunities)
  └─ Post recommendations to Slack / Teams for human review
```

### Step 3: Integrate with Mission Builder (Week 2)

```powershell
# Mission template now includes:
# - discovery/ folder auto-created with latest sensor data
# - Approval gate automatically checks discovery grounding
# - Pre-flight checklist includes "verify discovery data < 24h old"
```

### Step 4: Monitor & Iterate (Ongoing)

```
Monthly Health Check:
  ☐ Are sensors catching the right signals? (reduce noise)
  ☐ Is analysis producing actionable opportunities? (rank by impact)
  ☐ Are missions better grounded because of discovery data? (survey)
  ☐ ROI positive? (time saved from better problem targeting)
```

---

## Comparison: Manual vs Automated Discovery

| Step | Manual (Today) | Automated (Factory) | Time Saved |
|------|---|---|---|
| **Environment scan** | 4-8 hours (meetings) | Automated daily (sensors) | 4h/mission |
| **Data collection** | 2-4 hours (queries, scripts) | Automated API calls | 2h/mission |
| **Interview stakeholders** | 2-4 hours (scheduling headache) | Async survey + sentiment analysis | 1.5h/mission |
| **Analyze patterns** | 2-3 hours (manual) | Agent-powered (minutes) | 2h/mission |
| **Write discovery outputs** | 3-4 hours (docs) | Auto-generated + templated | 3h/mission |
| **Approval** | 1-2 hours | Dashboard, automated gate | 1h/mission |
| **Total per mission** | **14-29 hours** | **1-2 hours** | **12-27 hours (87% reduction)** |

**Cost impact**: 
- Manual: 14-29h of PM/architect time per mission → ~$1,000-$2,000 sunk cost
- Automated: 1-2h to review + approve → ~$150-$200 sunk cost
- ROI: 5-10× on typical mission cadence (2-3 missions/month = $18k-$36k/year savings)

---

## Reference Architectures: Domain Examples

### FinOps Discovery Factory

```
Sensors:
  ├─ Billing API (Azure Cost Management)
  ├─ Infrastructure telemetry (VM, storage, network)
  ├─ Workload profiler (identify unused resources)
  └─ Stakeholder feedback (engineering team priorities)

Analysis:
  ├─ Anomaly detection: spot cost spikes
  ├─ Trend analysis: identify growth patterns
  ├─ Opportunity scoring: "Switch to reserved instances" = $50k/year savings
  └─ Risk profile: "Shutdown that workload?" vs "We might need it"

Output: Governance discovery grounds cost optimization missions
```

### Security Discovery Factory

```
Sensors:
  ├─ Vulnerability scanner (NVD + GitHub Security Advisories)
  ├─ IAM auditor (check least-privilege violations)
  ├─ Secret detector (scan repos for exposed keys)
  ├─ Network mapper (enumerate services, firewall rules)
  └─ Incident response logs (what happened? why?)

Analysis:
  ├─ Risk roll-up: which services pose highest risk?
  ├─ Blast radius: if compromised, what spreads?
  ├─ Dependency chains: which vulnerabilities matter most?
  └─ Opportunity: "Update framework" vs "Refactor authentication"

Output: Security missions launched with prioritized threat model
```

### Data Quality Discovery Factory

```
Sensors:
  ├─ Schema monitor (version tracking)
  ├─ Quality profiler (null %, duplicates, outliers)
  ├─ Lineage tracker (source → transform → sink)
  ├─ Performance monitor (query latency, throughput)
  └─ User feedback (data consumers flag issues)

Analysis:
  ├─ Drift detection: "Schema changed without coordination"
  ├─ Quality trends: "Null % increasing? Why?"
  ├─ Root cause analysis: "Source API is flaky?"
  └─ Opportunity: "Consolidate duplicate tables" = 40% storage reduction

Output: Data missions backed by quality + lineage evidence
```

---

## Keys to Success

✅ **Sensors run continuously** — not just when a mission starts  
✅ **Analysis automates pattern detection** — agents do it, not humans  
✅ **Outputs feed mission definition** — discover → define → execute  
✅ **Low false positive rate** — tune patterns to context, not noise  
✅ **Feedback loop respected** — re-discover after each mission  
✅ **Evidence preserved** — discover/ folder is immutable audit trail  

---

## Next Steps (To Implement)

1. **Queue**: Prototype Governance Sensor (Week of March 17)
2. **Queue**: Implement Analysis Engine (Week of March 24)
3. **Test**: Run 2 governance missions with discovery data (April)
4. **Evaluate**: Measure time savings + mission success improvement (April)
5. **Scale**: Deploy to other domains (FinOps, Security, Data) (May+)

---

## See Also

- [PROJECT-CLOUD-AGENT-MISSION-TEMPLATE.md](../templates/PROJECT-CLOUD-AGENT-MISSION-TEMPLATE.md) — Mission lifecycle (now includes Discover phase)
- [DPDCA Operating Model](../standards-specification.md) — Core methodology
- [Project 48 (Veritas) - MTI Scoring](../../48-eva-veritas/) — Evidence source
- [Project 37 (Data Model) - API Documentation](../../37-data-model/docs/) — Data source

---

**Discovery Factory Status**: Reference design complete. Ready for pilot implementation with Governance domain.

