# Terraform AWS Cognito Identity Pool Module

This module creates an AWS Cognito Identity Pool for federated identities with IAM role management, supporting authenticated and unauthenticated access patterns.

## Features

- **Federated Identities**: Support for Cognito User Pools, SAML, OpenID Connect, and social identity providers
- **IAM Role Management**: Automatic creation and attachment of IAM roles for authenticated and unauthenticated users
- **Role Mappings**: Advanced role mapping rules for fine-grained access control
- **Unauthenticated Access**: Optional guest access with dedicated IAM role
- **Bring Your Own Roles**: Support for existing IAM roles or auto-created ones
- **Security Controls**: Extensible override system with audit justification

## Security

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Unauthenticated access | Allowed (with override) | Restricted | Restricted |
| IAM role validation | Relaxed | Enforced | Enforced |
| Classic auth flow | Allowed | Discouraged | Discouraged |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.

### Security Control Overrides

The module supports selective disabling of security controls with documented justification:

```hcl
security_control_overrides = {
  allow_unauthenticated_access = true
  justification                = "Public application requiring guest access for read-only content"
}
```

| Override | Use Case | Example Justification |
|----------|----------|----------------------|
| `allow_unauthenticated_access` | Public/guest access | "Application requires guest access for read-only content" |
| `skip_iam_role_validation` | Custom IAM management | "IAM roles managed externally by security team" |

## Usage

### Basic Example

```hcl
module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/identity-pool"

  namespace   = "example"
  environment = "prod"
  name        = "app-identities"
  region      = "us-east-1"

  # Cognito User Pool as identity provider
  cognito_identity_providers = [
    {
      client_id               = module.user_pool_client.client_id
      provider_name           = module.user_pool.user_pool_endpoint
      server_side_token_check = true
    }
  ]

  # Attach policies to authenticated role
  authenticated_role_policy_arns = {
    s3_read = "arn:aws:iam::123456789012:policy/S3ReadOnly"
  }

  tags = {
    Project = "MyApp"
  }
}
```

### With Unauthenticated (Guest) Access

```hcl
module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/identity-pool"

  namespace   = "example"
  environment = "dev"
  name        = "app-identities"
  region      = "us-east-1"

  allow_unauthenticated_identities = true
  allow_classic_flow               = false

  cognito_identity_providers = [
    {
      client_id               = module.user_pool_client.client_id
      provider_name           = module.user_pool.user_pool_endpoint
      server_side_token_check = true
    }
  ]

  authenticated_role_policy_arns = {
    s3_read = "arn:aws:iam::123456789012:policy/S3ReadOnly"
  }

  unauthenticated_role_policy_arns = {
    s3_public = "arn:aws:iam::123456789012:policy/S3PublicRead"
  }

  security_control_overrides = {
    allow_unauthenticated_access = true
    justification                = "Application requires guest access for read-only content and demo features."
  }

  tags = {
    Project = "MyApp"
  }
}
```

### With Existing IAM Roles

```hcl
module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/identity-pool"

  namespace   = "example"
  environment = "prod"
  name        = "app-identities"
  region      = "us-east-1"

  cognito_identity_providers = [
    {
      client_id               = module.user_pool_client.client_id
      provider_name           = module.user_pool.user_pool_endpoint
      server_side_token_check = true
    }
  ]

  # Use existing IAM roles instead of creating new ones
  authenticated_role_arn   = "arn:aws:iam::123456789012:role/CognitoAuthRole"
  unauthenticated_role_arn = "arn:aws:iam::123456789012:role/CognitoUnauthRole"

  tags = {
    Project = "MyApp"
  }
}
```

## Integration with User Pool

This module works alongside the user-pool and user-pool-client modules:

```hcl
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/user-pool"
  # ... user pool configuration
}

module "user_pool_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/user-pool-client"

  user_pool_id = module.user_pool.user_pool_id
  # ... client configuration
}

module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito//modules/identity-pool"

  cognito_identity_providers = [
    {
      client_id               = module.user_pool_client.client_id
      provider_name           = module.user_pool.user_pool_endpoint
      server_side_token_check = true
    }
  ]
  # ... identity pool configuration
}
```

## Best Practices

1. **Disable Unauthenticated Access**: Keep `allow_unauthenticated_identities = false` unless guest access is required
2. **Use Server-Side Token Check**: Enable `server_side_token_check` for Cognito providers
3. **Least Privilege Policies**: Attach minimal IAM policies to authenticated and unauthenticated roles
4. **Disable Classic Flow**: Keep `allow_classic_flow = false` unless legacy integration requires it
5. **Document Overrides**: Always provide justification when overriding security controls
6. **Use Role Mappings**: For multi-tenant apps, use role mappings for fine-grained access control


<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_identity_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_iam_role.authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.unauthenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.unauthenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.authenticated_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.unauthenticated_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_classic_flow"></a> [allow\_classic\_flow](#input\_allow\_classic\_flow) | Enables the classic / basic authentication flow | `bool` | `false` | no |
| <a name="input_allow_unauthenticated_identities"></a> [allow\_unauthenticated\_identities](#input\_allow\_unauthenticated\_identities) | Whether the identity pool supports unauthenticated logins | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_authenticated_role_arn"></a> [authenticated\_role\_arn](#input\_authenticated\_role\_arn) | ARN of existing IAM role for authenticated users. If null, a new role will be created | `string` | `null` | no |
| <a name="input_authenticated_role_policy_arns"></a> [authenticated\_role\_policy\_arns](#input\_authenticated\_role\_policy\_arns) | Map of policy ARNs to attach to the authenticated role | `map(string)` | `{}` | no |
| <a name="input_cognito_identity_providers"></a> [cognito\_identity\_providers](#input\_cognito\_identity\_providers) | List of Cognito User Pools to use as identity providers | <pre>list(object({<br/>    client_id               = string<br/>    provider_name           = string<br/>    server_side_token_check = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cognito Identity Pool | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_openid_connect_provider_arns"></a> [openid\_connect\_provider\_arns](#input\_openid\_connect\_provider\_arns) | List of OpenID Connect provider ARNs | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_role_mappings"></a> [role\_mappings](#input\_role\_mappings) | Role mappings for identity providers | <pre>list(object({<br/>    identity_provider         = string<br/>    ambiguous_role_resolution = optional(string, "AuthenticatedRole")<br/>    type                      = string<br/>    mapping_rules = optional(list(object({<br/>      claim      = string<br/>      match_type = string<br/>      role_arn   = string<br/>      value      = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_saml_provider_arns"></a> [saml\_provider\_arns](#input\_saml\_provider\_arns) | List of SAML provider ARNs | `list(string)` | `[]` | no |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this Cognito Identity Pool.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- allow\_unauthenticated\_access: Public applications requiring guest access<br/>- skip\_iam\_role\_validation: Custom IAM role management outside Terraform<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    allow_unauthenticated_access = optional(bool, false)<br/>    skip_iam_role_validation     = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "allow_unauthenticated_access": false,<br/>  "justification": "",<br/>  "skip_iam_role_validation": false<br/>}</pre> | no |
| <a name="input_supported_login_providers"></a> [supported\_login\_providers](#input\_supported\_login\_providers) | Map of supported login providers (e.g., accounts.google.com, graph.facebook.com) | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_unauthenticated_role_arn"></a> [unauthenticated\_role\_arn](#input\_unauthenticated\_role\_arn) | ARN of existing IAM role for unauthenticated users. If null, a new role will be created | `string` | `null` | no |
| <a name="input_unauthenticated_role_policy_arns"></a> [unauthenticated\_role\_policy\_arns](#input\_unauthenticated\_role\_policy\_arns) | Map of policy ARNs to attach to the unauthenticated role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authenticated_role_arn"></a> [authenticated\_role\_arn](#output\_authenticated\_role\_arn) | ARN of the IAM role for authenticated users |
| <a name="output_authenticated_role_name"></a> [authenticated\_role\_name](#output\_authenticated\_role\_name) | Name of the IAM role for authenticated users |
| <a name="output_identity_pool_arn"></a> [identity\_pool\_arn](#output\_identity\_pool\_arn) | ARN of the Cognito Identity Pool |
| <a name="output_identity_pool_id"></a> [identity\_pool\_id](#output\_identity\_pool\_id) | ID of the Cognito Identity Pool |
| <a name="output_identity_pool_name"></a> [identity\_pool\_name](#output\_identity\_pool\_name) | Name of the Cognito Identity Pool |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Cognito Identity Pool |
| <a name="output_unauthenticated_role_arn"></a> [unauthenticated\_role\_arn](#output\_unauthenticated\_role\_arn) | ARN of the IAM role for unauthenticated users |
| <a name="output_unauthenticated_role_name"></a> [unauthenticated\_role\_name](#output\_unauthenticated\_role\_name) | Name of the IAM role for unauthenticated users |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
