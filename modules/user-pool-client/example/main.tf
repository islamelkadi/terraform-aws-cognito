# Cognito User Pool Client Example
# Demonstrates client configuration for web applications

module "user_pool_client" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "web-app"
  region      = var.region

  # User pool ID - replace with your actual user pool ID
  user_pool_id = var.user_pool_id

  # Client secret for server-side applications
  generate_secret = true

  # OAuth configuration
  oauth_flows = ["code"]
  oauth_scopes = [
    "openid",
    "email",
    "profile",
    "aws.cognito.signin.user.admin"
  ]

  # Callback and logout URLs - replace with your actual URLs
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Token validity
  token_validity = {
    access_token_validity  = 60 # minutes
    id_token_validity      = 60 # minutes
    refresh_token_validity = 30 # days
    access_token_unit      = "minutes"
    id_token_unit          = "minutes"
    refresh_token_unit     = "days"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"
}
