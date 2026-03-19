"""
MCP Server: foundation-primer
Tools:
  - apply_primer      Apply v3.1.0 copilot-instructions template to a target project
  - audit_project     Check PART 1 / PART 2 / PART 3 compliance for a project
  - get_template_section  Return one section of the master template by name
  - list_projects     Query EVA data model and return project id / maturity table
  - check_encoding    Run fix-encoding.ps1 on a project path

Transport: stdio
Encoding: ASCII-only, no emoji, [PASS]/[FAIL]/[INFO]/[WARN] tokens only

Location:
  C:\\eva-foundry\\eva-foundation\\07-foundation-layer\\mcp-server\\foundation-primer\\server.py

Added: 2026-02-25 by agent:copilot
"""
from __future__ import annotations

import asyncio
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any
from urllib.request import urlopen
from urllib.error import URLError

import mcp.server.stdio
from mcp.server import Server
from mcp.types import TextContent, Tool
from pydantic import BaseModel, Field

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

_PROJECT_ROOT = Path(__file__).parent.parent.parent
_TEMPLATES_DIR = _PROJECT_ROOT / "02-design" / "artifact-templates"
_TEMPLATE_FILE = _TEMPLATES_DIR / "copilot-instructions-template.md"
_APPLY_SCRIPT  = _TEMPLATES_DIR / "Apply-Project07-Artifacts.ps1"
_FIX_ENCODING  = Path("C:/eva-foundry/tools/fix-encoding.ps1")

# Data model endpoints (ACA primary, local fallback)
_ACA_BASE = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
_LOCAL_BASE = "http://localhost:8010"

def _detect_data_model_base() -> str:
    """Detect which data model endpoint is reachable. Prefer ACA, fallback to local."""
    try:
        resp = urlopen(_ACA_BASE + "/health", timeout=5)
        if resp.status == 200:
            return _ACA_BASE
    except (URLError, Exception):
        pass
    try:
        resp = urlopen(_LOCAL_BASE + "/health", timeout=5)
        if resp.status == 200:
            return _LOCAL_BASE
    except (URLError, Exception):
        pass
    return _LOCAL_BASE  # fallback even if both are down

_DATA_MODEL_BASE = _detect_data_model_base()

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

server = Server("foundation-primer")

# ---------------------------------------------------------------------------
# Input models
# ---------------------------------------------------------------------------


class ApplyPrimerInput(BaseModel):
    target_path: str = Field(description="Absolute path to the EVA project folder to prime")
    dry_run: bool   = Field(default=True, description="If true, preview only -- no files written")


class AuditProjectInput(BaseModel):
    target_path: str = Field(description="Absolute path to the project folder")


class GetTemplateSectionInput(BaseModel):
    section: str = Field(
        description="Section name: PART1, PART2, or PART3 (case-insensitive)"
    )


class ListProjectsInput(BaseModel):
    maturity_filter: str | None = Field(
        default=None,
        description="Optional filter: active, poc, retired, empty, idea"
    )


class CheckEncodingInput(BaseModel):
    target_path: str = Field(description="Absolute path to a file or project folder")


class PrimeWorkspaceInput(BaseModel):
    target_path: str | None = Field(
        default=None,
        description="Absolute path to a single project folder to prime. Mutually exclusive with workspace_root."
    )
    workspace_root: str | None = Field(
        default=None,
        description="Absolute path to a workspace containing numbered project sub-folders (e.g. C:\\eva-foundry\\eva-foundation)."
    )
    dry_run: bool = Field(default=True, description="Preview only when true (default). Set false to apply.")
    skip_copilot_instructions: bool = Field(default=False, description="Skip copilot-instructions step, governance docs only.")


class BootstrapProject07Input(BaseModel):
    data_model_base: str = Field(default="", description="Override data model base URL. Leave blank for auto-detect.")


# ---------------------------------------------------------------------------
# Tool registration
# ---------------------------------------------------------------------------


@server.list_tools()
async def handle_list_tools() -> list[Tool]:
    return [
        Tool(
            name="apply_primer",
            description=(
                "Apply the v3.1.0 copilot-instructions template to a target EVA project. "
                "Preserves any existing PART 2 content. Creates a timestamped backup. "
                "Use dry_run=true (default) for a preview before committing."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "target_path": {
                        "type": "string",
                        "description": "Absolute path to the EVA project folder",
                    },
                    "dry_run": {
                        "type": "boolean",
                        "description": "Preview only when true (default). Set false to write.",
                        "default": True,
                    },
                },
                "required": ["target_path"],
            },
        ),
        Tool(
            name="audit_project",
            description=(
                "Check whether a project's copilot-instructions.md is compliant: "
                "PART 1 / PART 2 / PART 3 all present, ASCII-only, no stale v2.x markers."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "target_path": {
                        "type": "string",
                        "description": "Absolute path to the EVA project folder",
                    },
                },
                "required": ["target_path"],
            },
        ),
        Tool(
            name="get_template_section",
            description=(
                "Return one section of the master copilot-instructions template "
                "(PART1, PART2, or PART3)."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "section": {
                        "type": "string",
                        "description": "PART1, PART2, or PART3 (case-insensitive)",
                    },
                },
                "required": ["section"],
            },
        ),
        Tool(
            name="list_projects",
            description=(
                "Query the EVA data model and return a table of "
                "project id, maturity, and notes."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "maturity_filter": {
                        "type": "string",
                        "description": "Optional filter: active, poc, retired, empty, idea",
                    },
                },
            },
        ),
        Tool(
            name="check_encoding",
            description=(
                "Run fix-encoding.ps1 on a file or folder to replace "
                "non-ASCII characters with ASCII equivalents."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "target_path": {
                        "type": "string",
                        "description": "Absolute path to a file or project folder",
                    },
                },
                "required": ["target_path"],
            },
        ),
        Tool(
            name="prime_workspace",
            description=(
                "Idempotent full prime: apply copilot-instructions template AND create/update "
                "PLAN.md, STATUS.md, ACCEPTANCE.md, and README.md header block for one project "
                "or every numbered project under a workspace root. Safe to run many times."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "target_path": {
                        "type": "string",
                        "description": "Absolute path to a single project folder",
                    },
                    "workspace_root": {
                        "type": "string",
                        "description": "Absolute path to workspace root (primes all ##-name sub-folders)",
                    },
                    "dry_run": {
                        "type": "boolean",
                        "description": "Preview only (default true). Set false to write.",
                        "default": True,
                    },
                    "skip_copilot_instructions": {
                        "type": "boolean",
                        "description": "Skip copilot-instructions step, governance docs only.",
                        "default": False,
                    },
                },
            },
        ),
        Tool(
            name="bootstrap_project07",
            description=(
                "Run the project 07 session bootstrap: health-check data model, "
                "verify template + Apply script + governance templates + MCP server, "
                "and produce a session brief with next-step commands."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "data_model_base": {
                        "type": "string",
                        "description": "Override data model base URL. Leave blank for auto-detect.",
                    },
                },
            },
        ),
    ]


# ---------------------------------------------------------------------------
# Tool dispatch
# ---------------------------------------------------------------------------


@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[TextContent]:
    try:
        if name == "apply_primer":
            result = _apply_primer(ApplyPrimerInput.model_validate(arguments or {}))
        elif name == "audit_project":
            result = _audit_project(AuditProjectInput.model_validate(arguments or {}))
        elif name == "get_template_section":
            result = _get_template_section(GetTemplateSectionInput.model_validate(arguments or {}))
        elif name == "list_projects":
            result = _list_projects(ListProjectsInput.model_validate(arguments or {}))
        elif name == "check_encoding":
            result = _check_encoding(CheckEncodingInput.model_validate(arguments or {}))
        elif name == "prime_workspace":
            result = _prime_workspace(PrimeWorkspaceInput.model_validate(arguments or {}))
        elif name == "bootstrap_project07":
            result = _bootstrap_project07(BootstrapProject07Input.model_validate(arguments or {}))
        else:
            result = {"status": "[FAIL]", "error": f"Unknown tool: {name}"}
    except Exception as exc:
        result = {"status": "[FAIL]", "error": f"{type(exc).__name__}: {exc}"}

    return [TextContent(type="text", text=json.dumps(result, indent=2))]


# ---------------------------------------------------------------------------
# Tool implementations
# ---------------------------------------------------------------------------


def _apply_primer(inp: ApplyPrimerInput) -> dict[str, Any]:
    if not _APPLY_SCRIPT.exists():
        return {
            "status": "[FAIL]",
            "error": f"Apply script not found: {_APPLY_SCRIPT}",
        }
    target = Path(inp.target_path)
    if not target.exists():
        return {"status": "[FAIL]", "error": f"Target path not found: {target}"}

    cmd = [
        "powershell.exe",
        "-NonInteractive",
        "-ExecutionPolicy", "Bypass",
        "-File", str(_APPLY_SCRIPT),
        "-TargetPath", str(target),
    ]
    if inp.dry_run:
        cmd.append("-DryRun")

    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="ascii",
        errors="replace",
        timeout=120,
    )
    return {
        "status": "[PASS]" if proc.returncode == 0 else "[FAIL]",
        "dry_run": inp.dry_run,
        "return_code": proc.returncode,
        "stdout": proc.stdout[-4000:] if proc.stdout else "",
        "stderr": proc.stderr[-2000:] if proc.stderr else "",
    }


def _audit_project(inp: AuditProjectInput) -> dict[str, Any]:
    target = Path(inp.target_path)
    candidates = [
        target / ".github" / "copilot-instructions.md",
        target / "copilot-instructions.md",
    ]
    ci_file: Path | None = next((p for p in candidates if p.exists()), None)
    if ci_file is None:
        return {
            "status": "[FAIL]",
            "project": str(target),
            "findings": ["[FAIL] copilot-instructions.md not found"],
        }

    content = ci_file.read_text(encoding="utf-8", errors="replace")
    findings: list[str] = []

    # PART markers
    has_p1 = bool(re.search(r"^## PART 1[: -]", content, re.MULTILINE))
    has_p2 = bool(re.search(r"^## PART 2[: -]", content, re.MULTILINE))
    has_p3 = bool(re.search(r"^## PART 3[: -]", content, re.MULTILINE))
    if has_p1:
        findings.append("[PASS] PART 1 present")
    else:
        findings.append("[FAIL] PART 1 missing")
    if has_p2:
        findings.append("[PASS] PART 2 present")
    else:
        findings.append("[FAIL] PART 2 missing")
    if has_p3:
        findings.append("[PASS] PART 3 present")
    else:
        findings.append("[FAIL] PART 3 missing")

    # ASCII check (detect first non-ASCII)
    non_ascii = [ch for ch in content if ord(ch) > 127]
    if non_ascii:
        sample = "".join(non_ascii[:10])
        findings.append(
            f"[FAIL] Non-ASCII characters detected ({len(non_ascii)} chars, sample: {repr(sample)})"
        )
    else:
        findings.append("[PASS] ASCII-clean")

    # Stale v2.x marker check
    if re.search(r"## PART 2:", content):
        findings.append("[WARN] Stale v2.x PART 2 colon-style header found -- update to double-dash")
    if "1,902 lines" in content or "1902 lines" in content:
        findings.append("[WARN] Stale v2.x line count reference (1,902) found")

    overall = "[PASS]" if all(f.startswith("[PASS]") for f in findings) else "[FAIL]"
    return {
        "status": overall,
        "project": str(target),
        "file": str(ci_file),
        "line_count": content.count("\n"),
        "findings": findings,
    }


def _get_template_section(inp: GetTemplateSectionInput) -> dict[str, Any]:
    if not _TEMPLATE_FILE.exists():
        return {"status": "[FAIL]", "error": f"Template not found: {_TEMPLATE_FILE}"}

    content = _TEMPLATE_FILE.read_text(encoding="utf-8", errors="replace")
    lines   = content.splitlines()
    section = inp.section.upper().strip()

    # Map section names to regex patterns
    marks = {
        "PART1": r"^## PART 1[: -]",
        "PART2": r"^## PART 2[: -]",
        "PART3": r"^## PART 3[: -]",
    }
    if section not in marks:
        return {
            "status": "[FAIL]",
            "error": f"Unknown section '{inp.section}'. Valid values: PART1, PART2, PART3",
        }

    # Find start and end indices
    order  = ["PART1", "PART2", "PART3"]
    starts = {}
    for key, pat in marks.items():
        for i, line in enumerate(lines):
            if re.match(pat, line):
                starts[key] = i
                break

    if section not in starts:
        return {"status": "[FAIL]", "error": f"{section} marker not found in template"}

    idx      = order.index(section)
    start_ln = starts[section]
    end_ln   = starts[order[idx + 1]] if idx + 1 < len(order) and order[idx + 1] in starts else len(lines)

    section_text = "\n".join(lines[start_ln:end_ln])
    return {
        "status": "[PASS]",
        "section": section,
        "line_start": start_ln + 1,
        "line_end":   end_ln,
        "line_count": end_ln - start_ln,
        "content":    section_text,
    }


def _list_projects(inp: ListProjectsInput) -> dict[str, Any]:
    try:
        url  = f"{_DATA_MODEL_BASE}/model/projects/"
        with urlopen(url, timeout=10) as resp:
            projects: list[dict] = json.loads(resp.read())
    except URLError as exc:
        return {"status": "[FAIL]", "error": f"Data model unreachable: {exc}"}

    if inp.maturity_filter:
        projects = [p for p in projects if p.get("maturity") == inp.maturity_filter]

    rows = [
        {
            "id":       p.get("id") or p.get("obj_id"),
            "maturity": p.get("maturity"),
            "notes":    (p.get("notes") or "")[:120],
        }
        for p in projects
    ]
    return {
        "status":  "[PASS]",
        "total":   len(rows),
        "filter":  inp.maturity_filter,
        "projects": rows,
    }


def _check_encoding(inp: CheckEncodingInput) -> dict[str, Any]:
    target = Path(inp.target_path)
    if not target.exists():
        return {"status": "[FAIL]", "error": f"Path not found: {target}"}
    if not _FIX_ENCODING.exists():
        return {"status": "[FAIL]", "error": f"fix-encoding.ps1 not found: {_FIX_ENCODING}"}

    proc = subprocess.run(
        [
            "powershell.exe",
            "-NonInteractive",
            "-ExecutionPolicy", "Bypass",
            "-File", str(_FIX_ENCODING),
            "-Path", str(target),
        ],
        capture_output=True,
        text=True,
        encoding="ascii",
        errors="replace",
        timeout=60,
    )
    return {
        "status":      "[PASS]" if proc.returncode == 0 else "[FAIL]",
        "target_path": str(target),
        "return_code": proc.returncode,
        "stdout":      proc.stdout[-2000:] if proc.stdout else "",
        "stderr":      proc.stderr[-1000:] if proc.stderr else "",
    }


def _prime_workspace(inp: PrimeWorkspaceInput) -> dict[str, Any]:
    invoke_script = _TEMPLATES_DIR / "Invoke-PrimeWorkspace.ps1"
    if not invoke_script.exists():
        return {"status": "[FAIL]", "error": f"Invoke-PrimeWorkspace.ps1 not found: {invoke_script}"}

    if not inp.target_path and not inp.workspace_root:
        return {"status": "[FAIL]", "error": "Provide either target_path or workspace_root"}

    cmd = [
        "powershell.exe",
        "-NonInteractive",
        "-ExecutionPolicy", "Bypass",
        "-File", str(invoke_script),
    ]
    if inp.target_path:
        target = Path(inp.target_path)
        if not target.exists():
            return {"status": "[FAIL]", "error": f"target_path not found: {target}"}
        cmd += ["-TargetPath", str(target)]
    else:
        root = Path(inp.workspace_root)
        if not root.exists():
            return {"status": "[FAIL]", "error": f"workspace_root not found: {root}"}
        cmd += ["-WorkspaceRoot", str(root)]

    if inp.dry_run:
        cmd.append("-DryRun")
    if inp.skip_copilot_instructions:
        cmd.append("-SkipCopilotInstructions")

    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="ascii",
        errors="replace",
        timeout=300,
    )
    return {
        "status":      "[PASS]" if proc.returncode == 0 else "[FAIL]",
        "dry_run":     inp.dry_run,
        "return_code": proc.returncode,
        "stdout":      proc.stdout[-6000:] if proc.stdout else "",
        "stderr":      proc.stderr[-2000:] if proc.stderr else "",
    }


def _bootstrap_project07(inp: BootstrapProject07Input) -> dict[str, Any]:
    bootstrap_script = _TEMPLATES_DIR / "Bootstrap-Project07.ps1"
    if not bootstrap_script.exists():
        return {"status": "[FAIL]", "error": f"Bootstrap-Project07.ps1 not found: {bootstrap_script}"}

    cmd = [
        "powershell.exe",
        "-NonInteractive",
        "-ExecutionPolicy", "Bypass",
        "-File", str(bootstrap_script),
    ]
    if inp.data_model_base:
        cmd += ["-DataModelBase", inp.data_model_base]

    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="ascii",
        errors="replace",
        timeout=60,
    )
    lines   = proc.stdout.split("\n") if proc.stdout else []
    brief   = [l for l in lines if "BRIEF" in l or "PASS" in l or "FAIL" in l or "WARN" in l or "STEP" in l]
    return {
        "status":      "[PASS]" if proc.returncode == 0 else "[WARN]",
        "return_code": proc.returncode,
        "brief":       brief,
        "full_output": proc.stdout[-5000:] if proc.stdout else "",
        "stderr":      proc.stderr[-1000:] if proc.stderr else "",
    }


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


async def run() -> None:
    async with mcp.server.stdio.stdio_server() as (reader, writer):
        await server.run(
            reader,
            writer,
            server.create_initialization_options(),
        )


if __name__ == "__main__":
    asyncio.run(run())
