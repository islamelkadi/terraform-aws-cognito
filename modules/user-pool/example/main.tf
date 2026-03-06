# Cognito User Pool Example
# Demonstrates user pool configuration with security best practices

module "user_pool" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "app-users"
  region      = var.region

  # User pool configuration
  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  # Password policy (CIS compliance requires minimum 14 characters)
  password_policy = {
    minimum_length                   = 14
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"

  # Email configuration
  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Account recovery
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  # User attributes
  user_attributes = [
    {
      name                = "email"
      attribute_data_type = "String"
      required            = true
      mutable             = true
    },
    {
      name                = "name"
      attribute_data_type = "String"
      required            = true
      mutable             = true
    }
  ]

  # Lambda triggers - replace with your actual Lambda ARNs
  lambda_triggers = var.lambda_triggers

  tags = {
    Example = "USER_POOL"
    Purpose = "AUTHENTICATION"
  }
}
