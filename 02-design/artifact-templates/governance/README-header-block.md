<!-- eva-primed -->
<!-- foundation-primer: {{PRIME_DATE}} by {{PRIME_ACTOR}} -->

## EVA Ecosystem Integration

| Tool | Purpose | How to Use |
|------|---------|------------|
| 37-data-model | Single source of truth for all project entities | GET http://localhost:8010/model/projects/{{PROJECT_FOLDER}} |
| 29-foundry | Agentic capabilities (search, RAG, eval, observability) | C:\AICOE\eva-foundation\29-foundry |
| 48-eva-veritas | Trust score and coverage audit | MCP tool: audit_repo / get_trust_score |
| 07-foundation-layer | Copilot instructions primer + governance templates | MCP tool: apply_primer / audit_project |

**Agent rule**: Query the data model API before reading source files.
```powershell
Invoke-RestMethod "http://localhost:8010/model/agent-guide"   # complete protocol
Invoke-RestMethod "http://localhost:8010/model/agent-summary" # all layer counts
```

---
