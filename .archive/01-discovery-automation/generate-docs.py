#!/usr/bin/env python3
"""
EVA Foundation Documentation Generator
Automated workflow execution with AI validation

⚠️ LOCAL-ONLY - DO NOT COMMIT
"""

import os
import sys
import time
import json
import yaml
import argparse
import re
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional
import logging
from datetime import datetime

# Third-party imports
try:
    from langchain_openai import AzureChatOpenAI
    from langchain_core.messages import HumanMessage, SystemMessage
    from dotenv import load_dotenv
    from rich.console import Console
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.table import Table
    from rich.panel import Panel
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Run: pip install -r requirements.txt")
    sys.exit(1)

# Import validators and evidence (local modules)
try:
    from validators import validate_yaml_frontmatter, validate_consumability, validate_traceability
    from evidence import EvidenceCollector
except ImportError as e:
    print(f"❌ Missing local module: {e}")
    print("Ensure validators.py and evidence.py are in the same directory.")
    sys.exit(1)

# Load environment variables
load_dotenv()

# Setup logging
log_file = Path(__file__).parent.parent / "eva-foundation-generation.log"
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Rich console for pretty output
console = Console()


@dataclass
class FileSpec:
    """Specification for a file to be generated"""
    phase: int
    filename: str
    prompt: str
    requires_validation: bool = True
    requires_traceability: bool = True


@dataclass
class ValidationResult:
    """Result of validation checks"""
    passed: bool
    issues: List[str]
    warnings: List[str]
    
    def to_dict(self):
        return asdict(self)


class EVAFoundationGenerator:
    """Main orchestrator for EVA Foundation documentation generation"""
    
    def __init__(self, workspace_root: Path, dry_run: bool = False, skip_validation: bool = False):
        self.workspace_root = workspace_root
        self.eva_dir = workspace_root / "docs" / "eva-foundation"
        self.src_v02_dir = self.eva_dir / "source-materials" / "requirements-v0.2"
        self.output_dir = self.eva_dir / "generated-output" / "markdown"
        self.dry_run = dry_run
        self.skip_validation = skip_validation
        
        # Create output directory
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load configuration
        console.print("[cyan]📚 Loading configuration...[/cyan]")
        self.system_prompt = self._load_system_prompt()
        self.v02_sources = self._load_v02_sources()
        self.file_specs = self._load_file_specs()
        
        # Initialize LLM
        if not self.dry_run:
            console.print("[cyan]🤖 Initializing Azure OpenAI...[/cyan]")
            self.llm = self._init_llm()
        
        # State tracking
        self.state_file = self.eva_dir / "generation-state.json"
        self.state = self._load_state()
        
        # Evidence collection
        self.evidence = EvidenceCollector(self.output_dir, self.eva_dir)
        
        console.print("[green]✅ Initialization complete[/green]\n")
        
    def _load_system_prompt(self) -> str:
        """Load README.md system prompt"""
        readme_path = self.eva_dir / "README.,md"
        if not readme_path.exists():
            raise FileNotFoundError(f"System prompt not found: {readme_path}")
        with open(readme_path, 'r', encoding='utf-8') as f:
            return f.read()
    
    def _load_v02_sources(self) -> Dict[str, str]:
        """Load all v0.2 source files"""
        sources = {}
        for md_file in self.src_v02_dir.glob("*.md"):
            with open(md_file, 'r', encoding='utf-8') as f:
                sources[md_file.stem] = f.read()
        console.print(f"   ✅ Loaded {len(sources)} v0.2 source files")
        return sources
    
    def _load_file_specs(self) -> List[FileSpec]:
        """Parse file-generation-oneliner.md to extract file specs"""
        oneliner_path = self.eva_dir / "workspace-notes" / "file-generation-oneliner.md"
        with open(oneliner_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        specs = []
        # Parse each PHASE section
        current_phase = None
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            # Detect phase headers
            if line.startswith("## PHASE"):
                match = re.match(r"## PHASE (\d+)", line)
                if match:
                    current_phase = int(match.group(1))
            
            # Detect file specifications
            if line.startswith("### `") and current_phase is not None:
                filename_match = re.match(r"### `([^`]+)`", line)
                if filename_match:
                    filename = filename_match.group(1)
                    # Next line should be the prompt
                    if i + 1 < len(lines):
                        prompt = lines[i + 1].strip()
                        specs.append(FileSpec(
                            phase=current_phase,
                            filename=filename,
                            prompt=prompt,
                            requires_traceability=(current_phase >= 1)
                        ))
        
        console.print(f"   ✅ Parsed {len(specs)} file specifications")
        return specs
    
    def _init_llm(self) -> AzureChatOpenAI:
        """Initialize Azure OpenAI LLM"""
        try:
            api_key = os.getenv("AZURE_OPENAI_API_KEY")
            
            # If using managed identity, get token
            if api_key == "USE_MANAGED_IDENTITY" or not api_key:
                from azure.identity import DefaultAzureCredential
                credential = DefaultAzureCredential()
                # LangChain's AzureChatOpenAI can use azure_ad_token
                token = credential.get_token("https://cognitiveservices.azure.com/.default")
                api_key = token.token
            
            return AzureChatOpenAI(
                azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
                api_key=api_key,
                deployment_name=os.getenv("AZURE_OPENAI_CHAT_DEPLOYMENT", "gpt-4o"),
                api_version=os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-15-preview"),
                temperature=float(os.getenv("TEMPERATURE", "0.3")),
                max_tokens=int(os.getenv("MAX_TOKENS", "4000")),
                timeout=300,  # 5 minute timeout for API calls (increased for VPN stability)
                request_timeout=300  # Also set request timeout
            )
        except Exception as e:
            console.print(f"[red]❌ Failed to initialize Azure OpenAI: {e}[/red]")
            console.print("[yellow]💡 Check your .env file configuration[/yellow]")
            sys.exit(1)
    
    def _load_state(self) -> Dict:
        """Load generation state"""
        self.state_file = self.eva_dir / "generated-output" / "generation-state.json"
        if self.state_file.exists():
            with open(self.state_file, 'r') as f:
                return json.load(f)
        return {
            "completed_files": [],
            "phase_completed": [],
            "last_run": None,
            "total_tokens": 0,
            "total_cost": 0.0
        }
    
    def _save_state(self):
        """Save generation state"""
        self.state["last_run"] = datetime.now().isoformat()
        with open(self.state_file, 'w') as f:
            json.dump(self.state, f, indent=2)
    
    def generate_file(self, spec: FileSpec) -> tuple[str, ValidationResult]:
        """Generate a single file with retries"""
        
        # Check if already completed
        if spec.filename in self.state["completed_files"]:
            console.print(f"[yellow]⏭️  Skipping (already completed): {spec.filename}[/yellow]")
            output_path = self.output_dir / spec.filename
            if output_path.exists():
                with open(output_path, 'r', encoding='utf-8') as f:
                    return f.read(), ValidationResult(True, [], [])
        
        console.print(f"\n[bold cyan]📝 Generating: {spec.filename}[/bold cyan]")
        
        max_retries = int(os.getenv("MAX_RETRIES", "3"))
        validation_feedback = ""
        
        for attempt in range(1, max_retries + 1):
            console.print(f"   Attempt {attempt}/{max_retries}")
            
            # Build prompt
            messages = [
                SystemMessage(content=self.system_prompt),
                SystemMessage(content=self._build_v02_context()),
                HumanMessage(content=spec.prompt)
            ]
            
            # Add validation feedback from previous attempt
            if validation_feedback:
                messages.append(HumanMessage(content=f"""
CRITICAL VALIDATION ERRORS FROM PREVIOUS ATTEMPT:
{validation_feedback}

YOU MUST FIX THESE ERRORS. Generate the complete document again with all corrections applied.
REMEMBER: You MUST include YAML front matter at the very beginning of your response, starting with '---'.
"""))
            
            # Generate content
            if self.dry_run:
                content = self._generate_dry_run_content(spec)
            else:
                try:
                    console.print(f"   [dim]Calling Azure OpenAI API...[/dim]")
                    response = self.llm.invoke(messages)
                    content = response.content
                    
                    # Strip markdown code fences if LLM wrapped the response
                    content_stripped = content.strip()
                    if content_stripped.startswith("```"):
                        lines = content_stripped.split('\n')
                        # Remove opening fence (```markdown or ```)
                        if lines[0].startswith("```"):
                            lines = lines[1:]
                        # Remove closing fence
                        if lines and lines[-1].strip() == "```":
                            lines = lines[:-1]
                        content = '\n'.join(lines).strip()
                    
                    # Track tokens (approximate)
                    tokens_used = len(content.split()) * 1.3  # Rough estimate
                    self.state["total_tokens"] += int(tokens_used)
                    console.print(f"   [dim]~{int(tokens_used)} tokens[/dim]")
                        
                except TimeoutError as te:
                    console.print(f"[yellow]   ⏱️  Timeout Error: {te}[/yellow]")
                    if attempt < max_retries:
                        retry_delay = attempt * 3  # Exponential backoff: 3, 6, 9 seconds
                        console.print(f"   [yellow]Retrying in {retry_delay}s...[/yellow]")
                        time.sleep(retry_delay)
                        continue
                    else:
                        return "", ValidationResult(False, [f"Timeout after {max_retries} attempts: {te}"], [])
                except (ConnectionError, ConnectionResetError) as ce:
                    console.print(f"[yellow]   🔌 Connection Error: {ce}[/yellow]")
                    if attempt < max_retries:
                        retry_delay = attempt * 5  # Longer delay for connection issues: 5, 10, 15 seconds
                        console.print(f"   [yellow]Waiting {retry_delay}s for connection recovery...[/yellow]")
                        time.sleep(retry_delay)
                        continue
                    else:
                        return "", ValidationResult(False, [f"Connection failed after {max_retries} attempts: {ce}"], [])
                except Exception as e:
                    console.print(f"[red]   ❌ API Error: {e}[/red]")
                    if attempt < max_retries:
                        console.print(f"   [yellow]Retrying...[/yellow]")
                        time.sleep(2)  # Brief delay before generic retry
                        continue
                    else:
                        return "", ValidationResult(False, [f"API Error: {e}"], [])
            
            # Validate
            if self.skip_validation:
                validation = ValidationResult(True, [], ["Validation skipped"])
            else:
                validation = self.validate_file(content, spec)
            
            if validation.passed:
                console.print(f"[green]✅ Validation passed[/green]")
                if not self.dry_run:
                    self._save_file(spec.filename, content)
                    self.state["completed_files"].append(spec.filename)
                    self._save_state()
                    
                    # Record evidence
                    self.evidence.record_file_generation(
                        filename=spec.filename,
                        phase=spec.phase,
                        prompt=spec.prompt,
                        validation_results={
                            "yaml": {"is_valid": True, "errors": [], "warnings": []},
                            "consumability": {"is_valid": True, "errors": [], "warnings": []},
                            "traceability": {"is_valid": True, "errors": [], "warnings": []}
                        },
                        retry_count=attempt - 1,
                        tokens_used=0,  # Token counting to be implemented
                        status="success"
                    )
                return content, validation
            else:
                console.print(f"[red]⚠️  Validation failed:[/red]")
                for issue in validation.issues:
                    console.print(f"      [red]• {issue}[/red]")
                if attempt < max_retries:
                    console.print(f"   [yellow]Retrying with validation feedback...[/yellow]")
                    # Build validation feedback for next attempt
                    validation_feedback = "\n".join([f"- {issue}" for issue in validation.issues])
        
        # All retries exhausted
        console.print(f"[red]❌ Failed after {max_retries} attempts[/red]")
        return content, validation
    
    def _generate_dry_run_content(self, spec: FileSpec) -> str:
        """Generate placeholder content for dry run"""
        # Include sample requirement IDs for traceability validation
        traceability_section = ""
        if spec.requires_traceability:
            traceability_section = """

## Implementation Evidence

**Requirements Traceability:**
- INF01, INF02, INF03 (Infrastructure requirements)
- ACC01, ACC02 (Access control requirements)
- SEC01 (Security requirements)

**Source References:** docs/eva-foundation/src-v02/00_source_summary.md
"""
        
        return f"""---
document_type: {spec.filename.replace('.md', '')}
phase: {spec.phase}
audience: [Enterprise Architects, Operators, Auditors]
traceability: [src-v02/00_source_summary.md]
---

# {spec.filename.replace('.md', '').replace('-', ' ').title()}

## In Scope
[DRY RUN MODE - Content would be generated here]

## Out of Scope
[DRY RUN MODE - Content would be generated here]

## Primary Audience
[DRY RUN MODE - Content would be generated here]{traceability_section}

---

**Note**: This is a DRY RUN placeholder. Run without --dry-run to generate actual content.
"""
    
    def _build_v02_context(self) -> str:
        """Build context from v0.2 sources"""
        context = "## v0.2 Source Material (Authoritative)\n\n"
        for name, content in self.v02_sources.items():
            context += f"### File: {name}.md\n\n{content}\n\n---\n\n"
        return context
    
    def validate_file(self, content: str, spec: FileSpec) -> ValidationResult:
        """Run 3-part validation"""
        from validators import (
            validate_yaml_frontmatter,
            validate_consumability,
            validate_traceability
        )
        
        issues = []
        warnings = []
        
        # Part 1: YAML front matter
        yaml_result = validate_yaml_frontmatter(content)
        if not yaml_result["valid"]:
            issues.append(f"YAML: {yaml_result['error']}")
        
        # Part 2: AI-consumability
        consumability = validate_consumability(content)
        issues.extend(consumability["errors"])
        warnings.extend(consumability["warnings"])
        
        # Part 3: Requirement traceability (if needed)
        if spec.requires_traceability:
            traceability = validate_traceability(content)
            if not traceability["valid"]:
                issues.append(f"Traceability: {traceability['error']}")
        
        return ValidationResult(
            passed=(len(issues) == 0),
            issues=issues,
            warnings=warnings
        )
    
    def _save_file(self, filename: str, content: str):
        """Save generated file"""
        output_path = self.output_dir / filename
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        console.print(f"[green]💾 Saved: {output_path.relative_to(self.workspace_root)}[/green]")
    
    def run_phase(self, phase_num: int) -> bool:
        """Generate all files for a phase"""
        console.print(Panel.fit(
            f"[bold cyan]PHASE {phase_num}[/bold cyan]",
            border_style="cyan"
        ))
        
        phase_specs = [s for s in self.file_specs if s.phase == phase_num]
        
        if not phase_specs:
            console.print(f"[yellow]No files found for Phase {phase_num}[/yellow]")
            return True
        
        console.print(f"Files to generate: {len(phase_specs)}\n")
        
        failed_files = []
        
        for spec in phase_specs:
            content, validation = self.generate_file(spec)
            
            if not validation.passed:
                failed_files.append(spec.filename)
                console.print(f"[red]❌ FAILED: {spec.filename}[/red]\n")
        
        if failed_files:
            console.print(f"\n[red]❌ Phase {phase_num} completed with failures:[/red]")
            for filename in failed_files:
                console.print(f"   • {filename}")
            return False
        
        # Mark phase as completed
        if phase_num not in self.state["phase_completed"]:
            self.state["phase_completed"].append(phase_num)
            self._save_state()
        
        # Generate evidence report
        if not self.dry_run and not failed_files:
            console.print("\n[cyan]📊 Generating evidence report...[/cyan]")
            evidence_path = self.evidence.generate_evidence_report()
            console.print(f"[green]✅ Evidence report saved: {evidence_path}[/green]")
        
        self._save_state()
        console.print(f"\n[green]✅ Phase {phase_num} COMPLETE[/green]\n")
        return True
    
    def run_all(self):
        """Run all phases"""
        phases = sorted(set(s.phase for s in self.file_specs))
        
        console.print(Panel.fit(
            "[bold cyan]EVA Foundation Documentation Generator[/bold cyan]\n"
            f"Total phases: {len(phases)}\n"
            f"Total files: {len(self.file_specs)}",
            border_style="cyan"
        ))
        
        for phase in phases:
            success = self.run_phase(phase)
            if not success:
                console.print(f"\n[red]⚠️  Stopping at Phase {phase} due to failures[/red]")
                break
        
        # Final summary
        self._print_summary()
    
    def _print_summary(self):
        """Print generation summary"""
        table = Table(title="Generation Summary")
        table.add_column("Metric", style="cyan")
        table.add_column("Value", style="green")
        
        table.add_row("Completed Files", str(len(self.state["completed_files"])))
        table.add_row("Completed Phases", str(len(self.state["phase_completed"])))
        table.add_row("Total Tokens", f"~{self.state['total_tokens']:,}")
        table.add_row("Output Directory", str(self.output_dir))
        
        console.print("\n")
        console.print(table)


def main():
    parser = argparse.ArgumentParser(
        description="EVA Foundation Documentation Generator",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--phase",
        default="all",
        help="Phase to generate (0-5 or 'all')"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Dry run mode (no API calls)"
    )
    parser.add_argument(
        "--skip-validation",
        action="store_true",
        help="Skip validation checks (not recommended)"
    )
    
    args = parser.parse_args()
    
    # Determine workspace root
    script_dir = Path(__file__).parent
    workspace_root = script_dir.parent.parent.parent
    
    # Initialize generator
    try:
        generator = EVAFoundationGenerator(
            workspace_root,
            dry_run=args.dry_run,
            skip_validation=args.skip_validation
        )
        
        # Run generation
        if args.phase == "all":
            generator.run_all()
        else:
            phase_num = int(args.phase)
            generator.run_phase(phase_num)
            generator._print_summary()
            
    except KeyboardInterrupt:
        console.print("\n[yellow]⚠️  Generation interrupted by user[/yellow]")
        sys.exit(1)
    except Exception as e:
        console.print(f"\n[red]❌ Fatal error: {e}[/red]")
        logger.exception("Fatal error during generation")
        sys.exit(1)


if __name__ == "__main__":
    main()
