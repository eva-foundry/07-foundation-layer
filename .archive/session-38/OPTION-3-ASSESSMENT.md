# Option 3 Assessment: Other Project 07 Items

**Analysis Date**: March 7, 2026

---

## Item 1: github-discussion-agent/

**Status**: ✅ ACTIVE (Created March 3, 2026)

**Contents**:
- `agent.py` — Sprint planning/management agent
- `README.md` — Documentation
- `QUICKSTART.md` — Quick start guide

**Purpose**: Cloud-based sprint agent accessible from GitHub Discussions tab (works on phone/desktop)

**Capabilities**:
- Progress reports
- Gap analysis  
- Sprint velocity tracking
- DPDCA handoff planning
- Veritas expert (MTI audits)

**Current Location**: Project 07 root folder

**Assessment**:
- ✅ Actively maintained
- ✅ Works with EVA Factory & veritas
- ✅ Integrates with GitHub Actions
- ⚠️ Currently located in wrong project (should be Project 40 or own project)

**Verdict**: **RELOCATE** — This should be its own project (e.g., `40-github-discussion-agent`) or at minimum moved to `tools/` subfolder

**Action Options**:
- **A**: Move to `tools/github-discussion-agent/` (keep in Project 07)
- **B**: Relocate to separate project `40-github-discussion-agent/`
- **C**: Keep as-is (current location acceptable)

**Recommendation**: **Option A** (within Project 07 as tool) — simpler than new project, keeps related tooling together

---

## Item 2: mcp-server/

**Status**: ⚠️ UNCLEAR

**Contents**:
- `server.py` — MCP server implementation
- `config.json` — Configuration
- `requirements.txt` — Dependencies
- `server.cpython-311.pyc` — Compiled module

**Purpose**: Model Context Protocol server (likely for EVA Factory governance operations)

**Questions**:
- ❓ Is this actively maintained?
- ❓ What's its purpose? (foundation-expert skill? apply-primer?)
- ❓ Does it have inbound dependencies?

**Assessment**: 
- Cannot fully assess without reading server.py
- Likely part of governance automation
- Should be documented

**Verdict**: **INVESTIGATE** — Needs documentation clarification

**Action**: 
- Document its purpose in PROJECT README
- If critical: Move to `tools/mcp-server/` or `scripts/mcp-server/`
- If non-critical: Archive to `.archive/unclear-status/`

---

## Item 3: patterns/

**Status**: 🔍 UNDER REVIEW (Last updated Feb 4)

**Contents**:
- `README.md` — Pattern catalog
- `APIM-ANALYSIS-METHODOLOGY.md` — API Management analysis pattern

**Purpose**: Reusable patterns extracted from completed projects

**Current Status**:
- ✅ APIM pattern proven on Project 17 (MS-InfoJP)
- 🔍 Awaiting validation on EVA-JP-v1.2
- Needs second project validation before "Production-Ready"

**Assessment**:
- ✅ Valuable knowledge base  
- ✅ Actively used
- ⚠️ Incomplete (only 1 pattern, needs validation)

**Verdict**: **KEEP** — Pattern library is strategic

**Action**: Move to `docs/patterns/` (consolidate with other docs) OR leave as-is if more patterns expected in this folder

---

## Summary: Option 3 Decisions

| Item | Current | Status | Action | Priority |
|------|---------|--------|--------|----------|
| **github-discussion-agent** | Project 07 root | ✅ Active | Move to `tools/` | Medium |
| **mcp-server** | Project 07 root | ⚠️ Unclear | Document purpose | High |
| **patterns** | `patterns/` | 🔍 Review | Move to `docs/patterns/` | Medium |

---

## Next Steps (If Approved)

### Immediate (Clarification)
- [ ] Investigate mcp-server purpose & dependencies
- [ ] Document findings in README

### Short-term (Consolidation)
- [ ] Create `tools/` folder for agents/servers
- [ ] Move github-discussion-agent → `tools/github-discussion-agent/`
- [ ] Move mcp-server → `tools/mcp-server/` (if active)
- [ ] Move patterns → `docs/patterns/` (if keeping)

### Documentation
- [ ] Update PROJECT README with tools/ purpose
- [ ] Add mcp-server usage documentation
- [ ] Add pattern validation timeline for patterns/

---

## User Decision Required

**For Option 3 completion, which direction?**

### Path A: Conservative (Keep As-Is)
- Leave all three items in current locations
- Just document their purposes in README

### Path B: Organize to Tools Folder
- Create `tools/` folder
- Move github-discussion-agent and mcp-server to tools/
- Leave patterns in root or move to docs/patterns/

### Path C: Full Cleanup + Move
- Create `tools/` folder
- Move discussion agent + mcp-server → tools/
- Move patterns → docs/patterns/
- Create .archive/unclear-status/ for any non-essential items

**Which path?**
