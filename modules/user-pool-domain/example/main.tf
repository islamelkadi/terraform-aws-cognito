# Cognito User Pool Domain Example
# Demonstrates Cognito-hosted domain (simplest setup)

# ============================================================================
# Example 1: Cognito-Hosted Domain (Simplest)
# Uses the default Cognito domain prefix - no ACM certificate needed
# ============================================================================

module "user_pool_domain" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "auth"
  region      = var.region

  # Replace with your actual Cognito User Pool ID
  user_pool_id = var.user_pool_id

  # Use Cognito-hosted domain (no custom domain)
  use_custom_domain = false
  domain_prefix     = "example-auth-dev"

  tags = {
    Example = "COGNITO_DOMAIN"
    Purpose = "AUTHENTICATION"
  }
}
