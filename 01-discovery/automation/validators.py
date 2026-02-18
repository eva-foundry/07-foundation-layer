"""
Validation functions for EVA Foundation documentation
"""

import re
import yaml
from typing import Dict, List


def validate_yaml_frontmatter(content: str) -> Dict:
    """Validate YAML front matter against schema"""
    try:
        if not content.strip().startswith("---"):
            return {"valid": False, "error": "Missing YAML front matter"}
        
        # Extract YAML
        yaml_match = re.match(r"---\n(.*?)\n---", content, re.DOTALL)
        if not yaml_match:
            return {"valid": False, "error": "Malformed YAML front matter"}
        
        yaml_content = yaml.safe_load(yaml_match.group(1))
        
        # Validate required fields
        required = ["document_type", "phase", "audience", "traceability"]
        for field in required:
            if field not in yaml_content:
                return {"valid": False, "error": f"Missing required field: {field}"}
        
        # Validate types
        if not isinstance(yaml_content["audience"], list):
            return {"valid": False, "error": "audience must be a list"}
        
        if not isinstance(yaml_content["traceability"], list):
            return {"valid": False, "error": "traceability must be a list"}
        
        return {"valid": True}
    except yaml.YAMLError as e:
        return {"valid": False, "error": f"YAML parse error: {e}"}
    except Exception as e:
        return {"valid": False, "error": str(e)}


def validate_consumability(content: str) -> Dict:
    """Check AI-consumability requirements"""
    errors = []
    warnings = []
    
    # Check for tables
    if "|" not in content or not re.search(r"\|.*\|.*\|", content):
        warnings.append("No markdown tables found - consider using tables for comparisons")
    
    # Check for code blocks
    if "```" not in content:
        warnings.append("No code blocks found")
    
    # Check for code blocks without language tags
    untagged_blocks = re.findall(r"```\n", content)
    if untagged_blocks:
        warnings.append(f"Found {len(untagged_blocks)} code blocks without language tags")
    
    # Check for ambiguous pronouns
    ambiguous_patterns = [
        r"\b(it|this|that)\s+(is|was|will|should|must)\b",
        r"\bthey\s+(are|were|will)\b"
    ]
    ambiguous_count = 0
    for pattern in ambiguous_patterns:
        ambiguous_count += len(re.findall(pattern, content, re.IGNORECASE))
    
    if ambiguous_count > 10:  # Threshold
        warnings.append(f"Excessive ambiguous pronouns: {ambiguous_count} instances")
    
    # Check for "see above" references
    see_above_pattern = r"\b(see above|as mentioned|as discussed|as stated earlier)\b"
    if re.search(see_above_pattern, content, re.IGNORECASE):
        errors.append("Found 'see above' or similar - use explicit markdown links")
    
    # Check for file references without links
    file_refs = re.findall(r"`[\w\-/]+\.(?:py|md|ts|tsx|json|yaml|yml)`", content)
    if file_refs:
        # Check if they're wrapped in markdown links
        for ref in file_refs[:5]:  # Check first 5
            if ref not in content or f"]({ref[1:-1]})" not in content:
                warnings.append(f"File reference without link: {ref}")
                break
    
    return {"errors": errors, "warnings": warnings}


def validate_traceability(content: str) -> Dict:
    """Validate requirement traceability to v0.2 sources"""
    
    # Check for requirement IDs (INF01, ACC03, IOP01, etc.)
    req_pattern = r"\b[A-Z]{2,3}\d{2}\b"
    req_ids = re.findall(req_pattern, content)
    
    if len(req_ids) == 0:
        return {
            "valid": False,
            "error": "No v0.2 requirement IDs found (expected format: INF01, ACC03, etc.)"
        }
    
    # Check for source-materials file references
    if "source-materials/requirements-v0.2/" not in content:
        return {
            "valid": False,
            "error": "No references to source-materials/requirements-v0.2 source files"
        }
    
    # Check for traceability section
    if "traceability" not in content.lower() and "implementation evidence" not in content.lower():
        return {
            "valid": False,
            "error": "Missing traceability or implementation evidence section"
        }
    
    return {"valid": True, "requirement_ids": len(req_ids)}
