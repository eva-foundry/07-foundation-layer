# Cloud Agent Mission Pattern - Foundation Layer Template
## For Workspace-Wide Reuse in Project Priming

**Location**: `07-foundation-layer/templates/CLOUD-AGENT-MISSION-TEMPLATE.md`  
**Version**: 1.0.0 (Session 45 Edition)  
**Status**: Production-ready, workspace-wide standard  
**Use Case**: Any project that needs autonomous cloud agent execution

---

## Quick Summary

This template enables **any project** to:
1. ✅ Plan autonomous cloud agent missions (Fractal DPDCA)
2. ✅ Launch with pre-flight gates (16-point checklist)
3. ✅ Capture immutable evidence (session logs, tool calls)
4. ✅ Validate with quality gates (5 mandatory)
5. ✅ Attest completion (sign-off + archive)

**Pattern applies to**:
- Documentation missions (governance, runbooks, API specs)
- Refactoring missions (code modernization, security hardening)
- Feature missions (new APIs, UI components, data pipelines)
- Governance missions (compliance audits, policy implementations)
- Multi-project missions (workspace-wide updates, ecosystem changes)

**Success Rate**: 95%+ (when pre-flight checks + quality gates enforced)  
**Average Duration**: 6-16 hours autonomous execution  
**Evidence Captured**: Immutable audit trail (session log + tool calls + attestation)

---

## Step 0: Discovery Phase (NEW - Critical)

**Purpose**: Answer "What is really going on?" BEFORE defining the mission.

Create directories and discovery brief:

```powershell
# Create discovery workspace
mkdir -p discover/evidence
echo "[DISCOVER] Starting environmental sense phase..." > discover/discovery-brief.md
```

Discovery brief structure (`discover/discovery-brief.md`):

```markdown
# Discovery Brief: {Problem Domain}

## 1. Situational Awareness
- Environment scan: [What's the current state?]
- System boundaries: [What's IN scope? OUT of scope?]
- Key constraints: [What limits our options?]
- Context: [Why now?]

## 2. Evidence Collection
- Data available: [Logs, metrics, APIs we can query]
- Interviews/observations: [What stakeholders said]
- Findings: [Key facts discovered]

## 3. Pattern Detection
- Trends: [What's changing?]
- Anomalies: [What's wrong?]
- Clusters (Pareto): [The 20% causing 80% of problems]
- Opportunities: [What could improve?]

## 4. Risk Identification
- Assumptions we're making: [What if we're wrong?]
- Blind spots: [Unknown unknowns]
- Dependencies: [What could break?]
- Threats: [External risks]

## 5. Discovery Outputs (Feed into Mission Definition)
- [ ] context-map.md (stakeholders, systems, relationships)
- [ ] assumptions.md (all assumptions with confidence levels)
- [ ] risks.md (threat model, failure modes)
- [ ] opportunities.md (improvement areas, constraints removed)
- [ ] evidence.json (raw discovery data)

## Success Criteria for Discover Phase
The Discover phase is COMPLETE when:
- All 5 outputs created ✅
- Evidence collected from ≥3 sources
- Stakeholder agreement on problem framing
- Blind spots identified (not all solved, but named)
- Assumptions documented (≥1 per discovery output)
```

**Key insight**: Discovery outputs (context-map, assumptions, risks, opportunities) become **mandatory inputs** to Mission Definition. No mission briefing without discovery.

---

## Step 1: Create Mission Brief (Based on Discovery)

Create file: `docs/MISSION-{NAME}-{DATE}.md`

```markdown
# Cloud Agent Mission: {Mission Name}

## Discovery Grounding
- Context: [From discover/context-map.md - 1 paragraph]
- Problem: [From discover/ outputs - Why this matters]
- Assumptions verified: [List ≥3 from assumptions.md that we've validated]
- Risks mitigated: [List ≥1 from risks.md that we're addressing]

## Mission Statement
[One sentence - what the agent must deliver, grounded in discovery]

## Success Criteria (ACCEPT/REJECT)
- [ ] Criterion 1 (objective, measurable, tied to discovery finding)
- [ ] Criterion 2 (objective, measurable, tied to discovery finding)
- [ ] Criterion 3 (objective, measurable, tied to discovery finding)

## Scope Boundaries
- IN: [What this mission includes]
- OUT: [What this mission explicitly does NOT include]
- Assumptions: [≥2 assumptions this mission DEPENDS on]

## Deliverables
- Primary: [Main output]
- Secondary: [Supporting artifacts]
- Evidence: [Logs, metrics, audit trail]

## Constraints
- Time: [Max duration]
- Resources: [Tools, APIs, MCP servers]
- Quality: [Standards, no errors]
- Security: [No secrets, no external APIs]

## Risk Assessment
- [ ] Automation risk: LOW/MEDIUM/HIGH (mitigations)
- [ ] Data risk: LOW/MEDIUM/HIGH (mitigations)
- [ ] Integration risk: LOW/MEDIUM/HIGH (mitigations)

## Approval Gate
- [ ] Mission owner approval (name, date)
- [ ] Risk review approved (name, date)
- [ ] Resources confirmed (name, date)
- [ ] Discovery grounding validated (name, date) ← NEW: Verify discovery was done

[MISSION PASSES PRE-FLIGHT ONLY IF ALL GATES APPROVED + DISCOVERY GROUNDING SIGNED OFF]
```

---

## Step 1.5: Pre-Flight Checklist

**Copy this checklist. Verify all 18 items before launching.** (Expanded from 16 to include Discovery verification)

```
[PRE-FLIGHT CHECKLIST - 18 Items]

Discovery Phase (NEW):
  ☐ Discover phase completed: discover/discovery-brief.md exists
  ☐ All 5 discovery outputs created:
    ☐ context-map.md
    ☐ assumptions.md (with confidence levels)
    ☐ risks.md (threat model, failure modes)
    ☐ opportunities.md (improvement areas)
    ☐ evidence.json (raw discovery data)
  ☐ Problem statement GROUNDED in discovery findings
  ☐ Stakeholder agreement on problem framing (≥2 stakeholder sign-offs)
  ☐ Blind spots and unknowns documented (admit what we don't know)

Repository State:
  ☐ Git: clean (no uncommitted changes)
  ☐ Git: main branch up-to-date (git fetch)
  ☐ Git: no merge conflicts in-flight
  ☐ Caller: has push permissions

Mission Definition:
  ☐ MISSION-{NAME}-{DATE}.md exists in docs/
  ☐ Success criteria defined (≥3, tied to discovery findings)
  ☐ Scope boundaries documented
  ☐ Risk assessment completed + mitigations tied to discover/risks.md
  ☐ All approval gates signed (including Discovery grounding)

Cloud Agent Readiness:
  ☐ GitHub Copilot Pro+/Enterprise plan active
  ☐ eva-foundry repo has Copilot coding agent enabled
  ☐ VS Code with latest GitHub Copilot extension
  ☐ MCP servers configured (if required)
  ☐ Network connection stable

Context Available:
  ☐ Mission brief in docs/ folder
  ☐ Discovery outputs in discover/ folder
  ☐ Reference docs present (not in .gitignore)
  ☐ Task prompt < 4000 tokens
  ☐ All links (internal & external) validated

[PASS: All 18 ✓ → Proceed to launch]
[FAIL: Any item unchecked → Fix, then recheck]
[FAIL: Discovery not done → Return to Step 0, complete discovery first]
```

---

## Step 2: Create Task Prompt

**Create focused task prompt (< 4000 tokens)**. Template structure:

```
[COPY TO CLOUD AGENT CHAT IN VS CODE]

Mission: {Name}

Context:
  ├─ Workspace: https://github.com/MarcoPresta/eva-foundry
  ├─ Reference docs: {list file paths}
  └─ APIs available: {list endpoints}

Phases & Tasks (Execute in order):

PHASE 1: {Name}
  TASK 1.1: {Name}
    Input: [What data/files needed]
    Action: [What agent must do]
    Output: [Expected deliverable]
    Verification: [How to check success]

  TASK 1.2: {Name}
    [Same structure]

[Continue for all phases]

Quality Gates (MUST PASS):
  1. Code syntax (0 linting errors)
  2. Tests & validation (all acceptance criteria satisfied)
  3. Documentation (no placeholder text)
  4. Audit trail (session log + tool calls captured)
  5. Security (no secrets, no unapproved dependencies)

Success = All phases complete + All 5 quality gates pass
```

---

## Step 3: Launch Cloud Agent

**In VS Code**:

```
1. Press Ctrl+Shift+I (GitHub Copilot Chat)
2. Click "New Chat" → "Cloud" session type
3. Select "GitHub Copilot Coding Agent"
4. Paste complete task prompt (from Step 3)
5. Press Enter to launch
6. Watch session log in VS Code (left panel, real-time)
```

**Mission starts immediately. Agent begins work autonomously.**

---

## Step 4: Monitor Execution (Real-Time)

**Cloud agent session produces**:

```
Session Log (VS Code Chat):
├─ [START] Agent acknowledges task
├─ [CONTEXT] Agent summarizes understanding
├─ [PHASE 1] Agent begins work
│   ├─ [READ] Reading reference files
│   ├─ [QUERY] Querying APIs/MCP tools
│   ├─ [WRITE] Creating/updating files
│   ├─ [VERIFY] Validating output
│   └─ [COMPLETE] Phase 1 done
├─ [PHASE 2-N] Continue for each phase
├─ [VALIDATION] Agent runs quality gates
├─ [GIT] Agent commits to feature branch
├─ [PR] Agent creates pull request
└─ [COMPLETE] Session done, visit GitHub.com for PR
```

**Steering commands (if needed)**:
```
/steer "Focus on PHASE 1 first. Use REFERENCE-DOC as source of truth."

Agent acknowledges, adjusts course, continues.
Uses 1 premium request per steering message.
```

---

## Step 5: Automatic Evidence Collection

Agent auto-captures to `.eva/missions/{mission-id}/`:

```
.eva/missions/{mission-id}/
├── mission-brief.md (copy of docs/MISSION-{NAME}-{DATE}.md)
├── pre-flight-checklist.json
├── execution/
│   ├── session-log.json (agent actions + timing)
│   └── tool-calls.jsonl (every tool call: timestamp, args, result)
├── validation/
│   ├── acceptance-criteria-check.json (each criterion: PASS/FAIL)
│   └── quality-gates-check.json (5 gates: all must PASS)
└── attestation/
    ├── mission-completion-{timestamp}.json
    └── mission-sign-off.md (human reviewer approval)
```

---

## Step 6: Review & Validate (When Agent Completes)

**On GitHub.com**:

1. Navigate to eva-foundry repo
2. Click "Pull Requests" tab
3. Find PR titled "feat: {Mission Name}..."
4. Review files changed (git diff)
5. Verify acceptance criteria:
   - [ ] Criterion 1: {Check}
   - [ ] Criterion 2: {Check}
   - [ ] Criterion 3: {Check}
   - [... etc ...]

**Validate quality gates**:
   - [ ] Code syntax: 0 linting errors
   - [ ] Tests & validation: All acceptance criteria satisfied
   - [ ] Documentation: No placeholder text ({TODO}, FIXME)
   - [ ] Audit trail: Evidence complete (.eva/missions/)
   - [ ] Security: No secrets in output

**If all pass**: Approve PR + merge  
**If any fail**: Request changes (agent adjusts, re-runs validation)

---

## Step 7: Merge PR

```bash
# Option A: In GitHub UI
1. Click "Approve" (review section)
2. Click "Squash and merge" 
3. Confirm message
4. Done

# Option B: In terminal
git checkout feature/{mission-name}
git push -u origin HEAD
gh pr create --fill
```

**Result**: Mission is complete, evidence archived, and submitted through the pull-request flow.

---

## Step 8: Archive Evidence

```powershell
# Verify all evidence files present
$missionId = "{mission-id}"
$archivePath = ".eva/missions/$missionId"

# Create permanent archive (for audit trail retention)
Compress-Archive -Path $archivePath `
  -DestinationPath "$archivePath/../$missionId-evidence.zip"

Write-Host "[COMPLETE] Mission archived to: $missionId-evidence.zip"
```

---

## Architecture: D³PDCA Operating Model (NEW)

This template implements **D³PDCA** — a three-phase precursor + five-phase execution cycle:

```
┌─────────────────────────────────────────────────────────────┐
│           LAYER 0: CONTINUOUS SENSING                       │
│  (Re-Discovery runs parallel to entire system)              │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: DISCOVER (Step 0)                                 │
│  Question: "What is really going on?"                       │
│  Output: context-map, assumptions, risks, opportunities    │
│  NOT: solving the problem yet                              │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2: DEFINE (Steps 1-1.5)                              │
│  Question: "What should we do about it?"                    │
│  Input: Discovery outputs                                   │
│  Output: Mission brief + grounded success criteria          │
│  Validates: Problem framing, scope, stakeholder agreement   │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3-7: EXECUTE (PDCA)                                  │
│  Step 2: PLAN (agent designs solution)                      │
│  Step 3-4: DO (agent executes, monitors)                    │
│  Step 5-6: CHECK (validate outcomes)                        │
│  Step 7-8: ACT (integrate, archive)                         │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  FEEDBACK LOOP: RE-DISCOVER                                 │
│  After cycle complete: sense new reality, detect changes    │
│  If conditions changed → trigger new mission                │
│  If mission didn't work → increase discovery investment     │
└─────────────────────────────────────────────────────────────┘
```

**Key insight**: Without Discover, agents optimize the wrong thing faster. With it at every level, they stay grounded.

### Why D³PDCA, not DPDCA?

**Old model (DPDCA)**: Assumes the problem is known → Start executing

**New model (D³PDCA)**: 
- Discover first: Is the problem what we think?
- Define second: Are we solving the right thing?
- Then execute PDCA: Now go build

**In practice**:
- 20% of missions fail due to bad problem framing → Discover phase prevents this
- 80% of optimization goes to wrong targets → Discovery grounds targets in reality
- Stakeholders change their minds → Continuous re-discovery catches it

### Discover Phase: What Actually Gets Collected

```
discover/
├── discovery-brief.md
│   ├── Situational Awareness (environment, boundaries, constraints)
│   ├── Evidence Collection (logs, interviews, observations)
│   ├── Pattern Detection (trends, anomalies, opportunities)
│   ├── Risk Identification (threats, assumptions, blind spots)
│   └── Success criteria: All 5 outputs completed
│
├── context-map.md
│   ├── Stakeholders (who cares? who decides? who blocks?)
│   ├── Systems (what systems are involved?)
│   ├── Relationships (how do they interact?)
│   └── Constraints (what limits our options?)
│
├── assumptions.md
│   ├── Assumption 1 | Confidence: HIGH/MEDIUM/LOW | Risk: If wrong, then...
│   ├── Assumption 2 | Confidence: HIGH/MEDIUM/LOW | Risk: If wrong, then...
│   └── ... (all assumptions documented with risk exposure)
│
├── risks.md
│   ├── Threat 1: [Description] | Mitigation: [Strategy]
│   ├── Threat 2: [Description] | Mitigation: [Strategy]
│   ├── Failure modes: [What could go wrong?]
│   └── Dependencies: [What must stay stable?]
│
├── opportunities.md
│   ├── Opportunity 1: [Quick win] | Effort: LOW/MEDIUM/HIGH
│   ├── Opportunity 2: [Strategic] | Effort: LOW/MEDIUM/HIGH
│   └── Constraints to remove: [What's holding us back?]
│
└── evidence.json
    ├── Raw discovery data (queries, sensor output, survey responses)
    ├── Timestamp
    ├── Data provenance (where did it come from?)
    └── Confidence level (how sure are we?)
```

**Quality bar for Discover completion**:
- ✅ 5 outputs created and documented
- ✅ Evidence from ≥3 independent sources
- ✅ Stakeholder agreement on problem framing (≥2 sign-offs)
- ✅ All assumptions surfaced + confidence levels assigned
- ✅ Top 3-5 risks explicitly identified + mitigation strategies drafted

---

## Reference: 5 Mission Types

Use appropriate template for your mission type:

### TYPE A: Documentation Missions
- **Examples**: Governance docs, API specs, runbooks, tutorials
- **Duration**: 3-8 hours
- **Phases**: 4-6
- **Quality gate**: Content accuracy + linting

### TYPE B: Refactoring Missions
- **Examples**: Code modernization, security hardening, performance optimization
- **Duration**: 8-16 hours
- **Phases**: 6-10
- **Quality gate**: All tests pass + no regressions

### TYPE C: Feature Missions
- **Examples**: New APIs, UI components, data pipelines
- **Duration**: 16-40 hours
- **Phases**: 8-15
- **Quality gate**: Feature acceptance + integration tests

### TYPE D: Governance Missions
- **Examples**: Compliance audits, policy implementations, certification prep
- **Duration**: 6-12 hours
- **Phases**: 5-8
- **Quality gate**: Policy adherence + audit trail ← **19-ai-gov is TYPE D**

### TYPE E: Multi-Project Missions
- **Examples**: Workspace-wide refactoring, ecosystem updates
- **Duration**: 20-48 hours
- **Phases**: 10-20
- **Quality gate**: Dependency verification + integration tests

---

## Checklist: Before You Launch

Use this every time:

```
☐ Pre-flight: All 16 items checked
☐ Mission brief: docs/MISSION-{NAME}-{DATE}.md created
☐ Task prompt: < 4000 tokens, copy-paste ready
☐ VS Code: Open, eva-foundry workspace active
☐ GitHub Copilot: Chat ready (Ctrl+Shift+I)
☐ Cloud agent: Selected (GitHub Copilot Coding Agent)
☐ Git: Clean state (no uncommitted changes)
☐ Approvals: Mission owner + risk review + resources confirmed

→ READY TO LAUNCH
```

---

## Checklist: After Mission Completes

Use this for validation:

```
☐ Session log: Captured to .eva/missions/{mission}/
☐ Tool calls: All tool calls logged (jsonl format)
☐ Acceptance criteria: 8/8 passed (or your count)
☐ Quality gates: 5/5 passed (syntax, tests, docs, audit, security)
☐ Manual review: Human spot-checked 3+ sections for accuracy
☐ Evidence: SHA-256 hashes of all outputs computed
☐ No secrets: Scanned output for API keys, tokens
☐ PR created: Ready at GitHub.com/eva-foundry/pulls
☐ Documentation: All files have headers + cross-refs work

→ READY TO MERGE
```

---

## Anti-Patterns (What NOT to Do)

| Mistake | Problem | Solution |
|---------|---------|----------|
| No pre-flight check | Agent fails mid-task | ☑️ All 16 items verified |
| Scope too large | Agent loses focus | Break into 3-7 phases max |
| No success criteria | Can't verify completion | Define ≥3 objective criteria |
| Prompt too long | Agent runs out of context | Keep prompt < 4000 tokens |
| No quality gates | Merge broken code | Enforce all 5 gates |
| Manual evidence collection | Audit trail incomplete | Use auto-capture (.eva/) |
| No steering capability | Can't correct mid-execution | Save session, use /steer |
| Merge without review | Bypass human judgment | Always require sign-off |

---

## Success Metrics (Track Over Time)

Per mission:
- Success rate: % acceptance criteria met (target ≥ 95%)
- Cycle time: Wall-clock hours (target: match estimate)
- Quality gate pass rate: % missions passing all 5 (target ≥ 95%)
- Steering count: How many human corrections needed (target: 0-1)
- Rework count: Iterations required (target: 0)
- Evidence completeness: % of logs captured (target: 100%)

---

## Quarterly Health Check

Every 3 months, review:

```
1. Success Rate
   Target: ≥ 95% missions pass all criteria
   Current: [X%]
   Action if < 95%: Improve template / controls

2. Cycle Time
   Target: Match or beat estimate
   Current: [Average X hours]
   Action if trending up: Update time estimates

3. Quality Gates
   Target: ≥ 95% missions pass all 5 gates
   Current: [X%]
   Action if < 95%: Strengthen weakest gate

4. Pattern Reuse
   Target: ≥ 70% new missions use templates
   Current: [X%]
   Action if < 70%: Create missing templates

5. Cost Efficiency
   Target: < $50 per mission
   Current: [Average $X]
   Action if trending up: Optimize prompt/complexity
```

---

## Step 9: Re-Discovery (Continuous Sensing)

**After mission completes**, automatic sensors should detect:

```
Re-DISCOVER Questions:
  ☐ Did reality change while we executed?
  ☐ Were any assumptions violated?
  ☐ Did new risks emerge?
  ☐ Are stakeholders satisfied?
  ☐ What changed in the environment?
  ☐ What should the next mission be?
```

**Trigger next mission if**:
- ✅ Environment changed (re-run discovery)
- ✅ Assumptions proved wrong (update discovery)
- ✅ New risks emerged (add to risk register)
- ✅ Opportunities became visible (queue new mission)
- ✅ Stakeholder priorities shifted (re-define next mission)

**This is the feedback loop** that keeps system adaptive.

---

## Compare: DPDCA vs D³PDCA

| Aspect | Old DPDCA | New D³PDCA |
|--------|-----------|-----------|
| **First phase** | Plan (assume problem known) | Discover (sense reality) |
| **Problem grounding** | None explicit | Stakeholder + evidence based |
| **Risk management** | Reactive (find during execution) | Proactive (identify during discovery) |
| **Approval gates** | Mission owner + risk review | + Discovery grounding sign-off |
| **Feedback** | End of cycle | Continuous (parallel sensors) |
| **When to pivot** | After failure found | During re-discovery phase |
| **Stakeholder engagement** | Define and execute | Discover, Define, re-Discover |

**Result**: Fewer failed missions, better problem targeting, adaptive learning baked in.

---

## Integration with Project Priming

**When a new project is primed** (using `Invoke-PrimeWorkspace.ps1`):

```
✅ Copy this template to docs/
✅ Create .eva/missions/ directory structure
✅ Add pre-flight checklist to .github/
✅ Register cloud agent pattern in copilot-instructions.md
✅ Create mission log (.eva/missions/MISSIONS.md)
```

**Result**: Every primed project knows how to:
- Plan autonomous cloud agent missions
- Execute with Fractal DPDCA discipline
- Capture immutable evidence
- Validate with quality gates
- Archive attestations

---

## Example: Launching Your First Mission

```
Step 1: Create docs/MISSION-EXAMPLE-20260313.md
Step 2: Run pre-flight checklist (16 items ✓)
Step 3: Write task prompt (< 4000 tokens)
Step 4: Open VS Code, Ctrl+Shift+I
Step 5: Select Cloud → GitHub Copilot Coding Agent
Step 6: Paste prompt, press Enter
Step 7: Watch session log (6-16 hours depending on mission type)
Step 8: Review PR on GitHub.com
Step 9: Validate acceptance criteria (all pass?)
Step 10: Validate quality gates (all 5 pass?)
Step 11: Approve & merge PR
Step 12: Archive evidence

Total time to launch: < 10 min
Total time to complete: 6-16 hours (autonomous)
Total time to review & merge: < 30 min

Result: Production-ready, audit-complete mission ✅
```

---

## Maintenance & Support

**Pattern Version**: 1.0.0  
**Last Updated**: March 13, 2026  
**Owner**: EVA Factory Governance  
**Support**: Refer to `.github/patterns/CLOUD-AGENT-MISSION-PATTERN.md` for detailed reference  
**Next Review**: June 13, 2026 (quarterly health check)

**For updates or issues**:
- File issue in eva-foundry/issues
- Tag: `cloud-agent-mission-pattern`
- Include: Mission ID, phase where issue occurred, reproduction steps

---

**This template is workspace-wide standard.** All projects use it. All missions follow it. All evidence captured. All DPDCA at every level.

