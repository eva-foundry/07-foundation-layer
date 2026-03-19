---
skill-id: universal-command-wrapper
version: 1.0.0
created: 2026-02-28
status: active
layer: foundation
triggers:
  - "terminal output not showing"
  - "command results missing"
  - "cannot see command output"
  - "terminal capture bug"
  - "run command with log"
category: debugging infrastructure-pattern
---

# Universal Command Wrapper - Log File Pattern

## Problem Statement

**Terminal Output Capture Bug**: In AI agent sessions, terminal commands executed via `run_in_terminal` often return only command echoes without actual execution results. This makes verification impossible and blocks progress.

**Root Cause**: Unknown (terminal state, output buffer limit, or tool limitation in agent environment)

**Impact**: Cannot verify system state, cannot run tests, cannot check command results

---

## Solution Pattern

**Universal wrapper** that redirects ALL command output to a uniquely-named log file, then returns structured results without relying on terminal capture.

### Key Properties

1. **Deterministic log file naming** - No searching required
2. **Captures ALL output** - stdout + stderr + exit code
3. **Optional pattern extraction** - Return only what you need
4. **Auto-cleanup** - Old logs removed after 1 hour
5. **Structured results** - JSON-serializable output
6. **Cross-platform** - PowerShell + Python implementations

---

## Usage

### PowerShell Version

```powershell
# Source the script
. C:\eva-foundry\07-foundation-layer\scripts\Invoke-CommandWithLog.ps1

# Example 1: Run pytest, extract summary
$result = Invoke-CommandWithLog `
    -Command "C:\eva-foundry\.venv\Scripts\python.exe -m pytest services/ -x -q" `
    -SearchPattern "passed|failed|error" `
    -Label "pytest"

Write-Host "Exit Code: $($result.ExitCode)"
Write-Host "Test Summary: $($result.Output)"
Write-Host "Full log: $($result.LogFile)"

# Example 2: Query ADO work item, extract iteration
$result = Invoke-CommandWithLog `
    -Command "az boards work-item show --id 2978 --org https://dev.azure.com/marcopresta --query 'fields.``System.IterationPath``' -o tsv" `
    -SearchPattern "51-aca" `
    -Label "ado-query"

Write-Host "Iteration: $($result.Output)"

# Example 3: Full log output
$result = Invoke-CommandWithLog `
    -Command "C:\eva-foundry\.venv\Scripts\python.exe check-state.py" `
    -ReturnFullLog `
    -Label "state-check"

$result.Output | Out-String | Write-Host
```

### Python Version

```python
import sys
sys.path.insert(0, 'C:/eva-foundry/07-foundation-layer/scripts')
from invoke_command_with_log import run_with_log

# Example 1: Run pytest, extract summary
result = run_with_log(
    command="pytest services/ -x -q",
    search_pattern=r"passed|failed|error",
    label="pytest"
)

print(f"Exit Code: {result['exit_code']}")
print(f"Test Summary: {result['output']}")
print(f"Full log: {result['log_file']}")

# Example 2: LOCAL DB check
result = run_with_log(
    command="python -c \"import sys; sys.path.insert(0, 'data-model'); import db; print(len([s for s in db.list_layer('wbs') if s.get('sprint_id')=='Sprint-02']))\"",
    search_pattern=r"\d+",
    label="db-check"
)

print(f"Sprint 2 count: {result['output']}")

# Example 3: Full output
result = run_with_log(
    command="python manual-verify.py",
    return_full_log=True,
    label="verify"
)

print(result['output'])
```

---

## Implementation Details

### Log File Location

**Directory**: `$env:TEMP\eva-command-logs\` (Windows) or `/tmp/eva-command-logs/` (Linux)

**Naming**: `{label}_{YYYYMMDD-HHMMSS-fff}.log`

**Example**: `pytest_20260228-143022-456.log`

### Log File Structure

```
=== COMMAND LOG ===
Timestamp: 2026-02-28 14:30:22
Command: pytest services/ -x -q
WorkingDirectory: C:\eva-foundry\51-ACA
Label: pytest
==================

[command output here]

==================
Exit Code: 0
Duration: 2.34 seconds
==================
```

### Return Structure

```json
{
  "command": "pytest services/ -x -q",
  "log_file": "C:\\Users\\...\\Temp\\eva-command-logs\\pytest_20260228-143022-456.log",
  "exit_code": 0,
  "output": "...passed in 2.3s",
  "duration": 2.34,
  "timestamp": "2026-02-28T14:30:22",
  "success": true
}
```

---

## When to Use

### Always Use For

1. **Pytest execution** - Need test results
2. **ADO CLI queries** - Need work item data
3. **Python scripts** - Need script output
4. **Data model queries** - Need query results
5. **Any command** - Where terminal output is critical

### Pattern in DPDCA Workflow

**Before (Broken)**:
```powershell
# Agent runs command
run_in_terminal("pytest services/")
# Output: Only command echo, no results
# Agent: Cannot verify if tests passed
```

**After (Fixed)**:
```powershell
# Agent loads wrapper
. C:\eva-foundry\07-foundation-layer\scripts\Invoke-CommandWithLog.ps1

# Agent runs via wrapper
$result = Invoke-CommandWithLog -Command "pytest services/" -SearchPattern "passed"

# Output: Full structured result
# Agent: Can verify test pass/fail, read log, proceed with confidence
```

---

## Integration with EVA Projects

### Project copilot-instructions Pattern

Add to PART 1 (Universal Rules) after Section 3 (Data Model API):

```markdown
### 3.5. Universal Command Wrapper (Terminal Output Capture Fix)

**Problem**: Terminal commands in AI agent sessions often return only echoes, no output.
**Solution**: Use log file wrapper from 07-foundation-layer.

**PowerShell**:
```powershell
. C:\eva-foundry\07-foundation-layer\scripts\Invoke-CommandWithLog.ps1
$result = Invoke-CommandWithLog -Command "your-command" -SearchPattern "pattern"
```

**Python**:
```python
import sys
sys.path.insert(0, 'C:/eva-foundry/07-foundation-layer/scripts')
from invoke_command_with_log import run_with_log
result = run_with_log(command="your-command", search_pattern="pattern")
```

**When to use**: Any command where you need results (pytest, az CLI, python scripts, queries).
**Reference skill**: `07-foundation-layer/.github/copilot-skills/universal-command-wrapper.skill.md`
```

---

## Testing

### PowerShell Test

```powershell
cd C:\eva-foundry\07-foundation-layer
. scripts\Invoke-CommandWithLog.ps1

# Test 1: Simple command
$r = Invoke-CommandWithLog -Command "Write-Host 'Hello World'" -Label "test1"
Write-Host "[TEST 1] Exit: $($r.ExitCode), Output: $($r.Output)"

# Test 2: With search pattern
$r = Invoke-CommandWithLog -Command "Write-Host 'Line1'; Write-Host 'PASS: Test'; Write-Host 'Line3'" -SearchPattern "PASS" -Label "test2"
Write-Host "[TEST 2] Matched: $($r.Output)"

# Test 3: Error handling
$r = Invoke-CommandWithLog -Command "Get-ChildItem nonexistent" -Label "test3"
Write-Host "[TEST 3] Exit: $($r.ExitCode), Success: $($r.Success)"
```

### Python Test

```python
import sys
sys.path.insert(0, 'C:/eva-foundry/07-foundation-layer/scripts')
from invoke_command_with_log import run_with_log

# Test 1: Simple command
r = run_with_log(command="echo 'Hello World'", label="test1")
print(f"[TEST 1] Exit: {r['exit_code']}, Output: {r['output']}")

# Test 2: With search pattern
r = run_with_log(command="echo 'Line1\\nPASS: Test\\nLine3'", search_pattern="PASS", label="test2")
print(f"[TEST 2] Matched: {r['output']}")

# Test 3: Error handling
r = run_with_log(command="ls nonexistent", label="test3")
print(f"[TEST 3] Exit: {r['exit_code']}, Success: {r['success']}")
```

---

## Adoption Roadmap

### Immediate (Sprint 2)

**51-ACA verification**:
- Use wrapper for ADO Sprint 2 check
- Use wrapper for pytest baseline
- Use wrapper for LOCAL DB query

**Scripts to convert**:
- `manual-verify.py` - Use `run_with_log`
- `verify-with-log.ps1` - Use `Invoke-CommandWithLog`
- `check-sprint2-status.ps1` - Convert to wrapper pattern

### Short-term (Sprint 3)

**Update 07-foundation-layer**:
- Add Section 3.5 to copilot-instructions-template.md
- Document in PROJECT7-VALUE-TO-AI-AGENTS.md
- Add to Apply-Project07-Artifacts.ps1 deployment

**Update workspace copilot-instructions**:
- Add wrapper reference to EVA-Wide Rules
- Document as mandatory pattern for all terminal commands

### Medium-term (Q1 2026)

**Retrofit all EVA projects**:
- Audit all terminal commands in workflow files
- Convert to wrapper pattern where output needed
- Update skills with wrapper examples

**Add to DPDCA templates**:
- CHECK phase: Always use wrapper for test runs
- ACT phase: Always use wrapper for state queries

---

## Maintenance

**Version**: 1.0.0  
**Owner**: 07-foundation-layer  
**Review cycle**: Quarterly  
**Breaking changes**: Require EVA-wide notification  

**Changelog**:
- 2026-02-28 v1.0.0 - Initial implementation (PowerShell + Python)

---

## Related Patterns

- **DebugArtifactCollector** - Professional component from Apply-Project07-Artifacts.ps1 (evidence capture)
- **SessionManager** - Professional component (checkpoint/resume)
- **StructuredErrorHandler** - Professional component (JSON logging)

**Difference**: This wrapper is lighter-weight, focused specifically on terminal output capture bug. The professional components are for production code; this is for agent infrastructure.

---

## Success Criteria

**Wrapper is successful when**:
- No MORE "terminal output not showing" in AI sessions
- 100% reliability on command result capture
- Adoption in >= 5 EVA projects
- Zero manual log file searching required
- Auto-cleanup prevents disk bloat

**Metrics**:
- Log files created per day: Track usage
- Average log file size: Monitor for bloat
- Commands using wrapper vs bare terminal: Adoption rate
- Failed extractions: Pattern quality indicator
