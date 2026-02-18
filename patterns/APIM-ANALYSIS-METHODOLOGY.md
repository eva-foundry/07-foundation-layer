# APIM Analysis Methodology - Reusable Pattern

**Status**: 🔍 **TO BE REVIEWED**  
**Created**: 2026-02-04  
**Source**: Project 17-APIM (MS-InfoJP analysis)  
**Proven**: ✅ 100% accuracy validated through evidence-based cross-check  
**Time to Execute**: 2-3 days (with template) vs 3 weeks (from scratch)

---

## What This Is

A **systematic, repeatable methodology** for analyzing any web application to determine APIM integration readiness. Produces **evidence-based documentation** with file:line references that can be validated against source code.

**Proven Results** (Project 17-APIM):
- 212+ hours of analysis → 8,000+ lines of documentation
- 27 endpoints documented with exact line numbers
- 47 environment variables mapped with usage patterns
- 150+ Azure SDK integration points counted
- 92% initial accuracy → 100% after cross-check validation

---

## When to Use This

**Use this methodology when**:
- Integrating Azure API Management into existing application
- Need complete API inventory for governance/cost attribution
- Planning authentication/authorization overhaul
- Preparing for SOC 2/FedRAMP compliance audit
- Migrating from monolith to microservices

**Do NOT use this when**:
- Application is greenfield (no existing endpoints to analyze)
- Tech stack is non-HTTP (pure event-driven, message queues)
- Project timeline < 1 week (no time for thorough analysis)

---

## The 5-Phase Process

### Phase 1: Stack Evidence (1 day, 8 hours)

**Goal**: Understand what you're analyzing

**Tools**:
- `file_search` - Find all source files
- `read_file` - Read key files (main app, package manifests)
- Pattern recognition - Identify tech stack

**Grep Patterns**:
```powershell
# Identify backend framework
file_search(query="**/{app.py,main.py,server.py,index.js,server.js}")

# Identify frontend framework
file_search(query="**/{package.json,tsconfig.json,angular.json,vue.config.js}")

# Identify dependencies
read_file(filePath="requirements.txt")  # Python
read_file(filePath="package.json")       # Node.js
read_file(filePath="pom.xml")            # Java
```

**Outputs**:
1. **Tech Stack Inventory**: Languages, frameworks, libraries
2. **Scan Patterns**: Grep commands tailored to tech stack
3. **Inspection Priorities**: Which files to analyze first

**Deliverable**: `evidences/01-tech-stack-inventory.md`

---

### Phase 2A: API Endpoint Inventory (1 day, 8 hours)

**Goal**: Document every HTTP endpoint with evidence

**Grep Patterns by Tech Stack**:

**FastAPI (Python)**:
```powershell
grep_search(
    query="@app\.(post|get|put|delete|patch|route)\(",
    includePattern="**/*.py",
    isRegexp=true
)
```

**Express (Node.js)**:
```powershell
grep_search(
    query="app\.(post|get|put|delete|patch)\(",
    includePattern="**/*.{js,ts}",
    isRegexp=true
)
```

**ASP.NET Core (C#)**:
```powershell
grep_search(
    query="\[Http(Get|Post|Put|Delete|Patch)\]",
    includePattern="**/*.cs",
    isRegexp=true
)
```

**For Each Endpoint Found**:
1. `read_file` to get exact code (5 lines before/after decorator)
2. Document:
   - **Method**: GET, POST, PUT, DELETE, PATCH
   - **Path**: /api/endpoint
   - **Line Number**: file.py:123
   - **Purpose**: 1-sentence description
   - **Parameters**: Query params, path params, body schema
   - **Response Type**: JSON schema, streaming, binary
   - **Authentication**: Required? Token type?
   - **Rate Limit Needs**: High traffic? User-specific limits?

3. Cross-reference with frontend API client (api.ts, apiClient.js)

**Validation**:
```powershell
# Count endpoints in backend
$backendCount = (grep_search results).Count

# Count endpoints in frontend client
$frontendCount = (grep_search "@api/api.ts" functions).Count

# Should match (within ±2 for private/admin endpoints)
```

**Output**: `docs/apim-scan/01-api-call-inventory.md`

**Template**:
```markdown
## API Endpoint Inventory

**Total Endpoints**: 27  
**Public Endpoints**: 20  
**Admin Endpoints**: 7  
**Streaming Endpoints**: 3

### Standard Endpoints

| Method | Path | Line | Purpose | Auth |
|--------|------|------|---------|------|
| POST | /chat | app.py:307 | Multi-turn chat | Required |
| GET | /health | app.py:150 | Health check | Public |
| POST | /upload | app.py:420 | Document upload | Required |

### Streaming Endpoints (SSE)

| Method | Path | Line | Protocol | Buffer |
|--------|------|------|----------|--------|
| POST | /stream | app.py:779 | SSE (text/event-stream) | Must disable |
```

---

### Phase 2B: Authentication Analysis (1 day, 8 hours)

**Goal**: Map authentication flow and identify gaps

**Grep Patterns**:
```powershell
# Find credential initialization
grep_search(
    query="DefaultAzureCredential|AzureCliCredential|ManagedIdentityCredential|ClientSecretCredential",
    isRegexp=true
)

# Find JWT/token handling
grep_search(
    query="jwt\.decode|verify_token|@require_auth|check_authorization",
    isRegexp=true
)

# Find user identity extraction
grep_search(
    query="request\.user|get_user|current_user|X-MS-CLIENT-PRINCIPAL",
    isRegexp=true
)

# Find authorization checks
grep_search(
    query="@require_role|check_permission|authorize|@auth",
    isRegexp=true
)
```

**For Each Auth Pattern**:
1. Trace authentication flow (request → validation → user object)
2. Document credential types (Managed Identity, API Key, JWT)
3. Identify missing user authentication
4. Map authorization enforcement points
5. Check for vulnerable endpoints (no auth required)

**Critical Questions**:
- [ ] Is user authentication implemented? (JWT from Entra ID?)
- [ ] Are all endpoints protected? (Or some public?)
- [ ] How are user identities extracted? (Claims, headers, tokens?)
- [ ] Is authorization enforced? (Role-based, resource-based?)
- [ ] Are service-to-service calls using Managed Identity?

**Output**: `docs/apim-scan/02-auth-and-identity.md`

**Template**:
```markdown
## Authentication Architecture

### Current State: Service-to-Service Only

**Credential Type**: Azure Managed Identity + DefaultAzureCredential  
**User Authentication**: ❌ NOT IMPLEMENTED  
**Authorization**: ❌ NOT ENFORCED

### Authentication Flow

1. App Service → Azure OpenAI: Managed Identity
2. App Service → Cognitive Search: Managed Identity
3. App Service → Blob Storage: Managed Identity
4. UI → Backend: **NO AUTHENTICATION** (all endpoints public)

### Critical Gap: Missing User Authentication

**Risk**: Any user can call any endpoint, access any data

**Recommendation**: Implement Entra ID OAuth 2.0 flow
- Frontend: MSAL.js for token acquisition
- Backend: JWT validation middleware
- APIM: JWT validation policy
```

---

### Phase 2C: Configuration Mapping (1 day, 8 hours)

**Goal**: Document all environment variables with usage patterns

**Grep Patterns**:
```powershell
# Python
grep_search(query="os\.getenv|ENV\[", isRegexp=true)

# Node.js
grep_search(query="process\.env\.", isRegexp=false)

# .NET
grep_search(query="Configuration\[|Environment\.GetEnvironmentVariable", isRegexp=true)
```

**For Each Environment Variable**:
1. `read_file` to see ENV dictionary initialization
2. Document:
   - **Name**: AZURE_OPENAI_ENDPOINT
   - **Purpose**: Azure OpenAI service endpoint URL
   - **Type**: URL, String, Integer, Boolean
   - **Required**: Yes/No
   - **Default**: (if any)
   - **Used In**: app.py:156, chatreadretrieveread.py:45
   - **Category**: Azure Services, Features, Operational, Security

3. Group by category for readability

**Validation**:
```powershell
# Read ENV dictionary directly
read_file(filePath="app.py", startLine=46, endLine=93)

# Count variables
$envCount = (ENV dictionary keys).Count

# Cross-check with .env file
$envFileCount = (Get-Content .env | Where-Object {$_ -match "^[A-Z_]+"}).Count
```

**Output**: `docs/apim-scan/03-config-and-base-urls.md`

**Template**:
```markdown
## Environment Variables

**Total**: 47 variables  
**Azure Services**: 18  
**Feature Flags**: 12  
**Operational**: 10  
**Security**: 7

### Azure OpenAI Configuration

| Variable | Purpose | Type | Required |
|----------|---------|------|----------|
| AZURE_OPENAI_ENDPOINT | Service endpoint | URL | Yes |
| AZURE_OPENAI_CHATGPT_DEPLOYMENT | Model deployment name | String | Yes |
| AZURE_OPENAI_TEMPERATURE | Response randomness | Float | No (default: 0.7) |

### Special Notes: EVA-JP-v1.2 Environment Switcher

**Multi-Environment Support**: EVA-JP-v1.2 has a PowerShell script that switches between environments:
- `Switch-Environment.ps1 -Environment sandbox` - Marco's personal sandbox
- `Switch-Environment.ps1 -Environment dev2` - Shared development
- `Switch-Environment.ps1 -Environment hccld2` - Production HCCLD2

**What It Does**:
- Backs up current `backend.env` → `backend.env.backup-{timestamp}`
- Copies `backend.env.{environment}` → `backend.env`
- Preserves fallback flags (OPTIMIZED_KEYWORD_SEARCH_OPTIONAL, etc.)

**Implication for APIM**: Need environment-specific APIM instances or URL routing
```

---

### Phase 2D: Streaming Analysis (1 day, 8 hours)

**Goal**: Identify streaming endpoints and APIM buffering concerns

**Grep Patterns**:
```powershell
# Find SSE (Server-Sent Events)
grep_search(query="text/event-stream|Server-Sent Events", isRegexp=false)

# Find streaming responses
grep_search(query="StreamingResponse|stream=True|Response.*stream", isRegexp=true)

# Find async generators
grep_search(query="async def.*yield|async for", isRegexp=true)

# Find ndjson/chunked transfer
grep_search(query="ndjson|chunked|Transfer-Encoding", isRegexp=false)
```

**For Each Streaming Endpoint**:
1. Trace data flow (request → async generator → response)
2. Document:
   - **Endpoint**: /stream
   - **Protocol**: SSE (text/event-stream) or ndjson
   - **Chunking Strategy**: Token-by-token, sentence-by-sentence
   - **Data Format**: JSON per line, binary chunks
   - **APIM Concern**: Buffering will break streaming

3. Test streaming behavior:
   ```powershell
   # Test with curl
   curl -N http://localhost:5000/stream -H "Content-Type: application/json" -d '{"query":"test"}'
   
   # Look for incremental chunks (not buffered)
   ```

**Critical APIM Configuration**:
- **Policy Required**: `<set-backend-service ... buffering="false" />`
- **Timeout**: Increase to match longest response time (default 30s → 300s)
- **Connection**: Use persistent connections (HTTP/1.1 keep-alive)

**Output**: `docs/apim-scan/04-streaming-analysis.md`

---

### Phase 2E: SDK Integration Deep Dive (2 days, 16 hours)

**Goal**: Count Azure SDK integration points, assess APIM interception feasibility

**Grep Patterns**:
```powershell
# Find Azure SDK imports
grep_search(query="from azure|import azure", isRegexp=false, includeIgnoredFiles=true)

# Find specific SDK clients
grep_search(
    query="AsyncAzureOpenAI|SearchClient|BlobServiceClient|CosmosClient|DocumentAnalysisClient",
    isRegexp=true
)

# Find SDK method calls
grep_search(query="\.chat\.completions\.create|\.search\(|\.upload_blob\(|\.read_item\(", isRegexp=true)
```

**For Each SDK Found**:
1. Count integration points:
   - Import statements (how many files use this SDK?)
   - Client initialization (singleton or per-request?)
   - Method calls (how many actual API calls?)

2. Assess APIM interception:
   - ❌ **Cannot intercept**: SDKs handle auth internally, bypass HTTP proxies
   - 🟡 **Can intercept with refactoring**: Replace SDK with raw HTTP calls (200-400 hours)
   - ✅ **Alternative**: Backend middleware logs SDK calls to Cosmos DB

3. Calculate refactoring effort:
   ```python
   # Effort formula
   sdk_calls_count = 150  # From grep results
   hours_per_call = 1.8   # Refactor + test + deploy
   total_hours = sdk_calls_count * hours_per_call  # 270 hours
   risk_factor = 1.5      # High risk (breaking changes)
   adjusted_hours = total_hours * risk_factor      # 405 hours
   ```

**Recommendation Logic**:
- If SDK calls < 20: Refactor to HTTP (manageable)
- If SDK calls 20-50: Evaluate case-by-case
- If SDK calls > 50: Use backend middleware (saves 250-380 hours)

**Output**: `docs/apim-scan/APPENDIX-A-Azure-SDK-Clients.md`

---

## Phase 3: Cross-Check Validation (4 hours)

**Goal**: Verify documentation accuracy against source code

**Process**:
1. **Endpoint Count Validation**:
   ```powershell
   # Grep actual endpoints
   $actualCount = grep_search("@app\.(post|get)").Count
   
   # Read documented count
   $documentedCount = (read_file "01-api-call-inventory.md" | Select-String "Total Endpoints: (\d+)").Matches.Groups[1].Value
   
   # Compare
   if ($actualCount -ne $documentedCount) {
       Write-Host "DISCREPANCY: Actual=$actualCount, Documented=$documentedCount"
   }
   ```

2. **Environment Variable Validation**:
   ```powershell
   # Read ENV dict directly
   $envDict = read_file "app.py" -StartLine 46 -EndLine 93
   $actualEnvCount = ($envDict | Select-String 'ENV\["([^"]+)"\]').Matches.Count
   
   # Compare with documentation
   ```

3. **Line Number Drift Check**:
   ```powershell
   # Endpoints documented at line 307, verify current location
   $currentLine = grep_search("@app.post\('/chat'\)").Line
   
   if ($currentLine -ne 307) {
       Write-Host "LINE DRIFT: /chat moved from 307 to $currentLine"
   }
   ```

**Expected Accuracy**: 90-95% initial → 100% after corrections

**Output**: `ACCURACY-AUDIT-{date}.md`

---

## Phase 4: Correction & Validation (4 hours)

**Goal**: Update documentation to 100% accuracy

**Process**:
1. For each discrepancy found in Phase 3:
   - Update count (endpoints, env vars)
   - Correct line numbers
   - Add missing items
   - Remove obsolete items

2. Use `multi_replace_string_in_file` for efficient bulk updates

3. Create audit report documenting:
   - Before/after metrics
   - Specific changes made
   - Verification method
   - Achieved accuracy

**Output**: Updated documentation + audit report

---

## Evidence-Based Validation Principles

### 1. Always Include File:Line References
```markdown
❌ BAD: "The chat endpoint handles user messages"
✅ GOOD: "The chat endpoint (app.py:307) handles user messages via POST /chat"
```

### 2. Use Conservative Claims
```markdown
❌ BAD: "20 endpoints documented"
✅ GOOD: "20+ endpoints documented" (provides buffer for undercounting)
```

### 3. Cross-Reference Multiple Sources
- Backend code (app.py) ↔ Frontend client (api.ts)
- ENV dictionary ↔ .env file
- Documentation claims ↔ Grep results

### 4. Capture Evidence Trails
Every finding should be traceable:
```markdown
**Finding**: 27 HTTP endpoints
**Evidence**: grep_search(@app.(post|get), "app.py") → 27 matches
**Files**: app.py:150-850 (endpoint definitions)
**Cross-check**: api.ts has 20 client functions (7 are admin-only)
```

### 5. Document Line Drift Expectations
```markdown
**Note**: Line numbers accurate as of 2026-02-04. Active development may cause ±30 line drift.
**Validation**: Re-run grep searches quarterly to update line numbers.
```

---

## Time Estimates by Project Size

| Project Size | Endpoints | Files | Phase 1 | Phase 2 | Phase 3-4 | Total |
|--------------|-----------|-------|---------|---------|-----------|-------|
| **Small** | 5-10 | <20 | 4 hours | 2 days | 4 hours | 3 days |
| **Medium** | 11-30 | 20-50 | 8 hours | 4 days | 8 hours | 5 days |
| **Large** | 31-100 | 50-100 | 1 day | 2 weeks | 1 day | 3 weeks |
| **Enterprise** | 100+ | 100+ | 2 days | 4 weeks | 2 days | 5 weeks |

**Project 17-APIM was "Large"**: 27 endpoints, 40+ files, 3 weeks (212 hours)

---

## Deliverables Template

Create this folder structure:

```
{project-name}-apim-analysis/
├── README.md                           # Project overview
├── PLAN.md                             # Phases 3-5 execution plan
├── STATUS.md                           # Current status dashboard
├── 00-SUMMARY.md                       # Phase 1-2 completion summary
├── 00-NEXT-STEPS.md                    # Immediate action items
├── ACCURACY-AUDIT-{date}.md            # Validation report
├── evidences/                          # Phase 1 outputs
│   ├── 01-tech-stack-inventory.md
│   ├── 02-scan-patterns.md
│   └── 03-inspection-priorities.md
└── docs/apim-scan/                     # Phase 2 outputs
    ├── INDEX.md                        # Deliverable index
    ├── 01-api-call-inventory.md        # All HTTP endpoints
    ├── 02-auth-and-identity.md         # Authentication analysis
    ├── 03-config-and-base-urls.md      # Environment variables
    ├── 04-streaming-analysis.md        # Streaming patterns
    ├── 05-header-contract-draft.md     # Governance headers
    ├── 06-error-handling-analysis.md   # Error patterns
    ├── 07-rate-limiting-needs.md       # Rate limit requirements
    └── APPENDIX-A-Azure-SDK-Clients.md # SDK integration analysis
```

---

## Success Criteria

### Documentation Quality
- [ ] 100% accuracy verified through cross-check
- [ ] All endpoints documented with file:line evidence
- [ ] All environment variables mapped with usage
- [ ] Authentication gaps identified
- [ ] Streaming concerns documented
- [ ] SDK integration points counted

### Actionable Outputs
- [ ] OpenAPI spec can be generated from inventory
- [ ] APIM policies can be designed from requirements
- [ ] Backend middleware scope is clear (if SDK refactoring not viable)
- [ ] Cost estimates are evidence-based (not guesses)
- [ ] Risk assessment is comprehensive

### Project Readiness
- [ ] Team can proceed to Phase 3 (APIM Design) with confidence
- [ ] No "unknown unknowns" - architecture fully mapped
- [ ] Effort estimates are validated (not ballpark)
- [ ] Stakeholders have evidence to review and approve

---

## Known Limitations

1. **Line Drift**: Active development causes line numbers to shift (±30 lines over 1 month)
   - **Mitigation**: Re-run grep searches quarterly

2. **Dynamic Endpoints**: Endpoints registered at runtime (not statically analyzable)
   - **Mitigation**: Inspect runtime logs, OpenAPI /docs endpoint

3. **SDK Calls Behind Abstractions**: SDK calls wrapped in utility functions
   - **Mitigation**: Use `includeIgnoredFiles=true` to search in node_modules/site-packages

4. **Private/Admin Endpoints**: Not exposed in frontend client
   - **Mitigation**: Check backend routes directly, review Swagger docs

---

## Lessons Learned (Project 17-APIM)

### What Worked Well
✅ Systematic grep patterns found all endpoints  
✅ File:line references enabled precise validation  
✅ Conservative claims ("20+") provided buffer for undercounting  
✅ Cross-check audit caught discrepancies before stakeholder review  
✅ Multi-environment note (sandbox/dev2/hccld2) prevented future confusion

### What Could Be Improved
🟡 Initial analysis didn't account for line drift (±30 lines over 1 month)  
🟡 Admin endpoints not cross-referenced with frontend (caused undercount)  
🟡 ENV dictionary should have been read directly (not inferred from usage)

### Critical Insight
**Evidence trails are essential**: Every claim should be traceable to source code. "We found 27 endpoints" means nothing without `grep_search(@app.post|@app.get) → 27 matches in app.py`.

---

## Adaptation Notes for Different Tech Stacks

### Express.js (Node.js)
```javascript
// Grep pattern
app.(get|post|put|delete)\(

// Environment variables
process.env.AZURE_OPENAI_ENDPOINT
```

### ASP.NET Core (C#)
```csharp
// Grep pattern
\[Http(Get|Post|Put|Delete|Patch)\]

// Environment variables
Configuration["AzureOpenAI:Endpoint"]
```

### Flask (Python)
```python
# Grep pattern
@app.route\(|@bp.route\(

# Environment variables
os.environ.get("AZURE_OPENAI_ENDPOINT")
```

### Django (Python)
```python
# Grep pattern
path\(|re_path\(

# Environment variables
settings.AZURE_OPENAI_ENDPOINT
```

---

## Next Steps After Analysis Complete

1. **Week 1**: Review with stakeholders, get approval
2. **Week 2**: Generate OpenAPI spec from inventory
3. **Week 3**: Design APIM policies (auth, rate limit, headers)
4. **Week 4**: Implement backend middleware (if SDK refactoring not viable)
5. **Week 5**: Integration testing
6. **Week 6**: Deployment and cutover

**Reference**: See [PLAN.md](../17-apim/PLAN.md) for detailed Phase 3-5 execution plan

---

## Questions & Feedback

**For questions about this methodology**:
- Review Project 17-APIM as reference implementation
- Check [ACCURACY-AUDIT-20260204.md](../17-apim/ACCURACY-AUDIT-20260204.md) for validation example
- See [copilot-instructions.md](../../.github/copilot-instructions.md) for evidence-based validation principles

**Status**: 🔍 **TO BE REVIEWED** - This methodology needs validation on second project (EVA-JP-v1.2) before marking as production-ready.
