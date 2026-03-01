# Copilot Instructions Reorganization Proposal

**Date**: 2026-02-28
**Author**: Project 07 Foundation Layer
**Status**: Draft for Review

---

## Executive Summary

After reviewing both workspace-level (`C:\AICOE\.github\copilot-instructions.md`) and project-level template (`07-foundation-layer/02-design/artifact-templates/copilot-instructions-template.md`), significant duplication and misplacement of content was identified. This proposal recommends a clear separation of concerns to reduce maintenance burden and improve agent comprehension.

---

## Current State Analysis

### Duplication Issues

| Content | Workspace | Template PART 1 | Issue |
|---|---|---|---|
| Python Environment | YES | YES | Identical -- duplicated |
| Azure Account | YES | YES | Similar -- duplicated |
| Data Model API Bootstrap | YES | YES | Near-identical with variations |
| Data Model API PUT Rules | YES | YES | Identical -- duplicated |
| Data Model API Write Cycle | YES | YES | Identical -- duplicated |
| Encoding Rule | Section 2 | Section 4 | Same rule, different locations |

### Misplaced Content

| Content | Currently in | Should be in | Reason |
|---|---|---|---|
| Sandbox AI Services (marco-sandbox) | Template PART 1 | Workspace | Shared infrastructure, not project-specific |
| DPDCA Execution Loop | Template PART 1 | Workspace | Universal pattern, never varies by project |
| Context Health Protocol | Template PART 1 | Workspace | Universal pattern, never varies by project |
| 29-Foundry Registry | Workspace | Workspace | [PASS] Correct location |
| EVA-Veritas MCP | Workspace | Workspace | [PASS] Correct location |
| Project Registry (46-project table) | Workspace | Workspace | [PASS] Correct location |
| Source of Truth Hierarchy | Workspace | Workspace | [PASS] Correct location |

### Bootstrap Complexity

**Workspace bootstrap (5 steps)**:
1. Identify active project
2. Read project's copilot-instructions
3. Read project governance docs
4. Check for skills
5. Produce session brief (includes health check, readiness probe, dependency audit)

**Template bootstrap (4 steps)**:
1. Establish $base
2. Read governance docs
3. Read skills index
4. Query data model for project record
5. Produce session brief

Issue: Step numbering mismatch, responsibility overlap, workspace Step 2 delegates to template entirely.

---

## Proposed Reorganization

### Design Principle: Two-Layer Separation

**Layer 1: WORKSPACE** (`C:\AICOE\.github\copilot-instructions.md`)
- Cross-cutting concerns: project registry, shared services, infrastructure
- Global bootstrap ritual: identify project -> delegate to project instructions
- Shared resources: Python env, Azure accounts, Sandbox AI, 29-Foundry, Veritas
- Universal patterns that NEVER vary: encoding, DPDCA, context health
- Workspace-level data model operations (project registry queries)

**Layer 2: PROJECT TEMPLATE PART 1** (`copilot-instructions-template.md`)
- Project-scoped bootstrap: governance docs, skills, project data model record
- Data model operations for this project: entity queries, PUT/write cycles
- Technical rules for coding work: PUT rules, validation, write cycle
- Quality gates

**Layer 3: PROJECT TEMPLATE PART 2**
- No change -- remains project-specific

---

## Detailed Content Mapping

### WORKSPACE CONTENT (new structure)

```markdown
# GitHub Copilot Instructions -- AICOE Workspace

## 1. ENCODING RULE -- ABSOLUTE, NO EXCEPTIONS
[MOVE from workspace section 2 -- keep as-is]

## 2. UNIVERSAL PATTERNS (never vary by project)

### 2.1 DPDCA Execution Loop
[MOVE from template PART 1 section 2]

### 2.2 Context Health Protocol
[MOVE from template PART 1 section 5]

## 3. WORKSPACE BOOTSTRAP RITUAL

### Step 1 -- Identify Active Project
[KEEP from workspace -- current Step 1]

### Step 2 -- Delegate to Project Instructions
Read `{project}/.github/copilot-instructions.md` in full.
It will guide the project-level bootstrap (governance, skills, data model).

### Step 3 -- Workspace Health Check
[MOVE from workspace Step 5a/5b/5c -- health, readiness probe, dependency audit]
This runs AFTER project bootstrap, surfaces blockers before implementation.

## 4. SHARED INFRASTRUCTURE

### 4.1 Python Environment
[KEEP from workspace -- REMOVE from template]

### 4.2 Azure Account
[KEEP from workspace -- REMOVE from template]

### 4.3 Sandbox AI Services (marco-sandbox)
[MOVE from template PART 1 section 8 -- it's shared infra, not project-specific]

## 5. ECOSYSTEM SERVICES

### 5.1 EVA Foundation -- Project Registry
[KEEP from workspace -- 46-project table]

### 5.2 29-Foundry -- Agentic Capabilities Registry
[KEEP from workspace]

### 5.3 EVA-Veritas MCP
[KEEP from workspace]

### 5.4 Source of Truth Hierarchy
[KEEP from workspace]

### 5.5 Project 07 -- Foundation Layer (Seeder)
[KEEP from workspace]

## 6. DATA MODEL API -- WORKSPACE OPERATIONS

### 6.1 Query Project Registry
[Extract from current workspace Data Model section -- only registry queries]
```powershell
$base = "https://marco-eva-data-model..."
Invoke-RestMethod "$base/model/projects/" | Select-Object id, maturity
```

[DO NOT include: Bootstrap, PUT Rules, Write Cycle -- those move to project template]
```

### PROJECT TEMPLATE PART 1 CONTENT (new structure)

```markdown
## PART 1 -- UNIVERSAL RULES

### 1. Project Bootstrap (run after workspace bootstrap)

#### Step 1 -- Establish $base (Data Model API)
[MOVE from template Step 1 + current Bootstrap section 3.1]

#### Step 2 -- Read Governance Docs
[KEEP from template Step 2]

#### Step 3 -- Read Skills Index
[KEEP from template Step 3]

#### Step 4 -- Query This Project's Data Model Record
[KEEP from template Step 4]

#### Step 5 -- Produce Session Brief
[KEEP from template Step 5 -- project-specific brief]

### 2. Data Model API -- Project Operations

#### 2.1 Query Decision Table
[KEEP from template section 3.2 -- how to query layers/endpoints/screens]

#### 2.2 PUT Rules
[KEEP from template section 3.3 -- Rules 1-8]

#### 2.3 Write Cycle
[KEEP from template section 3.4 -- 3-step PUT + confirm + commit]

#### 2.4 Validation and Fixes
[KEEP from template section 3.5 -- fix validation FAIL]

#### 2.5 What to Update for Each Source Change
[KEEP from template section 3.6 -- table mapping source changes to model layers]

### 3. Encoding and Output Safety
[KEEP from template section 4 -- examples of [PASS]/[FAIL] tokens]
[NOTE: Rule itself is in workspace -- this section shows code examples]

[REMOVE sections 5, 6, 7 -- moved to workspace]
[REMOVE section 8 -- moved to workspace]
```

---

## Rationale for Each Move

### DPDCA -> Workspace
Universal pattern. Every active project uses it. Never customized. Belongs in shared knowledge.

### Context Health Protocol -> Workspace
Universal pattern. Thresholds (step 5, 10, 15) never vary. 4 health questions apply everywhere.

### Sandbox AI Services -> Workspace
Shared Azure infrastructure. Marco-sandbox resources serve all EVA projects. Not project-specific.

### Python Environment -> Workspace Only
Path `C:\AICOE\.venv\` is workspace-level. Same for all projects. No need to duplicate in every template.

### Azure Account -> Workspace Only
Personal vs. professional account logic is workspace-wide. Same credentials for all projects.

### Data Model Bootstrap -> Project Template Only
Establishing `$base` is the first step of project-level work. Keep it in project bootstrap.
Workspace doesn't need it -- workspace operations use project registry query only.

### PUT Rules / Write Cycle -> Project Template Only
These are technical rules used DURING coding. Agent reads workspace first (identify project),
then reads project instructions (learns how to PUT model entities for this project's work).

### Encoding Rule -> Workspace (policy statement)
Template section 4 keeps CODE EXAMPLES showing how to apply it (print statements, tokens).
Separation: workspace = policy, template = implementation guidance.

---

## Migration Plan

### Phase 1: Update Template to v3.4.0 (backward-compatible)

1. Add version header: `Template Version: 3.4.0-reorganization`
2. PART 1 changes:
   - Remove sections 5, 6, 7, 8 (moved to workspace)
   - Add note at top: "Universal patterns (DPDCA, Context Health) are in workspace instructions"
   - Keep Data Model API sections (2.1-2.5) as core of PART 1
   - Keep Encoding section 3 (code examples) -- reference workspace for policy
3. Add migration note in template header:
   ```
   > Template v3.4.0: DPDCA, Context Health, Python Env, Azure Account, Sandbox AI
   > are now in workspace instructions only. Read workspace instructions first.
   ```

### Phase 2: Update Workspace to v1.2.0

1. Add version header: `Version: 1.2.0`
2. Insert new section 2: Universal Patterns (DPDCA + Context Health)
3. Move Sandbox AI Services from template to section 4.3
4. Simplify Bootstrap Step 2:
   ```
   ### Step 2 -- Delegate to Project Instructions
   Read `{project}/.github/copilot-instructions.md` in full before proceeding.
   Project instructions guide: governance docs, skills, data model queries, session brief.
   ```
5. Rename Step 5 -> Step 3: "Workspace Health Check" (runs AFTER project bootstrap)
6. Remove duplicated Data Model PUT Rules / Write Cycle (they stay in project template)

### Phase 3: Reseed All Active Projects

Run `Reseed-Projects.ps1 -Scope active` to propagate template v3.4.0 to all 12 active projects.
PART 2 preserved. PART 1 now leaner (no env/account/sandbox duplication).

### Phase 4: Update Workspace Last

Push workspace v1.2.0 AFTER all projects have v3.4.0 template (avoid broken references).

---

## Benefits

1. **Zero duplication**: Python env, Azure account, Sandbox AI exist in ONE place only
2. **Clearer bootstrap flow**: Workspace -> Project -> Work (linear delegation)
3. **Easier maintenance**: Universal patterns (DPDCA, Context Health) updated once, apply everywhere
4. **Smaller project template PART 1**: 588 lines -> ~400 lines (30% reduction)
5. **Session Brief clarity**: Workspace health check (gates G01-G10) runs separately from project brief
6. **Agent comprehension**: Workspace = "what projects exist + shared infra", Project = "how to work on THIS project"

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Agent loads project template before workspace | vs-code auto-loads workspace first; project template references workspace in header |
| Broken references during migration | Phase 4 (workspace v1.2.0) deploys AFTER Phase 3 (all projects v3.4.0) |
| PART 2 accidentally overwritten | Reseed script preserves PART 2 -- tested on 12 projects (2026-02-25 session 3) |
| Template too lean (missing context) | Data Model API (core of PART 1) stays in template; universal patterns referenced |

---

## Acceptance Criteria

- [ ] Template v3.4.0 created with sections 5-8 removed
- [ ] Workspace v1.2.0 created with sections 2 (Universal Patterns) and 4.3 (Sandbox AI) added
- [ ] `Reseed-Projects.ps1` dry-run PASS on 3 test projects
- [ ] `Reseed-Projects.ps1 -Scope active` PASS=12 FAIL=0
- [ ] Workspace v1.2.0 manually tested: agent correctly delegates to project after Step 2
- [ ] No duplication: grep for "Python Environment" returns 1 file only (workspace)
- [ ] No duplication: grep for "marco-sandbox" returns 1 file only (workspace)
- [ ] Session brief produced correctly: workspace health -> project brief -> work

---

## Open Questions for Review

1. Should DPDCA remain in workspace or stay in template PART 1?
   - Argument for workspace: universal, never varies
   - Argument for template: it's the execution loop for project work, closer to the task

2. Should encoding rule policy AND examples both be in workspace?
   - Current proposal: policy in workspace, code examples in template section 3
   - Alternative: everything in workspace, template just references it

3. Should "What to Update for Each Source Change" (3.6) stay in template or move to workspace?
   - Current: stays in template (it's operational guidance during coding)
   - Alternative: workspace "EVA-Wide Rules" (it's the same for every project)

4. Should Bootstrap split be Step 1-2 (workspace) / Step 1-5 (project) or sequential 1-8?
   - Current: nested (workspace delegates to project)
   - Alternative: flat 1-8 (workspace Steps 1-3, project Steps 4-8)

---

*Next Steps*: Review this proposal, answer open questions, proceed to Phase 1 implementation.
