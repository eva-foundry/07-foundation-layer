# Copilot Instructions for EVA Foundry Library (29-foundry)

**Library:** EVA Foundry Library  
**Version:** 0.1.0-beta  
**Location:** `c:\AICOE\eva-foundation\29-foundry`  
**Last Updated:** February 18, 2026 - 8:30 AM ET  
**Purpose:** Reusable AI agent development toolkit using Microsoft Agent Framework, Azure AI Foundry, and Model Context Protocol (MCP)

---

## General Usage Rules

### Code Quality Standards
- **Type Hints Required:** All Python code must include complete type hints (PEP 484)
- **Error Handling:** Use try-except blocks with specific exceptions, log errors with context
- **Async Patterns:** Use async/await for I/O operations (Azure SDK, OpenAI API calls)
- **Logging:** Use Python logging module with appropriate levels (DEBUG, INFO, WARNING, ERROR)
- **Documentation:** Include docstrings (Google style) for all public functions and classes
- **No Emojis in Code:** Do not use emojis or non-ASCII characters in production Python code

   Guidance and rationale:

   - Rationale: Non-ASCII characters (including emojis) often cause cross-platform encoding errors (for example, Windows terminals defaulting to cp1252) and can break tooling that expects ASCII-only outputs (CI systems, JSON parsers, log collectors).
   - Scope: This rule applies to all source code, scripts, generated JSON/YAML/TOML outputs, evidence manifests, and any machine-readable artifacts produced by tools in this repository.
   - Allowed exceptions: Markdown and other human-facing documentation files may include emojis for visual clarity, but emojis must never appear in code, CLI output that is parsed programmatically, or persisted evidence files.

   Recommended textual tokens (use these instead of emojis):

   - `[PASS]` for success indicators (instead of ✅)
   - `[FAIL]` for failures (instead of ❌)
   - `[WARN]` for warnings (instead of ⚠️)
   - `[INFO]` for informational messages (instead of 📋)
   - `[DOC]` for documentation-related actions (instead of 📄)
   - `[ARCHIVE]` for archive actions (instead of 📦)
   - `[PLAN]` for planning actions (instead of 🎯)
   - `[FIX]` for fix actions (instead of 🔧)

   Operational guidance:

   - When writing code that emits human-readable console output, prefer bracketed ASCII tokens above; keep machine-readable flags and JSON fields emoji-free.
   - When generating evidence manifests or certificates, ensure string fields meant for machine consumption contain only ASCII characters; human-friendly fields in markdown may be richer.
   - Add a lightweight repo maintenance tool (for example, `audit/fix-emoji-usage.py`) to scan for emoji usage in code and fail CI if found. Consider adding an automated check in CI to run this script pre-merge.

   Example (good):

   - print("[PASS] Bootstrap complete. Context saved to: agent-context-20260218-172104.json")

   Example (avoid):

   - print("✅ Bootstrap complete. Context saved to: agent-context-20260218-172104.json")

### Naming Conventions
- **Classes:** PascalCase (e.g., `EVASearchClient`, `RAGPipeline`)
- **Functions:** snake_case (e.g., `hybrid_search`, `build_context`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `DEFAULT_CHUNK_SIZE`)
- **Private methods:** Prefix with underscore (e.g., `_init_client`)
- **Environment variables:** UPPER_SNAKE_CASE with namespace (e.g., `AZURE_OPENAI_ENDPOINT`)

### Import Pattern for Cross-Project Integration (CRITICAL)
When importing foundry tools from other EVA projects, ALWAYS use this pattern:

```python
# Standard pattern for relative imports
import sys
from pathlib import Path

# Add foundry to Python path
foundry_path = Path(__file__).parent.parent.parent / "29-foundry"
sys.path.insert(0, str(foundry_path))

# Now import foundry components
from tools.search import EVASearchClient
from tools.rag import RAGPipeline, DocumentChunker, CitationBuilder
from tools.evaluation import EVAEvaluator
from tools.observability import TracedOperation, setup_foundry_tracing
from tools.auth import get_azure_credential
```

---

## 📚 Library Inventory

### GitHub Copilot Skills (copilot-skills/)

Six production-ready skills for agent development

---

## 🔧 Library Structure

```
29-foundry/
├── copilot-skills/          # Reusable Copilot agent skills
├── agent-framework/         # Microsoft Agent Framework patterns & examples
├── mcp-servers/            # Model Context Protocol implementations
├── tools/                  # Python utility libraries
│   ├── search/            # Azure AI Search wrappers
│   ├── rag/               # RAG pipeline components
│   ├── evaluation/        # Quality assessment tools
│   └── observability/     # Tracing & monitoring
├── prompts/               # Prompty-format prompt templates
├── cloned-repos/          # Microsoft sample repositories
├── notebooks/             # Jupyter exploration notebooks
└── docs/                  # Comprehensive documentation
```

---

## 🚀 Usage Patterns for Copilot

### Pattern 1: Import Foundry Tools

When generating code in `eva-brain-v2`, import from foundry:

```python
# Instead of duplicating code:
# from app.services.azure_search_service import AzureSearchService

# Import from foundry library:
import sys
sys.path.append("../../29-foundry")
from tools.search import AzureSearchClient
from tools.rag import RAGContextBuilder
from tools.observability import setup_foundry_tracing
```

### Pattern 2: Reference Copilot Skills

When user asks to "implement RAG approach":

```markdown
@workspace Use the RAG Approach Builder skill from the foundry library
at ../../29-foundry/copilot-skills/02-rag-approach-builder.md to implement
retrieve-rerank-read pattern with Azure AI Search semantic reranking.
```

### Pattern 3: Use MCP Servers

When agents need data access:

```python
# Configure agent to use MCP server
from agent_framework import A2AAgent

agent = A2AAgent(
    name="PolicySearchAgent",
    mcp_servers=[
        "../../29-foundry/mcp-servers/azure-ai-search",
        "../../29-foundry/mcp-servers/cosmos-db"
    ]
)
```

### Pattern 4: Apply Prompty Templates

When generating prompts:

```python
from prompty import load_prompty

# Load domain-specific prompt template
prompt = load_prompty("../../29-foundry/prompts/policy-analysis.prompty")
response = prompt.invoke(question=user_query, documents=context)
```

### Pattern 5: Use Audit Tools for Project Certification

When you need to audit or certify a project:

```bash
# Copy audit tools to your project (one-time setup)
cp -r ../../29-foundry/audit ./audit

# Run bootstrap to get project-specific context
python audit/agent-bootstrap.py --verbose

# Run full audit sequence (2-3 minutes)
python audit/step1-artifact-inventory.py
python audit/step1-capability-mapping.py
python audit/step2-capability-testing.py
python audit/step3-phase0-discovery.py
python audit/step3-phase1-scaffold.py
python audit/step3-phase2-implementation.py
python audit/step4-aggregate-evidence.py
python audit/step4-remediation-plan.py
python audit/step4-generate-certificate.py

# Review certification
cat evidence/CERTIFICATION-CERTIFICATE-*.txt
cat evidence/REMEDIATION-PLAN-*.json
```

**The audit system is portable** - it auto-detects your project and provides correct import patterns for accessing foundry tools.

---

## 📊 Authority Hierarchy

When generating code, Copilot should respect this authority order:

1. **Domain-Specific Skills** (eva-faces, eva-brain-v2 `.github/copilot-skills/`)
   - Project-specific patterns and business logic

2. **Foundry Library Skills** (`29-foundry/copilot-skills/`)
   - Reusable technical patterns (RAG, agents, observability)

3. **Cloned Microsoft Samples** (`29-foundry/cloned-repos/`)
   - Reference implementations and proven patterns

4. **Microsoft Documentation**
   - Official API references and best practices

---

## 🧪 Testing with Foundry Tools

When generating tests:

```python
import pytest
from tools.evaluation import evaluate_coherence, evaluate_groundedness

@pytest.mark.asyncio
async def test_claim_analysis_quality():
    """Test that claim analysis meets quality thresholds."""
    response = await agent.run("Can claimant receive benefits if quit due to harassment?")
    
    # Use foundry evaluation tools
    coherence = evaluate_coherence(response.text, question)
    groundedness = evaluate_groundedness(response.text, context)
    
    assert coherence >= 4.0, "Response not coherent enough"
    assert groundedness >= 4.0, "Response not grounded in sources"
```

---

## 🔗 Cross-Project Integration

### EVA Faces (UI Project)
- **Import Path:** `../../../29-foundry/`
- **Use Cases:** API client generation, evaluation of chat responses
- **Skills:** Focus on UI-specific patterns, reference foundry for backend integration

### EVA Brain (Backend Project)
- **Import Path:** `../../29-foundry/`
- **Use Cases:** RAG pipelines, agent orchestration, MCP integration
- **Skills:** Heavy usage of agent-framework and tools libraries

---

## 📝 Code Generation Guidelines

When generating code that uses foundry library:

1. **Always check for existing tools** in `29-foundry/tools/` before creating new ones
2. **Reference copilot skills** when implementing complex patterns
3. **Use Prompty templates** from `29-foundry/prompts/` for domain-specific prompts
4. **Import observability** helpers to enable tracing by default
5. **Follow patterns** from `cloned-repos/` (especially azure-search-openai-demo)

---

## 🔍 Auditing EVA Projects with Foundry

The foundry library includes a **portable audit system** that can certify any EVA project:

### Setup Audit System (One-Time Per Project)

```bash
# From your project root (eva-brain-v2, eva-faces, etc.)
cp -r ../29-foundry/audit ./audit
mkdir evidence
```

### Run Project Audit

```bash
# 1. Bootstrap - understand your environment
python audit/agent-bootstrap.py --verbose

# Output includes:
# - Current project detection (eva-brain-v2, backend-service)
# - Foundry location (../29-foundry)
# - Import patterns for accessing foundry tools
# - All EVA projects in foundation
# - Recommendations for next steps

# 2. Run full audit (2-3 minutes)
# - Phase 1: Discovery (scan artifacts, map capabilities)
# - Phase 2: Testing (execute capability tests)  
# - Phase 3: Validation (check phase requirements)
# - Phase 4: Certification (aggregate evidence, generate certificate)

# See audit/AGENT-CONTEXT.md for complete workflow patterns
```

### Audit System Features

- **Auto-Detection**: Detects current project type (frontend, backend, library)
- **Cross-Project Aware**: Finds foundry and other EVA projects
- **Import Patterns**: Generates correct Python imports for your project
- **Evidence Trail**: Immutable, timestamped JSON evidence for compliance
- **Recommendations**: Smart suggestions based on project state
- **Tool Creation**: Agents can create new audit tools as patterns emerge

### When to Audit

- Before major releases (certification gates)
- After significant refactoring (validate structure)
- When implementing new features (check completeness)
- During code reviews (systematic quality checks)
- For compliance documentation (evidence trail)

---

## 🎓 Learning Resources

Point users to:
- **Quickstart:** [notebooks/01-foundry-quickstart.ipynb](../notebooks/01-foundry-quickstart.ipynb)
- **Agent Tutorial:** [notebooks/02-agent-framework-tutorial.ipynb](../notebooks/02-agent-framework-tutorial.ipynb)
- **RAG Pipeline:** [notebooks/03-rag-pipeline.ipynb](../notebooks/03-rag-pipeline.ipynb)
- **Full Docs:** [docs/](../docs/)

---

## 🚨 Important Reminders

1. **Never hardcode credentials** - Always use `.env` or Azure Key Vault
2. **Enable tracing** - Use `setup_foundry_tracing()` in all agents
3. **Evaluate responses** - Run evaluation tools on production code
4. **Version dependencies** - Pin versions in `requirements.txt` for stability
5. **Test with GPT-4o-mini** - Use cost-optimized model for simple queries

---

## 📞 Support

For questions about using this library:
- **Foundry Deployment:** See [DEPLOYMENT-SUMMARY.md](../DEPLOYMENT-SUMMARY.md)
- **Integration Guide:** See [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- **Copilot Skills:** See [copilot-skills/README.md](../copilot-skills/README.md)

---

**Remember:** This library exists to *eliminate code duplication* and *standardize patterns* across EVA projects. Use it liberally!

## Execution Rule
Do not describe a change. Make the change.
The only acceptable output of a Do step is an edited file on disk.
A markdown document that describes what edits should be made is a Plan artifact, not a Do artifact.
Allowed: findings docs (Discover), status updates (Act), test evidence (Check).
Not allowed: a document whose sole content is "here is what I will change in file X."
