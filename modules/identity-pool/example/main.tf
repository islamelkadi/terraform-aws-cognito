# Cognito Identity Pool Example
# Demonstrates identity pool configuration with authenticated and unauthenticated access

module "identity_pool" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "app-identities"
  region      = var.region

  # Enable unauthenticated access for guest users
  allow_unauthenticated_identities = true
  allow_classic_flow               = false

  # Cognito User Pool as identity provider - replace with your actual values
  cognito_identity_providers = [
    {
      client_id               = var.cognito_client_id
      provider_name           = var.cognito_provider_name
      server_side_token_check = true
    }
  ]

  # Attach policies to authenticated role - replace with your actual policy ARNs
  authenticated_role_policy_arns = var.authenticated_role_policy_arns

  # Attach limited policies to unauthenticated role
  unauthenticated_role_policy_arns = var.unauthenticated_role_policy_arns

  # Override security controls with justification
  security_control_overrides = {
    allow_unauthenticated_access = true
    justification                = "Application requires guest access for read-only content and demo features."
  }

  tags = {
    Example = "IDENTITY_POOL"
    Purpose = "AUTHORIZATION"
  }
}
