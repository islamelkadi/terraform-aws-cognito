# Cognito User Pool Domain Module Variables

# Metadata Module Variables (for standardized naming)
variable "namespace" {
  description = "Namespace (organization name)"
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
  description = "Name of the resource"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = null
}

# User Pool Domain Configuration
variable "user_pool_id" {
  description = "ID of the Cognito User Pool"
  type        = string
}

variable "use_custom_domain" {
  description = "Whether to use a custom domain (true) or Cognito domain prefix (false)"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Custom domain name (e.g., auth.example.com). Required if use_custom_domain is true"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for custom domain. Required if use_custom_domain is true. Certificate must be in us-east-1 region"
  type        = string
  default     = null
}

variable "domain_prefix" {
  description = "Cognito domain prefix (e.g., my-app). Required if use_custom_domain is false. Must be unique across all AWS accounts"
  type        = string
  default     = null

  validation {
    condition     = var.domain_prefix == null || can(regex("^[a-z0-9](?:[a-z0-9\\-]{0,61}[a-z0-9])?$", var.domain_prefix))
    error_message = "domain_prefix must be lowercase alphanumeric with hyphens, 1-63 characters"
  }
}

# Tags
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
