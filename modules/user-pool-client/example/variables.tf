# User Pool Client Example Variables

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

variable "user_pool_id" {
  description = "Cognito User Pool ID (replace with your actual user pool ID)"
  type        = string
}

variable "callback_urls" {
  description = "List of allowed callback URLs for the client"
  type        = list(string)
  default = [
    "https://example.com/callback",
    "http://localhost:3000/callback"
  ]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the client"
  type        = list(string)
  default = [
    "https://example.com/logout",
    "http://localhost:3000/logout"
  ]
}
