# Cognito User Pool Domain Module
# Creates AWS Cognito User Pool Domain for hosted UI

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "this" {
  domain          = var.use_custom_domain ? var.custom_domain : var.domain_prefix
  user_pool_id    = var.user_pool_id
  certificate_arn = var.use_custom_domain ? var.certificate_arn : null
}
