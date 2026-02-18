# GitHub Copilot Instructions Template

**Template Version**: 2.1.0  
**Generated**: January 30, 2026, 2:00 PM EST  
**Last Updated**: January 30, 2026  
**Project Type**: {PROJECT_TYPE}  
**Based on**: EVA Professional Component Architecture Standards (from EVA-JP-v1.2 production learnings)

---

## Release Notes

### Version 2.1.0 (January 30, 2026)
**Breaking Changes**:
- Redesigned PART 2 from generic [TODO] format to AI-instructional placeholders
- Added [INSTRUCTION for AI] markers explaining what content to fill and why
- Introduced **[MANDATORY]** vs **[RECOMMENDED]** category markers for prioritization

**New Features**:
- 11 structured placeholder categories based on production analysis (EVA-JP-v1.2, MS-InfoJP)
- Enhanced placeholder syntax with examples: `[TODO: Add X - e.g., value format]`
- Quick Commands Table (action-oriented lookup)
- Azure Resource Inventory (subscription IDs, resource groups)
- Anti-Patterns sections (❌ FORBIDDEN patterns with explanations)
- Success Criteria / Testable Goals
- Performance/Timing Expectations
- Deployment Status & Known Issues tracking

**Improvements**:
- Template now generates AI instruction manual (not documentation)
- Placeholders show correct format/structure (imperative, conditional, reference patterns)
- Backward compatible: existing PART 2 sections remain valid
- Research-based design: 100% coverage of high-frequency patterns (Quick Commands, Environment Config, File Paths)

**Migration Notes**:
- Projects using v2.0.0 template can continue as-is
- New projects should use v2.1.0 structured placeholders
- Apply-Project07-Artifacts.ps1 v1.4.0+ compatible with both versions

### Version 2.0.0 (January 29, 2026)
**Breaking Changes**:
- Transformed from project-specific to reusable template
- Added comprehensive placeholder system for all project-specific values
- Enhanced with anti-patterns prevention and quality gates

**New Features**:
- Template Usage Instructions section
- Anti-Patterns Prevention section
- Emergency Debugging Protocol
- File Organization Requirements
- Quality Gates checklist

**Improvements**:
- Complete PART 1 preservation (universal best practices)
- Structured placeholder guidance in PART 2
- Professional component implementations remain intact
- Enhanced documentation structure

### Version 1.0.0 (January 9, 2026)
**Initial Production Release**:
- Universal best practices (PART 1)
- EVA-JP-v1.2 project-specific patterns (PART 2)
- Professional Component Architecture (DebugArtifactCollector, SessionManager, StructuredErrorHandler, ProfessionalRunner)
- Azure account management patterns
- Workspace housekeeping principles
- Encoding safety standards

---

## Table of Contents

### PART 1: Universal Best Practices
- [Encoding & Script Safety](#critical-encoding--script-safety)
- [Azure Account Management](#critical-azure-account-management)
- [AI Context Management](#ai-context-management-strategy)
- [Azure Services Inventory](#azure-services--capabilities-inventory)
- [Professional Component Architecture](#professional-component-architecture)
  - [DebugArtifactCollector](#implementation-debugartifactcollector)
  - [SessionManager](#implementation-sessionmanager)
  - [StructuredErrorHandler](#implementation-structurederrorhandler)
  - [ProfessionalRunner](#implementation-zero-setup-project-runner)
- [Professional Transformation](#professional-transformation-methodology)
- [Dependency Management](#dependency-management-with-alternatives)
- [Workspace Housekeeping](#workspace-housekeeping-principles)
- [Code Style Standards](#code-style-standards)

### PART 2: {PROJECT_NAME} Project Specific
- [Documentation Guide](#documentation-guide)
- [Architecture Overview](#architecture-overview)
- [Development Workflows](#development-workflows)
- [Project-Specific Automation](#project-specific-automation)
- [Critical Code Patterns](#critical-code-patterns)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)
- [Performance Optimization](#performance-optimization)

### PART 3: Quality & Safety
- [Anti-Patterns Prevention](#anti-patterns-prevention)
- [File Organization Requirements](#file-organization-requirements)
- [Quality Gates](#quality-gates)
- [Emergency Debugging Protocol](#emergency-debugging-protocol)

### PART 4: Template Usage
- [Template Usage Instructions](#template-usage-instructions)

---

## Quick Reference

**Most Critical Patterns**:
1. **Encoding Safety** - Always use ASCII-only in scripts (prevents UnicodeEncodeError in Windows cp1252)
2. **Azure Account** - Professional account {PROFESSIONAL_EMAIL} required for {ORGANIZATION} resources (configure based on your subscription)
3. **Component Architecture** - DebugArtifactCollector + SessionManager + StructuredErrorHandler + ProfessionalRunner
4. **Session Management** - Checkpoint/resume capability for long-running operations
5. **Evidence Collection** - Screenshots, HTML dumps, network traces at operation boundaries

**Professional Components** (Full Working Implementations):

| Component | Purpose | Key Methods |
|-----------|---------|-------------|
| **DebugArtifactCollector** | Capture HTML/screenshots/traces | `capture_state()`, `set_page()` |
| **SessionManager** | Checkpoint/resume operations | `save_checkpoint()`, `load_latest_checkpoint()` |
| **StructuredErrorHandler** | JSON error logging | `log_error()`, `log_structured_event()` |
| **ProfessionalRunner** | Zero-setup execution | `auto_detect_project_root()`, `validate_pre_flight()` |

**Where to Find Source**:
- Complete working system: `{PROJECT_IMPLEMENTATION_PATH}`
- Best practices reference: `{BEST_PRACTICES_PATH}`
- Framework architecture: `{FRAMEWORK_ARCHITECTURE_PATH}`

---

## PART 1: UNIVERSAL BEST PRACTICES

> **Applicable to any project, any scenario**  
> Critical patterns, Azure inventory management, workspace organization principles

### Critical: Encoding & Script Safety

**ABSOLUTE BAN: No Unicode/Emojis Anywhere**
- **NEVER use in code**: Checkmarks, X marks, emojis, Unicode symbols, ellipsis
- **NEVER use in reports**: Unicode decorations, fancy bullets, special characters
- **NEVER use in documentation**: Unless explicitly required by specification
- **ALWAYS use**: Pure ASCII - "[PASS]", "[FAIL]", "[ERROR]", "[INFO]", "[WARN]", "..."
- **Reason**: Enterprise Windows cp1252 encoding causes silent UnicodeEncodeError crashes
- **Solution**: Set `PYTHONIOENCODING=utf-8` in batch files as safety measure

**Examples**:
```python
# [FORBIDDEN] Will crash in enterprise Windows
print("✓ Success")  # Unicode checkmark - NEVER
print("❌ Failed")   # Unicode X - NEVER
print("⏳ Wait…")    # Unicode symbols - NEVER

# [REQUIRED] ASCII-only alternatives
print("[PASS] Success")
print("[FAIL] Failed")
print("[INFO] Wait...")
```

### Critical: Azure Account Management

**Multiple Azure Accounts Pattern**
- **Personal Account**: {PERSONAL_SUBSCRIPTION_NAME} ({PERSONAL_SUBSCRIPTION_ID}) - personal sandbox
- **Professional Account**: {PROFESSIONAL_EMAIL} - {ORGANIZATION} production access
- **{ORGANIZATION} Subscriptions** (require professional account):
  - {DEV_SUBSCRIPTION_NAME} ({DEV_SUBSCRIPTION_ID}) - Dev+Stage environments
  - {PROD_SUBSCRIPTION_NAME} ({PROD_SUBSCRIPTION_ID}) - Production environments

**When Azure CLI fails with "subscription doesn't exist"**:
1. Check current account: `az account show --query user.name`
2. Switch accounts: `az logout` then `az login --use-device-code --tenant {TENANT_ID}`
3. Authenticate with professional email: {PROFESSIONAL_EMAIL}
4. Verify access: `az account list --query "[?contains(id, '{DEV_SUBSCRIPTION_ID_PARTIAL}') || contains(id, '{PROD_SUBSCRIPTION_ID_PARTIAL}')]"`

**Pattern**: If accessing {ORGANIZATION} resources, ALWAYS use professional account

### AI Context Management Strategy

**Pattern**: Systematic approach to avoid context overload

**5-Step Process**:
1. **Assess**: What context do I need? (Don't load everything)
2. **Prioritize**: What's most relevant NOW? (Focus on current task)
3. **Load**: Get specific context only (Use targeted file reads, grep searches)
4. **Execute**: Perform task with loaded context
5. **Verify**: Validate result matches intent

**Example**:
```python
# [AVOID] Bad: Load entire file when only need one function
with open('large_file.py') as f:
    content = f.read()  # Loads 10,000 lines

# [RECOMMENDED] Good: Targeted context loading
grep_search(query="def target_function", includePattern="large_file.py")
read_file(filePath="large_file.py", startLine=450, endLine=500)
```

**When to re-assess context**:
- Task scope changes
- Error requires different context
- User provides new information

### Azure Services & Capabilities Inventory

**Azure OpenAI**
- **Models**: GPT-4, GPT-4 Turbo, text-embedding-ada-002
- **Endpoints**: {AZURE_OPENAI_ENDPOINT}
- **Use Cases**: Chat completions, embeddings, content generation
- **Authentication**: API key or DefaultAzureCredential

**Azure AI Services (Cognitive Services)**
- **Capabilities**: Query optimization, content safety, content understanding
- **Use Cases**: Text analysis, translation, content moderation
- **Pattern**: Always implement fallback for private endpoint failures

**Azure Cognitive Search**
- **Capabilities**: Hybrid search (vector + keyword), semantic ranking
- **Use Cases**: Document search, RAG systems, knowledge bases
- **Pattern**: Use index-based access, implement retry logic

**Azure Cosmos DB**
- **Capabilities**: NoSQL database, session storage, change feed
- **Use Cases**: Session management, audit logs, CDC patterns
- **Pattern**: Use partition keys effectively, implement TTL

**Azure Blob Storage**
- **Capabilities**: Object storage, containers, metadata
- **Use Cases**: Document storage, file uploads, static assets
- **Pattern**: Use managed identity, implement lifecycle policies

**Azure Functions**
- **Capabilities**: Serverless compute, event-driven processing
- **Use Cases**: Document pipelines, webhook handlers, scheduled jobs
- **Pattern**: Use blob triggers, queue bindings

**Azure Document Intelligence**
- **Capabilities**: OCR, form recognition, layout analysis
- **Use Cases**: PDF processing, document extraction
- **Pattern**: Handle rate limits, implement retry logic

### Professional Component Architecture

**Pattern**: Enterprise-grade component design (from Project 06/07)

**Every professional component implements**:
- **DebugArtifactCollector**: Evidence at operation boundaries
- **SessionManager**: Checkpoint/resume capabilities
- **StructuredErrorHandler**: JSON logging with context
- **Observability Wrapper**: Pre-state, execution, post-state capture

**Usage Pattern - Combining Components**:

> **Note**: The following shows a conceptual pattern for combining components. For complete, production-ready implementations you can copy-paste directly, see the detailed sections below.
```python
from pathlib import Path
from datetime import datetime
import json

class ProfessionalComponent:
    """Base class for enterprise-grade components"""
    
    def __init__(self, component_name: str, base_path: Path):
        self.component_name = component_name
        self.base_path = base_path
        
        # Core professional infrastructure
        self.debug_collector = DebugArtifactCollector(component_name, base_path)
        self.session_manager = SessionManager(component_name, base_path)
        self.error_handler = StructuredErrorHandler(component_name, base_path)
    
    async def execute_with_observability(self, operation_name: str, operation):
        """Execute operation with full evidence collection"""
        # 1. ALWAYS capture pre-state
        await self.debug_collector.capture_state(f"{operation_name}_before")
        await self.session_manager.save_checkpoint("before_operation", {
            "operation": operation_name,
            "timestamp": datetime.now().isoformat()
        })
        
        try:
            # 2. Execute operation
            result = await operation()
            
            # 3. ALWAYS capture success state
            await self.debug_collector.capture_state(f"{operation_name}_success")
            await self.session_manager.save_checkpoint("operation_success", {
                "operation": operation_name,
                "result_preview": str(result)[:200]
            })
            return result
            
        except Exception as e:
            # 4. ALWAYS capture error state
            await self.debug_collector.capture_state(f"{operation_name}_error")
            await self.error_handler.log_structured_error(operation_name, e)
            raise
```

**When to use**: Any component that interacts with external systems, complex logic, or enterprise automation

---

### Implementation: DebugArtifactCollector

**Purpose**: Capture comprehensive diagnostic state at system boundaries for rapid debugging

**Working Implementation** (from Project 06):
```python
from pathlib import Path
from datetime import datetime
import json
import asyncio

class DebugArtifactCollector:
    """Systematic evidence capture at operation boundaries
    
    Captures HTML, screenshots, network traces, and structured logs
    for every significant operation to enable rapid debugging.
    """
    
    def __init__(self, component_name: str, base_path: Path):
        """Initialize collector for specific component
        
        Args:
            component_name: Name of component (e.g., "authentication", "data_extraction")
            base_path: Project root directory
        """
        self.component_name = component_name
        self.debug_dir = base_path / "debug" / component_name
        self.debug_dir.mkdir(parents=True, exist_ok=True)
        
        self.page = None  # Set by browser automation
        self.network_log = []  # Populated by network listener
    
    async def capture_state(self, context: str):
        """Capture complete diagnostic state
        
        Args:
            context: Operation context (e.g., "before_login", "after_submit", "error_state")
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 1. Capture HTML snapshot
        if self.page:
            html_file = self.debug_dir / f"{context}_{timestamp}.html"
            html_content = await self.page.content()
            html_file.write_text(html_content, encoding='utf-8')
        
        # 2. Capture screenshot
        if self.page:
            screenshot_file = self.debug_dir / f"{context}_{timestamp}.png"
            await self.page.screenshot(path=str(screenshot_file), full_page=True)
        
        # 3. Capture network trace
        if self.network_log:
            network_file = self.debug_dir / f"{context}_{timestamp}_network.json"
            network_file.write_text(json.dumps(self.network_log, indent=2))
        
        # 4. Capture structured log with application state
        log_file = self.debug_dir / f"{context}_{timestamp}.json"
        log_file.write_text(json.dumps({
            "timestamp": timestamp,
            "context": context,
            "component": self.component_name,
            "url": self.page.url if self.page else None,
            "viewport": await self.page.viewport_size() if self.page else None
        }, indent=2))
        
        return {
            "html": str(html_file) if self.page else None,
            "screenshot": str(screenshot_file) if self.page else None,
            "network": str(network_file) if self.network_log else None,
            "log": str(log_file)
        }
    
    def set_page(self, page):
        """Attach to browser page for capture"""
        self.page = page
        
        # Enable network logging
        async def log_request(request):
            self.network_log.append({
                "timestamp": datetime.now().isoformat(),
                "type": "request",
                "url": request.url,
                "method": request.method
            })
        
        page.on("request", lambda req: asyncio.create_task(log_request(req)))
```

**Usage Pattern**:
```python
# In your automation component
collector = DebugArtifactCollector("my_component", project_root)
collector.set_page(page)

# Before risky operation
await collector.capture_state("before_submit")

try:
    await risky_operation()
    await collector.capture_state("success")
except Exception as e:
    await collector.capture_state("error")
    raise
```

---

### Implementation: SessionManager

**Purpose**: Enable checkpoint/resume capabilities for long-running operations

**Working Implementation** (from Project 06):
```python
from pathlib import Path
from datetime import datetime, timedelta
import json
import shutil
from typing import Dict, Optional

class SessionManager:
    """Manages persistent session state for checkpoint/resume operations
    
    Enables long-running automation to save progress and resume
    from last successful checkpoint if interrupted.
    """
    
    def __init__(self, component_name: str, base_path: Path):
        """Initialize session manager
        
        Args:
            component_name: Component identifier
            base_path: Project root directory
        """
        self.component_name = component_name
        self.session_dir = base_path / "sessions" / component_name
        self.session_dir.mkdir(parents=True, exist_ok=True)
        
        self.session_file = self.session_dir / "session_state.json"
        self.checkpoint_dir = self.session_dir / "checkpoints"
        self.checkpoint_dir.mkdir(exist_ok=True)
    
    def save_checkpoint(self, checkpoint_id: str, data: Dict) -> Path:
        """Save checkpoint with state data
        
        Args:
            checkpoint_id: Unique checkpoint identifier (e.g., "item_5_processed")
            data: State data to persist
            
        Returns:
            Path to saved checkpoint file
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        checkpoint_file = self.checkpoint_dir / f"{checkpoint_id}_{timestamp}.json"
        
        checkpoint_data = {
            "checkpoint_id": checkpoint_id,
            "timestamp": datetime.now().isoformat(),
            "component": self.component_name,
            "data": data
        }
        
        checkpoint_file.write_text(json.dumps(checkpoint_data, indent=2))
        
        # Update session state to point to latest checkpoint
        self.update_session_state(checkpoint_id, str(checkpoint_file))
        
        return checkpoint_file
    
    def load_latest_checkpoint(self) -> Optional[Dict]:
        """Load most recent checkpoint if available
        
        Returns:
            Checkpoint data or None if no checkpoint exists
        """
        if not self.session_file.exists():
            return None
        
        try:
            session_data = json.loads(self.session_file.read_text())
            checkpoint_file = Path(session_data.get("latest_checkpoint"))
            
            if checkpoint_file.exists():
                return json.loads(checkpoint_file.read_text())
            
        except Exception as e:
            print(f"[WARN] Failed to load checkpoint: {e}")
        
        return None
    
    def update_session_state(self, checkpoint_id: str, checkpoint_path: str):
        """Update session state with latest checkpoint reference"""
        session_data = {
            "component": self.component_name,
            "last_updated": datetime.now().isoformat(),
            "latest_checkpoint": checkpoint_path,
            "checkpoint_id": checkpoint_id
        }
        
        self.session_file.write_text(json.dumps(session_data, indent=2))
    
    def clear_session(self):
        """Clear all session state and checkpoints"""
        if self.checkpoint_dir.exists():
            shutil.rmtree(self.checkpoint_dir)
            self.checkpoint_dir.mkdir()
        
        if self.session_file.exists():
            self.session_file.unlink()
```

**Usage Pattern**:
```python
# Initialize session manager
session_mgr = SessionManager("batch_processor", project_root)

# Try to resume from checkpoint
checkpoint = session_mgr.load_latest_checkpoint()
if checkpoint:
    start_index = checkpoint["data"]["last_processed_index"]
    print(f"[INFO] Resuming from checkpoint: item {start_index}")
else:
    start_index = 0

# Process items with checkpoints
for i in range(start_index, len(items)):
    process_item(items[i])
    
    # Save checkpoint every 10 items
    if i % 10 == 0:
        session_mgr.save_checkpoint(f"item_{i}", {
            "last_processed_index": i,
            "items_completed": i + 1,
            "timestamp": datetime.now().isoformat()
        })
```

---

### Implementation: StructuredErrorHandler

**Purpose**: Provide JSON-based error logging with full context for debugging

**Working Implementation** (from Project 06):
```python
from datetime import datetime
from typing import Dict, Any, Optional
from pathlib import Path
import json
import traceback

class StructuredErrorHandler:
    """Enterprise-grade error handling with structured logging
    
    Captures errors with full context in JSON format for easy parsing
    and analysis. All output is ASCII-safe for enterprise Windows.
    """
    
    def __init__(self, component_name: str, base_path: Path):
        """Initialize error handler
        
        Args:
            component_name: Component identifier
            base_path: Project root directory
        """
        self.component_name = component_name
        self.error_dir = base_path / "logs" / "errors"
        self.error_dir.mkdir(parents=True, exist_ok=True)
    
    def log_error(self, error: Exception, context: Optional[Dict[str, Any]] = None) -> Dict:
        """Log error with structured context
        
        Args:
            error: Exception object
            context: Additional context (operation name, parameters, etc.)
            
        Returns:
            Error report dictionary
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        error_report = {
            "timestamp": datetime.now().isoformat(),
            "component": self.component_name,
            "error_type": type(error).__name__,
            "error_message": str(error),
            "traceback": traceback.format_exc(),
            "context": context or {}
        }
        
        # Save to timestamped file
        error_file = self.error_dir / f"{self.component_name}_error_{timestamp}.json"
        error_file.write_text(json.dumps(error_report, indent=2))
        
        # Print ASCII-safe error message
        print(f"[ERROR] {self.component_name}: {type(error).__name__}")
        print(f"[ERROR] Message: {str(error)}")
        print(f"[ERROR] Details saved to: {error_file}")
        
        return error_report
    
    def log_structured_event(self, event_type: str, data: Dict[str, Any]):
        """Log structured event (non-error)
        
        Args:
            event_type: Event type (e.g., "operation_start", "data_validated")
            data: Event data
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        event_report = {
            "timestamp": datetime.now().isoformat(),
            "component": self.component_name,
            "event_type": event_type,
            "data": data
        }
        
        # Save to events log
        event_file = self.error_dir.parent / f"{self.component_name}_events_{timestamp}.json"
        event_file.write_text(json.dumps(event_report, indent=2))

class ProjectBaseException(Exception):
    """Base exception with structured error reporting
    
    All custom exceptions should inherit from this to ensure
    consistent error handling and reporting.
    """
    
    def __init__(self, message: str, context: Optional[Dict[str, Any]] = None):
        """Initialize exception with context
        
        Args:
            message: Error description (ASCII only)
            context: Additional error context
        """
        super().__init__(message)
        self.message = message
        self.context = context or {}
        self.timestamp = datetime.now().isoformat()
    
    def get_error_report(self) -> Dict[str, Any]:
        """Generate structured error report
        
        Returns:
            Dictionary with full error details
        """
        return {
            "error_type": self.__class__.__name__,
            "message": self.message,
            "context": self.context,
            "timestamp": self.timestamp
        }
```

**Usage Pattern**:
```python
# Initialize error handler
error_handler = StructuredErrorHandler("my_automation", project_root)

try:
    risky_operation()
except Exception as e:
    # Log with context
    error_handler.log_error(e, context={
        "operation": "data_processing",
        "input_file": "data.csv",
        "current_row": 42
    })
    raise

# Custom exception with automatic context
class DataValidationError(ProjectBaseException):
    pass

try:
    if not is_valid(data):
        raise DataValidationError(
            "Invalid data format",
            context={"expected": "CSV", "received": "JSON"}
        )
except DataValidationError as e:
    error_report = e.get_error_report()
    error_handler.log_error(e, context=error_report["context"])
```

---

### Implementation: Zero-Setup Project Runner

**Purpose**: Enable users to run project from anywhere without configuration

**Working Implementation** (from Project 06):
```python
#!/usr/bin/env python3
"""Professional project runner with zero-setup execution"""

import os
import sys
import argparse
from pathlib import Path
import subprocess
from typing import List

# Set UTF-8 encoding for Windows
os.environ.setdefault('PYTHONIOENCODING', 'utf-8')

class ProfessionalRunner:
    """Zero-setup professional automation wrapper"""
    
    def __init__(self):
        self.project_root = self.auto_detect_project_root()
        self.main_script = "scripts/main_automation.py"
    
    def auto_detect_project_root(self) -> Path:
        """Find project root from any subdirectory
        
        Searches for project markers in current and parent directories
        to enable running from any location within the project.
        """
        current = Path.cwd()
        
        # Project indicators (customize for your project)
        indicators = [
            "scripts/main_automation.py",
            "ACCEPTANCE.md",
            "README.md",
            ".git"
        ]
        
        # Check current directory
        for indicator in indicators:
            if (current / indicator).exists():
                return current
        
        # Check parent directories
        for parent in current.parents:
            for indicator in indicators:
                if (parent / indicator).exists():
                    return parent
        
        # Fallback to current directory
        print("[WARN] Could not auto-detect project root, using current directory")
        return current
    
    def validate_pre_flight(self) -> tuple[bool, str]:
        """Pre-flight checks before execution
        
        Validates environment, dependencies, and project structure.
        
        Returns:
            (success: bool, message: str)
        """
        checks = []
        
        # Check main script exists
        main_script_path = self.project_root / self.main_script
        if not main_script_path.exists():
            return False, f"[FAIL] Main script not found: {main_script_path}"
        checks.append("[PASS] Main script found")
        
        # Check required directories
        required_dirs = ["input", "output", "logs"]
        for dir_name in required_dirs:
            dir_path = self.project_root / dir_name
            if not dir_path.exists():
                dir_path.mkdir(parents=True)
                checks.append(f"[INFO] Created directory: {dir_name}")
            else:
                checks.append(f"[PASS] Directory exists: {dir_name}")
        
        # Check Python dependencies
        try:
            import pandas
            import asyncio
            checks.append("[PASS] Required Python modules available")
        except ImportError as e:
            return False, f"[FAIL] Missing Python module: {e}"
        
        return True, "\n".join(checks)
    
    def build_command(self, **kwargs) -> List[str]:
        """Build command with normalized parameters
        
        Converts user inputs to proper command structure.
        """
        cmd = [
            sys.executable,
            str(self.project_root / self.main_script)
        ]
        
        # Add parameters (customize for your project)
        for key, value in kwargs.items():
            if value is not None:
                if isinstance(value, bool):
                    if value:
                        cmd.append(f"--{key}")
                else:
                    cmd.extend([f"--{key}", str(value)])
        
        return cmd
    
    def execute_with_enterprise_safety(self, cmd: List[str]) -> int:
        """Execute with proper encoding and error handling"""
        # Set environment
        env = os.environ.copy()
        env['PYTHONIOENCODING'] = 'utf-8'
        
        # Change to project root
        original_cwd = os.getcwd()
        os.chdir(self.project_root)
        
        try:
            print(f"[INFO] Project root: {self.project_root}")
            print(f"[INFO] Command: {' '.join(cmd)}")
            print("-" * 60)
            
            result = subprocess.run(cmd, env=env)
            return result.returncode
            
        finally:
            os.chdir(original_cwd)
    
    def run(self, **kwargs) -> int:
        """Main execution entry point"""
        print("[INFO] Professional Runner - Zero-Setup Execution")
        print(f"[INFO] Detected project root: {self.project_root}")
        
        # Pre-flight validation
        success, message = self.validate_pre_flight()
        print("\n" + message)
        
        if not success:
            print("\n[FAIL] Pre-flight checks failed")
            return 1
        
        # Build and execute command
        cmd = self.build_command(**kwargs)
        return self.execute_with_enterprise_safety(cmd)

def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description="Professional automation runner with zero-setup execution"
    )
    
    # Add your project-specific arguments here
    parser.add_argument("--input", help="Input file path")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--headless", action="store_true", help="Run in headless mode")
    
    args = parser.parse_args()
    
    # Create runner and execute
    runner = ProfessionalRunner()
    sys.exit(runner.run(**vars(args)))

if __name__ == "__main__":
    main()
```

**Usage**:
```bash
# Run from anywhere in the project
python run_project.py --input data.csv --output results.csv

# Or create Windows batch wrapper
# run_project.bat:
@echo off
set PYTHONIOENCODING=utf-8
python run_project.py %*
```

---

### Professional Transformation Methodology

**Pattern**: Systematic 4-step approach to enterprise-grade development

**When refactoring or creating automation systems**:

1. **Foundation Systems** (20% of work)
   - Create `debug/`, `evidence/`, `logs/` directory structure
   - Establish coding standards and utilities
   - Implement ASCII-only error handling
   - Set up structured logging infrastructure

2. **Testing Framework** (30% of work)
   - Automated validation with evidence collection
   - Component-level unit tests
   - Integration tests with retry logic
   - Acceptance criteria validation

3. **Main System Refactoring** (40% of work)
   - Apply professional component architecture
   - Integrate validation and observability
   - Implement graceful error handling
   - Add session management and checkpoints

4. **Documentation & Cleanup** (10% of work)
   - Consolidate redundant code
   - Document patterns and decisions
   - Create runbooks and troubleshooting guides
   - Archive superseded implementations

**Quality Gate**: Each phase produces evidence before proceeding to next phase

### Dependency Management with Alternatives

**Pattern**: Handle blocked packages in enterprise environments

**Always provide fallback alternatives**:

```python
# Pattern 1: Try primary, fall back to alternative
try:
    from playwright.async_api import async_playwright
    BROWSER_ENGINE = "playwright"
except ImportError:
    print("[INFO] Playwright not available, using Selenium")
    from selenium import webdriver
    BROWSER_ENGINE = "selenium"

# Pattern 2: Feature detection
def get_available_http_client():
    """Return best available HTTP client"""
    if importlib.util.find_spec("httpx"):
        import httpx
        return httpx.AsyncClient()
    elif importlib.util.find_spec("aiohttp"):
        import aiohttp
        return aiohttp.ClientSession()
    else:
        import urllib.request
        return urllib.request  # Fallback to stdlib

# Pattern 3: Document alternatives in requirements
# requirements.txt:
# playwright>=1.40.0  # Primary choice
# selenium>=4.15.0    # Alternative if playwright blocked
# requests>=2.31.0    # Fallback for basic HTTP
```

**Document why alternatives chosen**: Add comments explaining enterprise constraints

### Workspace Housekeeping Principles

**Context Engineering - Keep AI context clean and focused**

**Best Practices**:
- **Root directory**: Active operations only (`RESTART_SERVERS.ps1`, `README.md`)
- **Context folder**: Use `docs/eva-foundation/` as AI agent "brain"
  - `projects/` - Active work with debugging artifacts
  - `workspace-notes/` - Ephemeral notes, workflow docs
  - `system-analysis/` - Architecture docs, inventory reports
  - `comparison-reports/` - Automated comparison outputs
  - `automation/` - Code generation scripts

**Pattern**: If referenced in copilot-instructions.md or used for AI context → belongs in `docs/eva-foundation/`

**File Organization Rules**:
1. **Logs** → `logs/{category}/`
   - `logs/deployment/terraform/` - Terraform logs
   - `logs/deployment/` - Deployment logs
   - `logs/tests/` - Test output

2. **Scripts** → `scripts/{category}/`
   - `scripts/deployment/` - Deploy, build, infrastructure
   - `scripts/testing/` - Test runners, evidence capture
   - `scripts/setup/` - Installation, configuration
   - `scripts/diagnostics/` - Health checks, validation
   - `scripts/housekeeping/` - Workspace organization

3. **Documentation** → `docs/{category}/`
   - Implementation docs → `docs/eva-foundation/projects/{project-name}/`
   - Deployment guides → `docs/deployment/`
   - Debug sessions → `docs/eva-foundation/projects/{session-name}-debug/`

**Naming Conventions**:
- **Scripts**: `verb-noun.ps1` (lowercase-with-dashes)
  - [RECOMMENDED] Good: `deploy-infrastructure.ps1`, `test-environment.ps1`
  - [AVOID] Bad: `Deploy-MSInfo-Fixed.ps1`, `TEST_COMPLETE.ps1`
- **Docs**: `CATEGORY-DESCRIPTION.md` (UPPERCASE for status docs)
  - [RECOMMENDED] Good: `DEPLOYMENT-STATUS.md`, `IMPLEMENTATION-SUMMARY.md`
  - [AVOID] Bad: `Final-Status-Report.ps1.md`
- **Logs**: `{operation}-{timestamp}.log` or `{component}.log`

**Self-Organizing Rules for AI Agents**:
- **Before creating a file**: Check if similar file exists in `docs/eva-foundation/`
- **When debugging**: Create session folder `docs/eva-foundation/projects/{issue-name}-debug/`
- **After completing work**: Summarize findings in `docs/eva-foundation/workspace-notes/`
- **When context grows**: Create comparison report, archive superseded versions

**Housekeeping Automation**:
```powershell
# Daily cleanup
.\scripts\housekeeping\organize-workspace.ps1

# Weekly archival
.\scripts\housekeeping\archive-debug-sessions.ps1
```

### Evidence Collection at Operation Boundaries

**Goal**: Systematic evidence capture for rapid debugging

**MANDATORY: Every component operation must capture**:
- **Pre-state**: HTML, screenshots, network traces BEFORE execution
- **Success state**: Evidence on successful completion  
- **Error state**: Full diagnostic artifacts on failure
- **Structured logging**: JSON-based error context with timestamps

**Implementation Pattern**:
```python
class DebugArtifactCollector:
    def __init__(self, component_name: str, base_path: Path):
        self.component_name = component_name
        self.debug_dir = base_path / "debug" / component_name
        self.debug_dir.mkdir(parents=True, exist_ok=True)
    
    async def capture_state(self, context: str):
        """Capture complete diagnostic state"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Capture HTML snapshot
        if self.page:  # Browser automation
            html_file = self.debug_dir / f"{context}_{timestamp}.html"
            await self.page.content().write(html_file)
        
        # Capture screenshot
        if self.page:
            screenshot_file = self.debug_dir / f"{context}_{timestamp}.png"
            await self.page.screenshot(path=screenshot_file)
        
        # Capture network trace
        if self.network_log:
            network_file = self.debug_dir / f"{context}_{timestamp}_network.json"
            network_file.write_text(json.dumps(self.network_log, indent=2))
        
        # Capture structured log
        log_file = self.debug_dir / f"{context}_{timestamp}.json"
        log_file.write_text(json.dumps({
            "timestamp": timestamp,
            "context": context,
            "component": self.component_name,
            "url": str(self.page.url) if self.page else None,
            "state": await self._capture_application_state()
        }, indent=2))
```

**Timestamped Naming Convention (MANDATORY)**:
- Pattern: `{component}_{context}_{YYYYMMDD_HHMMSS}.{ext}`
- Examples:
  - `{component}_debug_error_attempt_1_{YYYYMMDD_HHMMSS}.html`
  - `automation_execution_{YYYYMMDD_HHMMSS}.log`
  - `results_batch_001_{YYYYMMDD_HHMMSS}.csv`
- Benefits: Chronological sorting, parallel execution support, audit trails

**Azure Configuration State Tracking**:

**Structure**:
```
docs/eva-foundation/system-analysis/inventory/.eva-cache/
  azure-connectivity-{subscription}-{timestamp}.md
  azure-permissions-{subscription}-{timestamp}.md
  evidence-{subscription}-{timestamp}.md
  canonical-analysis/{storage-account}-{timestamp}.md
```

**Usage Pattern**:
1. Capture current state: `evidence-{subscription}-{timestamp}.md`
2. Compare with previous state: `evidence-{subscription}-{earlier-timestamp}.md`
3. Generate comparison report: `comparison-report-{timestamp}.md`
4. Document findings in project debug folder

### Code Style Standards

**Python**:
- **Type Hints**: Use for all function signatures
- **Async/Await**: Use throughout for I/O operations
- **Naming**: `snake_case` functions/variables, `PascalCase` classes
- **Formatting**: Black (line length 180) + isort
- **Error Handling**: Wrap external calls with try/except, respect `OPTIONAL` flags

**TypeScript**:
- **Naming**: `camelCase` functions/variables, `PascalCase` components/types
- **Components**: Functional components with hooks
- **State**: React Context for global state
- **Styling**: CSS Modules + component libraries

**Files**:
- Python: `snake_case.py`
- TypeScript: `lowercase-with-dashes.tsx`

---

**You are now ready for project-specific patterns**  
See [PART 2: {PROJECT_NAME} Project Specific](#part-2-project-name-project-specific) below for AI-instructional project patterns.

---

## PART 2: {PROJECT_NAME} PROJECT SPECIFIC

> **AI INSTRUCTION MODE**: This section provides structured instructions for AI assistants working on this project.  
> Use imperative language ("Use X for Y", "When user asks X, do Y") not descriptive documentation.

---

### **[MANDATORY]** Category 1: Quick Commands Table

**Purpose**: Instant command lookup without parsing prose. AI needs copy-paste ready commands.

| Task | Command | Expected Time | Output Location |
|------|---------|---------------|-----------------|
| **Start {COMPONENT_1}** | `[TODO: e.g., python app.py]` | [TODO: e.g., <5 sec] | [TODO: e.g., http://localhost:5000] |
| **Start {COMPONENT_2}** | `[TODO: e.g., npm run dev]` | [TODO: e.g., <10 sec] | [TODO: e.g., http://localhost:5173] |
| **Run Tests** | `[TODO: e.g., pytest tests/]` | [TODO: e.g., 30 sec] | [TODO: e.g., Terminal output] |
| **Deploy** | `[TODO: e.g., make deploy]` | [TODO: e.g., 5-10 min] | [TODO: e.g., Azure Portal] |
| **Stop All** | `[TODO: e.g., ./STOP_SERVERS.ps1]` | [TODO: e.g., <2 sec] | [TODO: Terminal] |

**Quick Restart Pattern**:
```powershell
[TODO: Add quick restart script - e.g., .\RESTART_SERVERS.ps1]
```

**[INSTRUCTION for AI]**: 
- Replace [TODO] with literal commands users run daily
- Include expected timing to set user expectations
- Specify output location (terminal, browser URL, file path)
- Make commands copy-paste ready (no placeholders in actual commands)

---

### **[MANDATORY]** Category 2: Azure Resource Inventory

**Purpose**: AI needs to know WHICH Azure account/resources to use (critical for multi-tenant/multi-subscription).

**Development Environment**:
- **Subscription Name**: `[TODO: e.g., PayAsYouGo Subs 1]`
- **Subscription ID**: `[TODO: e.g., c59ee575-eb2a-4b51-a865-4b618f9add0a]`
- **Tenant ID**: `[TODO: e.g., bfb12ca1-7f37-47d5-9cf5-8aa52214a0d8]`
- **Resource Group**: `[TODO: e.g., rg-dev-eastus2]` (Region: [TODO: e.g., East US 2])

**Production Environment** (if different):
- **Subscription Name**: `[TODO: e.g., ESDC Production]`
- **Subscription ID**: `[TODO: e.g., d2d4e571-e0f2-4f6c-901a-f88f7669bcba]`
- **Resource Group**: `[TODO: e.g., rg-prod-canadacentral]` (Region: [TODO: e.g., Canada Central])

**Required Azure Services**:

| Service Type | Resource Name | SKU/Tier | Purpose | When Used |
|--------------|---------------|----------|---------|-----------|
| [TODO: e.g., Azure OpenAI] | `[TODO: e.g., my-aoai-eastus2]` | [TODO: e.g., S0] | [TODO: e.g., GPT-4 completions] | [TODO: e.g., All RAG operations] |
| [TODO: Add 3-5 key services] | `[TODO: resource-name]` | [TODO: tier] | [TODO: purpose] | [TODO: usage condition] |

**Authentication Pattern**:
```bash
# Switch to correct subscription
az account set --subscription [TODO: subscription-id-here]
az account show --query user.name  # Verify correct account
```

**[INSTRUCTION for AI]**: 
- Copy subscription IDs from Azure Portal or `az account list` output
- Include BOTH dev and prod if multi-environment
- Add "When Used" column to specify which operations need which service
- Verify tenant ID matches professional account (not personal)
- Update resource group names to match actual Azure deployment

---

### **[MANDATORY]** Category 3: Environment Variables Reference

**Purpose**: AI needs copy-paste ready configuration with context about WHEN each variable is used.

**Configuration File**: `[TODO: e.g., app/backend/backend.env]`

```bash
# ===== [TODO: Category 1 - e.g., Azure OpenAI] =====
[TODO_VAR_1]=[TODO: e.g., https://my-aoai.openai.azure.com]
# [USAGE] Called when: [TODO: e.g., generating embeddings, chat completions]
# [CRITICAL] How to obtain: [TODO: e.g., Azure Portal → Azure OpenAI → Keys and Endpoint]

[TODO_VAR_2]=[TODO: e.g., gpt-4]
# [USAGE] Model deployment name for [TODO: e.g., chat operations]

# ===== [TODO: Category 2 - e.g., Azure Search] =====
[TODO_VAR_3]=[TODO: e.g., https://my-search.search.windows.net]
# [USAGE] Called when: [TODO: e.g., hybrid vector+keyword search]
# [NOTE] Private endpoint: Requires [TODO: e.g., VPN or DevBox access]

# [TODO: Add all required variables with inline comments]
```

**Local Development Overrides** (optional fallback flags):
```bash
# [TODO: Add OPTIONAL flags for local dev without private endpoints]
# Example pattern:
# OPTIMIZED_KEYWORD_SEARCH_OPTIONAL=true  # Allow AI Services failure (local dev only)
# ENRICHMENT_OPTIONAL=true                # Allow Enrichment Service failure
```

**[INSTRUCTION for AI]**: 
- Include inline comments explaining WHEN variable is called
- Add [CRITICAL], [USAGE], [NOTE] markers for important context
- Show value PATTERNS not actual secrets (e.g., https://[name].openai.azure.com)
- Document optional fallback flags for local development
- Group related variables by service category

---

### **[MANDATORY]** Category 4: File Path Quick Reference

**Purpose**: AI needs to know WHERE critical code lives without grep searching.

**Main Entry Points**:
- **Primary Script**: `[TODO: e.g., scripts/main_automation.py]` - [TODO: What it does]
- **Runner/Launcher**: `[TODO: e.g., run_project.py]` - [TODO: Zero-setup execution]

**Core Application Code**:
- **Backend**: `[TODO: e.g., app/backend/app.py]` - [TODO: Main API server]
- **Frontend**: `[TODO: e.g., app/frontend/src/]` - [TODO: UI components]
- **Shared Logic**: `[TODO: e.g., app/backend/core/shared_constants.py]` - [TODO: CRITICAL - Azure client init]

**Configuration**:
- **Environment**: `[TODO: e.g., app/backend/backend.env]` - [TODO: Backend config]
- **Infrastructure**: `[TODO: e.g., infra/terraform/]` - [TODO: IaC files]

**Testing**:
- **Unit Tests**: `[TODO: e.g., tests/unit/]`
- **Integration Tests**: `[TODO: e.g., tests/integration/]`
- **Test Config**: `[TODO: e.g., pytest.ini]`

**Debug/Evidence**:
- **Debug Artifacts**: `debug/{component}/` - [TODO: Screenshots, HTML, traces]
- **Structured Logs**: `logs/errors/` - [TODO: JSON error logs]
- **Session Checkpoints**: `sessions/{component}/checkpoints/` - [TODO: Resume capability]

**[INSTRUCTION for AI]**: 
- Group files by semantic purpose (entry points, config, testing, debug)
- Use absolute paths from project root
- Mark CRITICAL files (e.g., shared_constants.py for Azure clients)
- Include brief description of what each file/folder contains

---

### **[MANDATORY]** Category 5: Technology Stack Summary

**Purpose**: AI needs tech context before suggesting patterns (prevent suggesting React patterns in Vue project).

| Layer | Technology | Version | Purpose |
|-------|------------|---------|----------|
| **[TODO: e.g., Frontend]** | [TODO: e.g., React + TypeScript] | [TODO: e.g., 18.x] | [TODO: e.g., SPA with type safety] |
| **[TODO: e.g., Backend]** | [TODO: e.g., Python + Quart] | [TODO: e.g., 3.11+] | [TODO: e.g., Async REST API] |
| **[TODO: e.g., Database]** | [TODO: e.g., Azure Cosmos DB] | [TODO: e.g., Serverless] | [TODO: e.g., Session storage] |
| **[TODO: e.g., Search]** | [TODO: e.g., Azure Cognitive Search] | [TODO: e.g., Standard] | [TODO: e.g., Hybrid vector+keyword] |
| **[TODO: e.g., AI/ML]** | [TODO: e.g., Azure OpenAI] | [TODO: e.g., GPT-4] | [TODO: e.g., Completions] |
| **[TODO: e.g., Infrastructure]** | [TODO: e.g., Terraform] | [TODO: e.g., 1.5+] | [TODO: e.g., IaC] |

**Key Dependencies** (from requirements.txt / package.json):
```
[TODO: List 5-10 critical dependencies with versions]
# Example:
# azure-identity>=1.15.0
# pandas>=2.0.0
# pytest>=7.4.0
```

**[INSTRUCTION for AI]**: 
- List all major technologies across full stack
- Include version constraints (helps AI suggest compatible code)
- Add "Purpose" column explaining WHY each tech chosen
- Extract key dependencies from actual requirements files

---

### **[MANDATORY]** Category 6: Critical Code Patterns

**Purpose**: AI MUST follow these patterns when generating code. Include negative examples (what NOT to do).

#### Pattern 1: [TODO: Name - e.g., "Azure Service Client Initialization"]

**When to Use**: [TODO: e.g., "Any code calling Azure services (OpenAI, Search, Cosmos DB)"]

**Correct Implementation**:
```python
[TODO: Paste working code example - make it RUNNABLE]
# Example structure:
# from core.shared_constants import AZURE_CREDENTIAL, app_clients
# 
# # Use shared singleton clients (with retry policies, connection pooling)
# search_client = app_clients["azure_search"]
# cosmos_client = app_clients["azure_cosmosdb"]
```

**Why This Pattern**: [TODO: e.g., "Prevents connection leaks, enables automatic retry, uses managed identity"]

**❌ FORBIDDEN Anti-Pattern**:
```python
# NEVER DO THIS - creates new connection for each request
def bad_pattern():
    client = SearchClient(endpoint, credential)  # Connection leak
    return client.search(query)
```

---

#### Pattern 2: [TODO: Name - e.g., "Evidence Capture at Operation Boundaries"]

**When to Use**: [TODO: e.g., "All operations interacting with external systems or complex logic"]

**Correct Implementation**:
```python
[TODO: Add working code]
# Example structure:
# collector = DebugArtifactCollector("component_name", project_root)
# await collector.capture_state("before_operation")
# try:
#     result = await risky_operation()
#     await collector.capture_state("success")
# except Exception as e:
#     await collector.capture_state("error")
#     raise
```

**Why This Pattern**: [TODO: e.g., "Enables rapid debugging by capturing HTML/screenshots/traces"]

---

#### Pattern 3: [TODO: Name - e.g., "Checkpoint/Resume for Long Operations"]

**When to Use**: [TODO: e.g., "Operations taking >30 seconds or processing multiple items"]

**Correct Implementation**:
```python
[TODO: Add working code]
# Example structure:
# session_mgr = SessionManager("batch_processor", project_root)
# checkpoint = session_mgr.load_latest_checkpoint()
# start_index = checkpoint["data"]["last_index"] if checkpoint else 0
# 
# for i in range(start_index, len(items)):
#     process(items[i])
#     if i % 10 == 0:
#         session_mgr.save_checkpoint(f"item_{i}", {"last_index": i})
```

**Why This Pattern**: [TODO: e.g., "Allows resume after interruption, prevents data loss"]

---

**[INSTRUCTION for AI]**: 
- Add 3-5 patterns that appear frequently in codebase
- Include ❌ FORBIDDEN section showing what NOT to do
- Explain WHY pattern exists (architectural rationale)
- Make code examples RUNNABLE (include imports, error handling)
- Use actual code from project (not pseudocode)

---

### **[RECOMMENDED]** Category 7: Success Criteria / Testable Goals

**Purpose**: AI needs goal alignment before generating code (prevents implementing wrong requirements).

**Functional Requirements** (user-facing features):
1. [TODO: e.g., "User can authenticate via Entra ID OAuth 2.0"]
2. [TODO: e.g., "Chat query returns response within 30 seconds"]
3. [TODO: e.g., "Search results include citations with source links"]
4. [TODO: Add 3-5 testable criteria]

**Non-Functional Requirements** (quality attributes):
1. [TODO: e.g., "95% uptime SLA"]
2. [TODO: e.g., "All API endpoints require authentication"]
3. [TODO: e.g., "90% of answers include citations"]
4. [TODO: Add 2-3 quality requirements]

**Acceptance Tests**:
```python
[TODO: Add actual test examples]
# Example:
# def test_authentication_required():
#     response = client.get("/chat")  # No auth header
#     assert response.status_code == 401
# 
# def test_query_response_time():
#     start = time.time()
#     response = client.post("/chat", json={"query": "test"})
#     duration = time.time() - start
#     assert duration < 30  # 30-second requirement
```

**[INSTRUCTION for AI]**: 
- Make criteria TESTABLE (measurable, verifiable, automated)
- Use specific numbers (not "fast" but "<30 seconds")
- Include acceptance test code if project has test suite
- Separate functional (what it does) from non-functional (how well it does it)

---

### **[MANDATORY]** Category 8: Deployment Status & Known Issues

**Purpose**: AI needs current system state for troubleshooting (prevents suggesting fixes for already-resolved issues).

**Last Deployed**: [TODO: e.g., 2026-01-30]  
**Current Version**: [TODO: e.g., v1.2.0]  
**Environment**: [TODO: e.g., Development / Production]  
**Deployment Method**: [TODO: e.g., Terraform + Azure CLI]

**Infrastructure Status**:
- ✅ **[TODO: Completed Item]**: [TODO: e.g., "Azure OpenAI deployed (gpt-4, text-embedding-ada-002)"]
- ✅ **[TODO: Completed Item]**: [TODO: e.g., "Cognitive Search index created (hybrid vector+keyword)"]
- ⏳ **[TODO: In Progress]**: [TODO: e.g., "FinOps Hub deployment pending credentials"]

**Known Issues & Workarounds**:
- ⚠️ **[TODO: Active Issue]**: [TODO: e.g., "Azure AI Services private endpoint unreachable from local dev"]
  - **Impact**: [TODO: e.g., "Query optimization fails with 403"]
  - **Workaround**: [TODO: e.g., "Set OPTIMIZED_KEYWORD_SEARCH_OPTIONAL=true in backend.env"]
  - **ETA**: [TODO: e.g., "Pending VNet configuration - TBD"]

- ⚠️ **[TODO: Active Issue 2]**: [TODO: Description]
  - **Workaround**: [TODO: Temporary solution]

**[INSTRUCTION for AI]**: 
- Update after each deployment (keep current)
- Use ✅ for resolved, ⏳ for in-progress, ⚠️ for active issues
- Include workarounds for known issues (helps AI troubleshoot)
- Specify ETA for fixes if known

---

### **[RECOMMENDED]** Category 9: Performance/Timing Expectations

**Purpose**: AI needs to know when to implement retry logic, progress bars, checkpoint/resume.

**Expected Response Times**:
- **[TODO: Operation Type]**: [TODO: e.g., "<500ms" or "3-8 minutes for complex queries"]
- **[TODO: Operation Type]**: [TODO: Expected time]
- **[TODO: Operation Type]**: [TODO: Expected time]

**Retry/Checkpoint Requirements**:

Operations taking **> [TODO: e.g., 30 seconds]** MUST implement:
- [ ] Progress indicators (console logs, progress bar)
- [ ] Checkpoint/resume capability (SessionManager)
- [ ] Timeout handling (graceful failure)
- [ ] User notification ("This may take several minutes...")

**Polling Requirements** (if applicable):
```python
[TODO: Add polling pattern if needed]
# Example for multi-agent systems:
# - Poll every 5 seconds
# - Detect content changes (3 consecutive stable checks)
# - Timeout after 8 minutes
```

**Performance Targets** (vs. baseline):
- [TODO: e.g., "95% faster than manual approach (1 min vs 12-19 min)"]
- [TODO: e.g., "64% code reduction (1,321 → 481 lines)"]

**[INSTRUCTION for AI]**: 
- Define timing thresholds that trigger retry/checkpoint logic
- Include polling patterns for async operations
- Specify performance targets (helps AI optimize)
- Add checklist of required capabilities for long-running ops

---

### **[MANDATORY]** Category 10: Troubleshooting Quick Reference

**Purpose**: AI needs diagnostic workflows (Symptom → Cause → Solution pattern).

#### Issue 1: [TODO: Common Error - e.g., "403 Forbidden on Azure AI Services calls"]

**Symptom**: [TODO: e.g., "Backend logs show 'Access denied' when calling query optimization"]

**Root Cause**: [TODO: e.g., "Private endpoint not accessible from local dev machine (requires VPN or DevBox)"]

**Solution**:
1. [TODO: e.g., "Set OPTIMIZED_KEYWORD_SEARCH_OPTIONAL=true in backend.env"]
2. [TODO: e.g., "Restart backend: python app.py"]
3. [TODO: e.g., "Verify fallback working: Check logs for 'degrading gracefully' message"]

**Evidence Location**: [TODO: e.g., "logs/errors/backend_error_YYYYMMDD_HHMMSS.json"]

---

#### Issue 2: [TODO: Common Error - e.g., "Search returns no results"]

**Symptom**: [TODO: What user sees]

**Root Cause**: [TODO: Why it happens]

**Solution**:
1. [TODO: Step-by-step fix]
2. [TODO: Verification command]
3. [TODO: How to confirm resolved]

**Diagnostic Commands**:
```bash
[TODO: Add commands to check system state]
# Example:
# az search index show --name [index-name] --service [service-name]
# curl http://localhost:5000/health
```

---

#### Issue 3: [TODO: Common Error - e.g., "Authentication fails"]

**Checklist**:
1. [TODO: e.g., "Verify correct Azure account: az account show"]
2. [TODO: e.g., "Check subscription access: az account list"]
3. [TODO: e.g., "Re-login if needed: az login --use-device-code"]
4. [TODO: Add diagnostic steps]

---

**[INSTRUCTION for AI]**: 
- Document top 3-5 issues users encounter frequently
- Use Symptom → Cause → Solution structure
- Include diagnostic commands (not just descriptions)
- Reference evidence locations (logs, debug artifacts)
- Keep updated as new issues discovered

---

### **[RECOMMENDED]** Category 11: Documentation Guide

**Purpose**: Point AI to additional context beyond this file.

**Primary References**:
- **This file** ([copilot-instructions.md](i:\EVA-JP-v1.2\docs\eva-foundation\projects\14-az-finops\.github\copilot-instructions.md)): [TODO: e.g., "Quick reference for common tasks"]
- **[TODO: Architecture doc]**: [TODO: e.g., "Comprehensive system design, API reference"]
- **[TODO: README.md]**: [TODO: e.g., "Getting started, project overview"]

**When to Consult Each**:
- **copilot-instructions.md**: [TODO: e.g., "Daily development tasks, troubleshooting"]
- **[TODO: Architecture doc]**: [TODO: e.g., "Understanding system design decisions"]
- **[TODO: README.md]**: [TODO: e.g., "New team member onboarding"]

**[INSTRUCTION for AI]**: 
- Link to actual documentation files in project
- Explain WHEN to use each doc (not just "see X for more info")
- Keep hierarchy: This file (quick) → Architecture (deep) → README (onboarding)

---

### **[RECOMMENDED]** Category 12: Common Workflows (Step-by-Step)

**Purpose**: AI needs procedural knowledge for frequent tasks.

#### Workflow 1: [TODO: e.g., "Local Development Setup"]

**Prerequisites**:
- [TODO: e.g., "Python 3.11+, Node.js 18+, Azure CLI"]

**Steps**:
1. **[TODO: Step 1]**: [TODO: e.g., "Clone repository: git clone [repo-url]"]
2. **[TODO: Step 2]**: [TODO: e.g., "Install backend deps: cd app/backend && pip install -r requirements.txt"]
3. **[TODO: Step 3]**: [TODO: e.g., "Configure environment: cp backend.env.template backend.env"]
4. **[TODO: Step 4]**: [TODO: e.g., "Start backend: python app.py"]

**Validation**: [TODO: e.g., "Open http://localhost:5000/health - should return {status: ok}"]

---

#### Workflow 2: [TODO: e.g., "Deploy to Azure"]

**Prerequisites**:
- [TODO: e.g., "Azure CLI authenticated, Terraform installed"]

**Steps**:
1. **[TODO: Step 1]**: [TODO: Command with description]
2. **[TODO: Step 2]**: [TODO: Command]
3. **[TODO: Step 3]**: [TODO: Command]

**Validation**: [TODO: e.g., "Check Azure Portal for resource group creation"]

---

**[INSTRUCTION for AI]**: 
- Document 3-5 most frequent workflows
- Use imperative language ("Clone repository", not "Repository is cloned")
- Include validation step (how to verify success)
- Specify prerequisites (don't assume setup)

---

### **[RECOMMENDED]** Category 13: Testing

**Purpose**: AI needs to know how to validate generated code.

**Test Structure**:
- **Unit Tests**: `[TODO: e.g., tests/unit/]` - [TODO: e.g., "Component-level validation"]
- **Integration Tests**: `[TODO: e.g., tests/integration/]` - [TODO: e.g., "End-to-end pipeline"]
- **Test Config**: `[TODO: e.g., pytest.ini]`

**Running Tests**:
```powershell
# [TODO: Test suite description - e.g., "Full test suite"]
[TODO: e.g., pytest tests/ -v]

# [TODO: Specific test category - e.g., "Unit tests only"]
[TODO: e.g., pytest tests/unit/]
```

**Adding New Tests**:
1. [TODO: e.g., "Create test file in tests/ with test_ prefix"]
2. [TODO: e.g., "Follow pattern: test_{component}_{function}.py"]
3. [TODO: e.g., "Run pytest to validate"]

**[INSTRUCTION for AI]**: 
- Document test directory structure
- Provide exact commands (not "run tests")
- Explain how to add tests (AI may need to generate test code)

---

### **[RECOMMENDED]** Category 14: CI/CD Pipeline

**Purpose**: AI needs to understand automated workflows.

**Current Deployment Method**: [TODO: e.g., "Manual via Makefile" or "GitHub Actions"]

**GitHub Actions Workflows** (if applicable):
- **[TODO: Workflow name]**: [TODO: e.g., "PR validation - runs tests, linting"]
  - Triggers: [TODO: e.g., "Pull requests to main/develop"]
  - Status: [TODO: e.g., "✅ Active" or "⏳ Planned"]

**Manual Deployment Commands**:
```powershell
[TODO: e.g., make deploy]                   # Full deployment
[TODO: e.g., make build-deploy-webapp]      # Code only
[TODO: e.g., make infrastructure]           # Infrastructure only
```

**[INSTRUCTION for AI]**: 
- Document current state (don't assume automation exists)
- If manual: Provide deployment commands
- If automated: Link to workflow files, explain triggers
- Note future plans (e.g., "Planned: Automated staging deployment")

---

## PART 3: QUALITY & SAFETY

### Critical Code Patterns

### Anti-Patterns Prevention

**NEVER Do These**:

1. **Unicode in Production Code**
   - ❌ Using emoji or Unicode symbols in logs/output
   - ✅ Use ASCII-only: "[PASS]", "[FAIL]", "[INFO]"

2. **Hardcoded Credentials**
   - ❌ Secrets in source code or config files
   - ✅ Azure Key Vault, environment variables, managed identities

3. **Direct Service Client Creation**
   - ❌ `client = AzureOpenAIClient(endpoint, key)`
   - ✅ `client = app_clients["azure_openai"]` (centralized)

4. **Missing Error Context**
   - ❌ `log.error("Operation failed")`
   - ✅ `error_handler.log_error(e, context={...})`

5. **No Evidence Capture**
   - ❌ Silent failures without diagnostics
   - ✅ Capture pre-state, post-state, error state

6. **Blocking I/O in Async Code**
   - ❌ `time.sleep(5)` in async function
   - ✅ `await asyncio.sleep(5)`

7. **Missing Checkpoints**
   - ❌ Long-running operations without save points
   - ✅ `session_mgr.save_checkpoint()` every N iterations

8. **Implicit Project Root**
   - ❌ Assuming script runs from specific directory
   - ✅ `auto_detect_project_root()` in runner

9. **Unvalidated User Input**
   - ❌ Direct use of user-provided values
   - ✅ Pydantic models, type validation, sanitization

10. **Missing Fallback Logic**
    - ❌ Hard failure when optional service unavailable
    - ✅ Graceful degradation with `OPTIONAL=true` flags

### File Organization Requirements

**Mandatory Structure**:
```
{PROJECT_ROOT}/
  .github/
    copilot-instructions.md    # This file (project-specific)
  docs/
    eva-foundation/
      projects/                # Active project work
      workspace-notes/         # AI context notes
      system-analysis/         # Architecture docs
  debug/                       # Debug artifacts
    {component}/
      {operation}_{YYYYMMDD_HHMMSS}.{ext}
  logs/                        # Structured logs
    errors/
    events/
  sessions/                    # Checkpoint data
    {component}/
      checkpoints/
  scripts/                     # Automation
    {category}/
  tests/                       # Test suites
```

**Naming Enforcement**:
- Scripts: `verb-noun.ext` (lowercase-with-dashes)
- Docs: `CATEGORY-DESCRIPTION.md` (UPPERCASE)
- Logs: `{operation}-{YYYYMMDD_HHMMSS}.log`
- Artifacts: `{component}_{context}_{YYYYMMDD_HHMMSS}.{ext}`

### Quality Gates

**Before Committing Code**:
- [ ] No Unicode/emoji in production code
- [ ] All secrets externalized
- [ ] Error handlers with context implemented
- [ ] Evidence capture at operation boundaries
- [ ] Type hints on all function signatures
- [ ] ASCII-only output verified
- [ ] Professional components integrated
- [ ] Tests passing (unit + integration)

**Before Deploying**:
- [ ] Environment variables documented
- [ ] Fallback logic tested
- [ ] Checkpoint/resume verified
- [ ] Debug artifacts reviewed
- [ ] Performance baseline measured
- [ ] Security scan passed
- [ ] Documentation updated
- [ ] Rollback procedure documented

**Before Archiving Project**:
- [ ] All evidence consolidated
- [ ] Lessons learned documented
- [ ] Reusable components extracted
- [ ] Workspace housekeeping complete
- [ ] Knowledge transferred
- [ ] Related projects cross-referenced

### Emergency Debugging Protocol

**When Production Issue Occurs**:

1. **Immediate Response** (0-5 minutes)
   - Check Application Insights for errors
   - Review structured error logs in `logs/errors/`
   - Identify last successful checkpoint in `sessions/`
   - Capture current state with `DebugArtifactCollector`

2. **Evidence Collection** (5-15 minutes)
   - Screenshot current state
   - Export recent logs (last 1 hour)
   - Capture network traces if applicable
   - Document reproduction steps

3. **Root Cause Analysis** (15-60 minutes)
   - Compare with last known good state
   - Review debug artifacts: `debug/{component}/`
   - Check configuration changes
   - Verify Azure service health
   - Review recent deployments

4. **Mitigation** (immediate)
   - Rollback to last stable version if critical
   - Apply hotfix if root cause known
   - Enable fallback mode if service degraded
   - Communicate status to stakeholders

5. **Post-Incident** (within 24 hours)
   - Document incident in `docs/eva-foundation/projects/{incident-name}-debug/`
   - Update troubleshooting guide
   - Add test case to prevent regression
   - Update monitoring/alerting if needed

**Debug Artifact Checklist**:
- [ ] Error logs with full context
- [ ] Screenshots at failure point
- [ ] Network traces (if applicable)
- [ ] Configuration state
- [ ] Last successful checkpoint
- [ ] Reproduction steps
- [ ] Timeline of events

---

## PART 4: TEMPLATE USAGE

### Template Usage Instructions

**How to Use This Template**:

1. **Copy Template to Project**
   ```powershell
   # Copy to your project's .github/ directory
   Copy-Item copilot-instructions-template.md {PROJECT_ROOT}/.github/copilot-instructions.md
   ```

2. **Replace Placeholders**
   - Use Find & Replace to update all `{PLACEHOLDER}` values
   - Priority order:
     1. Project identity: `{PROJECT_NAME}`, `{PROJECT_DESCRIPTION}`, `{PROJECT_TYPE}`
     2. Azure config: `{PROFESSIONAL_EMAIL}`, subscription IDs, `{AZURE_OPENAI_ENDPOINT}`
     3. Paths: `{COMPONENT_X_PATH}`, `{CONFIG_FILE_PATH}`
     4. Commands: `{COMMAND_X}`, `{DEPLOY_X}`
     5. Patterns: `{PATTERN_X_NAME}`, code examples

3. **Customize PART 2**
   - Keep PART 1 (Universal Best Practices) as-is
   - Update PART 2 sections with your project specifics:
     - Architecture Overview: List actual components
     - Project Structure: Map your directory tree
     - Development Workflows: Document setup steps
     - Critical Code Patterns: Provide real examples
     - Testing: Describe test suites
     - Troubleshooting: Document known issues

4. **Validate Completeness**
   - Run Find for remaining `{` characters
   - Verify all code examples use project's actual patterns
   - Test all documented commands
   - Review with team for accuracy

5. **Maintain Over Time**
   - Update when architecture changes
   - Add new troubleshooting entries as issues discovered
   - Document new patterns as they emerge
   - Keep version number and last updated date current

**Placeholder Categories**:

| Category | Examples | Where Used |
|----------|----------|------------|
| **Project Identity** | `{PROJECT_NAME}`, `{PROJECT_TYPE}` | Header, TOC, PART 2 |
| **Azure Config** | `{PROFESSIONAL_EMAIL}`, `{DEV_SUBSCRIPTION_ID}` | Quick Reference, Azure Account Management |
| **Paths** | `{COMPONENT_1_PATH}`, `{CONFIG_FILE_1_PATH}` | Project Structure, Dev Workflows |
| **Commands** | `{START_COMMAND_1}`, `{TEST_COMMAND_1}` | Dev Workflows, Testing, Deployment |
| **Services** | `{SERVICE_1}`, `{AZURE_OPENAI_ENDPOINT}` | Azure Service Dependencies |
| **Patterns** | `{PATTERN_1_NAME}`, `{PATTERN_1_CODE_EXAMPLE}` | Critical Code Patterns |
| **Tasks** | `{TASK_1_NAME}`, `{TASK_1_STEP_1}` | Common Tasks |
| **Issues** | `{ISSUE_1_NAME}`, `{ISSUE_1_SOLUTION}` | Troubleshooting |

**Example Replacement Flow**:

```markdown
# Before (template)
**System Type**: {SYSTEM_TYPE}

**Core Components**:
1. **{COMPONENT_1}** (`{COMPONENT_1_PATH}`) - {COMPONENT_1_PURPOSE}

# After (project-specific)
**System Type**: Retrieval Augmented Generation (RAG) for secure document Q&A

**Core Components**:
1. **Backend** (`app/backend/app.py`) - Python/Quart async API with RAG
```

**Validation Checklist**:
- [ ] No remaining `{PLACEHOLDER}` values
- [ ] All file paths valid for your project
- [ ] All commands tested and working
- [ ] Code examples use actual project patterns
- [ ] Azure config matches your subscriptions
- [ ] Professional email correct
- [ ] Component descriptions accurate
- [ ] Troubleshooting entries relevant
- [ ] Test commands verified
- [ ] Deployment commands validated

**Template Version Tracking**:
- Current template: v2.0.0
- Last updated: January 29, 2026
- Based on: EVA-JP-v1.2 production learnings
- Update your project's version when making significant changes

---

**End of Template**

*Generated from EVA Professional Component Architecture Standards*  
*For questions or improvements, reference EVA-JP-v1.2 production implementation*
