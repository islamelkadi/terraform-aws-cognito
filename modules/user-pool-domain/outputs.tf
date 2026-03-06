# Cognito User Pool Domain Module Outputs

output "domain" {
  description = "The domain name (either custom domain or Cognito domain prefix)"
  value       = aws_cognito_user_pool_domain.this.domain
}

output "cloudfront_distribution" {
  description = "The CloudFront distribution ARN for the custom domain (null for Cognito domain prefix)"
  value       = aws_cognito_user_pool_domain.this.cloudfront_distribution
}

output "cloudfront_distribution_arn" {
  description = "The CloudFront distribution ARN (alias for cloudfront_distribution)"
  value       = aws_cognito_user_pool_domain.this.cloudfront_distribution_arn
}

output "cloudfront_distribution_zone_id" {
  description = "The CloudFront distribution zone ID for Route53 alias records"
  value       = aws_cognito_user_pool_domain.this.cloudfront_distribution_zone_id
}

output "s3_bucket" {
  description = "The S3 bucket where the static files for the custom domain are stored"
  value       = aws_cognito_user_pool_domain.this.s3_bucket
}

output "version" {
  description = "The version of the domain configuration"
  value       = aws_cognito_user_pool_domain.this.version
}

output "user_pool_id" {
  description = "The ID of the associated Cognito User Pool"
  value       = aws_cognito_user_pool_domain.this.user_pool_id
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate used for the custom domain (null for Cognito domain prefix)"
  value       = var.use_custom_domain ? var.certificate_arn : null
}

output "hosted_ui_url" {
  description = "The full URL for the Cognito Hosted UI"
  value       = var.use_custom_domain ? "https://${var.custom_domain}" : "https://${var.domain_prefix}.auth.${local.region}.amazoncognito.com"
}

output "tags" {
  description = "Tags applied to the domain (note: Cognito domains don't support tags directly)"
  value       = local.tags
}
