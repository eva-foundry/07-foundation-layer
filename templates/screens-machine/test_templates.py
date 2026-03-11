"""
Tests for screens-machine template files.

Validates that CreateForm.template.tsx and EditForm.template.tsx contain:
1. Required template placeholder variables
2. Dynamic field rendering (switch/case for all five field types)
3. WCAG 2.1 Level AA accessibility attributes
4. Validation logic for each constrained field type
5. Error handling for schema fetch failure and unknown field types
6. Key differences between CreateForm (blank) and EditForm (pre-populated)

Run with: pytest test_templates.py -v
"""

import re
import pytest
from pathlib import Path

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

TEMPLATE_DIR = Path(__file__).parent

CREATE_TEMPLATE = TEMPLATE_DIR / "CreateForm.template.tsx"
EDIT_TEMPLATE = TEMPLATE_DIR / "EditForm.template.tsx"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture(scope="module")
def create_source() -> str:
    return _read(CREATE_TEMPLATE)


@pytest.fixture(scope="module")
def edit_source() -> str:
    return _read(EDIT_TEMPLATE)


# ---------------------------------------------------------------------------
# File existence
# ---------------------------------------------------------------------------


class TestFilesExist:
    def test_create_form_template_exists(self):
        assert CREATE_TEMPLATE.exists(), "CreateForm.template.tsx is missing"

    def test_edit_form_template_exists(self):
        assert EDIT_TEMPLATE.exists(), "EditForm.template.tsx is missing"


# ---------------------------------------------------------------------------
# Required template placeholder variables
# ---------------------------------------------------------------------------


REQUIRED_PLACEHOLDERS = [
    "{{LAYER_ID}}",
    "{{LAYER_NAME}}",
    "{{SCHEMA_ENDPOINT}}",
    "{{LAYER_FIELDS_JSON}}",
    "{{GENERATED_AT}}",
]


class TestPlaceholders:
    @pytest.mark.parametrize("placeholder", REQUIRED_PLACEHOLDERS)
    def test_create_form_has_placeholder(self, create_source, placeholder):
        assert placeholder in create_source, (
            f"CreateForm.template.tsx is missing placeholder {placeholder}"
        )

    @pytest.mark.parametrize("placeholder", REQUIRED_PLACEHOLDERS)
    def test_edit_form_has_placeholder(self, edit_source, placeholder):
        assert placeholder in edit_source, (
            f"EditForm.template.tsx is missing placeholder {placeholder}"
        )


# ---------------------------------------------------------------------------
# Dynamic field type handling
# ---------------------------------------------------------------------------


FIELD_TYPES = ["string", "number", "boolean", "date", "reference"]


class TestFieldTypeRendering:
    @pytest.mark.parametrize("field_type", FIELD_TYPES)
    def test_create_form_handles_field_type(self, create_source, field_type):
        assert f"case '{field_type}':" in create_source, (
            f"CreateForm.template.tsx missing case '{field_type}'"
        )

    @pytest.mark.parametrize("field_type", FIELD_TYPES)
    def test_edit_form_handles_field_type(self, edit_source, field_type):
        assert f"case '{field_type}':" in edit_source, (
            f"EditForm.template.tsx missing case '{field_type}'"
        )

    def test_create_form_has_default_fallback(self, create_source):
        assert "default:" in create_source, (
            "CreateForm.template.tsx must have a default case for unknown field types"
        )

    def test_edit_form_has_default_fallback(self, edit_source):
        assert "default:" in edit_source, (
            "EditForm.template.tsx must have a default case for unknown field types"
        )

    def test_create_form_string_renders_text_input(self, create_source):
        # After 'string' case, must produce <input type="text"
        idx = create_source.index("case 'string':")
        snippet = create_source[idx: idx + 500]
        assert 'type="text"' in snippet

    def test_edit_form_string_renders_text_input(self, edit_source):
        idx = edit_source.index("case 'string':")
        snippet = edit_source[idx: idx + 500]
        assert 'type="text"' in snippet

    def test_create_form_number_renders_number_input(self, create_source):
        idx = create_source.index("case 'number':")
        snippet = create_source[idx: idx + 500]
        assert 'type="number"' in snippet

    def test_edit_form_number_renders_number_input(self, edit_source):
        idx = edit_source.index("case 'number':")
        snippet = edit_source[idx: idx + 500]
        assert 'type="number"' in snippet

    def test_create_form_boolean_renders_checkbox(self, create_source):
        idx = create_source.index("case 'boolean':")
        snippet = create_source[idx: idx + 500]
        assert 'type="checkbox"' in snippet

    def test_edit_form_boolean_renders_checkbox(self, edit_source):
        idx = edit_source.index("case 'boolean':")
        snippet = edit_source[idx: idx + 500]
        assert 'type="checkbox"' in snippet

    def test_create_form_date_renders_date_input(self, create_source):
        idx = create_source.index("case 'date':")
        snippet = create_source[idx: idx + 500]
        assert 'type="date"' in snippet

    def test_edit_form_date_renders_date_input(self, edit_source):
        idx = edit_source.index("case 'date':")
        snippet = edit_source[idx: idx + 500]
        assert 'type="date"' in snippet

    def test_create_form_reference_renders_select(self, create_source):
        idx = create_source.index("case 'reference':")
        snippet = create_source[idx: idx + 500]
        assert "<select" in snippet

    def test_edit_form_reference_renders_select(self, edit_source):
        idx = edit_source.index("case 'reference':")
        snippet = edit_source[idx: idx + 500]
        assert "<select" in snippet


# ---------------------------------------------------------------------------
# Accessibility attributes (WCAG 2.1 Level AA)
# ---------------------------------------------------------------------------


class TestAccessibility:
    def test_create_form_uses_html_for(self, create_source):
        assert "htmlFor={fieldId}" in create_source, (
            "CreateForm.template.tsx: <label> elements must use htmlFor={fieldId}"
        )

    def test_edit_form_uses_html_for(self, edit_source):
        assert "htmlFor={fieldId}" in edit_source, (
            "EditForm.template.tsx: <label> elements must use htmlFor={fieldId}"
        )

    def test_create_form_uses_aria_describedby(self, create_source):
        assert "aria-describedby" in create_source, (
            "CreateForm.template.tsx: inputs must use aria-describedby for error messages"
        )

    def test_edit_form_uses_aria_describedby(self, edit_source):
        assert "aria-describedby" in edit_source, (
            "EditForm.template.tsx: inputs must use aria-describedby for error messages"
        )

    def test_create_form_uses_aria_invalid(self, create_source):
        assert "aria-invalid" in create_source, (
            "CreateForm.template.tsx: inputs must use aria-invalid to signal validation errors"
        )

    def test_edit_form_uses_aria_invalid(self, edit_source):
        assert "aria-invalid" in edit_source, (
            "EditForm.template.tsx: inputs must use aria-invalid to signal validation errors"
        )

    def test_create_form_uses_aria_required(self, create_source):
        assert "aria-required" in create_source, (
            "CreateForm.template.tsx: required inputs must declare aria-required"
        )

    def test_edit_form_uses_aria_required(self, edit_source):
        assert "aria-required" in edit_source, (
            "EditForm.template.tsx: required inputs must declare aria-required"
        )

    def test_create_form_error_spans_have_role_alert(self, create_source):
        assert 'role="alert"' in create_source, (
            "CreateForm.template.tsx: error <span> elements must have role='alert'"
        )

    def test_edit_form_error_spans_have_role_alert(self, edit_source):
        assert 'role="alert"' in edit_source, (
            "EditForm.template.tsx: error <span> elements must have role='alert'"
        )

    def test_create_form_offline_notice_has_aria_live(self, create_source):
        assert "aria-live" in create_source, (
            "CreateForm.template.tsx: schema-notice must include aria-live for screen readers"
        )

    def test_edit_form_offline_notice_has_aria_live(self, edit_source):
        assert "aria-live" in edit_source, (
            "EditForm.template.tsx: schema-notice must include aria-live for screen readers"
        )

    def test_create_form_form_has_aria_label(self, create_source):
        assert "aria-label" in create_source, (
            "CreateForm.template.tsx: <form> must have an aria-label for assistive technology"
        )

    def test_edit_form_form_has_aria_label(self, edit_source):
        assert "aria-label" in edit_source, (
            "EditForm.template.tsx: <form> must have an aria-label for assistive technology"
        )

    def test_create_form_required_indicator_is_aria_hidden(self, create_source):
        assert 'aria-hidden="true"' in create_source, (
            "CreateForm.template.tsx: required asterisk (*) must be aria-hidden to avoid "
            "screen reader duplication (aria-required already communicates this)"
        )

    def test_edit_form_required_indicator_is_aria_hidden(self, edit_source):
        assert 'aria-hidden="true"' in edit_source, (
            "EditForm.template.tsx: required asterisk (*) must be aria-hidden"
        )


# ---------------------------------------------------------------------------
# Validation logic
# ---------------------------------------------------------------------------


class TestValidation:
    def test_create_form_validates_required_fields(self, create_source):
        assert "errors.required" in create_source

    def test_edit_form_validates_required_fields(self, edit_source):
        assert "errors.required" in edit_source

    def test_create_form_validates_min_length(self, create_source):
        assert "min_length" in create_source
        assert "errors.minLength" in create_source

    def test_edit_form_validates_min_length(self, edit_source):
        assert "min_length" in edit_source
        assert "errors.minLength" in edit_source

    def test_create_form_validates_max_length(self, create_source):
        assert "max_length" in create_source
        assert "errors.maxLength" in create_source

    def test_edit_form_validates_max_length(self, edit_source):
        assert "max_length" in edit_source
        assert "errors.maxLength" in edit_source

    def test_create_form_validates_number_min_max(self, create_source):
        assert "errors.min" in create_source
        assert "errors.max" in create_source

    def test_edit_form_validates_number_min_max(self, edit_source):
        assert "errors.min" in edit_source
        assert "errors.max" in edit_source

    def test_create_form_validates_date_range(self, create_source):
        assert "errors.dateMin" in create_source
        assert "errors.dateMax" in create_source

    def test_edit_form_validates_date_range(self, edit_source):
        assert "errors.dateMin" in edit_source
        assert "errors.dateMax" in edit_source


# ---------------------------------------------------------------------------
# Error handling
# ---------------------------------------------------------------------------


class TestErrorHandling:
    def test_create_form_handles_schema_fetch_failure(self, create_source):
        # Must catch fetch errors and use offline schema
        assert "usingOfflineSchema" in create_source
        assert "console.warn" in create_source

    def test_edit_form_handles_schema_fetch_failure(self, edit_source):
        assert "usingOfflineSchema" in edit_source
        assert "console.warn" in edit_source

    def test_create_form_warns_on_unknown_field_type(self, create_source):
        assert "Unknown field type" in create_source

    def test_edit_form_warns_on_unknown_field_type(self, edit_source):
        assert "Unknown field type" in edit_source

    def test_create_form_skips_missing_field_name(self, create_source):
        assert "Skipping field with missing field_name" in create_source

    def test_edit_form_skips_missing_field_name(self, edit_source):
        assert "Skipping field with missing field_name" in edit_source

    def test_create_form_has_offline_fallback_schema(self, create_source):
        assert "BAKED_SCHEMA" in create_source

    def test_edit_form_has_offline_fallback_schema(self, edit_source):
        assert "BAKED_SCHEMA" in edit_source

    def test_create_form_uses_abort_controller_for_schema_fetch(self, create_source):
        assert "AbortController" in create_source, (
            "CreateForm must use AbortController to prevent state updates on unmounted component"
        )

    def test_edit_form_uses_abort_controller_for_schema_fetch(self, edit_source):
        assert "AbortController" in edit_source, (
            "EditForm must use AbortController to prevent state updates on unmounted component"
        )

    def test_create_form_cleans_up_schema_fetch_on_unmount(self, create_source):
        assert "controller.abort()" in create_source, (
            "CreateForm schema fetch useEffect must return cleanup that calls controller.abort()"
        )

    def test_edit_form_cleans_up_schema_fetch_on_unmount(self, edit_source):
        assert "controller.abort()" in edit_source, (
            "EditForm schema fetch useEffect must return cleanup that calls controller.abort()"
        )


# ---------------------------------------------------------------------------
# CreateForm vs EditForm key differences
# ---------------------------------------------------------------------------


class TestCreateVsEditDifferences:
    def test_edit_form_accepts_initial_data_prop(self, edit_source):
        assert "initialData" in edit_source, (
            "EditForm must accept initialData prop to pre-populate fields"
        )

    def test_edit_form_accepts_record_id_prop(self, edit_source):
        assert "recordId" in edit_source, (
            "EditForm must accept recordId prop to identify the record being updated"
        )

    def test_edit_form_passes_record_id_to_on_submit(self, edit_source):
        assert re.search(r"onSubmit\(recordId", edit_source) is not None, (
            "EditForm must pass recordId to the onSubmit callback"
        )

    def test_create_form_does_not_require_initial_data(self, create_source):
        assert "initialData" not in create_source, (
            "CreateForm must NOT have an initialData prop – fields start empty"
        )

    def test_edit_form_save_label_differs_from_create(self, create_source, edit_source):
        assert "form.create" in create_source, "CreateForm must use 'form.create' i18n key"
        assert "form.save" in edit_source, "EditForm must use 'form.save' i18n key"

    def test_edit_form_populates_values_from_initial_data(self, edit_source):
        # The initialData population effect must check for existing values
        assert "initialData[field.field_name]" in edit_source
