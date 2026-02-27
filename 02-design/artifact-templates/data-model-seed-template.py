"""
# EVA-STORY: {PROJECT_PREFIX}-12-001
data-model-seed-template.py -- EVA Foundation wired seed script
================================================================
TEMPLATE VERSION: 1.0.0 (from 51-ACA lesson learned 2026-02-27)

PURPOSE:
  Replace this file's placeholder values and run on Day 1, BEFORE sprint 1 starts.
  This seed script is the single source of truth for ALL cross-layer wiring.
  It must be re-run (--reseed-model) after EVERY sprint that adds a new artifact.

LESSON LEARNED (51-ACA Sprint 2):
  Starting with object IDs only (no cosmos_reads/writes, no fields, no personas)
  means the evidence graph has nodes but no edges. Veritas consistency score passes
  vacuously -- there is nothing to cross-check. Every sprint must retrofit wiring
  instead of building on it.

  Start wired. Every DEFS entry must include its cross-layer links from day one.

USAGE:
  python seed-from-plan.py                  # rebuild veritas-plan.json only
  python seed-from-plan.py --reseed-model   # wipe + reseed all model layers
  python seed-from-plan.py --dry-run        # preview without writing

KANBAN EVIDENCE CHAIN (read right-to-left for DoD):
  [DoD gate]
    <- screen renders correct data              (screens.api_calls wired)
    <- endpoint returns gated response          (endpoints.status=implemented)
    <- endpoint reads/writes container          (endpoints.cosmos_reads/writes)  <-- WIRE THIS
    <- container holds correct fields           (containers.fields)              <-- WIRE THIS
    <- job wrote data correctly                 (agents -> containers)
    <- user paid correct tier                   (billing endpoints -> entitlements)
    <- infrastructure provisioned               (infrastructure layer)
  If any layer field is empty the evidence chain is broken at that link.
"""

# EVA-STORY: {PROJECT_PREFIX}-12-001

import re
import json
import sys
import argparse
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
EVA_DIR   = REPO_ROOT / ".eva"
PLAN_OUT  = EVA_DIR / "veritas-plan.json"

_DB_DIR = REPO_ROOT / "data-model"
if str(_DB_DIR) not in sys.path:
    sys.path.insert(0, str(_DB_DIR))
try:
    import db as _db
    USE_SQLITE = True
except ImportError:
    USE_SQLITE = False
    print("[WARN] data-model/db.py not found -- model ops disabled")

# ---------------------------------------------------------------------------
# WIRING PRINCIPLE: every DEFS entry includes cross-layer references.
# Adding cosmos_reads=[] or fields=[] is not neutral -- it means the object
# has no cross-layer links. An empty list is a documented fact, not a gap.
# ---------------------------------------------------------------------------

# ---------- ENDPOINTS -------------------------------------------------------
# Rule: every endpoint must declare cosmos_reads AND cosmos_writes.
# Empty list means "confirmed: this endpoint does not touch Cosmos directly".
ENDPOINT_DEFS = [
    # REPLACE these with the actual endpoints for your project.
    # Pattern: id = "METHOD /path", cosmos_reads = [containers...], cosmos_writes = [containers...]
    {
        "id": "GET /health",
        "status": "implemented", "service": "{project-api}",
        "implemented_in": "services/api/app/routers/health.py", "repo_line": 10,
        "auth": [],
        "cosmos_reads": [],   # confirmed: health check does not read Cosmos
        "cosmos_writes": [],  # confirmed: health check does not write Cosmos
    },
    {
        "id": "POST /v1/items/",
        "status": "stub", "service": "{project-api}",
        "implemented_in": "services/api/app/routers/items.py", "repo_line": 10,
        "auth": ["user"],
        "cosmos_reads": ["clients"],    # reads: client record for authz check
        "cosmos_writes": ["items"],     # writes: the new item
    },
    # ... add all endpoints with their container wiring before sprint 1 ...
]

# ---------- CONTAINERS -------------------------------------------------------
# Rule: every container must declare its fields list.
# Fields drive impact analysis: change a field -> see which endpoints break.
CONTAINER_DEFS = [
    {
        "id": "items", "status": "active", "partition_key": "/tenantId",
        "description": "Core item records",
        "fields": ["id", "tenantId", "status", "created_at", "updated_at", "payload"],
    },
    {
        "id": "clients", "status": "active", "partition_key": "/tenantId",
        "description": "Client tier and entitlement records",
        "fields": ["id", "tenantId", "tier", "status", "created_at"],
    },
    # ... add all containers with full field lists before sprint 1 ...
]

# ---------- SCREENS ----------------------------------------------------------
# Rule: every screen must declare api_calls AND personas.
# personas links screens to who drives them (for test-scenario generation).
SCREEN_DEFS = [
    {
        "id": "LoginPage", "route": "/", "service": "{project-frontend}",
        "api_calls": [], "personas": [], "auth_required": False,
    },
    {
        "id": "DashboardPage", "route": "/app/dashboard", "service": "{project-frontend}",
        "api_calls": ["GET /v1/items/"],
        "personas": ["standard-user"],   # link to persona IDs below
        "auth_required": True,
    },
    # ... add all screens with api_calls + persona wiring before sprint 1 ...
]

# ---------- SERVICES ---------------------------------------------------------
SERVICE_DEFS = [
    {"id": "{project-api}",      "label": "{Project} API",      "type": "fastapi", "port": 8080, "status": "active", "is_active": True},
    {"id": "{project-frontend}", "label": "{Project} Frontend", "type": "vite",    "port": 5173, "status": "active", "is_active": True},
]

# ---------- AGENTS -----------------------------------------------------------
AGENT_DEFS = [
    # Add agents from the spec. Stub them all on Day 1.
    # {"id": "analysis-agent", "label": "Analysis Agent", "framework": "29-foundry", "status": "stub", "is_active": True},
]

# ---------- PERSONAS ---------------------------------------------------------
PERSONA_DEFS = [
    {"id": "standard-user", "label": "Standard User", "tier": "standard", "features": ["core"]},
    {"id": "admin-user",     "label": "Admin User",    "tier": "admin",    "features": ["core", "admin"]},
]

# ---------- HOOKS ------------------------------------------------------------
# Rule: every frontend hook must declare calls_endpoints.
# This lets the agent know: if endpoint X changes, hooks Y and Z break.
HOOK_DEFS = [
    {
        "id": "useItems",
        "label": "useItems",
        "service": "{project-frontend}",
        "repo_path": "frontend/src/hooks/useItems.ts",
        "calls_endpoints": ["GET /v1/items/", "POST /v1/items/"],
        "used_by_screens": ["DashboardPage"],
        "status": "stub", "is_active": True,
    },
]

# ---------- FEATURE FLAGS ----------------------------------------------------
FEATURE_FLAG_DEFS = [
    {
        "id": "core_access",
        "label": "Core Access",
        "description": "Basic access for all authenticated users",
        "personas": ["standard-user", "admin-user"],
        "status": "active", "is_active": True,
    },
    {
        "id": "admin_controls",
        "label": "Admin Controls",
        "description": "Internal admin functions",
        "personas": ["admin-user"],
        "status": "active", "is_active": True,
    },
]

# ---------- INFRASTRUCTURE ---------------------------------------------------
# List every Azure resource that will be used (Phase 1 = existing resources).
# Add resource_type in Microsoft provider notation.
INFRASTRUCTURE_DEFS = [
    {
        "id": "{resource-name}", "label": "{Resource Label}",
        "resource_type": "Microsoft.{Provider}/{ResourceType}",
        "region": "canadacentral", "phase": 1,
        "status": "active", "is_active": True,
        "notes": "Purpose and wiring notes",
    },
]

# ---------------------------------------------------------------------------
# WIPEABLE LAYERS -- must include every layer (even empty ones).
# This ensures a --reseed-model always produces a clean, reproducible state.
WIPEABLE_LAYERS = [
    "requirements", "endpoints", "containers", "screens", "agents",
    "services", "personas", "decisions", "schemas", "hooks",
    "components", "literals", "infrastructure", "feature_flags",
    "sprints", "milestones", "wbs",
]


def model_wipe(dry_run: bool = False) -> int:
    if not USE_SQLITE:
        return 0
    wiped = 0
    for layer in WIPEABLE_LAYERS:
        if dry_run:
            items = _db.list_layer(layer)
            wiped += len(items)
        else:
            n = _db.wipe_layer(layer)
            print(f"  [INFO] Wiped {layer}: {n} objects")
            wiped += n
    return wiped


def model_upsert(layer: str, obj: dict, dry_run: bool = False) -> bool:
    if not USE_SQLITE:
        return False
    obj_id = obj.get("id", "")
    if not obj_id:
        return False
    if dry_run:
        print(f"  [DRY] UPSERT {layer}/{obj_id}")
        return True
    try:
        _db.upsert_object(layer, obj, actor="agent:seed")
        return True
    except Exception as e:
        print(f"  [WARN] UPSERT {layer}/{obj_id} -- {e}")
        return False


def model_reseed(dry_run: bool = False) -> dict:
    """
    Seed all model layers. Called after wipe. Returns counts per layer.

    SAME-SPRINT RULE: every source change must update the relevant DEFS in this
    file in the same commit. Never defer wiring updates to a later sprint.
    """
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
    ]:
        n = sum(1 for d in defs if model_upsert(layer, d, dry_run))
        counts[layer] = n

    return counts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--reseed-model", action="store_true")
    parser.add_argument("--wipe-only",    action="store_true")
    parser.add_argument("--dry-run",      action="store_true")
    args = parser.parse_args()

    if args.wipe_only or args.reseed_model:
        if not USE_SQLITE:
            print("[FAIL] data-model/db.py not found")
            sys.exit(1)
        n = model_wipe(dry_run=args.dry_run)
        print(f"[INFO] Wiped {n} objects")
        if args.wipe_only:
            return

    if args.reseed_model:
        counts = model_reseed(dry_run=args.dry_run)
        for layer, cnt in sorted(counts.items()):
            print(f"  [INFO] {layer}: {cnt} objects seeded")
        print(f"[PASS] Model seeded: {sum(counts.values())} objects")

    print("[PASS] seed complete")


if __name__ == "__main__":
    main()
