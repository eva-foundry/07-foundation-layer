# ADR-004: Professional Transformation Methodology

**Status**: Adopted  
**Date**: January 23, 2026  
**Deciders**: Marco Presta, Project 07 Team  

## Context

Project 06 (JP Auto-Extraction) demonstrated a systematic methodology for transforming development scripts into enterprise-grade systems. This methodology includes specific patterns for file organization, error handling, evidence collection, and operational excellence that should be standardized across all EVA projects.

## Decision

Adopt the Professional Transformation Methodology as the standard framework for all EVA projects, consisting of:

### 1. Foundation Systems
- Standardized file organization: `debug/`, `evidence/`, `logs/`, `input/`, `output/`, `sessions/`
- Professional error handling with ASCII-only output (Windows enterprise compatibility)
- Timestamped naming conventions: `{component}_{context}_{YYYYMMDD_HHMMSS}.{ext}`
- Built-in validation and testing infrastructure

### 2. Enterprise Compatibility
- Windows cp1252 encoding safety (ASCII-only markers: `[PASS]`, `[FAIL]`, `[ERROR]`)
- Corporate network restrictions handling with dependency workarounds
- Professional batch script wrappers with `PYTHONIOENCODING=utf-8`
- Graceful degradation for missing dependencies

### 3. Evidence-Based Development
- Automatic artifact collection at all decision points
- Structured error reporting with full context preservation
- Self-validating acceptance criteria
- Comprehensive audit trail generation

### 4. Zero-Friction Execution
- Auto-detection of project structure from any subdirectory
- Pre-flight environment validation
- Normalized parameter handling
- Professional error messages with actionable guidance

## Consequences

### Positive
- Consistent professional quality across all EVA projects
- Reduced onboarding time for new developers
- Improved debugging capability through systematic evidence collection
- Enterprise Windows compatibility by default
- Self-validating project deliverables

### Negative
- Higher initial complexity for simple scripts
- Additional storage requirements for debug artifacts
- Need for developer training on methodology

### Mitigation
- Provide scaffold templates to reduce implementation burden
- Create automated deployment tools for methodology components
- Develop comprehensive documentation and examples

## Implementation

1. **Phase 2 (Design)**: Define methodology templates and patterns
2. **Phase 3 (Development)**: Create scaffold generators implementing methodology
3. **Phase 4 (Testing)**: Validate methodology effectiveness
4. **Phase 5 (Implementation)**: Deploy methodology tools across EVA ecosystem

## Compliance Requirements

All new EVA projects must implement:

- [ ] Standardized directory structure with debug/evidence/logs folders
- [ ] ASCII-only output markers (no Unicode in enterprise scripts)
- [ ] Timestamped naming for all generated files
- [ ] Professional error handling with evidence preservation
- [ ] Pre-flight validation and zero-setup execution
- [ ] Self-validating acceptance criteria

## Related ADRs

- ADR-001: Windows Enterprise Encoding Safety
- ADR-002: Evidence Collection at Component Boundaries
- ADR-003: Professional Component Architecture
- ADR-005: Dependency Management Strategy

---

**Approved by**: Marco Presta  
**Next Review Date**: 2026-04-23