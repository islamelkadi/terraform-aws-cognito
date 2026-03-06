# Cognito Identity Pool Module Variables

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
  description = "Name of the Cognito Identity Pool"
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

# Identity Pool Configuration
variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins"
  type        = bool
  default     = false
}

variable "allow_classic_flow" {
  description = "Enables the classic / basic authentication flow"
  type        = bool
  default     = false
}

# Cognito Identity Providers (User Pools)
variable "cognito_identity_providers" {
  description = "List of Cognito User Pools to use as identity providers"
  type = list(object({
    client_id               = string
    provider_name           = string
    server_side_token_check = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for provider in var.cognito_identity_providers :
      can(regex("^cognito-idp\\.", provider.provider_name))
    ])
    error_message = "Provider name must be in format: cognito-idp.<region>.amazonaws.com/<user_pool_id>"
  }
}

# SAML Identity Providers
variable "saml_provider_arns" {
  description = "List of SAML provider ARNs"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.saml_provider_arns :
      can(regex("^arn:aws:iam::", arn))
    ])
    error_message = "SAML provider ARNs must be valid IAM SAML provider ARNs"
  }
}

# OpenID Connect Providers
variable "openid_connect_provider_arns" {
  description = "List of OpenID Connect provider ARNs"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.openid_connect_provider_arns :
      can(regex("^arn:aws:iam::", arn))
    ])
    error_message = "OpenID Connect provider ARNs must be valid IAM OIDC provider ARNs"
  }
}

# Social Identity Providers
variable "supported_login_providers" {
  description = "Map of supported login providers (e.g., accounts.google.com, graph.facebook.com)"
  type        = map(string)
  default     = {}
}


# IAM Role Configuration
variable "authenticated_role_arn" {
  description = "ARN of existing IAM role for authenticated users. If null, a new role will be created"
  type        = string
  default     = null
}

variable "unauthenticated_role_arn" {
  description = "ARN of existing IAM role for unauthenticated users. If null, a new role will be created"
  type        = string
  default     = null
}

variable "authenticated_role_policy_arns" {
  description = "Map of policy ARNs to attach to the authenticated role"
  type        = map(string)
  default     = {}
}

variable "unauthenticated_role_policy_arns" {
  description = "Map of policy ARNs to attach to the unauthenticated role"
  type        = map(string)
  default     = {}
}

# Role Mappings (Advanced)
variable "role_mappings" {
  description = "Role mappings for identity providers"
  type = list(object({
    identity_provider         = string
    ambiguous_role_resolution = optional(string, "AuthenticatedRole")
    type                      = string
    mapping_rules = optional(list(object({
      claim      = string
      match_type = string
      role_arn   = string
      value      = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for mapping in var.role_mappings :
      contains(["Token", "Rules"], mapping.type)
    ])
    error_message = "Role mapping type must be Token or Rules"
  }

  validation {
    condition = alltrue([
      for mapping in var.role_mappings :
      mapping.ambiguous_role_resolution == null || contains(["AuthenticatedRole", "Deny"], mapping.ambiguous_role_resolution)
    ])
    error_message = "Ambiguous role resolution must be AuthenticatedRole or Deny"
  }
}


# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this Cognito Identity Pool.
    Only use when there's a documented business justification.
    
    Example use cases:
    - allow_unauthenticated_access: Public applications requiring guest access
    - skip_iam_role_validation: Custom IAM role management outside Terraform
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    allow_unauthenticated_access = optional(bool, false)
    skip_iam_role_validation     = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    allow_unauthenticated_access = false
    skip_iam_role_validation     = false
    justification                = ""
  }
}
