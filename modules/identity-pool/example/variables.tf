# Identity Pool Example Variables

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cognito_client_id" {
  description = "Cognito User Pool Client ID (replace with your actual client ID)"
  type        = string
}

variable "cognito_provider_name" {
  description = "Cognito User Pool provider name (e.g., cognito-idp.us-east-1.amazonaws.com/us-east-1_ABC123)"
  type        = string
}

variable "authenticated_role_policy_arns" {
  description = "Map of IAM policy ARNs to attach to the authenticated role"
  type        = map(string)
  default     = {}
}

variable "unauthenticated_role_policy_arns" {
  description = "Map of IAM policy ARNs to attach to the unauthenticated role"
  type        = map(string)
  default     = {}
}
