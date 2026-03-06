# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    network = {
      require_private_subnets = false
      require_vpc_endpoints   = false
      block_public_ingress    = false
      require_imdsv2          = false
    }
    iam = {
      enforce_least_privilege  = false
      block_wildcard_resources = false
      require_mfa_for_humans   = false
      require_service_roles    = false
    }
    data_protection = {
      require_versioning         = false
      require_mfa_delete         = false
      require_automated_backups  = false
      block_public_access        = false
      require_lifecycle_policies = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    high_availability = {
      require_multi_az           = false
      require_multi_az_nat       = false
      enable_cross_region_backup = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
  }

  # Apply overrides to security controls
  # Controls are enforced UNLESS explicitly overridden with justification
  deletion_protection_required = local.security_controls.compliance.enable_deletion_protection && !var.security_control_overrides.disable_deletion_protection
  advanced_security_required   = !var.security_control_overrides.disable_advanced_security
  mfa_required                 = !var.security_control_overrides.disable_mfa_requirement
  password_complexity_required = !var.security_control_overrides.disable_password_complexity

  # Validation results
  deletion_protection_validation_passed = !local.deletion_protection_required || var.enable_deletion_protection
  advanced_security_validation_passed   = !local.advanced_security_required || var.advanced_security_mode != "OFF"
  mfa_validation_passed                 = !local.mfa_required || var.mfa_configuration != "OFF"
  password_complexity_validation_passed = !local.password_complexity_required || (
    var.password_policy.minimum_length >= 14 &&
    var.password_policy.require_lowercase &&
    var.password_policy.require_uppercase &&
    var.password_policy.require_numbers &&
    var.password_policy.require_symbols
  )

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_deletion_protection ||
    var.security_control_overrides.disable_advanced_security ||
    var.security_control_overrides.disable_mfa_requirement ||
    var.security_control_overrides.disable_password_complexity
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.deletion_protection_validation_passed
    error_message = "Security control violation: Deletion protection is required but enable_deletion_protection is false. Set security_control_overrides.disable_deletion_protection=true with justification if this is a development/testing user pool."
  }

  assert {
    condition     = local.advanced_security_validation_passed
    error_message = "Security control violation: Advanced security mode is required but set to OFF. Set security_control_overrides.disable_advanced_security=true with justification if this is intentional."
  }

  assert {
    condition     = local.mfa_validation_passed
    error_message = "Security control violation: MFA is required but mfa_configuration is OFF. Set security_control_overrides.disable_mfa_requirement=true with justification if this is a demo environment."
  }

  assert {
    condition     = local.password_complexity_validation_passed
    error_message = "Security control violation: Password policy does not meet CIS Benchmark requirements (min 14 chars, lowercase, uppercase, numbers, symbols). Set security_control_overrides.disable_password_complexity=true with justification if this is intentional."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
