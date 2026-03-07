# The Marco Framework: AI Development Operating System

**Document Type**: Architecture Design  
**Version**: 1.0.0  
**Date**: January 27, 2026  
**Author**: Marco Presta  
**Status**: Design - Working Framework (In Progress)

---

## Executive Summary

The Marco Framework is a three-layer AI development operating system that codifies 1980s engineering discipline (modularity, validation, evidence-based development) into modern AI capabilities. It consists of:

- **Layer 1 (Project 07)**: Context management - How AI should think
- **Layer 2 (Project 04)**: Process workflows - What workflows to follow  
- **Layer 3 (Project 02)**: Capability framework - How to build & reuse

---

## Core Architecture (Three Layers)

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: CONTEXT LAYER (Project 07)                        │
│ "How AI Should Think"                                       │
│ • Copilot Instructions Baseline                            │
│ • Memory Management                                         │
│ • Universal Standards                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓ feeds context to
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2: PROCESS LAYER (Project 04)                        │
│ "What Workflows to Follow"                                  │
│ • Prime → Generate → Validate Loop                         │
│ • Evidence Collection Built-in                             │
│ • Phase-Boundary Quality Gates                             │
└─────────────────────────────────────────────────────────────┘
                          ↓ orchestrates
┌─────────────────────────────────────────────────────────────┐
│ LAYER 3: CAPABILITY LAYER (Project 02)                     │
│ "How to Build & Reuse"                                      │
│ • Agent Skills Framework                                    │
│ • Pluggable Components                                      │
│ • Base Classes & Abstractions                              │
└─────────────────────────────────────────────────────────────┘
```

---

## LAYER 1: Context Layer (Project 07)

### Purpose
Teach AI to think like an experienced engineer with proper context management.

### Structure

```
07-copilot-instructions/
├── 01-discovery/
│   ├── README.md                          # Discovery phase overview
│   ├── artifacts-inventory.md             # All Copilot artifacts catalog
│   ├── current-state-assessment.md        # EVA-JP current config analysis
│   ├── gap-analysis.md                    # Missing pieces identification
│   └── discovery-summary.md               # Key findings & next actions
│
├── 02-design/
│   ├── README.md                          # Design phase overview
│   ├── marco-framework-architecture.md    # THIS FILE - Complete framework
│   ├── universal-patterns.md              # Patterns for ANY project
│   ├── project-specific-patterns.md       # Project-specific patterns
│   ├── copilot-instructions-template.md   # Base template
│   └── memory-management-strategy.md      # How to manage AI memory
│
├── 03-development/
│   ├── copilot-instructions-v1.md         # First unified version
│   ├── memory-template.md                 # Memory file structure
│   ├── skills-integration.md              # How to integrate with Layer 3
│   └── testing-instructions.md            # How to test instructions
│
├── 04-testing/
│   ├── test-scenarios.md                  # Test cases for instructions
│   ├── validation-checklist.md            # Quality validation
│   └── results/                           # Test evidence
│       ├── scenario-01-results.md
│       └── scenario-02-results.md
│
├── 05-implementation/
│   ├── rollout-plan.md                    # How to deploy across projects
│   ├── training-guide.md                  # Team training materials
│   └── maintenance-schedule.md            # Update & review cadence
│
└── README.md                               # Project overview
```

### Key Outputs

#### 1. Universal Copilot Instructions (ANY project)

```markdown
# Universal GitHub Copilot Instructions

## CRITICAL #1: Windows Enterprise Encoding Safety
**Never**: ✓ ✗ ⏳ 🎯 ❌ ✅ … (Unicode crashes cp1252)
**Always**: [PASS] [FAIL] [INFO] [ERROR] [FOUND] (ASCII-safe)

**Why Critical**:
- Enterprise Windows defaults to cp1252 encoding
- Unicode causes UnicodeEncodeError crashes
- Silent automation failures in production

**Solution**:
```python
# FORBIDDEN - Will crash
print("✅ Task complete")

# REQUIRED - Enterprise-safe
print("[PASS] Task complete")
```

```batch
REM Batch file safety
set PYTHONIOENCODING=utf-8
```

## Context Management Pattern
1. **Assess**: What do I need to know?
2. **Prioritize**: What's most relevant right now?
3. **Load**: Get specific context only
4. **Execute**: Perform the task
5. **Verify**: Validate the result

## Universal Standards

### Code Style
- **Type Hints**: Use for all function signatures
- **Async/Await**: Use throughout for I/O operations
- **Naming**: 
  - Python: `snake_case` (functions/vars), `PascalCase` (classes)
  - TypeScript: `camelCase` (functions/vars), `PascalCase` (components/types)
- **Files**: `lowercase-with-dashes.tsx`, `snake_case.py`

### Error Handling Philosophy
- Wrap external calls with try/except
- Respect optional flags for graceful degradation
- Always log context with errors
- **1980s analog**: "Check return codes, don't assume success"

### Resource Management
- Never create clients repeatedly (Singleton pattern)
- Reuse connections/clients (shared resources)
- Properly dispose/close resources
- **1980s analog**: Database connection pools, file handle management

### Configuration Management
- Environment-specific config files
- No hardcoded secrets (Key Vault/env variables only)
- Validation at startup
- **1980s analog**: .ini files, SET environment variables

### Security Standards
- No hardcoded secrets
- Authentication via OAuth 2.0/Entra ID
- Network isolation via private endpoints
- Audit logging for all operations
- RBAC for access control
```

#### 2. Memory Management Template

```markdown
# .copilot-memory.md

## Project-Specific Context
- **Architecture**: [e.g., RAG system with Azure OpenAI]
- **Key Patterns**: [e.g., Fallback graceful degradation]
- **Critical Paths**: [e.g., app/backend/approaches/]
- **Tech Stack**: [e.g., Python/Quart, React/TypeScript]

## Recent Learnings
- 2026-01-27: ENRICHMENT_OPTIONAL flag enables local dev without VPN
- 2026-01-22: Windows encoding safety - ASCII only in scripts

## Development Preferences
- **Python**: Black formatter, line length 180
- **TypeScript**: Prettier, Fluent UI components
- **Always**: Explain model/SDK choices before generating code

## Current Focus
- [What you're currently working on]
- [Recent changes/patterns discovered]

## Known Issues
- [Issues to remember across sessions]
- [Workarounds in place]
```

---

## LAYER 2: Process Layer (Project 04)

### Purpose
Standardized, repeatable workflows with built-in quality gates and evidence collection.

### Structure

```
04-OS-vNext/
├── workflows/
│   ├── copilot.md                         # Prime→Generate→Validate loop
│   ├── azure-ai-foundry.md                # Foundry-specific workflow
│   ├── agent-framework.md                 # Agent Framework workflow
│   └── evaluation-workflow.md             # Testing/evaluation workflow
│
├── validation/
│   ├── checklist.md                       # Quality gates
│   ├── ai-consumability.md                # Machine-readable validation
│   ├── evidence-requirements.md           # Audit trail requirements
│   └── traceability-validation.md         # Requirement tracing
│
├── templates/
│   ├── document-template.md               # Standard doc structure
│   ├── code-template.py                   # Standard code structure
│   └── test-template.py                   # Standard test structure
│
├── scripts/
│   ├── extract-architecture.ps1           # Architecture snapshot
│   ├── run-static-analysis.ps1            # Code quality checks
│   ├── test-connectivity.ps1              # Environment validation
│   └── collect-evidence.ps1               # Automated evidence collection
│
└── README.md                               # Process overview
```

### Key Workflow: Prime → Generate → Validate

```markdown
## Prime Phase
**Objective**: Establish clear requirements and context

**Steps**:
1. Load Layer 1 (Context): Copilot instructions + memory
2. Load Layer 3 (Capabilities): Available skills
3. Establish requirements & constraints
4. Set success criteria (MUST have validation)
5. Identify traceability requirements

**Outputs**:
- Requirements document
- Success criteria checklist
- Context loaded confirmation

## Generate Phase
**Objective**: Create artifacts using established patterns

**Steps**:
1. Use one-line prompts (from file-generation-oneliner.md)
2. Apply templates from templates/
3. Use skills from Layer 3 (Project 02)
4. Save without iterative rewrites
5. Proceed immediately to validation

**Constraints**:
- No speculative/future features
- Follow exact templates
- Maintain traceability
- Use ASCII-only in scripts (Windows safety)

## Validate Phase (Per Artifact)
**Objective**: Ensure quality before proceeding

**Validation Checklist**:
- ✓ Content sanity check
  - No assumptions/unclear statements
  - No contradictions
  - No scope leaks
  
- ✓ AI-consumability
  - YAML frontmatter present
  - Consistent tables (markdown format)
  - Language-tagged code blocks
  - Explicit traceability markers
  
- ✓ Traceability
  - Requirement IDs referenced (e.g., INF01)
  - Source file paths included
  - Version references clear
  
- ✓ Evidence collection
  - Validation results recorded
  - Timestamps captured
  - Artifacts versioned

## Phase-Boundary Gates
**When**: Between major phases (e.g., after Phase 3, before Phase 4)

**Quality Checks**:
- ✓ No contradictions across documents
- ✓ No scope leaks (future/aspirational content)
- ✓ Metadata parseability
- ✓ All commands executable
- ✓ Complete traceability chain

**Evidence Commands**:
```powershell
# Architecture snapshot
pwsh -File scripts/extract-architecture.ps1

# Static analysis
pwsh -File scripts/run-static-analysis.ps1

# Connectivity validation
pwsh -File scripts/test-connectivity.ps1 -VerboseHttp

# Mock API for local checks
python mock_backend.py
```
```

### Integration Pattern with Layer 1 & 3

```python
# Example: Using Layer 2 workflow with Layer 3 skills

from layer3.skills import DocumentationGeneratorSkill
from layer2.workflows import PrimeGenerateValidate

# Prime: Load context from Layer 1
workflow = PrimeGenerateValidate(
    context_file=".github/copilot-instructions.md",
    memory_file=".copilot-memory.md"
)

# Generate: Use Layer 3 skill
skill = DocumentationGeneratorSkill(
    manifest="skill-manifests/doc-gen.yaml"
)
output = workflow.generate(
    skill=skill, 
    prompt="Generate architecture doc"
)

# Validate: Use Layer 2 validators
results = workflow.validate(
    output=output,
    checklist="validation/checklist.md",
    collect_evidence=True
)
```

---

## LAYER 3: Capability Layer (Project 02)

### Purpose
Reusable, pluggable agent skills - "Don't rebuild the wheel"

### Structure

```
02-poc-agent-skills/
├── base/
│   ├── agent_skill_base.py                # Abstract base class
│   ├── prompt_template.py                 # Prompt engineering framework
│   ├── validator_framework.py             # Quality validation abstraction
│   ├── evidence_collector.py              # Audit trail system
│   └── README.md                          # Base framework docs
│
├── skills/
│   ├── documentation_generator/
│   │   ├── __init__.py
│   │   ├── skill.py                       # Refactored from generate-docs.py
│   │   ├── validators.py                  # YAML, traceability validators
│   │   └── prompts/                       # Prompt templates
│   │
│   ├── code_generator/
│   │   ├── __init__.py
│   │   ├── skill.py                       # AI-powered code generation
│   │   ├── templates/                     # Code templates
│   │   └── validators.py                  # Syntax, type validators
│   │
│   ├── architecture_analyzer/
│   │   ├── __init__.py
│   │   ├── skill.py                       # System architecture analysis
│   │   └── extractors/                    # Dependency, API extractors
│   │
│   └── evaluation_runner/                 # Azure AI Evaluation integration
│       ├── __init__.py
│       ├── skill.py
│       ├── evaluators/                    # Custom evaluators
│       └── datasets/                      # Test datasets (JSONL)
│
├── orchestrator/
│   ├── skill_orchestrator.py              # Workflow coordination engine
│   ├── skill_manifest_loader.py           # Dynamic skill loading from YAML
│   └── workflow_executor.py               # Multi-skill workflows
│
├── skill-manifests/
│   ├── documentation-generator.yaml       # Skill configuration
│   ├── code-generator.yaml
│   ├── architecture-analyzer.yaml
│   └── evaluation-runner.yaml
│
└── README.md                               # Framework overview
```

### Key Pattern: AgentSkillBase

```python
# base/agent_skill_base.py

from abc import ABC, abstractmethod
from typing import Dict, Any, List

class AgentSkillBase(ABC):
    """
    Abstract base class for all agent skills.
    
    Defines the contract that all skills must implement.
    Integrates with Layer 2 (workflows) and Layer 1 (context).
    
    1980s Analog: Subroutine libraries with standard interfaces
    """
    
    def __init__(self, manifest_path: str, context: Dict[str, Any]):
        """
        Initialize skill with manifest and context.
        
        Args:
            manifest_path: Path to skill manifest YAML
            context: Context from Layer 1 (copilot-instructions)
        """
        self.manifest = self._load_manifest(manifest_path)
        self.context = context
        self.evidence_collector = EvidenceCollector()
        self.validators = []
    
    @abstractmethod
    def execute(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Main execution logic for the skill.
        Must be implemented by all concrete skills.
        
        Args:
            input_data: Input parameters for skill execution
            
        Returns:
            Output data from skill execution
        """
        pass
    
    @abstractmethod
    def validate_input(self, input_data: Dict[str, Any]) -> bool:
        """
        Validate input data before execution.
        
        Args:
            input_data: Input parameters to validate
            
        Returns:
            True if valid, False otherwise
        """
        pass
    
    @abstractmethod
    def validate_output(self, output_data: Dict[str, Any]) -> bool:
        """
        Validate output data after execution.
        
        Args:
            output_data: Output data to validate
            
        Returns:
            True if valid, False otherwise
        """
        pass
    
    def pre_execute(self):
        """Hook: Called before execute()"""
        self.evidence_collector.start_session()
        self._log_context()
    
    def post_execute(self, output: Dict[str, Any]):
        """Hook: Called after execute()"""
        self.evidence_collector.record_output(output)
        self._collect_metrics()
    
    def on_error(self, error: Exception):
        """Hook: Called on error"""
        self.evidence_collector.record_error(error)
        self._log_error_context(error)
    
    def _load_manifest(self, path: str) -> Dict[str, Any]:
        """Load skill manifest from YAML"""
        # Implementation
        pass
    
    def _log_context(self):
        """Log execution context for debugging"""
        # Implementation
        pass
    
    def _collect_metrics(self):
        """Collect execution metrics"""
        # Implementation
        pass
    
    def _log_error_context(self, error: Exception):
        """Log error with full context"""
        # Implementation
        pass
```

### Skill Manifest Example

```yaml
# skill-manifests/documentation-generator.yaml

skill:
  name: documentation-generator
  version: 1.0.0
  description: Generate technical documentation from codebase
  author: Marco Presta
  
  # 1980s analog: Function library metadata

requires:
  - azure-openai              # From context (Layer 1)
  - layer2-workflow: prime-generate-validate

inputs:
  - name: source_files
    type: list[str]
    required: true
    description: List of source files to analyze
    
  - name: output_format
    type: string
    default: markdown
    allowed_values: [markdown, html, pdf]
    
  - name: include_evidence
    type: boolean
    default: true

outputs:
  - name: documents
    type: list[dict]
    description: Generated documentation files
    
  - name: evidence
    type: dict
    description: Validation evidence and metrics
    
  - name: validation_results
    type: dict
    description: Validation pass/fail status

validators:
  - yaml_frontmatter           # Check YAML metadata
  - requirement_traceability   # Check requirement IDs
  - ai_consumability          # Check machine-readable format
  - ascii_safety              # Check Windows encoding safety

prompts:
  system_prompt: prompts/system-prompt.md
  exemplar: prompts/example-doc.md

settings:
  model: gpt-4.1-mini
  temperature: 0.3
  max_tokens: 4000
  retry_attempts: 3
  timeout_seconds: 300

evidence:
  collect: true
  output_dir: evidence/
  include_timestamps: true
  include_metrics: true
```

---

## How The Three Layers Work Together

### Complete Example: Generate Documentation with Evaluation

```python
"""
Complete workflow demonstrating all three layers working together.

Scenario: Generate technical documentation and evaluate quality
"""

# ============================================================
# STEP 1: Load Context (Layer 1)
# ============================================================
from layer1.context import load_copilot_context, load_memory

context = load_copilot_context(".github/copilot-instructions.md")
memory = load_memory(".copilot-memory.md")

print("[INFO] Layer 1 context loaded")
print(f"[INFO] Encoding safety: {context['windows_encoding_safety']}")
print(f"[INFO] Recent learnings: {len(memory['recent_learnings'])} items")

# ============================================================
# STEP 2: Initialize Workflow (Layer 2)
# ============================================================
from layer2.workflows import PrimeGenerateValidate

workflow = PrimeGenerateValidate(
    context=context, 
    memory=memory,
    evidence_dir="evidence/2026-01-27-doc-generation"
)

print("[INFO] Layer 2 workflow initialized")

# ============================================================
# STEP 3: Load Skills (Layer 3)
# ============================================================
from layer3.orchestrator import SkillOrchestrator

orchestrator = SkillOrchestrator()
doc_skill = orchestrator.load_skill("documentation-generator")
eval_skill = orchestrator.load_skill("evaluation-runner")

print("[INFO] Layer 3 skills loaded")
print(f"[INFO] Available skills: {orchestrator.list_skills()}")

# ============================================================
# STEP 4: Execute Workflow (Layer 2 orchestrates Layer 3)
# ============================================================

# --- Prime Phase ---
with workflow.prime_phase() as prime:
    requirements = {
        "source_files": [
            "app/backend/app.py",
            "app/backend/approaches/chatreadretrieveread.py"
        ],
        "output_format": "markdown",
        "validation_required": True,
        "include_evidence": True
    }
    
    prime.validate_requirements(requirements)
    prime.set_success_criteria([
        "All documents have YAML frontmatter",
        "All requirement IDs traced",
        "ASCII-safe content (no Unicode)",
        "AI-consumable format"
    ])
    
    print("[PASS] Prime phase complete")

# --- Generate Phase ---
with workflow.generate_phase() as generate:
    # Generate documentation using Layer 3 skill
    docs = doc_skill.execute(requirements)
    
    generate.record_artifacts(docs)
    
    print(f"[PASS] Generated {len(docs['documents'])} documents")
    
# --- Validate Phase ---
with workflow.validate_phase() as validate:
    # Validate using Layer 2 checklist
    validation_results = validate.run_checklist(
        output=docs,
        checklist="validation/checklist.md"
    )
    
    print(f"[INFO] Validation: {validation_results['pass_count']}/{validation_results['total_count']} passed")
    
    # Evaluate quality using Layer 3 evaluation skill
    eval_results = eval_skill.execute({
        "documents": docs['documents'],
        "evaluators": [
            "coherence",
            "completeness",
            "ascii_safety"
        ],
        "dataset": "test-data/doc-eval.jsonl",
        "model_config": context['azure_openai_config']
    })
    
    print(f"[PASS] Evaluation complete")
    print(f"[INFO] Coherence: {eval_results['coherence']['score']}/5")
    print(f"[INFO] Completeness: {eval_results['completeness']['score']}/5")
    print(f"[INFO] ASCII Safety: {eval_results['ascii_safety']['pass_rate']}%")

# ============================================================
# STEP 5: Collect Evidence (Layer 2)
# ============================================================
workflow.collect_evidence(
    artifacts=[
        docs,
        validation_results,
        eval_results
    ],
    summary={
        "total_documents": len(docs['documents']),
        "validation_pass_rate": validation_results['pass_count'] / validation_results['total_count'],
        "evaluation_scores": {
            "coherence": eval_results['coherence']['score'],
            "completeness": eval_results['completeness']['score']
        }
    }
)

print("[PASS] Evidence collected")
print(f"[INFO] Evidence location: evidence/2026-01-27-doc-generation/")

# ============================================================
# STEP 6: Update Memory (Layer 1)
# ============================================================
from layer1.context import update_memory

update_memory(
    ".copilot-memory.md",
    learnings=[
        f"2026-01-27: Generated {len(docs['documents'])} docs with {validation_results['pass_rate']}% validation pass rate",
        f"2026-01-27: Evaluation scores - Coherence: {eval_results['coherence']['score']}, Completeness: {eval_results['completeness']['score']}"
    ]
)

print("[PASS] Memory updated")
print("[INFO] Workflow complete")
```

### Output Example

```
[INFO] Layer 1 context loaded
[INFO] Encoding safety: ASCII-only enforced
[INFO] Recent learnings: 5 items
[INFO] Layer 2 workflow initialized
[INFO] Layer 3 skills loaded
[INFO] Available skills: ['documentation-generator', 'code-generator', 'architecture-analyzer', 'evaluation-runner']
[PASS] Prime phase complete
[PASS] Generated 28 documents
[INFO] Validation: 28/28 passed
[PASS] Evaluation complete
[INFO] Coherence: 4.2/5
[INFO] Completeness: 4.5/5
[INFO] ASCII Safety: 100%
[PASS] Evidence collected
[INFO] Evidence location: evidence/2026-01-27-doc-generation/
[PASS] Memory updated
[INFO] Workflow complete
```

---

## Universal Patterns (1980s → 2026 AI)

| 1980s Concept | 2026 Implementation | Marco Framework Layer |
|---------------|---------------------|----------------------|
| **Connection pooling** | Singleton Azure clients | Layer 1 (Context) |
| **Network fallback caching** | Graceful degradation with optional flags | Layer 1 (Context) |
| **.ini config files** | Environment variables + Key Vault | Layer 1 (Context) |
| **printf debugging** | OpenTelemetry distributed tracing | Layer 1 (Context) |
| **Man pages hierarchy** | Documentation strategy (quick ref → comprehensive → deep dive) | Layer 1 (Context) |
| **Limited RAM management** | Token budget + context engineering | Layer 1 (Context) |
| **Modular programming** | Microservices + agent orchestration | Layer 3 (Capabilities) |
| **Makefiles/build scripts** | Prime → Generate → Validate workflows | Layer 2 (Process) |
| **Function libraries** | Agent skills framework | Layer 3 (Capabilities) |
| **Coding standards docs** | Copilot instructions | Layer 1 (Context) |
| **Subroutine interfaces** | AgentSkillBase abstract class | Layer 3 (Capabilities) |
| **Quality gates** | Phase-boundary validation | Layer 2 (Process) |
| **Audit trails** | Evidence collection system | Layer 2 (Process) |

---

## Current Status & Roadmap

### What's Working Now (January 2026)

| Layer | Status | What Works |
|-------|--------|------------|
| **Layer 1 (Project 07)** | 🟡 Partial | EVA-JP has excellent instructions; universal baseline in progress |
| **Layer 2 (Project 04)** | 🟢 Working | Prime→Generate→Validate loop proven in doc generation |
| **Layer 3 (Project 02)** | 🟡 POC | Base classes designed; 1 skill (doc-gen) refactored |

### Critical Patterns Established

✅ **Windows Enterprise Encoding Safety** (Layer 1)  
✅ **Prime → Generate → Validate Loop** (Layer 2)  
✅ **Evidence Collection Infrastructure** (Layer 2)  
✅ **AgentSkillBase Pattern** (Layer 3)  
✅ **Manifest-Driven Configuration** (Layer 3)

### What Needs Completion

#### Project 07 (Layer 1) - Next Steps
- [ ] Complete broader EVA ecosystem discovery
- [ ] Extract universal patterns from all projects (not just EVA-JP)
- [ ] Create unified copilot-instructions baseline
- [ ] Implement .copilot-memory.md system
- [ ] Test cross-project applicability
- [ ] Document integration with AI Toolkit tracing
- [ ] Add Agent Framework workflow patterns

#### Project 04 (Layer 2) - Next Steps
- [ ] Add agent-framework-workflow.md
- [ ] Add evaluation-workflow.md (Azure AI Evaluation SDK)
- [ ] Formalize evidence collection automation
- [ ] Create workflow integration tests
- [ ] Document integration with Layer 1 & 3
- [ ] Add OpenTelemetry tracing integration
- [ ] Create template for JSONL evaluation datasets

#### Project 02 (Layer 3) - Next Steps
- [ ] Complete base framework (Days 1-5 from PLAN.md)
- [ ] Refactor 2 more skills:
  - [ ] code-generator skill
  - [ ] architecture-analyzer skill
- [ ] Build skill orchestrator
- [ ] Add evaluation-runner skill (Azure AI Evaluation SDK integration)
- [ ] Create MCP integration (GitHub Copilot skills compatibility)
- [ ] Test with Layer 2 workflows
- [ ] Add Agent Framework SDK integration

---

## AI Development Best Practices (2026)

### From AI Toolkit Skills (VS Code Release 108)

#### 1. Agent Development Lifecycle

**Framework**: Microsoft Agent Framework (preview)
```bash
# Python (recommended - more features)
pip install agent-framework-azure-ai --pre

# .NET
dotnet add package Microsoft.Agents.AI.AzureAI --prerelease
```

**Best Practices**:
- Generate a plan before writing code
- Explain model selection rationale
- Explain SDK choice rationale
- Use Microsoft Foundry (formerly Azure AI Foundry) for production
- Use GitHub models for prototyping

#### 2. Model Selection Strategy

**Priority Order**:
1. **Production**: Microsoft Foundry models (full features, enterprise support)
2. **Prototyping**: GitHub models (free tier, quick testing)
3. **Always**: Explain why you chose the model

**Configuration Example**:
```python
from azure.ai.evaluation import AzureOpenAIModelConfiguration

model_config = AzureOpenAIModelConfiguration(
    azure_deployment="gpt-4",
    azure_endpoint="https://your-resource.openai.azure.com/",
    api_key=os.environ["AZURE_OPENAI_API_KEY"],
    api_version="2025-04-01-preview"
)
```

#### 3. Observability Pattern

**Standard**: OpenTelemetry with Agent Framework auto-instrumentation

```python
from agent_framework.observability import configure_otel_providers

configure_otel_providers(
    vs_code_extension_port=4317,  # AI Toolkit gRPC port
    enable_sensitive_data=True    # Capture prompts/completions
)
```

**Critical**: 
- Call VS Code command `ai-mlstudio.tracing.open` to start trace collector
- Use AI Toolkit OTLP endpoints: 
  - gRPC: `http://localhost:4317`
  - HTTP: `http://localhost:4318`
- Never manually create spans; SDK auto-instruments

#### 4. Evaluation Framework

**Standard**: Azure AI Evaluation SDK

**Evaluator Priority**:
1. **Built-in evaluators** (check first!)
   - Agent: TaskAdherenceEvaluator, IntentResolutionEvaluator, ToolCallAccuracyEvaluator
   - General: CoherenceEvaluator, FluencyEvaluator
   - RAG: GroundednessEvaluator, RelevanceEvaluator, RetrievalEvaluator
   - Similarity: F1ScoreEvaluator, BleuScoreEvaluator, RougeScoreEvaluator

2. **Custom code-based** (objective metrics with custom logic)

3. **Custom prompt-based** (LLM-as-judge for subjective criteria)

**Critical Requirements**:
- Dataset: JSONL format only
- No timestamps in data (causes SDK errors)
- Always use `evaluate()` API (never manual iteration)
- Set `output_path` to save results

**Example**:
```python
from azure.ai.evaluation import evaluate, TaskAdherenceEvaluator

evaluator = TaskAdherenceEvaluator(model_config=model_config)

result = evaluate(
    data="test-data.jsonl",
    evaluators={"task_adherence": evaluator},
    evaluator_config={
        "task_adherence": {
            "column_mapping": {
                "query": "${data.query}",
                "response": "${data.response}"
            }
        }
    },
    output_path="evaluation-results/"
)
```

---

## The Vision (When Complete)

### Command-Line Interface

```bash
# Initialize Marco Framework in new project
$ marco-framework init --project eva-chat-v2

[INFO] Initializing Marco Framework...
[PASS] Layer 1: Copilot context loaded
[PASS] Layer 2: Workflows initialized
[PASS] Layer 3: Skills catalog available
[INFO] Windows encoding safety: ENABLED
[INFO] Available skills: 4

# Generate documentation
$ marco-framework generate docs --skill documentation-generator

[INFO] Prime phase: Loading requirements...
[INFO] Context: Windows encoding safety enforced
[INFO] Generate phase: Creating 28 documents...
[INFO] Validate phase: Running quality checks...
[PASS] YAML frontmatter: 28/28
[PASS] Requirement traceability: 28/28
[PASS] ASCII safety: 28/28
[PASS] AI consumability: 28/28
[INFO] Evidence collected: evidence/2026-01-27-123456/

# Run evaluation
$ marco-framework evaluate --dataset test-data.jsonl

[INFO] Using evaluation-runner skill...
[INFO] Built-in evaluators: coherence, completeness, groundedness
[INFO] Processing 100 test cases...
[PASS] Coherence: 4.2/5
[PASS] Completeness: 4.5/5
[PASS] Groundedness: 4.8/5
[INFO] Results: evaluation-results/2026-01-27-123456.json

# Generate code with evaluation
$ marco-framework generate code \
    --skill code-generator \
    --evaluate \
    --trace

[INFO] Prime phase: Loading requirements...
[INFO] OpenTelemetry tracing: ENABLED (port 4317)
[INFO] Generate phase: Creating code modules...
[INFO] Validate phase: Running syntax checks...
[PASS] Syntax validation: 100%
[INFO] Evaluation phase: Testing generated code...
[PASS] Code quality: 4.3/5
[PASS] Type safety: 100%
[INFO] Trace URL: http://localhost:4318/traces/abc123
[INFO] Evidence: evidence/2026-01-27-code-gen/

# Update copilot memory
$ marco-framework memory update

[INFO] Recent learnings: 3 new items
[INFO] Memory updated: .copilot-memory.md
```

### Developer Experience

```python
# Developer writes new skill
from marco_framework.layer3 import AgentSkillBase

class MyCustomSkill(AgentSkillBase):
    """My custom agent skill"""
    
    def execute(self, input_data):
        # Automatic tracing enabled
        # Evidence collection built-in
        # Validation hooks available
        result = self._do_work(input_data)
        return result
    
    def validate_input(self, input_data):
        # Windows encoding safety checked automatically
        return True
    
    def validate_output(self, output_data):
        # Layer 2 validation runs automatically
        return True

# Register skill
skill = MyCustomSkill(
    manifest="my-skill.yaml",
    context=load_context()  # Layer 1 context auto-loaded
)

# Run with Layer 2 workflow
workflow = PrimeGenerateValidate()
result = workflow.run(skill=skill, requirements={...})

# Evidence automatically collected
# Trace automatically captured
# Memory automatically updated
```

---

## Conclusion

**The Marco Framework** is where 1980s engineering discipline meets 2026 AI capabilities:

- **Self-organizing** (context management)
- **Reusable** (agent skills)
- **Validated** (quality gates)
- **Evidence-based** (audit trails)

Three projects working in harmony to create a complete AI development operating system.

**Status**: Working framework, in active development across all three layers.

**Next Milestone**: Complete Layer 1 universal baseline (Project 07 Phase 2).

---

**Document History**:
- 2026-01-27: Initial architecture design created
- Based on: Projects 02, 04, and 07 current state
- Incorporates: AI Toolkit best practices (VS Code Release 108)
