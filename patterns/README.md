# Reusable Patterns & Methodologies

**Purpose**: Proven, repeatable patterns extracted from completed projects  
**Status**: 🔍 Under Review - Patterns need validation on second project  
**Last Updated**: 2026-02-04

---

## Available Patterns

### 1. APIM Analysis Methodology

**File**: [APIM-ANALYSIS-METHODOLOGY.md](./APIM-ANALYSIS-METHODOLOGY.md)  
**Source**: Project 17-APIM (MS-InfoJP)  
**Status**: 🔍 To Be Reviewed  
**Proven**: ✅ 100% accuracy achieved through evidence-based cross-check

**What It Does**: Systematic approach to analyze any web application for Azure API Management integration readiness. Produces evidence-based documentation with file:line references.

**Time Savings**: 2-3 days (with template) vs 3 weeks (from scratch)

**When to Use**:
- Integrating APIM into existing application
- Need complete API inventory for governance/cost attribution
- Planning authentication/authorization overhaul
- Preparing for compliance audit

**Key Outputs**:
- API endpoint inventory (with file:line evidence)
- Authentication gap analysis
- Environment variable mapping
- Streaming endpoint analysis
- Azure SDK integration count
- APIM readiness assessment

**Validation Needed**: Apply to EVA-JP-v1.2 to confirm methodology transfers across codebases

---

## Pattern Review Process

**Before marking pattern as "Production-Ready"**:

1. [ ] **Second Project Validation** - Apply pattern to different codebase
2. [ ] **Accuracy Check** - Verify outputs match ground truth (90%+ accuracy)
3. [ ] **Time Estimate Validation** - Actual time vs predicted time (±20%)
4. [ ] **Stakeholder Feedback** - Team found pattern useful and actionable
5. [ ] **Documentation Quality** - Clear, complete, no critical gaps

**Current**: APIM Analysis Methodology passed validation on MS-InfoJP (Project 17), awaiting validation on EVA-JP-v1.2

---

## How to Use Patterns

1. **Read pattern documentation** - Understand scope, inputs, outputs
2. **Check prerequisites** - Required tools, access, tech stack compatibility
3. **Follow phase-by-phase** - Don't skip validation steps
4. **Capture evidence** - Document file:line references for all findings
5. **Cross-check results** - Validate accuracy before sharing with stakeholders
6. **Provide feedback** - Report gaps, time variances, improvements

---

## Contributing New Patterns

**Requirements for new pattern submission**:
- Proven on at least one real project (not theoretical)
- Evidence-based outputs (not subjective assessments)
- Time estimates backed by actual effort tracking
- Clear success criteria and validation checklist
- Known limitations and edge cases documented

**Submit pattern as**:
1. Create `{PATTERN-NAME}-METHODOLOGY.md` in this folder
2. Mark status as "🔍 To Be Reviewed"
3. Document source project and validation status
4. Update this README with pattern overview

---

## Questions & Feedback

For questions about these patterns, see:
- [copilot-instructions.md](../../.github/copilot-instructions.md) - Evidence-based validation principles
- Project 17-APIM documentation - Reference implementation
- Foundation layer documentation - Context and architecture
