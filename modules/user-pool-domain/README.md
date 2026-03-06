# Terraform AWS Cognito User Pool Domain Module

This module creates an AWS Cognito User Pool Domain for the Cognito Hosted UI. It supports both custom domains (with ACM certificates) and Cognito-managed domain prefixes.

## Features

- **Custom Domain Support**: Use your own domain (e.g., `auth.example.com`) with ACM certificate
- **Cognito Domain Prefix**: Use Cognito-managed domain (e.g., `my-app.auth.us-east-1.amazoncognito.com`)
- **CloudFront Integration**: Automatic CloudFront distribution for custom domains
- **Standardized Naming**: Integration with metadata module for consistent resource naming
- **Validation**: Input validation for domain formats and required parameters

## Usage

### Basic Example - Cognito Domain Prefix

```hcl
module "user_pool_domain" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-domain"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"

  user_pool_id  = module.user_pool.user_pool_id
  domain_prefix = "example-corp-actions"

  tags = {
    Project = "CorporateActions"
  }
}
```

### Custom Domain Example

```hcl
module "user_pool_domain" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-domain"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"

  user_pool_id       = module.user_pool.user_pool_id
  use_custom_domain  = true
  custom_domain      = "auth.example.com"
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"

  tags = {
    Project = "CorporateActions"
  }
}
```

## Important Notes

### Custom Domain Requirements

1. **ACM Certificate Region**: The ACM certificate MUST be in the `us-east-1` region, regardless of where your Cognito User Pool is located
2. **Certificate Validation**: The certificate must be validated and in `ISSUED` status before creating the domain
3. **DNS Configuration**: After creating the custom domain, you must create a Route53 alias record pointing to the CloudFront distribution:

```hcl
resource "aws_route53_record" "auth" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "auth.example.com"
  type    = "A"

  alias {
    name                   = module.user_pool_domain.cloudfront_distribution
    zone_id                = module.user_pool_domain.cloudfront_distribution_zone_id
    evaluate_target_health = false
  }
}
```

### Cognito Domain Prefix Requirements

1. **Global Uniqueness**: Domain prefixes must be unique across ALL AWS accounts
2. **Format**: Lowercase alphanumeric with hyphens, 1-63 characters
3. **Availability**: Check availability before applying (Terraform will fail if taken)

## Complete Example with Route53

```hcl
# ACM Certificate (must be in us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "auth" {
  provider          = aws.us_east_1
  domain_name       = "auth.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Cognito User Pool
module "user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"

  # ... other user pool configuration
}

# Cognito User Pool Domain
module "user_pool_domain" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-domain"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"

  user_pool_id      = module.user_pool.user_pool_id
  use_custom_domain = true
  custom_domain     = "auth.example.com"
  certificate_arn   = aws_acm_certificate.auth.arn

  tags = {
    Project = "CorporateActions"
  }
}

# Route53 Alias Record
resource "aws_route53_record" "auth" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "auth.example.com"
  type    = "A"

  alias {
    name                   = module.user_pool_domain.cloudfront_distribution
    zone_id                = module.user_pool_domain.cloudfront_distribution_zone_id
    evaluate_target_health = false
  }
}

# Outputs
output "hosted_ui_url" {
  value = module.user_pool_domain.hosted_ui_url
}
```

## Hosted UI URLs

After creating the domain, you can access the Cognito Hosted UI at:

**Custom Domain:**
```
https://auth.example.com/login?client_id=<client_id>&response_type=code&redirect_uri=<redirect_uri>
```

**Cognito Domain Prefix:**
```
https://my-app.auth.us-east-1.amazoncognito.com/login?client_id=<client_id>&response_type=code&redirect_uri=<redirect_uri>
```

## Troubleshooting

### Custom Domain Not Working

1. **Certificate Region**: Verify the ACM certificate is in `us-east-1`
2. **Certificate Status**: Verify the certificate is in `ISSUED` status
3. **DNS Propagation**: Wait up to 60 minutes for CloudFront distribution to deploy
4. **Route53 Record**: Verify the alias record points to the correct CloudFront distribution

### Domain Prefix Already Taken

If you receive an error that the domain prefix is already taken:
1. Choose a different, more unique prefix
2. Add your organization name or random suffix
3. Check AWS Console to verify availability

## Security Considerations

- Custom domains use CloudFront with TLS 1.2+ by default
- Cognito domain prefixes use AWS-managed certificates
- All traffic is encrypted in transit
- Domain resources don't support tags directly (limitation of AWS Cognito)

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Custom domain with ACM | Optional | Recommended | Required |
| HTTPS enforcement | Required | Required | Required |
| CloudFront distribution | Optional | Recommended | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of ACM certificate for custom domain. Required if use\_custom\_domain is true. Certificate must be in us-east-1 region | `string` | `null` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Custom domain name (e.g., auth.example.com). Required if use\_custom\_domain is true | `string` | `null` | no |
| <a name="input_domain_prefix"></a> [domain\_prefix](#input\_domain\_prefix) | Cognito domain prefix (e.g., my-app). Required if use\_custom\_domain is false. Must be unique across all AWS accounts | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_use_custom_domain"></a> [use\_custom\_domain](#input\_use\_custom\_domain) | Whether to use a custom domain (true) or Cognito domain prefix (false) | `bool` | `false` | no |
| <a name="input_user_pool_id"></a> [user\_pool\_id](#input\_user\_pool\_id) | ID of the Cognito User Pool | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | The ARN of the ACM certificate used for the custom domain (null for Cognito domain prefix) |
| <a name="output_cloudfront_distribution"></a> [cloudfront\_distribution](#output\_cloudfront\_distribution) | The CloudFront distribution ARN for the custom domain (null for Cognito domain prefix) |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The CloudFront distribution ARN (alias for cloudfront\_distribution) |
| <a name="output_cloudfront_distribution_zone_id"></a> [cloudfront\_distribution\_zone\_id](#output\_cloudfront\_distribution\_zone\_id) | The CloudFront distribution zone ID for Route53 alias records |
| <a name="output_domain"></a> [domain](#output\_domain) | The domain name (either custom domain or Cognito domain prefix) |
| <a name="output_hosted_ui_url"></a> [hosted\_ui\_url](#output\_hosted\_ui\_url) | The full URL for the Cognito Hosted UI |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | The S3 bucket where the static files for the custom domain are stored |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the domain (note: Cognito domains don't support tags directly) |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the associated Cognito User Pool |
| <a name="output_version"></a> [version](#output\_version) | The version of the domain configuration |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
