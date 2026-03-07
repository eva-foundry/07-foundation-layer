"""
Unit tests for EVA Foundation documentation generator.

Tests the validation logic in validators.py to ensure:
1. YAML frontmatter validation catches malformed/missing metadata
2. Consumability validation enforces AI-readable patterns
3. Traceability validation verifies requirement linkage to v0.2 sources

Run with: pytest test_generator.py -v --cov=. --cov-report=html
Coverage target: >80%
"""

import pytest
import yaml
from validators import (
    validate_yaml_frontmatter,
    validate_consumability,
    validate_traceability
)


# ==================== YAML Frontmatter Tests ====================

class TestYAMLValidation:
    """Test YAML frontmatter validation logic."""

    def test_valid_yaml_frontmatter(self):
        """Valid YAML with all required fields should pass."""
        content = """---
document_type: architecture
phase: 1
audience: [architects, developers]
traceability: [source-materials/requirements-v0.2/03_eva_chat_requirements.md]
---

# Test Document
Content here.
"""
        result = validate_yaml_frontmatter(content)
        assert result["valid"]
        assert "error" not in result

    def test_missing_yaml_frontmatter(self):
        """Content without YAML frontmatter should fail."""
        content = """# Test Document
No frontmatter here.
"""
        result = validate_yaml_frontmatter(content)
        assert not result["valid"]
        assert "Missing YAML front matter" in result["error"]

    def test_malformed_yaml_frontmatter(self):
        """Malformed YAML should fail."""
        content = """---
document_type: architecture
phase: [this should be int not list
---

# Test Document
"""
        result = validate_yaml_frontmatter(content)
        assert not result["valid"]
        assert "error" in result

    def test_missing_required_fields(self):
        """YAML missing required fields should fail."""
        content = """---
document_type: architecture
# Missing: phase, audience, traceability
---

# Test Document
"""
        result = validate_yaml_frontmatter(content)
        assert not result["valid"]
        assert "phase" in result["error"]

    def test_invalid_field_types(self):
        """YAML with wrong field types should fail."""
        content = """---
document_type: architecture
phase: 1
audience: architects  # Should be list
traceability: [source-materials/requirements-v0.2/file.md]
---

# Test Document
"""
        result = validate_yaml_frontmatter(content)
        assert not result["valid"]
        assert "must be a list" in result["error"]


# ==================== Consumability Tests ====================

class TestConsumabilityValidation:
    """Test AI-consumability validation logic."""

    def test_valid_consumable_content(self):
        """Content with tables, tagged code, clear references should pass."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [src-v02/file.md]
---

# Architecture Overview

## Component Comparison

| Component | Purpose | Technology |
|-----------|---------|------------|
| Backend   | API     | Python     |
| Frontend  | UI      | React      |

## Configuration

```python
# app/backend/app.py
def main():
    pass
```

## Related Files

See [app/backend/app.py](app/backend/app.py#L10-L20) for implementation.
"""
        result = validate_consumability(content)
        assert len(result["errors"]) == 0

    def test_see_above_references(self):
        """Content with 'see above' references should fail."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [src-v02/file.md]
---

# Architecture

As discussed above, the system uses Python.
See above for details on configuration.
"""
        result = validate_consumability(content)
        assert len(result["errors"]) > 0
        assert any("see above" in err.lower() for err in result["errors"])

    def test_missing_tables(self):
        """Content without tables should warn."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [src-v02/file.md]
---

# Architecture

This is a description of the architecture without any tables.
"""
        result = validate_consumability(content)
        # Tables are recommended but not required
        assert any("tables" in warn.lower() for warn in result["warnings"])

    def test_untagged_code_blocks(self):
        """Code blocks without language tags should warn."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [src-v02/file.md]
---

# Architecture

## Example

```
# No language tag
def main():
    pass
```
"""
        result = validate_consumability(content)
        assert any("code block" in warn.lower() for warn in result["warnings"])


# ==================== Traceability Tests ====================

class TestTraceabilityValidation:
    """Test requirement traceability validation logic."""

    def test_valid_traceability(self):
        """Content with requirement IDs and source-materials references should pass."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [source-materials/requirements-v0.2/03_eva_chat_requirements.md]
---

# Architecture

## Requirements Coverage

| Requirement | Status | Evidence |
|-------------|--------|----------|
| INF01       | Met    | app/backend/app.py |
| ACC03       | Met    | app/frontend/src/auth/ |

Requirement INF01 (src-v02/03_eva_chat_requirements.md#L5-L8) requires private endpoints.

## Traceability

- INF01: See app/backend/core/shared_constants.py
- ACC03: See app/frontend/src/auth/auth.ts
"""
        result = validate_traceability(content)
        assert result["valid"]
        assert "requirement_ids" in result

    def test_missing_requirement_ids(self):
        """Content without requirement IDs should warn."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [source-materials/requirements-v0.2/03_eva_chat_requirements.md]
---

# Architecture

This document does not reference any specific requirements.

## Traceability

General references to the system.
"""
        result = validate_traceability(content)
        assert not result["valid"]
        assert "No v0.2 requirement IDs found" in result["error"]

    def test_missing_src_v02_references(self):
        """Content without source-materials/requirements-v0.2 references should fail."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [some-other-path/03_eva_chat_requirements.md]
---

# Architecture

Requirement INF01 requires private endpoints.

## Traceability

- INF01: See app/backend/app.py
"""
        result = validate_traceability(content)
        assert not result["valid"]
        assert "source-materials/requirements-v0.2" in result["error"]

    def test_requirement_ids_found(self):
        """Requirement IDs should be extracted correctly."""
        content = """---
document_type: architecture
phase: 1
audience: [architects]
traceability: [source-materials/requirements-v0.2/file.md]
---

# Architecture

Requirements: INF01, ACC03, SEC05, OPS12

Reference to source-materials/requirements-v0.2/03_eva_chat_requirements.md.
"""
        result = validate_traceability(content)
        assert result["valid"]
        assert result["requirement_ids"] >= 4


# ==================== Parametrized Tests ====================

@pytest.mark.parametrize("req_id,expected_valid", [
    ("INF01", True),
    ("ACC03", True),
    ("SEC05", True),
    ("OPS12", True),
    ("INVALID", False),
])
def test_requirement_id_format(req_id, expected_valid):
    """Test various requirement ID formats."""
    import re
    pattern = r'\b[A-Z]{2,3}\d{2}\b'
    match = re.search(pattern, req_id)
    assert (match is not None) == expected_valid


# ==================== Integration Tests (Marked for Separate Run) ====================

@pytest.mark.integration
class TestGeneratorIntegration:
    """Integration tests for full generator pipeline (requires mocked LLM)."""

    def test_full_file_generation(self):
        """Test complete file generation with mocked LLM response."""
        # TODO: Implement with mocked Azure OpenAI responses
        pytest.skip("Integration test - requires LLM mocking")

    def test_retry_logic(self):
        """Test retry logic when validation fails."""
        # TODO: Implement with failing then passing validation
        pytest.skip("Integration test - requires LLM mocking")

    def test_state_persistence(self):
        """Test that generation state is persisted correctly."""
        # TODO: Implement with state file verification
        pytest.skip("Integration test - requires state management")


# ==================== Test Configuration ====================

@pytest.fixture
def sample_valid_content():
    """Fixture providing valid documentation content."""
    return """---
document_type: architecture
phase: 1
audience: [architects, developers]
traceability: [source-materials/requirements-v0.2/03_eva_chat_requirements.md]
---

# Sample Architecture Document

## Overview

| Component | Purpose |
|-----------|---------|
| Backend   | API     |

```python
# app/backend/app.py
def main():
    pass
```

Requirement INF01 (source-materials/requirements-v0.2/03_eva_chat_requirements.md#L5-L8) is satisfied.

## Traceability

- INF01: app/backend/app.py
"""


@pytest.fixture
def sample_invalid_content():
    """Fixture providing invalid documentation content."""
    return """# No Frontmatter

See above for details.

```
# Untagged code
```

No requirement IDs or source-materials references.
"""


def test_end_to_end_validation(sample_valid_content):
    """Test all three validations on valid content."""
    yaml_result = validate_yaml_frontmatter(sample_valid_content)
    cons_result = validate_consumability(sample_valid_content)
    trace_result = validate_traceability(sample_valid_content)

    assert yaml_result["valid"]
    assert len(cons_result["errors"]) == 0
    assert trace_result["valid"]


def test_end_to_end_validation_failure(sample_invalid_content):
    """Test all three validations on invalid content."""
    yaml_result = validate_yaml_frontmatter(sample_invalid_content)
    cons_result = validate_consumability(sample_invalid_content)
    trace_result = validate_traceability(sample_invalid_content)

    assert not yaml_result["valid"]
    assert len(cons_result["errors"]) > 0  # 'see above' reference
    assert not trace_result["valid"]  # No source-materials reference
