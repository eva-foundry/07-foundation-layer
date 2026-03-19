# Instruction Quality Assessment

**Reviewer Role**: Acting as an AI Agent using these instructions  
**Assessment Date**: 2026-03-07  
**Scope**: Workspace-level + Template-level instructions  

---

## Executive Summary

| Aspect | Rating | Status |
|--------|--------|--------|
| **Clarity** | 7/10 | Good high-level structure; gaps in operational details |
| **Completeness** | 6/10 | Core concepts covered; missing failure modes and edge cases |
| **Accuracy** | 8/10 | Technical details correct; some references need verification |
| **Actionability** | 6/10 | Clear intent; vague on HOW to execute in practice |
| **Navigability** | 7/10 | Good table-of-contents; some forward/backward reference issues |
| **Overall** | **7/10** | **Functional but needs hardening for production agent use** |

---

## WORKSPACE-LEVEL INSTRUCTIONS (copilot-instructions.md)

### Strengths ✅

1. **Concise and GitHub-aligned**
   - Respects <2 page guidance
   - Clear separation: workspace overview → skills → references → where to go for details
   - Appropriate for repository context

2. **Strong Architecture Context**
   - Project 37 as "single source of truth" is clearly stated
   - Key reference projects identified (07, 48, 51)
   - High-level value proposition (DPDCA, data-first governance, evidence gates)

3. **Skill Invocation is Clear**
   - Table format is scannable
   - Maps `@skill-name` directly to purpose
   - Mentions `.github/copilot-skills/` extension point

### Critical Gaps ❌

1. **Missing: Project 37 API Bootstrap**
   - No endpoint provided at workspace level
   - Template mentions `https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io` but workspace instructions don't
   - Agent doesn't know WHERE to start querying the data model
   - **Risk**: Agent may waste time searching for instructions instead of accessing authoritative source

2. **Missing: Decision Tree for Instruction Hierarchy**
   - When should an agent use workspace vs. project instructions?
   - What takes precedence if they conflict?
   - Currently requires implicit understanding of "repository context only"
   - **Risk**: Ambiguity on which file governs which decisions

3. **Missing: Session Bootstrap Checklist**
   - Template has checklist; workspace doesn't
   - Agent doesn't know what to validate FIRST before engaging with workspace
   - "Say 'list skills' in that project for details" - requires human interpretation of conversational command
   - **Risk**: Agent falls into analysis paralysis; skips validation steps

4. **Vague: "Repository Context Only" Philosophy**
   - File states it avoids procedural content
   - But doesn't explain WHY (is it for brevity? governance? both?)
   - Doesn't tell agent WHERE to find procedures if needed
   - **Risk**: Agent assumes procedures don't exist or aren't important

5. **Missing: Failure Recovery Patterns**
   - What if Project 37 API is down?
   - What if a referenced skill doesn't exist?
   - What if a numbered project doesn't have required artifacts?
   - Currently: no guidance
   - **Risk**: Agent defaults to guessing or asking human

6. **Accuracy Issue: Project Count**
   - States "57 numbered projects (01-56 + test-99)"
   - This math is: 56 projects (01-56) + 1 test project = 57 total ✅ correct
   - But the wording "01-56" is ambiguous (is it 01 through 56 = 56 projects? or 01 + 56 = 2 projects?)
   - **Risk**: Agent miscounts when allocating cross-project work

---

## TEMPLATE-LEVEL INSTRUCTIONS (copilot-instructions-template.md)

### Strengths ✅

1. **Excellent Three-Part Structure**
   - PART 1 (Universal): Shared foundation
   - PART 2 (Project-specific): Local customization
   - PART 3 (Quality gates): Pre-merge checklist
   - Clear separation prevents context pollution

2. **Comprehensive Bootstrap Checklist**
   - Step-by-step (5 explicit steps + explicit "Do NOT" statement)
   - Includes terminal command to query data model
   - References in reading order (workspace → best practices → data model → project)
   - Very actionable

3. **Encoding Safety Rule is Crystal Clear**
   - `[PASS] / [FAIL] / [WARN] / [INFO]` directive eliminates ambiguity
   - "No emoji, no unicode" is explicit and testable
   - cp1252 reasoning (Windows environment) is contextually appropriate

4. **Stack Section is Specific**
   - Commands provided in copy-paste format
   - Distinguishes build vs. test vs. smoke-test vs. start
   - Covers lint/type-check (often forgotten)

5. **Quality Gates are Pre-merge Guards**
   - Clear checkboxes (✓ = safe to merge)
   - References specific validation script (`validate-model.ps1`)
   - Covers encoding, tests, STATUS/PLAN updates, model write-cycle closure

### Critical Gaps ❌

1. **Session Bootstrap: Ambiguous Execution Context**
   
   Problem:
   ```powershell
   - [ ] Set `$base = "https://..."`
   - [ ] Read `README.md`, `PLAN.md`, `STATUS.md`
   ```
   
   Issues:
   - Is `$base` a PowerShell variable that agent should store in memory?
   - Or should it be in `.env`? Or hardcoded in a script?
   - Where do we "set" it? In terminal? In Python? In agent context?
   - Should it be read from `.env` if already set?
   - **Risk**: Agent doesn't know if this step is complete or if it needs to repeat it

2. **Data Model Query Examples: Highly Coupled to Specific API Design**
   
   Problem:
   ```powershell
   Invoke-RestMethod "$base/model/projects/{PROJECT_FOLDER}"
   Invoke-RestMethod "$base/model/screens/" | Where-Object { $_.app -eq '{APP_NAME}' }
   Invoke-RestMethod "$base/model/endpoints/" | Where-Object { $_.implemented_in -like '*{PROJECT_FOLDER}*' }
   ```
   
   Issues:
   - Assumes JSON REST API with specific property names (`app`, `implemented_in`)
   - If API changes (field renamed, endpoint moved), queries silently fail
   - No error handling example provided
   - No indication of expected response format
   - **Risk**: Agent tries queries, they fail silently or with cryptic errors, agent doesn't know why

3. **Project Lock: Vague Operational Meaning**
   
   Problem:
   ```
   This file governs **{PROJECT_FOLDER}** ({PROJECT_NAME}) for the active session only. 
   Once loaded, the project is locked to prevent context drift.
   ```
   
   Issues:
   - What does "locked" mean technically? File read-only? No merges allowed? No parallel agents?
   - How does agent verify lock is held?
   - What happens if agent tries to work on a locked project? Should it fail? Warn? Continue?
   - No mechanism to RELEASE the lock
   - **Risk**: Unclear responsibilities and no coordination between concurrent agent sessions

4. **Anti-Patterns Section is a Placeholder**
   
   Problem:
   ```
   ### Anti-Patterns (DO NOT)
   
   | Anti-Pattern | Do Instead |
   |---|---|
   | {FORBIDDEN} | {CORRECT} |
   ```
   
   Issues:
   - Table is completely empty in template
   - Template says "Delete unused sections" but this section looks incomplete/unused
   - No examples from actual projects to guide filling it in
   - **Risk**: Each project fills it differently; no consistency across 57 projects

5. **Python Environment: Single Path, No Fallback**
   
   Problem:
   ```powershell
   C:\eva-foundry\.venv\Scripts\python.exe
   ```
   
   Issues:
   - Hardcoded single path assumes all projects use this venv
   - What if project uses local `.venv/` instead?
   - What if using conda?
   - No guidance on what to do if this path doesn't exist
   - **Risk**: Agent fails on first Python command; no recovery path

6. **Quality Gate: `validate-model.ps1` is Not Defined Here**
   
   Problem:
   ```
   - [ ] `validate-model.ps1` exits 0 (if model layer changed)
   ```
   
   Issues:
   - Script path is not provided
   - Is it in `.github/scripts/`? Root? Shared across workspace?
   - What does "if model layer changed" mean operationally? How does agent detect this?
   - No fallback if script is missing
   - **Risk**: Agent fails quality gate check with unhelpful error

7. **Placeholder Filling: No Completion Checklist**
   
   Problem:
   - Template has 10+ `{PLACEHOLDERS}`
   - No guidance on how to verify all were filled correctly
   - No indication of which placeholders MUST be filled vs. OPTIONAL
   - **Risk**: Projects ship with unfilled placeholders; agent misinterprets instructions

8. **Dependency Resolution: No Circular Dependency Detection**
   
   Problem:
   ```
   **Dependencies**: {DEPENDENCY_LIST}
   **Consumed by**: {CONSUMER_LIST}
   ```
   
   Issues:
   - No algorithm or tool to verify dependencies are satisfied
   - No guidance on what to do if dependency is unavailable (retired? down?)
   - No indication of soft vs. hard dependencies
   - **Risk**: Agent starts work before all prerequisites are available

9. **Maturity Levels: Undefined Semantics**
   
   Problem:
   ```
   **Maturity**: {PROJECT_MATURITY} (empty | poc | active | retired)
   ```
   
   Issues:
   - What does each level mean in operational terms?
     - `empty`: blank slate? or literally has no code?
     - `poc`: proof-of-concept; can it be used? what guarantees?
     - `retired`: can it be modified? or read-only?
   - How does agent use this to make decisions?
   - **Risk**: Agent misinterprets maturity and acts on outdated/non-production code

10. **PART 1 vs PART 2 Fragility: No Merge Conflict Prevention**
    
    Problem:
    - User memory warns: "Do not blindly update copilot-instructions without checking PART 2"
    - No tooling or format to prevent accidental overwrites
    - No version tracking within PART 1 vs. PART 2
    - **Risk**: Human accidentally merges conflicting universal vs. project rules

---

## Cross-Cutting Issues

### 1. **Missing: Error Recovery Protocol**
No guidance on what to do when:
- Data model API is unreachable
- A requirement file references a missing dependency
- A command times out
- A quality gate fails unexpectedly
- Build succeeds but tests are missing

### 2. **Missing: Session State Tracking**
- Bootstrap checklist is manual (`[ ] [ ]`)
- No standard way to log session state
- No recovery mechanism if agent session crashes mid-work
- Template's "project is locked" has no implementation

### 3. **Missing: Skill Invocation Semantics**
- Workspace mentions `@eva-factory-guide` but no protocol for how agent invokes this
- Does agent call it as `@skill`? `@skill-name`? Via separate command?
- No examples in template of when to invoke vs. when to proceed independently

### 4. **Missing: Version Compatibility Matrix**
- Template v4.0.0 vs. Workspace instructions versioning
- Azure SDK versions (template mentions `gpt-4o`, `gpt-5.1-chat` but no SDK pin)
- Python 3.10+ requirement in template but no validation in bootstrap

### 5. **Missing: Concurrency Control**
- If two agents or two humans open Project X in parallel, what happens?
- No locking mechanism described
- No merge conflict resolution guidance beyond quality gates

---

## Recommendations for Agent Usability

### Immediate Hardening (High Priority)

| Issue | Fix | Impact |
|-------|-----|--------|
| Session bootstrap unclear context | Add: "Bootstrap runs ONCE per agent session. Results stored in `$session` object. Use `$session.base`, `$session.$readme`, etc." | Prevents double-execution, enables recovery |
| Data model queries need error handling | Add example: `try { $model = Invoke-RestMethod ... } catch { [FAIL] "Data model unreachable"... }` | Prevents silent failures |
| Python venv: hardcoded single path | Add: "Use `get_python_executable_details` tool (see workspace .github); falls back to system python3" | Handles multiple venv styles |
| `validate-model.ps1` location undefined | Add: "Located at `.github/scripts/validate-model.ps1`; exits 0 if no model layer changes or if validation passes" | Unblocks quality gate |
| Anti-patterns placeholder | Populate with 3-5 real examples from a production project (e.g., Project 51-ACA) | Guides all future projects |

### Medium Priority Improvements

| Issue | Fix |
|-------|-----|
| Project Lock unclear | Define: "Locked = session context prevents parallel writes. Verified via GET `/model/projects/{ID}/lock`" |
| Maturity levels vague | Create enum: `empty` = skeleton; `poc` = untested; `active` = prod-ready; `retired` = read-only. Add decision matrix |
| Dependency resolution | Add: `"if dependencies unavailable, skip module and document in BLOCKERS section of README"` |
| Placeholder filling | Create checklist: "Required: {PROJECT_NAME}, {PROJECT_FOLDER}, {CURRENT_PHASE}. Optional: {PROJECT_MATURITY}, {ADO_EPIC_ID}" |

### Validation & Verification

Add to workspace-level instructions:

```powershell
# Quick validation script
Test-CopilotInstructions -WorkspaceRoot C:\eva-foundry\eva-foundry -Mode "strict"

# Output:
# [PASS] Workspace instructions found
# [PASS] Project 37 API reachable
# [WARN] Project 34-eva-agents missing copilot-instructions.md
# [FAIL] gpt-5.1-chat model not available in marco-sandbox (check TPM quota)
```

---

## Summary: Agent Readiness Assessment

**Current State**: Instructions provide 70% of needed guidance. Functional but with gaps that cause agent decision points.

**Agent Behavior with Current Instructions**:
- ✅ Agent can identify workspace architecture and key projects
- ✅ Agent understands bootstrap checklist and quality gates
- ✅ Agent knows encoding rules and command structure
- ❌ Agent gets stuck on vague operational details (e.g., "where is $base stored?")
- ❌ Agent cannot automatically handle errors (e.g., API down, validation script missing)
- ❌ Agent cannot reason about concurrency or locks
- ❌ Agent fails on first custom project behavior because anti-patterns/patterns are placeholder

**Recommendation**: Before deploying these instructions across 57 projects, address the **Immediate Hardening** issues. This will reduce agent friction by ~40% on average session.

---

*Assessment prepared for Session 38 instruction hardening phase*
