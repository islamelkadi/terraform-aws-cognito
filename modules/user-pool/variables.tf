# Cognito User Pool Module Variables

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
  description = "Name of the Cognito User Pool"
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

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Password Policy Configuration (CIS Benchmark compliant)
variable "password_policy" {
  description = "Password policy configuration for the user pool"
  type = object({
    minimum_length                   = number
    require_lowercase                = bool
    require_uppercase                = bool
    require_numbers                  = bool
    require_symbols                  = bool
    temporary_password_validity_days = number
  })
  default = {
    minimum_length                   = 14 # CIS Benchmark requirement
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  validation {
    condition     = var.password_policy.minimum_length >= 14
    error_message = "Password minimum length must be at least 14 characters for CIS compliance"
  }
}

# MFA Configuration
variable "mfa_configuration" {
  description = "Multi-factor authentication configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL"
  }
}

# Email Verification Configuration
variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified (email, phone_number)"
  type        = list(string)
  default     = ["email"]

  validation {
    condition = alltrue([
      for attr in var.auto_verified_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Auto-verified attributes must be email or phone_number"
  }
}

variable "email_configuration" {
  description = "Email configuration for the user pool"
  type = object({
    email_sending_account  = string
    source_arn             = optional(string)
    from_email_address     = optional(string)
    reply_to_email_address = optional(string)
  })
  default = {
    email_sending_account  = "COGNITO_DEFAULT"
    source_arn             = null
    from_email_address     = null
    reply_to_email_address = null
  }

  validation {
    condition     = contains(["COGNITO_DEFAULT", "DEVELOPER"], var.email_configuration.email_sending_account)
    error_message = "Email sending account must be COGNITO_DEFAULT or DEVELOPER"
  }
}

variable "verification_message_template" {
  description = "Verification message template configuration"
  type = object({
    default_email_option  = string
    email_subject         = optional(string)
    email_message         = optional(string)
    email_subject_by_link = optional(string)
    email_message_by_link = optional(string)
    sms_message           = optional(string)
  })
  default = {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_subject         = "Your verification code"
    email_message         = "Your verification code is {####}"
    email_subject_by_link = "Your verification link"
    email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}"
    sms_message           = "Your verification code is {####}"
  }

  validation {
    condition     = contains(["CONFIRM_WITH_CODE", "CONFIRM_WITH_LINK"], var.verification_message_template.default_email_option)
    error_message = "Default email option must be CONFIRM_WITH_CODE or CONFIRM_WITH_LINK"
  }
}

# Account Recovery Settings
variable "account_recovery_mechanisms" {
  description = "Account recovery mechanisms configuration"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  validation {
    condition = alltrue([
      for mechanism in var.account_recovery_mechanisms : contains(["verified_email", "verified_phone_number", "admin_only"], mechanism.name)
    ])
    error_message = "Recovery mechanism name must be verified_email, verified_phone_number, or admin_only"
  }
}

# User Attributes Schema
variable "user_attributes" {
  description = "User attribute schema configuration (email, name, custom attributes)"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    required                 = optional(bool, false)
    min_length               = optional(number)
    max_length               = optional(number)
    min_value                = optional(number)
    max_value                = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for attr in var.user_attributes : contains(["String", "Number", "DateTime", "Boolean"], attr.attribute_data_type)
    ])
    error_message = "Attribute data type must be String, Number, DateTime, or Boolean"
  }
}

# Lambda Triggers
variable "lambda_triggers" {
  description = "Lambda function ARNs for Cognito triggers (pre-signup, post-confirmation, etc.)"
  type        = map(string)
  default     = {}
}

# Advanced Security Mode
variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED"
  }
}

# Username Configuration
variable "username_attributes" {
  description = "Attributes that can be used as username (email, phone_number)"
  type        = list(string)
  default     = ["email"]

  validation {
    condition = alltrue([
      for attr in var.username_attributes : contains(["email", "phone_number"], attr)
    ])
    error_message = "Username attributes must be email or phone_number"
  }
}

variable "alias_attributes" {
  description = "Attributes that can be used as aliases (email, phone_number, preferred_username)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for attr in var.alias_attributes : contains(["email", "phone_number", "preferred_username"], attr)
    ])
    error_message = "Alias attributes must be email, phone_number, or preferred_username"
  }
}

variable "username_case_sensitive" {
  description = "Whether username is case sensitive"
  type        = bool
  default     = false
}

# Admin Create User Configuration
variable "allow_admin_create_user_only" {
  description = "Only allow administrators to create user profiles"
  type        = bool
  default     = false
}

variable "invite_message_template" {
  description = "Invite message template for admin-created users"
  type = object({
    email_subject = string
    email_message = string
    sms_message   = string
  })
  default = {
    email_subject = "Your temporary password"
    email_message = "Your username is {username} and temporary password is {####}."
    sms_message   = "Your username is {username} and temporary password is {####}."
  }
}

# Device Configuration
variable "device_configuration" {
  description = "Device tracking configuration"
  type = object({
    challenge_required_on_new_device      = bool
    device_only_remembered_on_user_prompt = bool
  })
  default = {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }
}

# Deletion Protection
variable "enable_deletion_protection" {
  description = "Enable deletion protection for the user pool"
  type        = bool
  default     = true
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
    Override specific security controls for this Cognito User Pool.
    Only use when there's a documented business justification.

    Example use cases:
    - disable_deletion_protection: Dev/test user pools that are disposable
    - disable_advanced_security: Cost optimization in non-production
    - disable_mfa_requirement: Demo environments with simplified auth
    - disable_password_complexity: Testing environments with simplified passwords

    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_deletion_protection = optional(bool, false)
    disable_advanced_security   = optional(bool, false)
    disable_mfa_requirement     = optional(bool, false)
    disable_password_complexity = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_deletion_protection = false
    disable_advanced_security   = false
    disable_mfa_requirement     = false
    disable_password_complexity = false
    justification               = ""
  }
}
