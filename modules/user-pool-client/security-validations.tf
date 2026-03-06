# Security Validations
# Enforces security controls from metadata module with override capability

# Validation: Token revocation should be enabled
check "token_revocation_enabled" {
  assert {
    condition = local.token_revocation_passed
    error_message = join("", [
      "Security control violation: Token revocation must be enabled for compliance. ",
      "Current: enable_token_revocation=${var.enable_token_revocation}. ",
      "Set security_control_overrides.disable_token_revocation=true with justification if this is intentional."
    ])
  }
}

# Validation: Prevent user existence errors should be enabled
check "prevent_user_existence_errors_enabled" {
  assert {
    condition = local.prevent_user_existence_errors_passed
    error_message = join("", [
      "Security control violation: Prevent user existence errors must be ENABLED for security. ",
      "Current: prevent_user_existence_errors=${var.prevent_user_existence_errors}. ",
      "Set security_control_overrides.disable_prevent_user_existence_errors=true with justification if this is intentional."
    ])
  }
}

# Validation: Security control overrides must have justification
check "security_control_overrides_justified" {
  assert {
    condition = local.override_audit_passed
    error_message = join("", [
      "Security control overrides detected but no justification provided. ",
      "When disabling security controls, you must document the business reason in security_control_overrides.justification. ",
      "This is required for audit and compliance purposes."
    ])
  }
}

# Validation: OAuth flows must be secure
check "oauth_flows_secure" {
  assert {
    condition = !contains(var.oauth_flows, "implicit") || var.environment != "prod"
    error_message = join("", [
      "Security warning: Implicit OAuth flow is not recommended for production environments. ",
      "Use authorization code flow (code) instead for better security. ",
      "Current environment: ${var.environment}, OAuth flows: ${join(", ", var.oauth_flows)}"
    ])
  }
}

# Validation: Callback URLs must use HTTPS in production
check "callback_urls_https" {
  assert {
    condition = var.environment != "prod" || alltrue([
      for url in var.callback_urls : can(regex("^https://", url))
    ])
    error_message = join("", [
      "Security control violation: All callback URLs must use HTTPS in production environment. ",
      "Current callback URLs: ${join(", ", var.callback_urls)}"
    ])
  }
}

# Validation: Logout URLs must use HTTPS in production
check "logout_urls_https" {
  assert {
    condition = var.environment != "prod" || alltrue([
      for url in var.logout_urls : can(regex("^https://", url))
    ])
    error_message = join("", [
      "Security control violation: All logout URLs must use HTTPS in production environment. ",
      "Current logout URLs: ${join(", ", var.logout_urls)}"
    ])
  }
}

# Validation: Token validity should be reasonable
check "token_validity_reasonable" {
  assert {
    condition = (
      # Refresh token: max 30 days in production
      (var.environment != "prod" || (
        var.token_validity.refresh_token_unit == "days" &&
        var.token_validity.refresh_token_validity <= 30
      )) &&
      # Access token: max 60 minutes
      (var.token_validity.access_token_unit == "minutes" &&
        var.token_validity.access_token_validity <= 60
      ) &&
      # ID token: max 60 minutes
      (var.token_validity.id_token_unit == "minutes" &&
        var.token_validity.id_token_validity <= 60
      )
    )
    error_message = join("", [
      "Security warning: Token validity periods should follow best practices. ",
      "Recommended: refresh_token <= 30 days, access_token <= 60 minutes, id_token <= 60 minutes. ",
      "Current: refresh_token=${var.token_validity.refresh_token_validity} ${var.token_validity.refresh_token_unit}, ",
      "access_token=${var.token_validity.access_token_validity} ${var.token_validity.access_token_unit}, ",
      "id_token=${var.token_validity.id_token_validity} ${var.token_validity.id_token_unit}"
    ])
  }
}
