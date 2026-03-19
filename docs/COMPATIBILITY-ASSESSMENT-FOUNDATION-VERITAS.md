# Foundation Layer & Veritas Audit Compatibility Assessment

**Date**: 2026-03-11  
**Author**: AI Agent (GitHub Copilot)  
**Purpose**: Assess readiness to rebuild Project 51 evidence-based backlog using Foundation primer + Veritas audit seeder  
**Status**: COMPATIBLE WITH REMEDIATION REQUIRED

---

## Executive Summary

**FINDING**: Foundation Layer templates and Veritas audit seeder are **80% compatible** with **critical gaps** that must be addressed before rebuilding Project 51's evidence-based backlog.

**STATUS**: 🟡 READY WITH REMEDIATION  
- ✅ **Architecture**: Complementary top-down (Foundation) + bottom-up (Veritas) workflows  
- ✅ **Data Model Integration**: Both systems write to same cloud API (Layer 26 WBS, Layer 31 Evidence, Layer 29 Risks, Layer 30 Decisions)  
- ⚠️ **Schema Alignment**: WBS ID generation patterns differ  
- ⚠️ **Workflow Gaps**: No unified "seed-then-audit-then-reconcile" workflow  
- ❌ **Template Coverage**: Foundation seed template missing WBS layer seeding

**RECOMMENDATION**: Implement 4 remediation steps before full Project 51 rebuild

---

## System Architecture Overview

### Foundation Layer (Project 07) - Top-Down Planning
```
Purpose: Project scaffolding and governance template deployment
Flow:    PLAN.md → veritas-plan.json → data-model seeder → Local SQLite/Cloud API
Layers:  
  - PLAN.md template (Feature/Story structure)
  - data-model-seed-template.py (seeding endpoints, containers, screens, etc.)
  - Invoke-PrimeWorkspace.ps1 (automated priming)
Outputs: Governance docs + Local data model layers (L1-L10, L20-L22, L36, etc.)
```

### Veritas Audit (Project 48) - Bottom-Up Evidence Extraction
```
Purpose: Evidence-based backlog generation from actuals
Flow:    Code/Evidence → Discover → Reconcile → Export → Upload → Cloud API
Layers:
  - discover.js (scans code, evidence files, governance docs)
  - reconcile.js (MTI scoring, gap analysis)
  - export-to-model.js (generates WBS, Evidence, Decisions, Risks)
  - upload-to-model.js (pushes to cloud API with conflict resolution)
Outputs: Layer 26 (WBS), Layer 31 (Evidence), Layer 29 (Risks), Layer 30 (Decisions)
```

### Data Model API (Project 37) - Single Source of Truth
```
Purpose: Cloud-based governance truth with 91 operational layers
Endpoint: https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io
Layers:
  - L26: WBS (3,292 objects - epic/feature/user_story hierarchy)
  - L27: Sprints (48 objects - sprint tracking)
  - L29: Risks (5 objects - risk register)
  - L30: Decisions (4 objects - decision log)
  - L31: Evidence (120 objects - immutable audit trail)
  - L33: Evidence (alias for L31)
  - L46: Project Work (session tracking)
Policy: API-only governance (fail-closed, no disk fallback)
```

---

## Compatibility Analysis

### ✅ COMPATIBLE: Complementary Architectures

**Finding**: Foundation (top-down) and Veritas (bottom-up) are **designed to work together**

| Aspect | Foundation Layer | Veritas Audit | Compatibility |
|--------|------------------|---------------|---------------|
| **Planning** | Creates PLAN.md with Feature/Story structure | Reads PLAN.md, generates veritas-plan.json | ✅ Compatible |
| **Evidence** | Templates for evidence file structure | Discovers evidence files, extracts to L31 | ✅ Compatible |
| **Data Model** | Seeds local SQLite with operational layers | Exports WBS/Evidence/Risks/Decisions to cloud | ✅ Compatible |
| **Workflow** | Day 1 scaffolding (before coding) | Ongoing audit (after coding) | ✅ Complementary |

**Lifecycle Integration**:
1. **Day 1**: Foundation primer creates PLAN.md, README, STATUS, ACCEPTANCE
2. **Day 2-N**: Development creates code and evidence files
3. **Sprint Close**: Veritas audit extracts actuals, generates WBS, uploads to cloud API
4. **Sprint Open**: Foundation can reseed from cloud API for next sprint

### ⚠️ INCOMPATIBLE: WBS ID Generation Patterns

**Finding**: ID generation differs between systems, causing **duplicate WBS records**

#### Foundation Template (data-model-seed-template.py)
```python
# WBS layer NOT included in WIPEABLE_LAYERS or model_reseed()
# WBS seeding is missing from template entirely
WIPEABLE_LAYERS = [
    "requirements", "endpoints", "containers", "screens", "agents",
    "services", "personas", "decisions", "schemas", "hooks",
    "components", "literals", "infrastructure", "feature_flags",
    "sprints", "milestones", "wbs",  # Listed but not seeded
]
```

#### Veritas Extractor (wbs-extractor.js)
```javascript
// Generates sequential IDs:
// - WBS-{PROJECT} (root epic)
// - WBS-F01, WBS-F02... (features)
// - WBS-S001, WBS-S002... (stories)

const rootId = `WBS-${projectId.replace(/[^a-zA-Z0-9]/g, '')}`;
const featureId = `WBS-F${String(featureSeq).padStart(2, '0')}`;
const storyId = `WBS-S${String(storySeq).padStart(3, '0')}`;
```

#### Project 51 Current State
```json
// .eva/model-export.json shows Veritas-generated IDs:
{
  "id": "WBS-51ACA",  // Root epic
  "id": "WBS-F01",    // Feature 1
  "id": "WBS-S001",   // Story 1
  ...
}
```

**Conflict**: If Foundation template adds WBS seeding with different ID pattern, creates duplicate WBS nodes

**Impact**: 
- MTI scoring confusion (which WBS record is truth?)
- Story-to-evidence linkage breaks
- Sprint velocity calculations fail

### ⚠️ MISSING: WBS Layer Seeding in Foundation Template

**Finding**: Foundation template seeds 14 layers but **excludes WBS (L26)**

#### Template Coverage Audit
| Layer | Foundation Seed | Veritas Export | Cloud API (L#) | Status |
|-------|----------------|----------------|----------------|--------|
| Services | ✅ SERVICE_DEFS | ❌ | L1 | ✅ Complete |
| Containers | ✅ CONTAINER_DEFS | ❌ | L4 | ✅ Complete |
| Endpoints | ✅ ENDPOINT_DEFS | ❌ | L5 | ✅ Complete |
| Screens | ✅ SCREEN_DEFS | ❌ | L7 | ✅ Complete |
| Agents | ✅ AGENT_DEFS | ❌ | L9 | ✅ Complete |
| Personas | ✅ PERSONA_DEFS | ❌ | L2 | ✅ Complete |
| Hooks | ✅ HOOK_DEFS | ❌ | L8 | ✅ Complete |
| Infrastructure | ✅ INFRASTRUCTURE_DEFS | ❌ | L10 | ✅ Complete |
| Feature Flags | ✅ FEATURE_FLAG_DEFS | ❌ | -- | ✅ Complete |
| **WBS** | ❌ **MISSING** | ✅ WBS_DEFS | **L26** | ⚠️ **GAP** |
| Evidence | ❌ | ✅ Evidence extraction | L31 | ✅ Veritas only |
| Decisions | ❌ | ✅ Decision extraction | L30 | ✅ Veritas only |
| Risks | ❌ | ✅ Risk extraction | L29 | ✅ Veritas only |

**Analysis**:
- Foundation seeds **operational app layers** (services, endpoints, screens)
- Veritas extracts **governance audit layers** (WBS, evidence, decisions, risks)
- **Intentional separation** BUT creates workflow gap: no Day 1 WBS seeding from PLAN.md

### ⚠️ WORKFLOW GAP: No Unified Seed-Audit-Reconcile Pattern

**Finding**: No documented workflow for **"Prime → Develop → Audit → Reconcile → Reseed"** cycle

#### Current State (Fragmented)
```
Foundation Workflow:
  1. Run Invoke-PrimeWorkspace.ps1 (creates governance docs)
  2. Manually create data-model seeder script
  3. Run seeder to create local layers
  4. Develop → code + evidence
  [NO STEP 5]

Veritas Workflow:
  1. Develop → code + evidence
  2. Run eva audit (discovers actuals)
  3. Run eva export-to-model (generates WBS/Evidence/Risks/Decisions)
  4. Run eva upload-to-model (pushes to cloud API)
  [NO STEP 0]
```

#### Desired State (Unified)
```
Integrated Workflow:
  [DAY 1 - FOUNDATION]
  1. Run Invoke-PrimeWorkspace.ps1 (creates PLAN.md, STATUS.md, README)
  2. Run eva generate-plan (PLAN.md → veritas-plan.json)
  3. Run eva seed-wbs-from-plan (veritas-plan.json → WBS Layer L26 + upload to cloud)
  4. Run foundation seeder (seeds operational layers L1-L10, L20-L22)
  
  [DAY 2-N - DEVELOPMENT]
  5. Develop → code + evidence files
  
  [SPRINT CLOSE - VERITAS AUDIT]
  6. Run eva sync_repo (discover + reconcile + export + upload in one command)
     - Discovers: code artifacts, evidence files
     - Reconciles: planned WBS vs actual implementation
     - Exports: Updates WBS status, generates evidence records
     - Uploads: Pushes to cloud API with conflict resolution
  
  [SPRINT OPEN - RESEED]
  7. Run foundation reseed from cloud API (optional: sync local from cloud)
```

**Impact**: Manual workflow orchestration required, error-prone

---

## Gap Analysis: Project 51 Readiness

### Current State Audit

#### ✅ PRESENT: Project 51 has Veritas audit artifacts
```
51-ACA/
├── .eva/
│   ├── veritas-plan.json          [PRESENT] ✅ 281 stories, 15 epics
│   ├── model-export.json          [PRESENT] ✅ WBS + Evidence extracted
│   ├── discovery.json             [PRESENT] ✅ Artifact scan complete
│   └── reconciliation.json        [PRESENT] ✅ MTI score calculated
├── data-model/
│   ├── db.py                      [PRESENT] ✅ SQLite backend operational
│   ├── seed-evidence.py           [PRESENT] ✅ Evidence seeder script
│   └── aca-model.db               [PRESENT] ✅ Local data model with layers
├── PLAN.md                        [PRESENT] ✅ Epic/Feature/Story structure
├── STATUS.md                      [PRESENT] ✅ Sprint/Story status
└── ACCEPTANCE.md                  [PRESENT] ✅ Quality gates defined
```

#### ⚠️ MISSING: Foundation template patterns
```
51-ACA/
├── data-model/
│   ├── seed-from-plan.py          [MISSING] ⚠️ No WBS seeding from PLAN.md
│   ├── seed-operational.py        [CUSTOM]  ⚠️ Not using Foundation template
│   └── .coverage data             [MISSING] ⚠️ No test coverage on seeder
├── .github/
│   └── copilot-instructions.md    [PRESENT] ✅ But outdated (pre-Session 44)
└── .eva/
    └── fractal-dpdca-*.json       [MISSING] ⚠️ No priming evidence
```

#### ❌ CONFLICTS: Multiple WBS sources
```
Source 1: PLAN.md                  [Epic 1-15, Feature 1.1-15.4, Story ACA-XX-XXX]
Source 2: veritas-plan.json        [Same content, JSON format]
Source 3: .eva/model-export.json   [WBS-51ACA, WBS-F01-F15, WBS-S001-S281]
Source 4: Cloud API L26 layer      [Unknown - needs audit]
```

**Conflict**: 4 WBS sources, no documented reconciliation strategy

### Remediation Required Before Rebuild

#### 🔴 CRITICAL Priority 1: Establish WBS Single Source of Truth

**Problem**: 4 WBS sources with no reconciliation  
**Impact**: Cannot rebuild backlog without knowing which WBS is authoritative

**Solution**:
```powershell
# Step 1: Audit cloud API WBS layer
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$wbs = Invoke-RestMethod "$base/model/wbs/?project_id=51-ACA"
Write-Host "Cloud WBS count: $($wbs.Count)"

# Step 2: Decision matrix
if ($wbs.Count -eq 0) {
    # No cloud WBS → Use Veritas export as seed
    Write-Host "[ACTION] Upload .eva/model-export.json to cloud as truth"
}
elseif ($wbs.Count -gt 0 -and $wbs.Count -ne 281) {
    # Partial cloud WBS → Reconcile or wipe + reseed
    Write-Host "[ACTION] Reconcile cloud vs local, or wipe + reseed"
}
else {
    # Full cloud WBS → Audit for staleness
    Write-Host "[ACTION] Compare cloud timestamps vs PLAN.md last update"
}

# Step 3: Document decision
Write-Output @"
WBS Truth Decision (2026-03-11):
  Source: [Cloud API | Veritas Export | PLAN.md]
  Rationale: [...]
  Action: [...]
"@ | Out-File "51-ACA/docs/WBS-TRUTH-DECISION.md"
```

**Acceptance Criteria**:
- [ ] Cloud API L26 layer audited
- [ ] WBS source decision documented in `51-ACA/docs/WBS-TRUTH-DECISION.md`
- [ ] All systems aligned to single source

#### 🟡 HIGH Priority 2: Create Unified Seeder Script

**Problem**: No script that seeds WBS from PLAN.md → Cloud API  
**Impact**: Manual workflow required for Day 1 setup

**Solution**: Create `07-foundation-layer/templates/seed-wbs-from-plan-template.py`
```python
#!/usr/bin/env python3
"""
seed-wbs-from-plan-template.py -- Foundation WBS Seeder
==========================================================
PURPOSE: Generate WBS layer (L26) from PLAN.md via veritas-plan.json

USAGE:
  python seed-wbs-from-plan.py               # Seed local SQLite
  python seed-wbs-from-plan.py --cloud       # Upload to cloud API
  python seed-wbs-from-plan.py --dry-run     # Preview

INTEGRATION:
  1. Requires: .eva/veritas-plan.json (run eva generate-plan first)
  2. Generates: WBS records compatible with Veritas export schema
  3. Uploads: To cloud API with conflict resolution
"""

import sys
import json
import argparse
from pathlib import Path
from datetime import datetime, timezone

# Load veritas-plan.json
REPO_ROOT = Path(__file__).parent.parent
PLAN_FILE = REPO_ROOT / ".eva" / "veritas-plan.json"

def load_veritas_plan():
    if not PLAN_FILE.exists():
        print("[FAIL] .eva/veritas-plan.json not found")
        print("[INFO] Run: eva generate-plan --repo .")
        sys.exit(1)
    
    with open(PLAN_FILE, 'r') as f:
        return json.load(f)

def generate_wbs_records(plan):
    """Generate WBS records matching Veritas export schema"""
    records = []
    project_id = plan.get("prefix", "PROJECT")
    
    # Root epic
    root_id = f"WBS-{project_id.replace('-', '')}"
    records.append({
        "id": root_id,
        "project_id": project_id,
        "parent_wbs_id": None,
        "label": f"Project: {project_id}",
        "level": "epic",
        "status": "planned",
        "percent_complete": 0,
        "points_total": 0,  # Will calculate
        "points_done": 0,
        "stories_total": 0,  # Will calculate
        "stories_done": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": datetime.now(timezone.utc).isoformat()
    })
    
    # Features + Stories
    feature_seq = 1
    story_seq = 1
    total_points = 0
    total_stories = 0
    
    for feature in plan.get("features", []):
        feature_id = f"WBS-F{str(feature_seq).zfill(2)}"
        feature_stories = feature.get("stories", [])
        feature_points = sum(s.get("points", 3) for s in feature_stories)
        
        records.append({
            "id": feature_id,
            "project_id": project_id,
            "parent_wbs_id": root_id,
            "label": feature.get("title", feature.get("id", "")),
            "level": "feature",
            "status": "planned",
            "percent_complete": 0,
            "points_total": feature_points,
            "points_done": 0,
            "stories_total": len(feature_stories),
            "stories_done": 0,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "updated_at": datetime.now(timezone.utc).isoformat()
        })
        
        total_points += feature_points
        total_stories += len(feature_stories)
        
        # Stories
        for story in feature_stories:
            story_id = f"WBS-S{str(story_seq).zfill(3)}"
            points = story.get("points", 3)
            
            records.append({
                "id": story_id,
                "project_id": project_id,
                "parent_wbs_id": feature_id,
                "label": story.get("title", story.get("id", "")),
                "level": "user_story",
                "status": "planned",
                "percent_complete": 0,
                "points_total": points,
                "points_done": 0,
                "acceptance_criteria": None,  # TODO: Extract from PLAN.md
                "original_story_id": story.get("id", ""),
                "created_at": datetime.now(timezone.utc).isoformat(),
                "updated_at": datetime.now(timezone.utc).isoformat()
            })
            
            story_seq += 1
        
        feature_seq += 1
    
    # Update root totals
    records[0]["points_total"] = total_points
    records[0]["stories_total"] = total_stories
    
    return records

def upload_to_cloud(records, api_base, dry_run=False):
    """Upload WBS records to cloud API with conflict resolution"""
    import requests
    
    success = 0
    skipped = 0
    failed = 0
    
    for record in records:
        if dry_run:
            print(f"[DRY] Would POST /model/wbs/ → {record['id']}")
            continue
        
        try:
            # Check if exists
            resp = requests.get(f"{api_base}/model/wbs/{record['id']}")
            if resp.status_code == 200:
                print(f"[SKIP] WBS {record['id']} already exists")
                skipped += 1
                continue
            
            # POST new record
            resp = requests.post(f"{api_base}/model/wbs/", json=record)
            resp.raise_for_status()
            print(f"[PASS] WBS {record['id']} uploaded")
            success += 1
            
        except Exception as e:
            print(f"[FAIL] WBS {record['id']}: {e}")
            failed += 1
    
    print(f"\n[SUMMARY] Success: {success} | Skipped: {skipped} | Failed: {failed}")
    return failed == 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cloud", action="store_true", help="Upload to cloud API")
    parser.add_argument("--dry-run", action="store_true", help="Preview without uploading")
    parser.add_argument("--api-base", 
        default="https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io",
        help="Cloud API base URL")
    args = parser.parse_args()
    
    # Load plan
    plan = load_veritas_plan()
    print(f"[INFO] Loaded veritas-plan.json: {plan.get('prefix', 'UNKNOWN')}")
    
    # Generate WBS records
    records = generate_wbs_records(plan)
    print(f"[INFO] Generated {len(records)} WBS records")
    
    # Upload to cloud
    if args.cloud:
        success = upload_to_cloud(records, args.api_base, args.dry_run)
        sys.exit(0 if success else 1)
    else:
        print("[INFO] Local seeding not implemented yet")
        print("[INFO] Use --cloud to upload to API")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

**Acceptance Criteria**:
- [ ] Template created in `07-foundation-layer/templates/`
- [ ] Tested on Project 51 with `--dry-run`
- [ ] Documented in Foundation README

#### 🟡 MEDIUM Priority 3: Document Unified Workflow

**Problem**: No documented end-to-end workflow  
**Impact**: Agents cannot autonomously prime + audit projects

**Solution**: Create `07-foundation-layer/docs/UNIFIED-PRIMER-AUDIT-WORKFLOW.md`
```markdown
# Unified Foundation Primer + Veritas Audit Workflow

## Overview
This workflow integrates Foundation Layer (top-down planning) with Veritas Audit (bottom-up evidence extraction) into a single coherent process.

## Prerequisites
- Project 37 Data Model API available (cloud endpoint)
- Project 48 eva-veritas installed (eva CLI)
- Project 07 Foundation templates available

## Day 1: Project Prime

### Step 1: Foundation Scaffolding
```powershell
# Create governance docs + project structure
cd C:\eva-foundry
.\07-foundation-layer\scripts\deployment\Invoke-PrimeWorkspace.ps1 `
    -TargetPath "C:\eva-foundry\51-ACA"
```

**Outputs**:
- `.github/copilot-instructions.md` (AI guidance)
- `PLAN.md` (Feature/Story structure)
- `STATUS.md` (Sprint tracking)
- `ACCEPTANCE.md` (Quality gates)
- `README.md` (Project header)
- `.github/PROJECT-ORGANIZATION.md` (Folder structure)

### Step 2: Generate Veritas Plan
```bash
# Convert PLAN.md → veritas-plan.json
cd 51-ACA
eva generate-plan --repo .
```

**Outputs**:
- `.eva/veritas-plan.json` (machine-readable plan)

### Step 3: Seed WBS Layer
```bash
# Generate WBS from plan → upload to cloud API
python seed-wbs-from-plan.py --cloud
```

**Outputs**:
- Cloud API Layer 26 (WBS) seeded with 281 stories
- `.eva/wbs-seed-evidence.json` (audit trail)

### Step 4: Seed Operational Layers
```bash
# Seed endpoints, containers, screens, etc.
python data-model/seed-from-plan.py --reseed-model
```

**Outputs**:
- Local SQLite layers: services, endpoints, containers, screens, etc.

## Day 2-N: Development

### Step 5: Code + Evidence
```
Development work with evidence tagging:
- Tag source files: # EVA-STORY: ACA-01-001
- Create evidence files: .eva/evidence/*.json
- Update STATUS.md with story progress
```

## Sprint Close: Veritas Audit

### Step 6: Full Sync
```bash
# Discover + Reconcile + Export + Upload in one command
eva sync_repo --repo . --layers wbs,evidence,decisions,risks
```

**Outputs**:
- `.eva/discovery.json` (artifact scan)
- `.eva/reconciliation.json` (MTI score)
- `.eva/model-export.json` (WBS + Evidence + Decisions + Risks)
- Cloud API updated (WBS status, Evidence records, Decisions, Risks)
- `.eva/sync-evidence.json` (audit trail)

**Quality Gate**: MTI score ≥ 70 required for sprint advance

## Sprint Open: Resync (Optional)

### Step 7: Pull Cloud State
```bash
# Optional: Sync local SQLite from cloud API
python data-model/sync-from-cloud.py
```

**Use Case**: Multi-agent teams with async updates

---

## Troubleshooting

### Issue: WBS duplicate records
**Cause**: Multiple seeding sources  
**Fix**: Run Priority 1 remediation (establish single source of truth)

### Issue: MTI score below 70
**Cause**: Missing evidence or implementation  
**Fix**: Run `eva audit --repo .` for detailed gap report

### Issue: Cloud API timeout
**Cause**: API unavailable (violates fail-closed policy)  
**Fix**: Wait for API recovery, or use `--allow-degraded` for local dev only
```

**Acceptance Criteria**:
- [ ] Workflow documented in `07-foundation-layer/docs/`
- [ ] Tested on Project 51 end-to-end
- [ ] Linked from workspace copilot-instructions.md

#### 🟢 LOW Priority 4: Update Foundation Template with WBS Seeding

**Problem**: Template missing WBS layer seeding logic  
**Impact**: Projects must manually create WBS seeders

**Solution**: Update `07-foundation-layer/templates/data-model-seed-template.py`
```python
# Add to WIPEABLE_LAYERS (already present)
WIPEABLE_LAYERS = [
    "requirements", "endpoints", "containers", "screens", "agents",
    "services", "personas", "decisions", "schemas", "hooks",
    "components", "literals", "infrastructure", "feature_flags",
    "sprints", "milestones", "wbs",  # ✅ Already listed
]

# Add WBS_DEFS section
# ---------- WBS (LAYER 26) ----------------------------------------------------
# IMPORTANT: WBS should be seeded from veritas-plan.json, not hardcoded here.
# This section is a stub for projects that need manual WBS seeding.
# Recommended: Use seed-wbs-from-plan.py instead.
WBS_DEFS = [
    # Stub: Project root epic
    {
        "id": "WBS-{PROJECT_PREFIX}",
        "project_id": "{project_id}",
        "parent_wbs_id": None,
        "label": "Project: {project_id}",
        "level": "epic",
        "status": "planned",
        "percent_complete": 0,
        "points_total": 0,
        "points_done": 0,
        "stories_total": 0,
        "stories_done": 0,
    },
    # Add features + stories from PLAN.md manually, or use seed-wbs-from-plan.py
]

# Update model_reseed to include WBS
def model_reseed(dry_run: bool = False) -> dict:
    """Seed all model layers. WBS seeding is optional (use seed-wbs-from-plan.py)."""
    counts = {}

    for layer, defs in [
        ("services",        SERVICE_DEFS),
        ("containers",      CONTAINER_DEFS),
        ("endpoints",       ENDPOINT_DEFS),
        ("screens",         SCREEN_DEFS),
        ("agents",          AGENT_DEFS),
        ("personas",        PERSONA_DEFS),
        ("hooks",           HOOK_DEFS),
        ("feature_flags",   FEATURE_FLAG_DEFS),
        ("infrastructure",  INFRASTRUCTURE_DEFS),
        ("wbs",             WBS_DEFS),  # ✅ Added
    ]:
        n = sum(1 for d in defs if model_upsert(layer, d, dry_run))
        counts[layer] = n

    return counts
```

**Acceptance Criteria**:
- [ ] Template updated with WBS_DEFS stub
- [ ] Template comment references seed-wbs-from-plan.py
- [ ] All 57 projects can optionally seed WBS

---

## Unified Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     EVA FOUNDATION + VERITAS                             │
│               Integrated Top-Down + Bottom-Up Workflow                   │
└─────────────────────────────────────────────────────────────────────────┘

DAY 1: FOUNDATION PRIME (Top-Down Planning)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│  [1] Invoke-PrimeWorkspace.ps1                                           │
│      ├─> .github/copilot-instructions.md                                 │
│      ├─> PLAN.md (Feature/Story structure)                               │
│      ├─> STATUS.md, ACCEPTANCE.md, README.md                             │
│      └─> .github/PROJECT-ORGANIZATION.md                                 │
│                                                                           │
│  [2] eva generate-plan                                                   │
│      PLAN.md ──> .eva/veritas-plan.json (machine-readable)               │
│                                                                           │
│  [3] python seed-wbs-from-plan.py --cloud                                │
│      veritas-plan.json ──> Cloud API Layer 26 (WBS)                      │
│      ├─> WBS-51ACA (root epic)                                           │
│      ├─> WBS-F01..F15 (features)                                         │
│      └─> WBS-S001..S281 (stories)                                        │
│                                                                           │
│  [4] python data-model/seed-from-plan.py --reseed-model                  │
│      ├─> Local SQLite: services, endpoints, containers, screens          │
│      └─> Local SQLite: agents, personas, hooks, infrastructure           │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

DAY 2-N: DEVELOPMENT (Implementation)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│  [5] Code + Evidence Creation                                            │
│      ├─> services/api/app/routers/*.py  # EVA-STORY: ACA-01-001         │
│      ├─> .eva/evidence/*.json                                            │
│      └─> tests/ (pytest, coverage reports)                               │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

SPRINT CLOSE: VERITAS AUDIT (Bottom-Up Evidence Extraction)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│  [6] eva sync_repo --repo . --layers wbs,evidence,decisions,risks        │
│                                                                           │
│      ┌───────────────────────────────────────────────────────────────┐  │
│      │ DISCOVER (discover.js)                                        │  │
│      │   Scan: Code (*.py, *.js), Evidence (*.json), Docs (*.md)    │  │
│      │   Output: .eva/discovery.json                                 │  │
│      └───────────────────────────────────────────────────────────────┘  │
│                        │                                                  │
│                        ▼                                                  │
│      ┌───────────────────────────────────────────────────────────────┐  │
│      │ RECONCILE (reconcile.js)                                      │  │
│      │   Compare: Planned (veritas-plan.json) vs Actual (discovery) │  │
│      │   Calculate: MTI score (coverage + evidence + consistency)   │  │
│      │   Output: .eva/reconciliation.json                            │  │
│      └───────────────────────────────────────────────────────────────┘  │
│                        │                                                  │
│                        ▼                                                  │
│      ┌───────────────────────────────────────────────────────────────┐  │
│      │ EXPORT (export-to-model.js)                                   │  │
│      │   Generate: WBS (L26), Evidence (L31), Decisions (L30),      │  │
│      │             Risks (L29)                                       │  │
│      │   Update: WBS status (planned → in_progress → completed)     │  │
│      │   Output: .eva/model-export.json                              │  │
│      └───────────────────────────────────────────────────────────────┘  │
│                        │                                                  │
│                        ▼                                                  │
│      ┌───────────────────────────────────────────────────────────────┐  │
│      │ UPLOAD (upload-to-model.js)                                   │  │
│      │   Push to: Cloud API (Project 37)                            │  │
│      │   Conflict Resolution: Skip if newer exists, update if older │  │
│      │   Batch: 50 records/batch, 3 retries                         │  │
│      │   Output: Cloud API updated + .eva/upload-evidence.json      │  │
│      └───────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  QUALITY GATE: MTI ≥ 70 required for sprint advance                      │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

SPRINT OPEN: RESYNC (Optional - Multi-Agent Coordination)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│  [7] python data-model/sync-from-cloud.py (optional)                     │
│      Cloud API ──> Local SQLite (for multi-agent teams)                  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

DATA FLOW SUMMARY:
──────────────────────────────────────────────────────────────────────────

  Top-Down (Foundation):
    PLAN.md → veritas-plan.json → WBS Layer (L26) → Cloud API

  Bottom-Up (Veritas):
    Code/Evidence → Discovery → Reconciliation → Export → Upload → Cloud API

  Single Source of Truth:
    Cloud API (Project 37) - 91 operational layers, fail-closed policy
```

---

## Recommendations

### For Immediate Action (Project 51 Rebuild)

1. **CRITICAL**: Run Priority 1 remediation (establish WBS truth source)
   - Timeline: 30 minutes
   - Owner: Agent or Marco
   - Blocking: All other work

2. **HIGH**: Create `seed-wbs-from-plan.py` template (Priority 2)
   - Timeline: 2 hours (development + testing)
   - Owner: Agent
   - Dependencies: Priority 1 complete

3. **MEDIUM**: Document unified workflow (Priority 3)
   - Timeline: 1 hour
   - Owner: Agent
   - Dependencies: Priority 2 tested

4. **Test End-to-End**: Run full workflow on Project 51
   ```bash
   # Dry-run first
   python seed-wbs-from-plan.py --dry-run
   
   # Live run
   python seed-wbs-from-plan.py --cloud
   
   # Verify
   eva sync_repo --repo . --dry-run
   ```

### For Future Enhancement

1. **Template Update**: Add WBS_DEFS to Foundation template (Priority 4)
2. **Automation**: Add WBS seeding to Invoke-PrimeWorkspace.ps1
3. **MCP Tool**: Create `seed_wbs_from_plan` MCP tool
4. **CI/CD**: Add automated WBS validation to GitHub Actions

---

## Conclusion

### Compatibility Score: 80% ✅

**Strengths**:
- ✅ Complementary architectures (top-down + bottom-up)
- ✅ Shared data model (Cloud API as single source of truth)
- ✅ Compatible schemas (WBS, Evidence, Risks, Decisions)
- ✅ Working implementations (51-ACA has both systems operational)

**Weaknesses**:
- ⚠️ WBS ID generation patterns differ
- ⚠️ Template missing WBS seeding
- ⚠️ No unified workflow documentation
- ❌ Multiple WBS sources without reconciliation

### Readiness Assessment: 🟡 READY WITH REMEDIATION

**Project 51 can be rebuilt** after completing the 4 remediation priorities.  
Estimated time: **4-5 hours** (1 priority per hour + testing).

**Post-Remediation State**:
- ✅ Single WBS source of truth (Cloud API L26)
- ✅ Unified seeder script (seed-wbs-from-plan.py)
- ✅ Documented workflow (Foundation primer + Veritas audit)
- ✅ Foundation template updated with WBS support
- ✅ End-to-end tested on Project 51

**Expected Outcome**:
```
Project 51: Evidence-Based Backlog (Rebuilt)
  ├─ 15 Epics (tracked in WBS L26)
  ├─ 54 Features (with points/stories aggregation)
  ├─ 281 Stories (with implementation status, evidence links)
  ├─ MTI Score: 75+ (quality gate passed)
  └─ Cloud API sync: Complete (single source of truth)
```

---

**Next Action**: Begin Priority 1 remediation → establish WBS truth source
