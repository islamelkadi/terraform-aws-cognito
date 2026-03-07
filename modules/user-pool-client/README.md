# Terraform AWS Cognito User Pool Client Module

This module creates an AWS Cognito User Pool Client for application integration with OAuth 2.0 and OpenID Connect support.

## Features

- **OAuth 2.0 Support**: Authorization code, implicit, and client credentials flows
- **Token Management**: Configurable token validity periods for access, ID, and refresh tokens
- **Security Best Practices**: Token revocation, user existence error prevention, HTTPS enforcement
- **Flexible Authentication**: Multiple auth flows and identity provider support
- **Attribute Control**: Configurable read/write permissions for user attributes
- **Security Controls**: Extensible override system with audit justification

## Security

### Security Controls

This module enforces security controls from the metadata module:

- **Token Revocation**: Enabled by default (can be overridden with justification)
- **User Existence Errors**: Prevention enabled by default
- **HTTPS Enforcement**: Required for production callback/logout URLs
- **Token Validity Limits**: Enforced reasonable token lifetimes
- **OAuth Flow Restrictions**: Implicit flow discouraged in production

### Overriding Security Controls

When you need to disable security controls (e.g., for development), provide justification:

```hcl
security_control_overrides = {
  disable_token_revocation = true
  justification            = "Development environment - simplified testing"
}
```

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Token revocation | Optional | Enabled | Enabled |
| HTTPS callback URLs | Recommended | Required | Required |
| PKCE for public clients | Recommended | Required | Required |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.
## Usage

### Basic Example

```hcl
module "user_pool_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "prod"
  name        = "web-app"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  # OAuth configuration
  oauth_flows  = ["code"]
  oauth_scopes = ["openid", "email", "profile"]

  callback_urls = ["https://app.example.com/callback"]
  logout_urls   = ["https://app.example.com/logout"]
}
```

### Server-Side Application (with Client Secret)

```hcl
module "server_app_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "prod"
  name        = "api-server"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  # Generate client secret for server-side apps
  generate_secret = true

  # Authorization code flow (most secure)
  oauth_flows  = ["code"]
  oauth_scopes = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]

  callback_urls = ["https://api.example.com/oauth/callback"]
  logout_urls   = ["https://api.example.com/logout"]

  # Token validity
  token_validity = {
    refresh_token_validity = 30    # 30 days
    access_token_validity  = 60    # 60 minutes
    id_token_validity      = 60    # 60 minutes
    refresh_token_unit     = "days"
    access_token_unit      = "minutes"
    id_token_unit          = "minutes"
  }
}
```

### Single Page Application (SPA)

```hcl
module "spa_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "dev"
  name        = "dashboard-spa"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  # No client secret for public clients
  generate_secret = false

  # Authorization code flow with PKCE (recommended for SPAs)
  oauth_flows  = ["code"]
  oauth_scopes = ["openid", "email", "profile"]

  callback_urls = [
    "http://localhost:3000/callback",  # Dev
    "https://dashboard.example.com/callback"
  ]
  logout_urls = [
    "http://localhost:3000/",
    "https://dashboard.example.com/"
  ]

  # Explicit auth flows for SPA
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Shorter token validity for public clients
  token_validity = {
    refresh_token_validity = 7     # 7 days
    access_token_validity  = 30    # 30 minutes
    id_token_validity      = 30    # 30 minutes
    refresh_token_unit     = "days"
    access_token_unit      = "minutes"
    id_token_unit          = "minutes"
  }
}
```

### Machine-to-Machine (M2M) Client

```hcl
module "m2m_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "prod"
  name        = "batch-processor"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  # Client credentials flow for M2M
  generate_secret = true
  oauth_flows     = ["client_credentials"]
  oauth_scopes    = ["aws.cognito.signin.user.admin"]

  # No callback/logout URLs needed for M2M
  callback_urls = []
  logout_urls   = []

  # Explicit auth flows
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}
```

### Custom Attribute Permissions

```hcl
module "custom_attrs_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "prod"
  name        = "admin-portal"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  oauth_flows  = ["code"]
  oauth_scopes = ["openid", "email", "profile"]

  callback_urls = ["https://admin.example.com/callback"]
  logout_urls   = ["https://admin.example.com/logout"]

  # Control which attributes the client can read/write
  read_attributes = [
    "email",
    "email_verified",
    "name",
    "phone_number",
    "custom:account_type",
    "custom:customer_id"
  ]

  write_attributes = [
    "name",
    "phone_number",
    "custom:account_type"
  ]
}
```

### Security Control Overrides (Development Environment)

```hcl
module "dev_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  namespace   = "example"
  environment = "dev"
  name        = "test-client"
  region      = "us-east-1"

  user_pool_id = module.user_pool.user_pool_id

  oauth_flows  = ["code", "implicit"]  # Allow implicit for testing
  oauth_scopes = ["openid", "email"]

  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/"]

  # Override security controls for development
  security_control_overrides = {
    disable_token_revocation              = true
    disable_prevent_user_existence_errors = false
    justification                         = "Development environment - simplified testing without token revocation complexity"
  }
}
```

## OAuth Flows

### Authorization Code Flow (Recommended)

Most secure flow for web and mobile applications. Requires client secret for server-side apps.

```hcl
oauth_flows = ["code"]
generate_secret = true  # For server-side apps
```

### Implicit Flow (Not Recommended for Production)

Legacy flow for SPAs. Use authorization code flow with PKCE instead.

```hcl
oauth_flows = ["implicit"]
generate_secret = false
```

### Client Credentials Flow (M2M)

For machine-to-machine authentication without user context.

```hcl
oauth_flows = ["client_credentials"]
generate_secret = true
```

## Security Best Practices

1. **Use Authorization Code Flow**: Most secure for web and mobile apps
2. **Enable Token Revocation**: Allows invalidating tokens when needed
3. **Use HTTPS**: All callback and logout URLs should use HTTPS in production
4. **Limit Token Validity**: Shorter tokens reduce exposure window
5. **Prevent User Existence Errors**: Avoid leaking user information
6. **Generate Client Secret**: For server-side applications only
7. **Limit Scopes**: Only request necessary OAuth scopes
8. **Control Attributes**: Restrict read/write permissions to required attributes

## Integration with User Pool

This module requires an existing Cognito User Pool. Use with the user-pool module:

```hcl
module "user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"
  # ... user pool configuration
}

module "user_pool_client" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool-client"

  user_pool_id = module.user_pool.user_pool_id
  # ... client configuration
}
```

## References

- [AWS Cognito User Pool Clients](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html)
- [OAuth 2.0 Flows](https://oauth.net/2/)
- [OpenID Connect](https://openid.net/connect/)
- [PKCE for OAuth Public Clients](https://oauth.net/2/pkce/)

<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
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
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_auth_session_validity"></a> [auth\_session\_validity](#input\_auth\_session\_validity) | Authentication session validity in minutes (3-15) | `number` | `3` | no |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | List of allowed callback URLs for OAuth flows | `list(string)` | `[]` | no |
| <a name="input_default_redirect_uri"></a> [default\_redirect\_uri](#input\_default\_redirect\_uri) | Default redirect URI (must be in callback\_urls list) | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_enable_propagate_additional_user_context_data"></a> [enable\_propagate\_additional\_user\_context\_data](#input\_enable\_propagate\_additional\_user\_context\_data) | Enable propagate additional user context data | `bool` | `false` | no |
| <a name="input_enable_token_revocation"></a> [enable\_token\_revocation](#input\_enable\_token\_revocation) | Enable token revocation | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_explicit_auth_flows"></a> [explicit\_auth\_flows](#input\_explicit\_auth\_flows) | List of authentication flows (ADMIN\_NO\_SRP\_AUTH, CUSTOM\_AUTH\_FLOW\_ONLY, USER\_PASSWORD\_AUTH, ALLOW\_ADMIN\_USER\_PASSWORD\_AUTH, ALLOW\_CUSTOM\_AUTH, ALLOW\_USER\_PASSWORD\_AUTH, ALLOW\_USER\_SRP\_AUTH, ALLOW\_REFRESH\_TOKEN\_AUTH) | `list(string)` | <pre>[<br/>  "ALLOW_USER_SRP_AUTH",<br/>  "ALLOW_REFRESH_TOKEN_AUTH"<br/>]</pre> | no |
| <a name="input_generate_secret"></a> [generate\_secret](#input\_generate\_secret) | Generate a client secret for server-side applications (required for authorization code flow) | `bool` | `false` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | List of allowed logout URLs | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cognito User Pool Client | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_oauth_flows"></a> [oauth\_flows](#input\_oauth\_flows) | List of allowed OAuth flows (code, implicit, client\_credentials) | `list(string)` | <pre>[<br/>  "code"<br/>]</pre> | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | List of allowed OAuth scopes (phone, email, openid, profile, aws.cognito.signin.user.admin) | `list(string)` | <pre>[<br/>  "openid",<br/>  "email",<br/>  "profile"<br/>]</pre> | no |
| <a name="input_prevent_user_existence_errors"></a> [prevent\_user\_existence\_errors](#input\_prevent\_user\_existence\_errors) | Prevent user existence errors (ENABLED or LEGACY) | `string` | `"ENABLED"` | no |
| <a name="input_read_attributes"></a> [read\_attributes](#input\_read\_attributes) | List of user pool attributes the client can read | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this Cognito User Pool Client.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_token\_revocation: Legacy applications that don't support token revocation<br/>- disable\_prevent\_user\_existence\_errors: Applications requiring legacy behavior<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_token_revocation              = optional(bool, false)<br/>    disable_prevent_user_existence_errors = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_prevent_user_existence_errors": false,<br/>  "disable_token_revocation": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    iam = object({<br/>      enforce_least_privilege  = bool<br/>      block_wildcard_resources = bool<br/>      require_mfa_for_humans   = bool<br/>      require_service_roles    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning         = bool<br/>      require_mfa_delete         = bool<br/>      require_automated_backups  = bool<br/>      block_public_access        = bool<br/>      require_lifecycle_policies = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    high_availability = object({<br/>      require_multi_az           = bool<br/>      require_multi_az_nat       = bool<br/>      enable_cross_region_backup = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_supported_identity_providers"></a> [supported\_identity\_providers](#input\_supported\_identity\_providers) | List of identity providers (COGNITO, Facebook, Google, LoginWithAmazon, SignInWithApple, SAML, OIDC) | `list(string)` | <pre>[<br/>  "COGNITO"<br/>]</pre> | no |
| <a name="input_token_validity"></a> [token\_validity](#input\_token\_validity) | Token validity periods and units | <pre>object({<br/>    refresh_token_validity = number<br/>    access_token_validity  = number<br/>    id_token_validity      = number<br/>    refresh_token_unit     = string<br/>    access_token_unit      = string<br/>    id_token_unit          = string<br/>  })</pre> | <pre>{<br/>  "access_token_unit": "minutes",<br/>  "access_token_validity": 60,<br/>  "id_token_unit": "minutes",<br/>  "id_token_validity": 60,<br/>  "refresh_token_unit": "days",<br/>  "refresh_token_validity": 30<br/>}</pre> | no |
| <a name="input_user_pool_id"></a> [user\_pool\_id](#input\_user\_pool\_id) | ID of the Cognito User Pool to create the client for | `string` | n/a | yes |
| <a name="input_write_attributes"></a> [write\_attributes](#input\_write\_attributes) | List of user pool attributes the client can write | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allowed_oauth_flows"></a> [allowed\_oauth\_flows](#output\_allowed\_oauth\_flows) | List of allowed OAuth flows |
| <a name="output_allowed_oauth_scopes"></a> [allowed\_oauth\_scopes](#output\_allowed\_oauth\_scopes) | List of allowed OAuth scopes |
| <a name="output_callback_urls"></a> [callback\_urls](#output\_callback\_urls) | List of allowed callback URLs |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | ID of the Cognito User Pool Client |
| <a name="output_client_name"></a> [client\_name](#output\_client\_name) | Name of the Cognito User Pool Client |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Client secret (only available if generate\_secret is true). Marked as sensitive. |
| <a name="output_logout_urls"></a> [logout\_urls](#output\_logout\_urls) | List of allowed logout URLs |
| <a name="output_supported_identity_providers"></a> [supported\_identity\_providers](#output\_supported\_identity\_providers) | List of supported identity providers |
| <a name="output_token_validity"></a> [token\_validity](#output\_token\_validity) | Token validity configuration |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | ID of the associated Cognito User Pool |

## Example

See [example/](example/) for a complete working example with all features.

