# Cognito User Pool Client Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# User Pool Configuration
variable "user_pool_id" {
  description = "ID of the Cognito User Pool to create the client for"
  type        = string
}

# Client Secret Configuration
variable "generate_secret" {
  description = "Generate a client secret for server-side applications (required for authorization code flow)"
  type        = bool
  default     = false
}

# OAuth Flow Configuration
variable "oauth_flows" {
  description = "List of allowed OAuth flows (code, implicit, client_credentials)"
  type        = list(string)
  default     = ["code"]

  validation {
    condition = alltrue([
      for flow in var.oauth_flows : contains(["code", "implicit", "client_credentials"], flow)
    ])
    error_message = "OAuth flows must be code, implicit, or client_credentials"
  }
}

variable "oauth_scopes" {
  description = "List of allowed OAuth scopes (phone, email, openid, profile, aws.cognito.signin.user.admin)"
  type        = list(string)
  default     = ["openid", "email", "profile"]

  validation {
    condition = alltrue([
      for scope in var.oauth_scopes : contains([
        "phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"
      ], scope)
    ])
    error_message = "OAuth scopes must be valid Cognito scopes"
  }
}

# Callback and Logout URLs
variable "callback_urls" {
  description = "List of allowed callback URLs for OAuth flows"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for url in var.callback_urls : can(regex("^https?://", url))
    ])
    error_message = "Callback URLs must start with http:// or https://"
  }
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for url in var.logout_urls : can(regex("^https?://", url))
    ])
    error_message = "Logout URLs must start with http:// or https://"
  }
}

variable "default_redirect_uri" {
  description = "Default redirect URI (must be in callback_urls list)"
  type        = string
  default     = null
}

variable "supported_identity_providers" {
  description = "List of identity providers (COGNITO, Facebook, Google, LoginWithAmazon, SignInWithApple, SAML, OIDC)"
  type        = list(string)
  default     = ["COGNITO"]
}

# Token Validity Configuration
variable "token_validity" {
  description = "Token validity periods and units"
  type = object({
    refresh_token_validity = number
    access_token_validity  = number
    id_token_validity      = number
    refresh_token_unit     = string
    access_token_unit      = string
    id_token_unit          = string
  })
  default = {
    refresh_token_validity = 30 # 30 days
    access_token_validity  = 60 # 60 minutes
    id_token_validity      = 60 # 60 minutes
    refresh_token_unit     = "days"
    access_token_unit      = "minutes"
    id_token_unit          = "minutes"
  }

  validation {
    condition = alltrue([
      contains(["seconds", "minutes", "hours", "days"], var.token_validity.refresh_token_unit),
      contains(["seconds", "minutes", "hours", "days"], var.token_validity.access_token_unit),
      contains(["seconds", "minutes", "hours", "days"], var.token_validity.id_token_unit)
    ])
    error_message = "Token validity units must be seconds, minutes, hours, or days"
  }

  validation {
    condition = (
      var.token_validity.refresh_token_validity > 0 &&
      var.token_validity.access_token_validity > 0 &&
      var.token_validity.id_token_validity > 0
    )
    error_message = "Token validity periods must be greater than 0"
  }
}

# Read/Write Attributes
variable "read_attributes" {
  description = "List of user pool attributes the client can read"
  type        = list(string)
  default     = []
}

variable "write_attributes" {
  description = "List of user pool attributes the client can write"
  type        = list(string)
  default     = []
}

# Explicit Auth Flows
variable "explicit_auth_flows" {
  description = "List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH)"
  type        = list(string)
  default = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  validation {
    condition = alltrue([
      for flow in var.explicit_auth_flows : contains([
        "ADMIN_NO_SRP_AUTH",
        "CUSTOM_AUTH_FLOW_ONLY",
        "USER_PASSWORD_AUTH",
        "ALLOW_ADMIN_USER_PASSWORD_AUTH",
        "ALLOW_CUSTOM_AUTH",
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ], flow)
    ])
    error_message = "Explicit auth flows must be valid Cognito auth flow types"
  }
}

# Security Configuration
variable "prevent_user_existence_errors" {
  description = "Prevent user existence errors (ENABLED or LEGACY)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "LEGACY"], var.prevent_user_existence_errors)
    error_message = "Prevent user existence errors must be ENABLED or LEGACY"
  }
}

variable "enable_token_revocation" {
  description = "Enable token revocation"
  type        = bool
  default     = true
}

variable "enable_propagate_additional_user_context_data" {
  description = "Enable propagate additional user context data"
  type        = bool
  default     = false
}

variable "auth_session_validity" {
  description = "Authentication session validity in minutes (3-15)"
  type        = number
  default     = 3

  validation {
    condition     = var.auth_session_validity >= 3 && var.auth_session_validity <= 15
    error_message = "Auth session validity must be between 3 and 15 minutes"
  }
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    iam = object({
      enforce_least_privilege  = bool
      block_wildcard_resources = bool
      require_mfa_for_humans   = bool
      require_service_roles    = bool
    })
    data_protection = object({
      require_versioning         = bool
      require_mfa_delete         = bool
      require_automated_backups  = bool
      block_public_access        = bool
      require_lifecycle_policies = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    high_availability = object({
      require_multi_az           = bool
      require_multi_az_nat       = bool
      enable_cross_region_backup = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this Cognito User Pool Client.
    Only use when there's a documented business justification.
    
    Example use cases:
    - disable_token_revocation: Legacy applications that don't support token revocation
    - disable_prevent_user_existence_errors: Applications requiring legacy behavior
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_token_revocation              = optional(bool, false)
    disable_prevent_user_existence_errors = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_token_revocation              = false
    disable_prevent_user_existence_errors = false
    justification                         = ""
  }
}
