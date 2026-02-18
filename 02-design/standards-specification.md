# Copilot Configuration Standards Specification

**Document Type**: Standards Specification  
**Phase**: 02-Design  
**Date**: January 30, 2026 (Updated)  
**Status**: Implementation Ready  
**Template Version**: v2.1.0  

---

## Executive Summary

This specification defines standardized GitHub Copilot configuration patterns derived from EVA ecosystem analysis, particularly Project 06 (JP Auto-Extraction) professional component architecture. These standards ensure consistent AI assistance across all EVA repositories.

## Core Principles

### 1. Professional Component Architecture (MANDATORY)
All AI-assisted projects must implement modular component architecture with:
- **Evidence Collection**: Debug artifacts at every component boundary
- **Session Management**: Persistent state tracking across operations
- **Error Observability**: Structured error handling with full context preservation
- **Windows Enterprise Compatibility**: ASCII-only output, encoding safety

### 2. Systematic Debugging Infrastructure (MANDATORY)
Every automation must include:
- **Pre-State Capture**: HTML, screenshots, network traces before operations
- **Success State Capture**: Evidence collection on successful completion  
- **Error State Capture**: Full diagnostic artifacts on failure
- **Structured Logging**: JSON-based error context with timestamps

### 3. Anti-Pattern Prevention (CRITICAL)
Copilot must enforce:
- **No Unicode in Scripts**: Prevent enterprise Windows encoding crashes
- **No Silent Failures**: All exceptions must preserve evidence
- **No Generic Retry**: Retry logic must capture state between attempts
- **No Black Box Operations**: All external calls must have observability

## File Organization Standards

### Directory Structure Template
```
project-name/
├── scripts/                    # Main execution scripts
│   ├── main_automation.py     # Primary automation entry point
│   ├── authenticate_system.py # Authentication helper
│   └── components/            # Modular components
├── debug/                     # Debug artifacts (MANDATORY)
│   ├── screenshots/           # UI operation captures
│   ├── html/                  # Page state captures
│   └── traces/                # Network/API traces
├── evidence/                  # Structured evidence (MANDATORY)
├── logs/                      # Execution logs (MANDATORY)
├── sessions/                  # Session state persistence
├── input/                     # Source data
├── output/                    # Results and reports
├── tests/                     # Test cases
├── .github/
│   ├── copilot-instructions.md # Project-specific Copilot config
│   └── architecture-ai-context.md # AI architecture reference
├── requirements-core.txt      # Core dependencies
├── requirements-test.txt      # Testing dependencies
├── run_project.bat           # Windows execution script (encoding-safe)
└── README.md                 # Project documentation
```

### Naming Conventions

| Artifact Type | Pattern | Example |
|---------------|---------|---------|
| Debug HTML | `{component}_debug_{context}_{timestamp}.html` | `jp_debug_error_attempt_1_20260123_113627.html` |
| Screenshots | `{component}_screenshot_{context}_{timestamp}.png` | `ui_screenshot_login_success_20260123_114530.png` |
| Evidence Reports | `{component}_evidence_report_{timestamp}.json` | `jp_evidence_report_20260123_113704.json` |
| Session Files | `{component}_session_{timestamp}.json` | `automation_session_20260123_073409.json` |
| Log Files | `{component}_execution_{date}.log` | `jp_automation_execution_20260123.log` |

## Copilot Instructions Template

### Standard Copilot Instructions Structure

**Template Version**: v2.0.0 (production-tested patterns from EVA-JP-v1.2)  
**Location**: `artifact-templates/copilot-instructions-template.md`  
**Status**: Production-ready (1,200+ lines)  
**Usage Guide**: `artifact-templates/template-v2-usage-guide.md`

```markdown
# GitHub Copilot Instructions - {PROJECT_NAME}

**CRITICAL**: Read this ENTIRE file before generating ANY code.

## Windows Enterprise Encoding Safety (MANDATORY)
- NEVER use Unicode characters (✓✗⏳🎯❌✅…) in Python/PowerShell scripts
- ALWAYS use ASCII equivalents: "[PASS]", "[FAIL]", "...", "[ERROR]", "[INFO]"
- ALWAYS set PYTHONIOENCODING=utf-8 in batch files
- REASON: Enterprise Windows cp1252 encoding causes UnicodeEncodeError crashes

## Professional Component Architecture (MANDATORY)
When creating automation/processing systems:

### 1. Component Structure
```python
class ProfessionalComponent:
    def __init__(self, component_name: str):
        self.component_name = component_name
        self.debug_collector = DebugArtifactCollector(component_name)
        self.session_manager = SessionManager(component_name)
        self.error_handler = StructuredErrorHandler(component_name)
    
    async def execute_with_observability(self, operation_name: str, operation):
        # 1. ALWAYS capture pre-state
        await self.debug_collector.capture_state(f"{operation_name}_before")
        
        try:
            # 2. Execute operation
            result = await operation()
            
            # 3. ALWAYS capture success state
            await self.debug_collector.capture_state(f"{operation_name}_success")
            return result
        except Exception as e:
            # 4. ALWAYS capture error state
            await self.debug_collector.capture_state(f"{operation_name}_error")
            await self.error_handler.log_structured_error(operation_name, e)
            raise
```

### 2. Retry Logic with Evidence Preservation
```python
async def execute_with_retry(self, operation, max_attempts=3):
    for attempt in range(1, max_attempts + 1):
        try:
            await self.debug_collector.capture_state(f"attempt_{attempt}_before")
            result = await operation()
            await self.debug_collector.capture_state(f"attempt_{attempt}_success")
            return result
        except Exception as e:
            await self.debug_collector.capture_state(f"attempt_{attempt}_error")
            if attempt == max_attempts:
                await self.error_handler.log_final_failure(e, attempt)
                raise
            await self.wait_with_backoff(attempt)
```

### 3. Windows-Safe Batch Script Pattern
```batch
@echo off
REM CRITICAL: Windows Enterprise Encoding Safety
set PYTHONIOENCODING=utf-8

echo [INFO] Starting {PROJECT_NAME} automation...
python scripts/main_automation.py %*

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Automation failed with exit code %ERRORLEVEL%
    echo [INFO] Check logs/ directory for debug information
    pause
    exit /b %ERRORLEVEL%
)

echo [PASS] Automation completed successfully
echo [INFO] Results saved to output/ directory
pause
```

## Anti-Patterns to Enforce Prevention

### NEVER Generate These Patterns:
1. **Silent Exception Swallowing**:
   ```python
   # ❌ NEVER DO THIS
   try:
       result = risky_operation()
   except:
       pass  # Silent failure - NO EVIDENCE
   ```

2. **Generic Retry Without Context**:
   ```python
   # ❌ NEVER DO THIS  
   for i in range(3):
       try:
           return operation()
       except:
           continue  # No evidence preservation
   ```

3. **Unicode in Enterprise Scripts**:
   ```python
   # ❌ NEVER DO THIS
   print("✓ Success")  # Will crash in cp1252 encoding
   ```

### ALWAYS Generate These Patterns:
1. **Evidence-Preserving Exception Handling**:
   ```python
   # ✅ ALWAYS DO THIS
   try:
       await self.capture_pre_state()
       result = await risky_operation()
       await self.capture_success_state()
       return result
   except Exception as e:
       await self.capture_error_state()
       await self.log_structured_error(e)
       raise
   ```

## Quality Gates

### Before Code Generation Checklist:
- [ ] Windows encoding safety confirmed
- [ ] Debug artifact collection implemented
- [ ] Session state management included
- [ ] Structured error handling with evidence preservation
- [ ] ASCII-only output markers
- [ ] Retry logic with state capture between attempts

### After Code Generation Validation:
- [ ] No Unicode characters in scripts
- [ ] All exceptions preserve evidence
- [ ] Directory structure follows standards
- [ ] Batch scripts include PYTHONIOENCODING
- [ ] Component architecture implements observability
```

## Architecture Decision Records

### ADR-001: Windows Enterprise Encoding Safety
**Status**: Adopted  
**Date**: January 23, 2026  
**Context**: Project 06 discovered cp1252 encoding crashes in enterprise Windows environments  
**Decision**: Mandate ASCII-only output in all automation scripts  
**Consequences**: Prevents Unicode-related crashes, requires developer discipline  

### ADR-002: Evidence Collection at Component Boundaries
**Status**: Adopted  
**Date**: January 23, 2026  
**Context**: Black-box automation failures difficult to debug without artifacts  
**Decision**: Require debug artifact collection at every component operation  
**Consequences**: Increased storage requirements, but vastly improved debugging capability  

### ADR-003: Professional Component Architecture
**Status**: Adopted  
**Date**: January 23, 2026  
**Context**: Project 06 evolved sophisticated modular architecture for enterprise automation  
**Decision**: Standardize component-based architecture across all automation projects  
**Consequences**: Higher initial complexity, but better maintainability and reliability  

## Implementation Roadmap

### Phase 1: Template Creation
- [x] Standards specification (this document)
- [ ] Copilot instructions template
- [ ] Architecture context template
- [ ] Component code templates

### Phase 2: Validation Tools
- [ ] Configuration validator script
- [ ] Unicode detection tool
- [ ] Evidence collection validator
- [ ] Architecture compliance checker

### Phase 3: Deployment Automation
- [ ] Project scaffold generator
- [ ] Automated template deployment
- [ ] Quality gate automation
- [ ] Developer onboarding guide

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Unicode Incident Reduction | 0 crashes | No UnicodeEncodeError in logs |
| Debug Artifact Coverage | 100% of components | All operations have pre/success/error artifacts |
| Architecture Compliance | 100% of new projects | All projects use professional component pattern |
| Developer Onboarding Time | <1 hour | Time to productive Copilot-assisted development |

---

**Next Steps**: Review and approve this specification, then proceed to template creation in Phase 3 (Development).