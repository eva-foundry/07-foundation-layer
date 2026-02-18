# ADR-005: Dependency Management Strategy

**Status**: Adopted  
**Date**: January 23, 2026  
**Deciders**: Marco Presta, Project 07 Team  

## Context

Enterprise environments often have pip installation restrictions, SSL certificate issues, and limited access to external package repositories. Project 06 revealed the need for a dependency management strategy that targets full functionality while providing practical workarounds for installation issues, rather than reduced functionality phases.

## Decision

Adopt a "Target Best, Provide Alternatives" dependency management strategy:

### Core Principle
**Always include ALL dependencies needed for full solution functionality in `requirements.txt`**, regardless of installation constraints. Never compromise on solution capability.

### Strategy Components

#### 1. Complete Requirements Declaration
```python
# requirements.txt - Always include full solution dependencies
playwright>=1.40.0          # Browser automation
pandas>=2.2.3               # Data processing  
requests>=2.32.3            # HTTP requests
pytest>=8.3.4               # Testing framework
mypy>=1.14.1                # Type checking
black>=24.10.0              # Code formatting
# ... complete list for full functionality
```

#### 2. Alternative Installation Solutions
```python
# Dependency workaround matrix
INSTALLATION_ALTERNATIVES = {
    "playwright": {
        "issue": "pip restrictions in enterprise environment",
        "solutions": [
            "Use DevBox environment (full pip access)",
            "Manual installation from pre-downloaded wheels",
            "Request IT approval for specific package",
            "Corporate PyPI mirror if available"
        ]
    },
    "enterprise_pip": {
        "issue": "global.no-index=true and SSL certificate failures",
        "solutions": [
            "DevBox as primary development environment",
            "Pre-built wheel cache on network share",
            "Offline wheelhouse with --find-links",
            "Corporate proxy configuration"
        ]
    }
}
```

#### 3. Graceful Degradation Pattern
```python
# Capability-based execution, not reduced functionality
try:
    import playwright
    BROWSER_AUTOMATION_AVAILABLE = True
except ImportError:
    BROWSER_AUTOMATION_AVAILABLE = False
    # Provide alternative solution, not reduced capability
    print("[INFO] Browser automation unavailable - using manual validation checklist")
    print("[INFO] See README.md for installation alternatives")
```

#### 4. Professional Installation Guidance
```markdown
# Standard README.md dependency section
## Dependencies

### Full Installation (Recommended)
```bash
pip install -r requirements.txt
```

### Enterprise Environment Issues?
If you encounter pip installation restrictions:

1. **DevBox Environment (Preferred)**:
   - Use Microsoft DevBox for full pip access
   - All dependencies install without restrictions

2. **Manual Installation**:
   - Download wheels from PyPI manually
   - Use `pip install --find-links <wheel_directory> -r requirements.txt`

3. **Corporate Environment**:
   - Request IT approval for required packages
   - Use corporate PyPI mirror if available

### Capability Validation
Run diagnostic script to check available capabilities:
```bash
python validate_environment.py
```
```

## Rejected Alternatives

### Phased Dependency Strategy (Rejected)
```python
# ❌ REJECTED: Reduces solution capability
# Phase 1: Core dependencies only (basic functionality)
# Phase 2: Full dependencies (complete functionality)
```

**Reason**: Creates artificial functionality limitations and confusion about what the solution actually does.

### Dependency Bundling (Rejected)
Packaging all dependencies with the solution was rejected due to:
- Licensing complications
- Version conflict potential
- Repository size concerns
- Update maintenance burden

## Consequences

### Positive
- Solutions always target full capability
- Clear documentation of installation alternatives
- DevBox provides consistent development environment
- No artificial feature limitations
- Professional installation guidance

### Negative
- May require IT coordination for enterprise deployment
- Developers need awareness of installation alternatives
- Some environments may require manual intervention

### Mitigation
- Provide comprehensive installation documentation
- Create diagnostic tools to validate environment capabilities
- Offer multiple solution paths for common installation issues
- Establish DevBox as standard development environment

## Implementation Guidelines

### For All EVA Projects

#### 1. Requirements Declaration
```python
# Always in requirements.txt - complete functionality
dependency_name>=version    # Purpose: specific functionality
```

#### 2. Capability Detection
```python
# Standard pattern for optional capabilities
try:
    import optional_dependency
    CAPABILITY_AVAILABLE = True
except ImportError:
    CAPABILITY_AVAILABLE = False
    # Provide alternative, not reduced functionality
```

#### 3. Installation Documentation
- README.md must include installation troubleshooting
- List specific alternatives for enterprise environments
- Provide diagnostic validation scripts
- Reference DevBox as standard solution

#### 4. Environment Validation
```python
# validate_environment.py - standard for all projects
def check_dependencies() -> ValidationReport:
    """Validate all required dependencies and suggest alternatives"""
    pass
```

## Monitoring and Review

### Success Metrics
- Reduced installation support requests
- Increased developer productivity in constrained environments
- Consistent solution capability across environments

### Review Triggers
- New corporate pip restrictions identified
- DevBox environment changes
- Alternative installation methods discovered

## Related ADRs

- ADR-004: Professional Transformation Methodology
- ADR-001: Windows Enterprise Encoding Safety
- ADR-003: Professional Component Architecture

---

**Approved by**: Marco Presta  
**Next Review Date**: 2026-04-23