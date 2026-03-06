# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  client_name_base = module.metadata.resource_prefix

  # Construct client name from components (with optional attributes)
  client_name = length(var.attributes) > 0 ? "${local.client_name_base}-${join(var.delimiter, var.attributes)}" : local.client_name_base

  # Security controls from metadata module
  security_controls = var.security_controls != null ? var.security_controls : module.metadata.security_controls

  # Determine if security controls should be enforced
  token_revocation_required              = local.security_controls.compliance.enable_deletion_protection && !var.security_control_overrides.disable_token_revocation
  prevent_user_existence_errors_required = !var.security_control_overrides.disable_prevent_user_existence_errors

  # Validation flags
  token_revocation_passed              = !local.token_revocation_required || var.enable_token_revocation
  prevent_user_existence_errors_passed = !local.prevent_user_existence_errors_required || var.prevent_user_existence_errors == "ENABLED"

  # Override audit trail
  has_overrides          = var.security_control_overrides.disable_token_revocation || var.security_control_overrides.disable_prevent_user_existence_errors
  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}
