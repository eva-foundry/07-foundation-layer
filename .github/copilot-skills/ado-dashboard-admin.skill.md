# ADO Dashboard Admin Skill

**Skill Name**: `@ado-dashboard-admin`  
**Domain**: EVA Portal & Dashboard Administration  
**Audience**: Portal managers, dashboard admins, workspace leads  
**Last Updated**: Session 38 (March 7, 2026)  

---

## Overview

This skill provides operational guidance for administering the EVA Dashboard (Project 39) and EVA Home portal. It covers portal configuration, product master list management, data sources, cache operations, and troubleshooting.

### When to Use This Skill

**DO use when**:
- Configuring the 23-product master list
- Adding or updating product tiles and icons
- Troubleshooting dashboard data source (APIM `/v1/scrum/dashboard`)
- Managing Cosmos cache (TTL, invalidation, refresh)
- Configuring drill-down to project details (PLAN/STATUS/ACCEPTANCE)
- Setting up sprint badges and health indicators
- Troubleshooting WI detail drawer display issues
- Testing portal in different sprint contexts

**DO NOT use when**:
- Configuring authentication/routing (use Project 31 eva-faces)
- Implementing backend API routes (use Project 33 eva-brain-v2)
- Setting up APIM policies (use Project 17 APIMtools)
- Modifying ADO work items (use `@ado-integration` skill)
- Adjusting CSS/styling (use React/frontend tools directly)

---

## 1. Portal Architecture

### Component Hierarchy

**EVA Home (/devops/home)**
```
NavHeader
├─ Logo + Bilingual toggle (GC Design System)
├─ User profile + logout

ProjectFilterBar
├─ "All Projects" dropdown
├─ Category filter (Security, Platform, AI, etc.)
└─ Sprint selector

RecentSprintSummaryBar
├─ Latest closed PBI count
├─ Team velocity trend
└─ Blocked items count

ProductTileGrid (23 products)
├─ ProductTile #1 (Red-Teaming)
│   ├─ Icon + name + category
│   ├─ SprintBadge (Active/Done/Blocked)
│   └─ Click → Project detail view
├─ ProductTile #2 (Data Model)
│   └─ ...
└─ ProductTile #23 (...)
```

**Sprint Board (/devops/sprint)**
```
SprintSelector
├─ All Sprints
├─ Sprint 2026-Q1-S1
├─ Sprint 2026-Q1-S2
└─ ...

FeatureSection (tree view)
├─ Epic 36: Red-Teaming & Adversarial Testing
│   ├─ Feature 36-01: OWASP LLM Top 10
│   │   ├─ WICard 36-01-001: Test A01 Prompt Injection
│   │   │   ├─ Status badge (Active)
│   │   │   ├─ Assignee
│   │   │   └─ Click → WIDetailDrawer
│   │   └─ WICard 36-01-002: ...
│   └─ Feature 36-02: ...
└─ Epic 37: Data Model
    └─ ...

VelocityPanel
├─ Test count sparkline (past 4 sprints)
├─ Coverage trend
└─ Blocked items trend
```

### Data Sources

| Component | Source | Endpoint | Cache TTL |
|---|---|---|---|
| ProductTileGrid | ADO via APIM | `/v1/scrum/dashboard?project=all` | 24h |
| SprintBadges | ADO work item state | `/v1/scrum/summary?sprint=...` | 6h |
| FeatureSection tree | ADO hierarchy | `/v1/scrum/features?epic=...` | 24h |
| VelocityPanel | Project 37 metrics + ADO history | `/v1/scrum/velocity?project=...` | 24h |
| WIDetailDrawer | ADO WI details + Veritas trust score | `/v1/scrum/wi/{id}/details` | 1h |

---

## 2. Product Master List Configuration

### Product Configuration Structure

Each of the 23 products is defined in `src/config/products.ts`:

```typescript
interface ProductConfig {
  id: string;              // unique ID (e.g., "red-teaming")
  projectNumber: number;   // e.g., 36
  name: string;            // display name
  description: string;     // one-liner
  category: string;        // category for filtering
  epic: number;            // ADO epic ID
  status: "active" | "poc" | "retired" | "idea";  // from PLAN.md
  icon: string;            // icon identifier or URL
  color: string;           // brand color (hex)
  team: string;            // owner team
  documentationUrl: string; // link to README/PLAN
}

const PRODUCTS: ProductConfig[] = [
  {
    id: "red-teaming",
    projectNumber: 36,
    name: "Red-Teaming",
    description: "Promptfoo black-box adversarial testing",
    category: "Security",
    epic: 29,
    status: "active",
    icon: "shield-alert",
    color: "#E81E24",
    team: "Security & AI COE",
    documentationUrl: "https://github.com/microsoft/eva-foundry/tree/main/36-red-teaming"
  },
  {
    id: "data-model",
    projectNumber: 37,
    name: "Data Model",
    description: "Single source of truth API (41 layers, cloud-hosted)",
    category: "Platform",
    epic: 30,
    status: "active",
    icon: "database",
    color: "#0078D4",
    team: "Platform",
    documentationUrl: "https://github.com/microsoft/eva-foundry/tree/main/37-data-model"
  },
  // ... 21 more products
];
```

### Adding a New Product

```typescript
// Step 1: Update PRODUCTS array in src/config/products.ts
const PRODUCTS: ProductConfig[] = [
  // ... existing products ...
  {
    id: "new-project",
    projectNumber: 52,
    name: "New Project",
    description: "Project description from README",
    category: "New Category",
    epic: 52,  // ADO epic ID
    status: "poc",
    icon: "lightbulb",
    color: "#107C10",
    team: "Your Team",
    documentationUrl: "https://github.com/microsoft/eva-foundry/tree/main/52-new-project"
  }
];

// Step 2: Update ProductTileGrid to re-render
// Component automatically refreshes when config changes

// Step 3: Verify in portal
// Visit /devops/home, check new tile appears

// Step 4: Test badge updates
// Check that Project 52's sprint badge updates as ADO work items progress
```

### Updating Product Status

When a project status changes in PLAN.md (e.g., poc → active):

```typescript
// In src/config/products.ts
{
  id: "red-teaming",
  status: "active",  // Changed from "poc"
  // ... rest of config
}

// Redeploy to update dashboard
npm run build
npm run deploy
```

---

## 3. Data Source Configuration

### APIM Endpoint: /v1/scrum/dashboard

**Endpoint**: `https://marco-sandbox-apim.azure-api.net/v1/scrum/dashboard`  
**Query Parameters**:
- `project={all|red-teaming|data-model|...}` -- Filter by project
- `sprint={all|Sprint-1|Sprint-2|...}` -- Filter by sprint
- `include=badges,velocity,wis` -- Choose response fields

**Response**: Cached in Cosmos DB (`scrum-cache` container)
```json
{
  "project": "red-teaming",
  "sprint": "2026-q1-s2",
  "wis": [
    {
      "id": "36-01-001",
      "title": "Test A01 - Prompt Injection",
      "state": "In Progress",
      "assignee": "alice@microsoft.com",
      "tests_passed": 12,
      "tests_failed": 0,
      "coverage": 87.5
    }
  ],
  "badge": "Active",
  "cached_at": "2026-03-07T12:34:56Z",
  "cache_ttl": 86400
}
```

### Backend Implementation (Project 33)

The backend route in eva-brain-v2 (`app/routes/scrum.py`):

```python
@app.get("/v1/scrum/dashboard")
async def get_scrum_dashboard(
    project: str = "all",
    sprint: str = "all",
    include: str = "badges,velocity,wis"
):
    """
    Fetch ADO dashboard data for EVA Home portal
    
    - Queries ADO via PAT
    - Computes badge status (Active/Done/Blocked)
    - Caches in Cosmos (scrum-cache, TTL 24h)
    - Injects x-eva-* cost attribution headers
    """
    
    # Step 1: Check Cosmos cache
    cache_key = f"{project}:{sprint}"
    cached = await cosmos_client.read_item(cache_key, "scrum-cache")
    if cached and not_expired(cached):
        return cached
    
    # Step 2: Query ADO via PAT
    ado_data = await ado_client.query(project, sprint)
    
    # Step 3: Compute badge
    badge = compute_badge(ado_data)
    
    # Step 4: Cache result
    response = {
        "project": project,
        "sprint": sprint,
        "wis": ado_data.work_items,
        "badge": badge,
        "cached_at": utcnow().isoformat(),
        "cache_ttl": 86400
    }
    await cosmos_client.upsert_item(response, "scrum-cache", ttl=86400)
    
    return response
```

### scrumApi.ts (Browser Client)

In Project 39, the browser client calls the APIM endpoint:

```typescript
// src/api/scrumApi.ts

export class ScrumApiClient {
  private baseUrl = "https://marco-sandbox-apim.azure-api.net";
  private cache: Map<string, CachedResponse> = new Map();
  
  async getDashboardData(project: string, sprint: string): Promise<DashboardData> {
    // Check local cache first
    const cacheKey = `${project}:${sprint}`;
    const cached = this.cache.get(cacheKey);
    if (cached && this.isFresh(cached)) {
      return cached.data;
    }
    
    // Fetch from APIM
    const response = await fetch(
      `${this.baseUrl}/v1/scrum/dashboard?project=${project}&sprint=${sprint}`,
      {
        headers: {
          "x-eva-project-id": project,
          "x-eva-sprint": sprint,
          // Request headers will have x-eva-* injected by APIM
        }
      }
    );
    
    const data = await response.json();
    
    // Cache locally for 1 hour
    this.cache.set(cacheKey, {
      data,
      cachedAt: Date.now(),
      ttl: 3600000
    });
    
    return data;
  }
}
```

---

## 4. Cache Management

### Cosmos Cache Strategy

**Container**: `scrum-cache`  
**Key Structure**: `{project}:{sprint}`  
**TTL**: 24 hours (86400 seconds)  
**Auto-expiration**: Cosmos DB TTL policy enabled

### Manual Cache Operations

**Refresh cache for a project:**
```python
from azure.cosmos import CosmosClient

client = CosmosClient(connection_string=cosmos_conn_str)
container = client.get_database_client("eva-db").get_container_client("scrum-cache")

# Delete cache entry for a project
cache_key = "red-teaming:all"
response = container.delete_item(cache_key, partition_key="red-teaming")
print(f"[PASS] Deleted cache entry {cache_key}")

# Next API call will fetch fresh data from ADO
```

**Clear all cache:**
```python
# WARNING: Affects all projects and sprints
# Only do this for maintenance/debugging

container = client.get_database_client("eva-db").get_container_client("scrum-cache")

# Delete all items in scrum-cache
query = "SELECT * FROM c"
items = container.query_items(query, enable_cross_partition_query=True)

for item in items:
    container.delete_item(item["id"], partition_key=item["project"])
    print(f"[DELETE] {item['id']}")

print("[PASS] Scrum cache cleared")
```

**Cache Status Check:**
```python
# Get cache entry age
container = client.get_database_client("eva-db").get_container_client("scrum-cache")

cache_key = "red-teaming:all"
item = container.read_item(cache_key, partition_key="red-teaming")

cached_at = datetime.fromisoformat(item["cached_at"])
age_minutes = (datetime.utcnow() - cached_at).total_seconds() / 60

print(f"Cache entry: {cache_key}")
print(f"Cached at: {cached_at}")
print(f"Age: {age_minutes:.1f} minutes")
print(f"TTL: 24 hours (will expire at {cached_at + timedelta(hours=24)})")
```

---

## 5. Drill-Down Configuration

### Project Detail View

When a user clicks a product tile, they drill down to the project detail view:

```
ProductTile (red-teaming) clicked
    ↓
Navigate to /devops/project/36
    ↓
Load project detail:
  - PLAN.md (from GitHub)
  - STATUS.md (from GitHub)
  - ACCEPTANCE.md (from GitHub)
  - Latest WI list (from ADO)
  - Trust score (from Project 37 / Project 48 Veritas)
    ↓
Display tabs:
  - Overview (README snippet + status)
  - Roadmap (PLAN.md features)
  - Backlog (ADO PBIs)
  - Evidence (test results, coverage)
  - Trust Score (Veritas audit)
```

### Configuration: Map Projects to Documentation

```typescript
// src/config/projectDetails.ts

interface ProjectDetail {
  projectId: number;
  planUrl: string;           // GitHub raw URL
  statusUrl: string;         // GitHub raw URL
  acceptanceUrl: string;     // GitHub raw URL
  readmeUrl: string;
}

const PROJECT_DETAILS: ProjectDetail[] = [
  {
    projectId: 36,
    planUrl: "https://raw.githubusercontent.com/microsoft/eva-foundry/main/36-red-teaming/PLAN.md",
    statusUrl: "https://raw.githubusercontent.com/microsoft/eva-foundry/main/36-red-teaming/STATUS.md",
    acceptanceUrl: "https://raw.githubusercontent.com/microsoft/eva-foundry/main/36-red-teaming/ACCEPTANCE.md",
    readmeUrl: "https://raw.githubusercontent.com/microsoft/eva-foundry/main/36-red-teaming/README.md"
  },
  // ... 22 more projects
];
```

### WI Detail Drawer

When a user clicks a work item in the Sprint Board, the WIDetailDrawer slides in:

```typescript
interface WIDetail {
  id: string;                    // e.g., "36-01-001"
  title: string;
  state: string;                 // "Active", "Done", "Testing", etc.
  assignee: string;
  acceptanceCriteria: string[];
  testsPassed: number;
  testsFailed: number;
  coverage: number;
  buildLog: string;              // GitHub Actions URL
  prLink: string;                // Pull request
  trustScore: number;            // From Project 48 (Veritas)
  evidence: EvidenceRecord[];    // From Project 37 Layer 31
}
```

---

## 6. Troubleshooting

### Symptom: "Dashboard not updating - showing stale data"

**Root Cause**: Cosmos cache TTL not expiring or manual refresh not triggered  
**Resolution**:
```python
# Step 1: Check current cache age
container = client.get_database_client("eva-db").get_container_client("scrum-cache")
item = container.read_item("red-teaming:all", partition_key="red-teaming")
print(f"Cache age: {(datetime.utcnow() - datetime.fromisoformat(item['cached_at'])).total_seconds() / 60} minutes")

# Step 2: If cache is old (>24 hours), delete to force refresh
if age > 24 * 60:
    container.delete_item("red-teaming:all", partition_key="red-teaming")
    print("[PASS] Deleted stale cache entry")

# Step 3: Refresh browser or manually call /v1/scrum/dashboard
# Next call will fetch fresh data from ADO
```

### Symptom: "Product tile shows 'Blocked' but all WIs are Done in ADO"

**Root Cause**: Badge logic incorrectly detecting blocked status  
**Resolution**:
```typescript
// Check badge computation logic in src/components/SprintBadge.tsx

function computeBadge(wis: WorkItem[]): "Active" | "Done" | "Blocked" {
  // Bug: checking for any tag "blocked" (case-sensitive)
  const hasBlocked = wis.some(wi => wi.tags?.includes("blocked"));
  
  // Fix: handle case variations and "blocked-by" tags
  const hasBlocked = wis.some(wi => 
    wi.tags?.some(tag => tag.toLowerCase().includes("block"))
  );
  
  return hasBlocked ? "Blocked" : ...;
}
```

### Symptom: "APIM /v1/scrum/dashboard returns 401 Unauthorized"

**Root Cause**: APIM API key missing or expired  
**Resolution**:
```bash
# Step 1: Check APIM subscription key
echo $APIM_SUBSCRIPTION_KEY

# Step 2: If empty, set from GitHub Secrets
export APIM_SUBSCRIPTION_KEY=$(get-secret "apim-subscription-key")

# Step 3: Test APIM endpoint
curl -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
     https://marco-sandbox-apim.azure-api.net/v1/scrum/dashboard?project=all

# Step 4: If still fails, regenerate APIM key
# Reach out to infrastructure team for new subscription key
```

### Symptom: "WIDetailDrawer not showing evidence or trust score"

**Root Cause**: Project 37 evidence layer or Project 48 Veritas audit not integrated  
**Resolution**:
```typescript
// Step 1: Verify Project 37 evidence is being collected
// Check `.eva/evidence/` folder in project
ls -la 36-red-teaming/.eva/evidence/

// Step 2: Verify Veritas trust score endpoint
curl https://msub-eva-data-model.../veritas/trust-score?project=36

// Step 3: If missing, trigger evidence collection
python seed-from-plan.py --project-id "36" --reseed-model

// Step 4: Re-render WIDetailDrawer
// Browser refresh should show updated evidence
```

---

## 7. Related Skills & Automation

| Skill | Purpose |
|---|---|
| `@ado-integration` | ADO work items (upstream source) |
| `@data-model-admin` | Project 37 evidence layer + Veritas trust scores |
| `@eva-faces-admin` | EVA Home portal routing + authentication |
| `scrumApi.ts` | Browser client for dashboard data |
| `/v1/scrum/dashboard` | APIM endpoint + backend implementation |

---

## 8. Key Takeaways

✅ **Product master list is source of truth** -- Update `src/config/products.ts` to add/update tiles  
✅ **APIM `/v1/scrum/dashboard` is data source** -- Cosmos cache with 24h TTL  
✅ **ADO work items feed the badges** -- Status synced via Project 38 orchestration  
✅ **Drill-down pulls from GitHub** -- PLAN/STATUS/ACCEPTANCE raw URLs  
✅ **Evidence + trust scores** -- From Project 37 + Project 48 Veritas  
✅ **Browser-side caching** -- 1-hour local cache to reduce APIM calls  

---

## 9. Quick Reference

**Add Product to Dashboard**:
```typescript
// Update src/config/products.ts
const PRODUCTS = [
  ...,
  { id: "new", projectNumber: 52, name: "New", epic: 52, ... }
];
```

**Refresh Cache**:
```python
container.delete_item("project:sprint", partition_key="project")
```

**Test APIM Endpoint**:
```bash
curl https://marco-sandbox-apim.azure-api.net/v1/scrum/dashboard?project=all
```

**View Portal**:
```
https://eva-faces.dev.azure.com/devops/home        (EVA Home)
https://eva-faces.dev.azure.com/devops/sprint      (Sprint Board)
```

---

**Revision**: 1.0.0 (March 7, 2026)  
**Maintainer**: Project 39 (ADO Dashboard) + Project 07 (Foundation Layer)  
**Last Validated**: Session 38
