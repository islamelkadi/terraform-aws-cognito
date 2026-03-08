# Terraform AWS Cognito Authentication Module

Comprehensive Terraform module for AWS Cognito authentication infrastructure with security best practices, CIS Benchmark compliance, and production-ready configurations.

## Overview

This module provides a complete Cognito authentication solution with four sub-modules that work together to create a secure, scalable authentication system:

1. **User Pool** - Core authentication with password policies, MFA, and user management
2. **User Pool Client** - OAuth 2.0/OIDC application integration
3. **User Pool Domain** - Hosted UI with custom or Cognito-managed domains
4. **Identity Pool** - Federated identity and AWS credential management

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [MCP Servers](#mcp-servers)

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security

### Security Controls

This module implements security controls to comply with:
- AWS Foundational Security Best Practices (FSBP)
- CIS AWS Foundations Benchmark
- NIST 800-53 Rev 5
- NIST 800-171 Rev 2
- PCI DSS v4.0

### Implemented Controls

- [x] **Password Policy**: CIS-compliant (14+ chars, complexity requirements)
- [x] **Multi-Factor Authentication**: TOTP-based MFA support
- [x] **Advanced Security**: Threat detection and risk-based authentication
- [x] **Deletion Protection**: Prevents accidental user pool deletion
- [x] **Token Security**: Configurable token validity and revocation
- [x] **Encryption**: Data encrypted at rest and in transit
- [x] **Account Recovery**: Email and phone-based recovery mechanisms
- [x] **Security Control Overrides**: Extensible override system with audit justification

### Security Best Practices

**Production User Pools:**
- Enable MFA (at least OPTIONAL mode)
- Use CIS-compliant password policy (14+ chars)
- Enable advanced security mode (ENFORCED)
- Enable deletion protection
- Configure account recovery mechanisms
- Use custom domains for better branding and security

**Development User Pools:**
- Relaxed password policies acceptable with justification
- MFA optional for testing
- Deletion protection can be disabled

For complete security standards and implementation details, see [AWS Security Standards](../../../.kiro/steering/aws/aws-security-standards.md).

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Password policy (CIS) | Relaxed | CIS-compliant (14+ chars) | CIS-compliant (14+ chars) |
| MFA | OFF | OPTIONAL | OPTIONAL/ON |
| Advanced security mode | AUDIT | ENFORCED | ENFORCED |
| Deletion protection | Disabled | Enabled | Enabled |
| Token revocation | Optional | Enabled | Enabled |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.

### Security Scan Suppressions

This module suppresses certain Checkov security checks that are either not applicable to example/demo code or represent optional features. The following checks are suppressed in `.checkov.yaml`:

**Module Source Versioning (CKV_TF_1, CKV_TF_2)**
- Suppressed because we use semantic version tags (`?ref=v1.0.0`) instead of commit hashes for better maintainability and readability
- Semantic versioning is a valid and widely-accepted versioning strategy for stable releases

**Cognito Optional Features**
- **Unauthenticated Access (CKV_AWS_366)**: Unauthenticated guest access is use-case specific; some applications require public access; users should disable if not needed

## Features

- **CIS Benchmark Compliant**: Password policies and security controls meet CIS AWS Foundations Benchmark
- **OAuth 2.0 & OpenID Connect**: Full support for modern authentication flows
- **Multi-Factor Authentication**: TOTP-based MFA with optional enforcement
- **Hosted UI**: Customizable login/signup pages with custom domains
- **Federated Identity**: Integration with social providers and SAML
- **AWS Credential Management**: Temporary AWS credentials for authenticated users
- **Security by Default**: Encryption, deletion protection, and advanced threat detection
- **Flexible Configuration**: Extensive customization options for all use cases
- **Security Control Overrides**: Documented override system for development/testing

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Cognito User Pool                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Password Policy (CIS Compliant)                     │  │
│  │  - Min 14 chars, complexity requirements             │  │
│  │  - MFA (TOTP)                                        │  │
│  │  - Email/Phone verification                          │  │
│  │  - Account recovery                                  │  │
│  │  - Lambda triggers                                   │  │
│  │  - Advanced security (threat detection)              │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
                            │
                            ├─────────────────────────────────┐
                            │                                 │
                            ▼                                 ▼
┌─────────────────────────────────────┐   ┌──────────────────────────────┐
│     User Pool Client                │   │    User Pool Domain          │
│  ┌───────────────────────────────┐  │   │  ┌────────────────────────┐  │
│  │  OAuth 2.0 Flows              │  │   │  │  Hosted UI             │  │
│  │  - Authorization Code         │  │   │  │  - Custom Domain       │  │
│  │  - Implicit (legacy)          │  │   │  │  - Cognito Domain      │  │
│  │  - Client Credentials (M2M)   │  │   │  │  - CloudFront          │  │
│  │                               │  │   │  │  - ACM Certificate     │  │
│  │  Token Management             │  │   │  └────────────────────────┘  │
│  │  - Access, ID, Refresh tokens │  │   └──────────────────────────────┘
│  │  - Configurable validity      │  │
│  │  - Token revocation           │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────────┐
│                    Identity Pool                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Federated Identity                                  │  │
│  │  - Cognito User Pool                                 │  │
│  │  - Social Providers (Google, Facebook, Amazon)       │  │
│  │  - SAML                                              │  │
│  │  - OpenID Connect                                    │  │
│  │                                                      │  │
│  │  IAM Role Mappings                                   │  │
│  │  - Authenticated users → IAM role                    │  │
│  │  - Unauthenticated users → IAM role (optional)       │  │
│  │  - Advanced role mapping rules                       │  │
│  │                                                      │  │
│  │  AWS Credentials                                     │  │
│  │  - Temporary credentials for AWS API access          │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

## Quick Start

### Basic Authentication Setup

```hcl
# 1. Create User Pool
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"

  # CIS-compliant password policy (default)
  password_policy = {
    minimum_length                   = 14
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # Optional MFA
  mfa_configuration = "OPTIONAL"

  tags = {
    Project = "CorporateActions"
  }
}

# 2. Create User Pool Client
module "user_pool_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
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

# 3. Create User Pool Domain (Optional - for Hosted UI)
module "user_pool_domain" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"

  user_pool_id  = module.user_pool.user_pool_id
  domain_prefix = "example-corp-actions"

  tags = {
    Project = "CorporateActions"
  }
}

# 4. Create Identity Pool (Optional - for AWS credentials)
module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"

  cognito_identity_providers = [
    {
      client_id     = module.user_pool_client.client_id
      provider_name = "cognito-idp.ca-central-1.amazonaws.com/${module.user_pool.user_pool_id}"
    }
  ]

  authenticated_role_policy_arns = {
    dynamodb = aws_iam_policy.dynamodb_access.arn
    s3       = aws_iam_policy.s3_access.arn
  }

  tags = {
    Project = "CorporateActions"
  }
}
```

## Module Documentation

Each sub-module has comprehensive documentation:

- [User Pool](modules/user-pool/README.md) - Core authentication configuration
- [User Pool Client](modules/user-pool-client/README.md) - OAuth 2.0 application integration
- [User Pool Domain](modules/user-pool-domain/README.md) - Hosted UI and custom domains
- [Identity Pool](modules/identity-pool/README.md) - Federated identity and AWS credentials

## Common Use Cases

### 1. Web Application with Hosted UI

```hcl
# User Pool with MFA
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  mfa_configuration = "ON"
}

# Web App Client
module "web_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  oauth_flows = ["code"]
  generate_secret = false  # Public client (SPA)
}

# Custom Domain for Hosted UI
module "domain" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  use_custom_domain = true
  custom_domain     = "auth.example.com"
  certificate_arn   = aws_acm_certificate.auth.arn
}
```

### 2. API with Machine-to-Machine Authentication

```hcl
# User Pool
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
}

# M2M Client
module "m2m_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  generate_secret = true
  oauth_flows     = ["client_credentials"]
  oauth_scopes    = ["aws.cognito.signin.user.admin"]
}
```

### 3. Mobile App with Social Login

```hcl
# User Pool
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
}

# Mobile App Client
module "mobile_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  oauth_flows = ["code"]
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# Identity Pool with Social Providers
module "identity_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  supported_login_providers = {
    "accounts.google.com" = var.google_client_id
    "graph.facebook.com"  = var.facebook_app_id
  }
}
```

### 4. Demo Environment (Simplified Security)

```hcl
# User Pool with relaxed security for demo
module "demo_user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  password_policy = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = false
    require_numbers   = true
    require_symbols   = false
    temporary_password_validity_days = 7
  }

  mfa_configuration          = "OFF"
  advanced_security_mode     = "AUDIT"
  enable_deletion_protection = false

  security_control_overrides = {
    disable_deletion_protection = true
    disable_mfa_requirement     = true
    disable_password_complexity = true
    justification               = "Demo environment for stakeholder presentation"
  }
}
```

## Integration with API Gateway

### Cognito Authorizer

```hcl
# Create API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "corporate-actions-api"
}

# Create Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [module.user_pool.user_pool_arn]
}

# Protect API Method
resource "aws_api_gateway_method" "protected" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}
```

### Lambda Function Integration

```hcl
# Lambda function can access user identity from event
def lambda_handler(event, context):
    # Get user identity from Cognito authorizer
    claims = event['requestContext']['authorizer']['claims']
    user_id = claims['sub']
    email = claims['email']
    
    # Your business logic here
    return {
        'statusCode': 200,
        'body': json.dumps({'message': f'Hello {email}'})
    }
```

## OAuth 2.0 Flows

### Authorization Code Flow (Recommended)

Most secure flow for web and mobile applications.

```hcl
module "client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  oauth_flows     = ["code"]
  generate_secret = true  # For server-side apps
  
  callback_urls = ["https://app.example.com/callback"]
  logout_urls   = ["https://app.example.com/logout"]
}
```

**Flow:**
1. User clicks "Login" → Redirect to Cognito Hosted UI
2. User authenticates → Cognito returns authorization code
3. App exchanges code for tokens (access, ID, refresh)
4. App uses access token to call APIs

### Implicit Flow (Legacy - Not Recommended)

Legacy flow for SPAs. Use authorization code with PKCE instead.

```hcl
module "client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  oauth_flows     = ["implicit"]
  generate_secret = false
}
```

### Client Credentials Flow (M2M)

For machine-to-machine authentication without user context.

```hcl
module "client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  oauth_flows     = ["client_credentials"]
  generate_secret = true
  oauth_scopes    = ["aws.cognito.signin.user.admin"]
}
```

**Flow:**
1. Service authenticates with client ID and secret
2. Cognito returns access token
3. Service uses access token to call APIs

## MFA Setup and Best Practices

### Enabling MFA

```hcl
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  # MFA options: OFF, OPTIONAL, ON
  mfa_configuration = "OPTIONAL"  # Users can enable MFA
  # mfa_configuration = "ON"      # MFA required for all users
}
```

### MFA Configuration Options

1. **OFF**: No MFA support
2. **OPTIONAL**: Users can enable MFA (recommended for most applications)
3. **ON**: MFA required for all users (highest security)

### TOTP (Time-based One-Time Password)

Cognito supports TOTP-based MFA using authenticator apps:
- Google Authenticator
- Microsoft Authenticator
- Authy
- 1Password

### MFA Best Practices

1. **Start with OPTIONAL**: Allow users to opt-in to MFA
2. **Educate Users**: Provide clear instructions on setting up MFA
3. **Recovery Mechanisms**: Configure account recovery for users who lose MFA devices
4. **Enforce for Admins**: Require MFA for administrative accounts
5. **Monitor Adoption**: Track MFA enrollment rates

### MFA User Experience

```
1. User signs up → Account created
2. User logs in → Prompted to set up MFA (if OPTIONAL)
3. User scans QR code with authenticator app
4. User enters verification code → MFA enabled
5. Future logins → Username/password + MFA code
```

## Security Considerations

### Password Policy (CIS Benchmark)

The default password policy meets CIS AWS Foundations Benchmark:

```hcl
password_policy = {
  minimum_length                   = 14  # CIS requirement
  require_lowercase                = true
  require_uppercase                = true
  require_numbers                  = true
  require_symbols                  = true
  temporary_password_validity_days = 7
}
```

### Advanced Security Features

```hcl
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  # Threat detection and risk-based authentication
  advanced_security_mode = "ENFORCED"  # AUDIT or ENFORCED
  
  # Prevent user enumeration attacks
  # (in user pool client)
}
```

### Deletion Protection

```hcl
module "user_pool" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  # Prevent accidental deletion
  enable_deletion_protection = true  # Recommended for production
}
```

### Token Security

```hcl
module "user_pool_client" {
  source = "github.com/islamelkadi/terraform-aws-cognito"
  
  # Enable token revocation
  enable_token_revocation = true
  
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

### Security Control Overrides

When you need to disable security controls (e.g., for development), provide justification:

```hcl
security_control_overrides = {
  disable_deletion_protection = true
  disable_mfa_requirement     = true
  justification               = "Development environment for testing"
}
```

## Best Practices

### 1. User Pool Configuration

- ✅ Enable MFA (at least OPTIONAL)
- ✅ Use CIS-compliant password policy (14+ chars, complexity)
- ✅ Enable advanced security mode (ENFORCED for production)
- ✅ Enable deletion protection for production
- ✅ Configure account recovery mechanisms
- ✅ Use SES for email (better deliverability)

### 2. User Pool Client Configuration

- ✅ Use authorization code flow (most secure)
- ✅ Enable token revocation
- ✅ Use HTTPS for all callback/logout URLs
- ✅ Limit token validity (shorter = more secure)
- ✅ Generate client secret for server-side apps only
- ✅ Limit OAuth scopes to necessary permissions

### 3. User Pool Domain Configuration

- ✅ Use custom domain for production (better branding)
- ✅ Ensure ACM certificate is in us-east-1 region
- ✅ Configure Route53 alias record for custom domain
- ✅ Use HTTPS only

### 4. Identity Pool Configuration

- ✅ Disable unauthenticated access by default
- ✅ Use least privilege IAM policies
- ✅ Use advanced role mappings for fine-grained access
- ✅ Monitor IAM role usage

### 5. Lambda Triggers

- ✅ Use Lambda triggers for custom workflows
- ✅ Implement proper error handling
- ✅ Keep trigger functions fast (< 5 seconds)
- ✅ Log all trigger executions

### 6. Monitoring and Logging

- ✅ Enable CloudWatch Logs for Lambda triggers
- ✅ Monitor authentication metrics
- ✅ Set up alarms for failed login attempts
- ✅ Track MFA enrollment rates

## Troubleshooting

### Common Issues

#### 1. Custom Domain Not Working

**Symptoms**: Custom domain returns 404 or SSL errors

**Solutions**:
- Verify ACM certificate is in `us-east-1` region
- Verify certificate is in `ISSUED` status
- Wait up to 60 minutes for CloudFront distribution to deploy
- Verify Route53 alias record points to CloudFront distribution

#### 2. OAuth Callback Errors

**Symptoms**: "redirect_uri_mismatch" error

**Solutions**:
- Verify callback URL is in the client's `callback_urls` list
- Ensure URL matches exactly (including protocol, domain, path)
- Check for trailing slashes

#### 3. Token Validation Failures

**Symptoms**: "Invalid token" errors in API Gateway

**Solutions**:
- Verify token hasn't expired
- Verify token is from the correct user pool
- Check API Gateway authorizer configuration
- Verify user pool ARN is correct

#### 4. MFA Setup Issues

**Symptoms**: Users can't set up MFA

**Solutions**:
- Verify `mfa_configuration` is set to `OPTIONAL` or `ON`
- Check user has verified email or phone number
- Verify authenticator app is synced with correct time

## Examples

Each module includes a comprehensive example:

- [User Pool Example](modules/user-pool/example/)
- [User Pool Client Example](modules/user-pool-client/example/)
- [User Pool Domain Example](modules/user-pool-domain/example/)
- [Identity Pool Example](modules/identity-pool/example/)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.3 |
| aws | >= 6.34 |

## References

- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [OpenID Connect Specification](https://openid.net/connect/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
