/**
 * Auto-generated EditForm for {{LAYER_NAME}} layer.
 *
 * Template variables (substituted by generate-screens.ps1):
 *   {{LAYER_ID}}         - Layer identifier (e.g. "projects", "L25")
 *   {{LAYER_NAME}}       - Display / component name (e.g. "Projects")
 *   {{SCHEMA_ENDPOINT}}  - Base URL of the Data Model API
 *   {{LAYER_FIELDS_JSON}} - JSON snapshot of the layer schema (offline fallback)
 *
 * Accessibility: WCAG 2.1 Level AA
 * Generated: {{GENERATED_AT}}
 */

import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';

// ---------------------------------------------------------------------------
// Type definitions
// ---------------------------------------------------------------------------

interface FieldSchema {
  field_name: string;
  field_type: 'string' | 'number' | 'boolean' | 'date' | 'reference';
  label: string;
  required?: boolean;
  /** string field constraints */
  min_length?: number;
  max_length?: number;
  /** number field constraints */
  min?: number;
  max?: number;
  /** date field constraints (ISO-8601 date strings) */
  min_date?: string;
  max_date?: string;
  /** reference field configuration */
  reference_endpoint?: string;
  reference_label_field?: string;
  reference_value_field?: string;
  /** static options used when reference_endpoint is unavailable */
  options?: Array<{ value: string; label: string }>;
}

interface LayerSchema {
  layer_id: string;
  layer_name: string;
  fields: FieldSchema[];
}

type FormValue = string | number | boolean | null;

interface FormData {
  [key: string]: FormValue;
}

interface FormErrors {
  [key: string]: string;
}

interface ReferenceOption {
  value: string;
  label: string;
}

export interface {{LAYER_NAME}}EditFormProps {
  /** Record id of the item being edited */
  recordId: string | number;
  /** Pre-populated values from the existing record */
  initialData: FormData;
  /** Called with the updated form data on successful submission */
  onSubmit?: (id: string | number, data: FormData) => void | Promise<void>;
  /** Called when the user clicks Cancel */
  onCancel?: () => void;
  /**
   * Override the API base URL used for runtime schema refresh and reference
   * lookups.  Defaults to the endpoint baked in at generation time.
   */
  schemaEndpoint?: string;
}

// ---------------------------------------------------------------------------
// Baked-in schema (snapshot captured at generation time)
// Source: {{SCHEMA_ENDPOINT}}/model/{{LAYER_ID}}/fields
// ---------------------------------------------------------------------------
const BAKED_SCHEMA: LayerSchema = {{LAYER_FIELDS_JSON}};

// ---------------------------------------------------------------------------
// Component
// ---------------------------------------------------------------------------

export const {{LAYER_NAME}}EditForm: React.FC<{{LAYER_NAME}}EditFormProps> = ({
  recordId,
  initialData,
  onSubmit,
  onCancel,
  schemaEndpoint = '{{SCHEMA_ENDPOINT}}',
}) => {
  const { t } = useTranslation();

  const [schema, setSchema] = useState<LayerSchema>(BAKED_SCHEMA);
  const [formData, setFormData] = useState<FormData>({});
  const [errors, setErrors] = useState<FormErrors>({});
  const [referenceOptions, setReferenceOptions] = useState<Record<string, ReferenceOption[]>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [usingOfflineSchema, setUsingOfflineSchema] = useState(false);

  // -------------------------------------------------------------------------
  // Attempt to refresh schema from the API at runtime.
  // On failure, fall back silently to BAKED_SCHEMA and log a console warning.
  // An AbortController ensures no state update occurs after unmount.
  // -------------------------------------------------------------------------
  useEffect(() => {
    const controller = new AbortController();

    const fetchSchema = async () => {
      try {
        const response = await fetch(`${schemaEndpoint}/model/{{LAYER_ID}}/fields`, {
          signal: controller.signal,
        });
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const freshSchema: LayerSchema = await response.json();
        setSchema(freshSchema);
      } catch (err) {
        if ((err as DOMException).name === 'AbortError') return;
        console.warn(
          '[{{LAYER_NAME}}EditForm] Schema fetch failed – using offline snapshot:',
          err,
        );
        setUsingOfflineSchema(true);
        // BAKED_SCHEMA already set as initial state; nothing more to do.
      }
    };

    fetchSchema();
    return () => controller.abort();
  }, [schemaEndpoint]);

  // -------------------------------------------------------------------------
  // Populate form with pre-existing record values whenever schema or
  // initialData changes.  Field defaults fill any gaps left by initialData.
  // -------------------------------------------------------------------------
  useEffect(() => {
    const populated: FormData = {};
    schema.fields.forEach(field => {
      const existing = initialData[field.field_name];
      if (existing !== undefined && existing !== null) {
        populated[field.field_name] = existing;
      } else {
        populated[field.field_name] = field.field_type === 'boolean' ? false : '';
      }
    });
    setFormData(populated);
  }, [schema, initialData]);

  // -------------------------------------------------------------------------
  // Load options for every reference field.
  // Falls back to the static options array on fetch failure.
  // An AbortController ensures no state update occurs after unmount.
  // -------------------------------------------------------------------------
  useEffect(() => {
    const controller = new AbortController();

    const loadReferenceOptions = async () => {
      const refFields = schema.fields.filter(
        f => f.field_type === 'reference' && f.reference_endpoint,
      );

      for (const field of refFields) {
        if (controller.signal.aborted) break;
        try {
          const response = await fetch(`${schemaEndpoint}${field.reference_endpoint}`, {
            signal: controller.signal,
          });
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
          }
          const data: Record<string, unknown>[] = await response.json();
          const options: ReferenceOption[] = data.map(item => ({
            value: String(item[field.reference_value_field ?? 'id']),
            label: String(item[field.reference_label_field ?? 'name']),
          }));
          setReferenceOptions(prev => ({ ...prev, [field.field_name]: options }));
        } catch (err) {
          if ((err as DOMException).name === 'AbortError') break;
          console.warn(
            `[{{LAYER_NAME}}EditForm] Could not load options for "${field.field_name}":`,
            err,
          );
          setReferenceOptions(prev => ({
            ...prev,
            [field.field_name]: field.options ?? [],
          }));
        }
      }
    };

    loadReferenceOptions();
    return () => controller.abort();
  }, [schema, schemaEndpoint]);

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------
  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    schema.fields.forEach(field => {
      const value = formData[field.field_name];

      // Required check (booleans are always "provided")
      if (field.required && field.field_type !== 'boolean') {
        if (value === '' || value === null || value === undefined) {
          newErrors[field.field_name] = t('errors.required', { field: field.label });
          return;
        }
      }

      // String constraints
      if (field.field_type === 'string' && typeof value === 'string' && value !== '') {
        if (field.min_length !== undefined && value.length < field.min_length) {
          newErrors[field.field_name] = t('errors.minLength', {
            field: field.label,
            min: field.min_length,
          });
        } else if (field.max_length !== undefined && value.length > field.max_length) {
          newErrors[field.field_name] = t('errors.maxLength', {
            field: field.label,
            max: field.max_length,
          });
        }
      }

      // Number constraints
      if (field.field_type === 'number' && typeof value === 'string' && value !== '') {
        const num = Number(value);
        if (isNaN(num)) {
          newErrors[field.field_name] = t('errors.invalidNumber', { field: field.label });
        } else {
          if (field.min !== undefined && num < field.min) {
            newErrors[field.field_name] = t('errors.min', { field: field.label, min: field.min });
          } else if (field.max !== undefined && num > field.max) {
            newErrors[field.field_name] = t('errors.max', {
              field: field.label,
              max: field.max,
            });
          }
        }
      }

      // Date constraints
      if (field.field_type === 'date' && typeof value === 'string' && value !== '') {
        if (field.min_date && value < field.min_date) {
          newErrors[field.field_name] = t('errors.dateMin', {
            field: field.label,
            min: field.min_date,
          });
        } else if (field.max_date && value > field.max_date) {
          newErrors[field.field_name] = t('errors.dateMax', {
            field: field.label,
            max: field.max_date,
          });
        }
      }
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // -------------------------------------------------------------------------
  // Event handlers
  // -------------------------------------------------------------------------
  const handleChange = (fieldName: string, value: string | boolean) => {
    setFormData(prev => ({ ...prev, [fieldName]: value }));
    // Clear field-level error as soon as the user starts correcting it
    if (errors[fieldName]) {
      setErrors(prev => {
        const next = { ...prev };
        delete next[fieldName];
        return next;
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    try {
      if (onSubmit) await onSubmit(recordId, formData);
    } finally {
      setIsSubmitting(false);
    }
  };

  // -------------------------------------------------------------------------
  // Field renderer – maps each FieldSchema to an accessible input element
  // pre-populated with the existing record value.
  // Unknown field types are rendered as text inputs with a console warning.
  // -------------------------------------------------------------------------
  const renderField = (field: FieldSchema): React.ReactElement | null => {
    if (!field.field_name) {
      console.warn('[{{LAYER_NAME}}EditForm] Skipping field with missing field_name:', field);
      return null;
    }

    const fieldId = `field-{{LAYER_ID}}-${field.field_name}`;
    const errorId = `error-{{LAYER_ID}}-${field.field_name}`;
    const hasError = Boolean(errors[field.field_name]);
    const value = formData[field.field_name] ?? '';

    switch (field.field_type) {
      case 'string':
        return (
          <div key={field.field_name} className="form-field">
            <label htmlFor={fieldId}>
              {field.label}
              {field.required && <span aria-hidden="true"> *</span>}
            </label>
            <input
              id={fieldId}
              type="text"
              value={String(value)}
              onChange={e => handleChange(field.field_name, e.target.value)}
              required={field.required}
              minLength={field.min_length}
              maxLength={field.max_length}
              aria-describedby={hasError ? errorId : undefined}
              aria-invalid={hasError || undefined}
              aria-required={field.required}
            />
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );

      case 'number':
        return (
          <div key={field.field_name} className="form-field">
            <label htmlFor={fieldId}>
              {field.label}
              {field.required && <span aria-hidden="true"> *</span>}
            </label>
            <input
              id={fieldId}
              type="number"
              value={String(value)}
              onChange={e => handleChange(field.field_name, e.target.value)}
              required={field.required}
              min={field.min}
              max={field.max}
              aria-describedby={hasError ? errorId : undefined}
              aria-invalid={hasError || undefined}
              aria-required={field.required}
            />
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );

      case 'boolean':
        return (
          <div key={field.field_name} className="form-field form-field--checkbox">
            <input
              id={fieldId}
              type="checkbox"
              checked={Boolean(value)}
              onChange={e => handleChange(field.field_name, e.target.checked)}
              aria-describedby={hasError ? errorId : undefined}
            />
            <label htmlFor={fieldId}>{field.label}</label>
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );

      case 'date':
        return (
          <div key={field.field_name} className="form-field">
            <label htmlFor={fieldId}>
              {field.label}
              {field.required && <span aria-hidden="true"> *</span>}
            </label>
            <input
              id={fieldId}
              type="date"
              value={String(value)}
              onChange={e => handleChange(field.field_name, e.target.value)}
              required={field.required}
              min={field.min_date}
              max={field.max_date}
              aria-describedby={hasError ? errorId : undefined}
              aria-invalid={hasError || undefined}
              aria-required={field.required}
            />
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );

      case 'reference':
        return (
          <div key={field.field_name} className="form-field">
            <label htmlFor={fieldId}>
              {field.label}
              {field.required && <span aria-hidden="true"> *</span>}
            </label>
            <select
              id={fieldId}
              value={String(value)}
              onChange={e => handleChange(field.field_name, e.target.value)}
              required={field.required}
              aria-describedby={hasError ? errorId : undefined}
              aria-invalid={hasError || undefined}
              aria-required={field.required}
            >
              <option value="">{t('form.selectOption')}</option>
              {(referenceOptions[field.field_name] ?? field.options ?? []).map(opt => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );

      default:
        console.warn(
          `[{{LAYER_NAME}}EditForm] Unknown field type "${field.field_type}" for field ` +
            `"${field.field_name}" – rendering as text input.`,
        );
        return (
          <div key={field.field_name} className="form-field">
            <label htmlFor={fieldId}>
              {field.label}
              {field.required && <span aria-hidden="true"> *</span>}
            </label>
            <input
              id={fieldId}
              type="text"
              value={String(value)}
              onChange={e => handleChange(field.field_name, e.target.value)}
              required={field.required}
              aria-describedby={hasError ? errorId : undefined}
              aria-invalid={hasError || undefined}
              aria-required={field.required}
            />
            {hasError && (
              <span id={errorId} role="alert" className="error-message">
                {errors[field.field_name]}
              </span>
            )}
          </div>
        );
    }
  };

  // -------------------------------------------------------------------------
  // Render
  // -------------------------------------------------------------------------
  return (
    <form
      onSubmit={handleSubmit}
      aria-label={t('form.editTitle', { layer: '{{LAYER_NAME}}' })}
      noValidate
    >
      {usingOfflineSchema && (
        <div role="status" className="schema-notice" aria-live="polite">
          {t('form.offlineSchema')}
        </div>
      )}

      {schema.fields.map(field => renderField(field))}

      <div className="form-actions">
        {onCancel && (
          <button type="button" onClick={onCancel}>
            {t('form.cancel')}
          </button>
        )}
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? t('form.submitting') : t('form.save', { layer: '{{LAYER_NAME}}' })}
        </button>
      </div>
    </form>
  );
};

export default {{LAYER_NAME}}EditForm;
