# Cognito User Pool Client Module
# Creates AWS Cognito User Pool Client for application integration

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "this" {
  name         = local.client_name
  user_pool_id = var.user_pool_id

  # Generate client secret for server-side applications
  generate_secret = var.generate_secret

  # Refresh token validity
  refresh_token_validity = var.token_validity.refresh_token_validity
  access_token_validity  = var.token_validity.access_token_validity
  id_token_validity      = var.token_validity.id_token_validity

  # Token validity units
  token_validity_units {
    refresh_token = var.token_validity.refresh_token_unit
    access_token  = var.token_validity.access_token_unit
    id_token      = var.token_validity.id_token_unit
  }

  # OAuth Configuration
  allowed_oauth_flows                  = var.oauth_flows
  allowed_oauth_flows_user_pool_client = length(var.oauth_flows) > 0 ? true : false
  allowed_oauth_scopes                 = var.oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  default_redirect_uri                 = var.default_redirect_uri
  supported_identity_providers         = var.supported_identity_providers

  # Read/Write Attributes
  read_attributes  = var.read_attributes
  write_attributes = var.write_attributes

  # Explicit auth flows
  explicit_auth_flows = var.explicit_auth_flows

  # Prevent user existence errors
  prevent_user_existence_errors = var.prevent_user_existence_errors

  # Enable token revocation
  enable_token_revocation = var.enable_token_revocation

  # Enable propagate additional user context data
  enable_propagate_additional_user_context_data = var.enable_propagate_additional_user_context_data

  # Auth session validity
  auth_session_validity = var.auth_session_validity
}
