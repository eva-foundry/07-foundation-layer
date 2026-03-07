"""
Evidence collection and audit trail generation for EVA Foundation documentation.

This module provides:
1. File generation tracking (filename, phase, validation results, timestamps)
2. Requirement coverage analysis (maps v0.2 requirement IDs to generated files)
3. Traceability matrix generation (links v0.2 sources → requirements → implementation)
4. Quality metrics calculation (validation pass rates, file statistics)
5. Evidence report generation (JSON + Markdown audit reports)

Usage:
    from evidence import EvidenceCollector
    
    evidence = EvidenceCollector(output_dir, eva_dir)
    evidence.record_file_generation(
        filename="01-architecture-overview.md",
        phase=1,
        prompt="Generate architecture overview...",
        validation_results={"yaml": {...}, "consumability": {...}, "traceability": {...}},
        retry_count=0,
        tokens_used=1500
    )
    evidence_path = evidence.generate_evidence_report()
"""

import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict


@dataclass
class FileGenerationRecord:
    """Record of a single file generation event."""
    filename: str
    phase: int
    prompt: str
    timestamp: str
    validation_results: Dict[str, Any]
    retry_count: int
    tokens_used: int
    status: str  # "success" | "failed"


@dataclass
class RequirementCoverage:
    """Coverage analysis for a single requirement ID."""
    requirement_id: str
    source_file: str  # e.g., "src-v02/03_eva_chat_requirements.md"
    mentioned_in_files: List[str]
    implementation_evidence: List[str]  # File paths from traceability sections


class EvidenceCollector:
    """Collects evidence of documentation generation for audit purposes."""

    def __init__(self, output_dir: Path, eva_dir: Path):
        """
        Initialize evidence collector.
        
        Args:
            output_dir: Directory where generated .md files are saved
            eva_dir: Root EVA Foundation directory (contains source-materials/)
        """
        self.output_dir = Path(output_dir)
        self.eva_dir = Path(eva_dir)
        self.evidence_dir = self.eva_dir / "generated-output" / "evidence"
        self.evidence_dir.mkdir(parents=True, exist_ok=True)
        
        self.generation_records: List[FileGenerationRecord] = []
        self.requirement_coverage: Dict[str, RequirementCoverage] = {}
        
    def record_file_generation(
        self,
        filename: str,
        phase: int,
        prompt: str,
        validation_results: Dict[str, Any],
        retry_count: int,
        tokens_used: int,
        status: str = "success"
    ):
        """
        Record a file generation event.
        
        Args:
            filename: Name of generated file
            phase: Phase number (0-5)
            prompt: Prompt used to generate file
            validation_results: Dict with keys "yaml", "consumability", "traceability"
            retry_count: Number of retries needed
            tokens_used: Total tokens used (including retries)
            status: "success" or "failed"
        """
        record = FileGenerationRecord(
            filename=filename,
            phase=phase,
            prompt=prompt[:200] + "..." if len(prompt) > 200 else prompt,  # Truncate for readability
            timestamp=datetime.now().isoformat(),
            validation_results=validation_results,
            retry_count=retry_count,
            tokens_used=tokens_used,
            status=status
        )
        self.generation_records.append(record)
        
    def analyze_requirement_coverage(self):
        """
        Analyze requirement coverage across all generated files.
        
        Scans all .md files in output_dir for:
        - Requirement IDs (e.g., INF01, ACC03)
        - src-v02 references
        - Implementation evidence in traceability sections
        """
        req_pattern = re.compile(r'\b([A-Z]{2,3}\d{2})\b')
        src_pattern = re.compile(r'src-v02/([a-zA-Z0-9_\-]+\.md)')
        
        for md_file in self.output_dir.glob("*.md"):
            content = md_file.read_text(encoding="utf-8")
            
            # Extract requirement IDs
            req_ids = req_pattern.findall(content)
            src_files = src_pattern.findall(content)
            
            for req_id in set(req_ids):
                if req_id not in self.requirement_coverage:
                    # Determine source file from src-v02 references
                    source_file = f"src-v02/{src_files[0]}" if src_files else "unknown"
                    self.requirement_coverage[req_id] = RequirementCoverage(
                        requirement_id=req_id,
                        source_file=source_file,
                        mentioned_in_files=[],
                        implementation_evidence=[]
                    )
                
                self.requirement_coverage[req_id].mentioned_in_files.append(md_file.name)
                
                # Extract implementation evidence from traceability section
                trace_match = re.search(
                    rf'{req_id}[:\s]+(.+?)(?:\n-|\n##|\Z)',
                    content,
                    re.DOTALL
                )
                if trace_match:
                    evidence = trace_match.group(1).strip()
                    self.requirement_coverage[req_id].implementation_evidence.append(evidence)
    
    def generate_traceability_matrix(self) -> List[Dict[str, Any]]:
        """
        Generate traceability matrix linking v0.2 → requirements → implementation.
        
        Returns:
            List of dicts with keys: requirement_id, source_file, generated_files, evidence
        """
        matrix = []
        for req_id, coverage in self.requirement_coverage.items():
            matrix.append({
                "requirement_id": req_id,
                "source_file": coverage.source_file,
                "generated_files": coverage.mentioned_in_files,
                "implementation_evidence": coverage.implementation_evidence,
                "coverage_count": len(coverage.mentioned_in_files)
            })
        
        # Sort by requirement ID
        matrix.sort(key=lambda x: x["requirement_id"])
        return matrix
    
    def calculate_quality_metrics(self) -> Dict[str, Any]:
        """
        Calculate quality metrics for generated documentation.
        
        Returns:
            Dict with metrics:
            - total_files: Total files generated
            - successful_files: Files that passed validation
            - failed_files: Files that failed validation
            - validation_pass_rate: Percentage of files passing validation
            - avg_retry_count: Average retries needed
            - total_tokens: Total tokens used
            - files_with_yaml: Count of files with valid YAML
            - files_with_tables: Count of files with tables
            - files_with_code: Count of files with code blocks
            - files_with_requirements: Count of files referencing requirements
            - files_with_traceability: Count of files with traceability sections
        """
        total = len(self.generation_records)
        successful = sum(1 for r in self.generation_records if r.status == "success")
        failed = total - successful
        
        metrics = {
            "total_files": total,
            "successful_files": successful,
            "failed_files": failed,
            "validation_pass_rate": f"{(successful / total * 100):.1f}%" if total > 0 else "0%",
            "avg_retry_count": sum(r.retry_count for r in self.generation_records) / total if total > 0 else 0,
            "total_tokens": sum(r.tokens_used for r in self.generation_records),
        }
        
        # Content quality metrics (scan generated files)
        files_with_yaml = 0
        files_with_tables = 0
        files_with_code = 0
        files_with_requirements = 0
        files_with_traceability = 0
        
        for md_file in self.output_dir.glob("*.md"):
            content = md_file.read_text(encoding="utf-8")
            if content.startswith("---"):
                files_with_yaml += 1
            if "|" in content and "---" in content:  # Simple table detection
                files_with_tables += 1
            if "```" in content:
                files_with_code += 1
            if re.search(r'\b[A-Z]{2,3}\d{2}\b', content):
                files_with_requirements += 1
            if "## Traceability" in content or "## Implementation Evidence" in content:
                files_with_traceability += 1
        
        metrics.update({
            "files_with_yaml": files_with_yaml,
            "files_with_tables": files_with_tables,
            "files_with_code": files_with_code,
            "files_with_requirements": files_with_requirements,
            "files_with_traceability": files_with_traceability,
        })
        
        return metrics
    
    def generate_evidence_report(self) -> str:
        """
        Generate comprehensive evidence report.
        
        Returns:
            Path to generated evidence report (Markdown + JSON)
        """
        # Analyze coverage first
        self.analyze_requirement_coverage()
        
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        report_base = self.evidence_dir / f"evidence-report-{timestamp}"
        
        # Calculate metrics
        metrics = self.calculate_quality_metrics()
        traceability = self.generate_traceability_matrix()
        
        # Generate JSON report
        json_data = {
            "timestamp": datetime.now().isoformat(),
            "quality_metrics": metrics,
            "traceability_matrix": traceability,
            "generation_records": [asdict(r) for r in self.generation_records],
            "requirement_coverage": {
                req_id: {
                    "source_file": cov.source_file,
                    "mentioned_in_files": cov.mentioned_in_files,
                    "implementation_evidence": cov.implementation_evidence,
                }
                for req_id, cov in self.requirement_coverage.items()
            }
        }
        
        json_path = f"{report_base}.json"
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(json_data, f, indent=2)
        
        # Generate Markdown report
        md_path = f"{report_base}.md"
        with open(md_path, "w", encoding="utf-8") as f:
            f.write("# EVA Foundation Documentation Generation - Evidence Report\n\n")
            f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            # Quality Metrics
            f.write("## Quality Metrics\n\n")
            f.write("| Metric | Value |\n")
            f.write("|--------|-------|\n")
            for key, value in metrics.items():
                label = key.replace("_", " ").title()
                f.write(f"| {label} | {value} |\n")
            f.write("\n")
            
            # Traceability Matrix
            f.write("## Traceability Matrix\n\n")
            f.write("| Requirement ID | Source File | Generated Files | Evidence Files |\n")
            f.write("|----------------|-------------|-----------------|----------------|\n")
            for item in traceability:
                req_id = item["requirement_id"]
                source = item["source_file"]
                gen_files = ", ".join(item["generated_files"][:3])  # Limit to 3 for readability
                if len(item["generated_files"]) > 3:
                    gen_files += f" (+{len(item['generated_files']) - 3} more)"
                evidence = ", ".join(item["implementation_evidence"][:2])
                if len(item["implementation_evidence"]) > 2:
                    evidence += f" (+{len(item['implementation_evidence']) - 2} more)"
                f.write(f"| {req_id} | {source} | {gen_files} | {evidence} |\n")
            f.write("\n")
            
            # Generation Records
            f.write("## File Generation Records\n\n")
            for record in self.generation_records:
                f.write(f"### {record.filename} (Phase {record.phase})\n\n")
                f.write(f"- **Status:** {record.status}\n")
                f.write(f"- **Timestamp:** {record.timestamp}\n")
                f.write(f"- **Retries:** {record.retry_count}\n")
                f.write(f"- **Tokens:** {record.tokens_used}\n")
                f.write(f"- **Prompt:** {record.prompt}\n")
                
                # Validation results
                f.write("\n**Validation Results:**\n\n")
                for val_type, result in record.validation_results.items():
                    status = "✅ PASS" if result.get("is_valid", False) else "❌ FAIL"
                    f.write(f"- {val_type.title()}: {status}\n")
                    if result.get("errors"):
                        for err in result["errors"]:
                            f.write(f"  - ❌ {err}\n")
                    if result.get("warnings"):
                        for warn in result["warnings"]:
                            f.write(f"  - ⚠️ {warn}\n")
                f.write("\n")
            
            # Issues Summary
            f.write("## Issues Summary\n\n")
            failed_records = [r for r in self.generation_records if r.status == "failed"]
            if failed_records:
                f.write(f"**{len(failed_records)} file(s) failed validation:**\n\n")
                for record in failed_records:
                    f.write(f"- {record.filename}\n")
            else:
                f.write("✅ All files passed validation.\n")
            f.write("\n")
        
        return md_path
