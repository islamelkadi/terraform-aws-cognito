# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Apply overrides to security controls
  # Controls are enforced UNLESS explicitly overridden with justification
  unauthenticated_access_restricted = !var.security_control_overrides.allow_unauthenticated_access
  iam_roles_configured              = !var.security_control_overrides.skip_iam_role_validation

  # Validation results
  unauthenticated_access_validation_passed = !local.unauthenticated_access_restricted || !var.allow_unauthenticated_identities
  iam_roles_validation_passed              = !local.iam_roles_configured || (var.authenticated_role_arn != null || length(var.cognito_identity_providers) > 0)

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.allow_unauthenticated_access ||
    var.security_control_overrides.skip_iam_role_validation
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.unauthenticated_access_validation_passed
    error_message = "Security control violation: Unauthenticated access is not recommended for production. Set security_control_overrides.allow_unauthenticated_access=true with justification if this is a public application."
  }

  assert {
    condition     = local.iam_roles_validation_passed
    error_message = "Security control violation: Identity pool must have at least one authentication provider configured. Set security_control_overrides.skip_iam_role_validation=true with justification if this is intentional."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
