# Terraform AWS Cognito User Pool Module

This module creates an AWS Cognito User Pool with security best practices and CIS Benchmark compliance.

## Features

- **CIS Benchmark Compliant**: Password policy with minimum 14 characters and complexity requirements
- **MFA Support**: Optional multi-factor authentication with TOTP
- **Email Verification**: Configurable email verification with custom templates
- **Account Recovery**: Multiple recovery mechanisms (email, phone, admin)
- **Custom Attributes**: Support for standard and custom user attributes
- **Lambda Triggers**: Integration with Lambda functions for custom workflows
- **Advanced Security**: Built-in threat detection and risk-based authentication
- **Deletion Protection**: Prevent accidental deletion of user pools
- **Security Controls**: Extensible override system with audit justification

## Usage

### Basic Example

```hcl
module "user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"

  # Password policy (CIS compliant by default)
  password_policy = {
    minimum_length                   = 14
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"

  # Email verification
  auto_verified_attributes = ["email"]

  tags = {
    Project = "CorporateActions"
    Owner   = "Operations"
  }
}
```

### Complete Example with All Features

```hcl
module "user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"

  # Password policy (CIS Benchmark compliant)
  password_policy = {
    minimum_length                   = 16
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA configuration (TOTP)
  mfa_configuration = "ON"

  # Email verification
  auto_verified_attributes = ["email"]

  email_configuration = {
    email_sending_account  = "DEVELOPER"
    source_arn             = "arn:aws:ses:ca-central-1:123456789012:identity/noreply@example.com"
    from_email_address     = "noreply@example.com"
    reply_to_email_address = "support@example.com"
  }

  verification_message_template = {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_subject         = "Verify your email address"
    email_message         = "Your verification code is {####}"
    email_subject_by_link = "Verify your email address"
    email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}"
    sms_message           = "Your verification code is {####}"
  }

  # Account recovery
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  # Custom user attributes
  user_attributes = [
    {
      name                = "department"
      attribute_data_type = "String"
      mutable             = true
      required            = false
      min_length          = 1
      max_length          = 50
    },
    {
      name                = "employee_id"
      attribute_data_type = "String"
      mutable             = false
      required            = true
      min_length          = 5
      max_length          = 20
    }
  ]

  # Lambda triggers
  lambda_triggers = {
    pre_sign_up       = "arn:aws:lambda:ca-central-1:123456789012:function:pre-signup"
    post_confirmation = "arn:aws:lambda:ca-central-1:123456789012:function:post-confirmation"
    custom_message    = "arn:aws:lambda:ca-central-1:123456789012:function:custom-message"
  }

  # Advanced security
  advanced_security_mode = "ENFORCED"

  # Username configuration
  username_attributes      = ["email"]
  username_case_sensitive  = false

  # Admin create user
  allow_admin_create_user_only = false

  invite_message_template = {
    email_subject = "Welcome to Corporate Actions"
    email_message = "Your username is {username} and temporary password is {####}."
    sms_message   = "Your username is {username} and temporary password is {####}."
  }

  # Device tracking
  device_configuration = {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  # Deletion protection
  enable_deletion_protection = true

  tags = {
    Project     = "CorporateActions"
    Owner       = "Operations"
    Compliance  = "CIS-Benchmark"
  }
}
```

### Demo Environment Example (with Security Overrides)

```hcl
module "demo_user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"

  namespace   = "example"
  environment = "dev"
  name        = "corporate-actions-demo"
  region      = "us-east-1"

  # Simplified password policy for demo
  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = false
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # MFA disabled for demo simplicity
  mfa_configuration = "OFF"

  # Email verification
  auto_verified_attributes = ["email"]

  # Advanced security in audit mode (not enforced)
  advanced_security_mode = "AUDIT"

  # Deletion protection disabled for easy cleanup
  enable_deletion_protection = false

  # Security control overrides with justification
  security_control_overrides = {
    disable_deletion_protection = true
    disable_mfa_requirement     = true
    disable_password_complexity = true
    justification               = "Demo environment with simplified authentication for stakeholder presentation. Will be deleted after demo."
  }

  tags = {
    Project     = "CorporateActions"
    Environment = "Demo"
    Temporary   = "true"
  }
}
```

### Default Values

**password_policy** (CIS Benchmark compliant):
```hcl
{
  minimum_length                   = 14
  require_lowercase                = true
  require_uppercase                = true
  require_numbers                  = true
  require_symbols                  = true
  temporary_password_validity_days = 7
}
```

**email_configuration**:
```hcl
{
  email_sending_account  = "COGNITO_DEFAULT"
  source_arn             = null
  from_email_address     = null
  reply_to_email_address = null
}
```

**verification_message_template**:
```hcl
{
  default_email_option  = "CONFIRM_WITH_CODE"
  email_subject         = "Your verification code"
  email_message         = "Your verification code is {####}"
  email_subject_by_link = "Your verification link"
  email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}"
  sms_message           = "Your verification code is {####}"
}
```

**account_recovery_mechanisms**:
```hcl
[
  {
    name     = "verified_email"
    priority = 1
  },
  {
    name     = "verified_phone_number"
    priority = 2
  }
]
```

**invite_message_template**:
```hcl
{
  email_subject = "Your temporary password"
  email_message = "Your username is {username} and temporary password is {####}."
  sms_message   = "Your username is {username} and temporary password is {####}."
}
```

**device_configuration**:
```hcl
{
  challenge_required_on_new_device      = false
  device_only_remembered_on_user_prompt = false
}
```

**security_control_overrides**:
```hcl
{
  disable_deletion_protection = false
  disable_advanced_security   = false
  disable_mfa_requirement     = false
  disable_password_complexity = false
  justification               = ""
}
```

## Security Features

### CIS Benchmark Compliance

The module enforces CIS AWS Foundations Benchmark requirements by default:

- **Password Policy**: Minimum 14 characters with complexity requirements
- **MFA Support**: Optional or required multi-factor authentication
- **Account Recovery**: Multiple recovery mechanisms with priority
- **Advanced Security**: Threat detection and risk-based authentication

### Security Control Overrides

The module supports selective disabling of security controls with documented justification:

```hcl
security_control_overrides = {
  disable_deletion_protection = true
  disable_mfa_requirement     = true
  justification               = "Demo environment for stakeholder presentation"
}
```

**Common Override Use Cases**:

| Override | Use Case | Example Justification |
|----------|----------|----------------------|
| `disable_deletion_protection` | Dev/test user pools | "Development environment, user pool is disposable" |
| `disable_mfa_requirement` | Demo environments | "Demo environment with simplified authentication" |
| `disable_password_complexity` | Testing environments | "Testing environment with simplified password requirements" |
| `disable_advanced_security` | Cost optimization | "Non-production environment, cost optimization" |

### Lambda Triggers

The module supports all Cognito Lambda triggers:

- **pre_sign_up**: Custom validation before user registration
- **post_confirmation**: Actions after user confirms registration
- **pre_authentication**: Custom validation before authentication
- **post_authentication**: Actions after successful authentication
- **pre_token_generation**: Customize tokens before generation
- **user_migration**: Migrate users from legacy systems
- **custom_message**: Customize verification and invitation messages
- **define_auth_challenge**: Define custom authentication challenges
- **create_auth_challenge**: Create custom authentication challenges
- **verify_auth_challenge_response**: Verify custom authentication responses
- **custom_email_sender**: Custom email sending logic
- **custom_sms_sender**: Custom SMS sending logic

## Integration with API Gateway

To use this user pool with API Gateway:

```hcl
# Create user pool
module "user_pool" {
  source = "../../modules/terraform-aws-cognito/modules/user-pool"
  # ... configuration
}

# Create API Gateway authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [module.user_pool.user_pool_arn]
}

# Protect API Gateway method
resource "aws_api_gateway_method" "protected" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}
```

## Best Practices

1. **Enable MFA**: Use `mfa_configuration = "ON"` for production environments
2. **Use SES for Email**: Configure `email_configuration.email_sending_account = "DEVELOPER"` with SES for better deliverability
3. **Enable Advanced Security**: Use `advanced_security_mode = "ENFORCED"` for production
4. **Enable Deletion Protection**: Keep `enable_deletion_protection = true` for production
5. **Custom Attributes**: Plan custom attributes carefully - they cannot be deleted after creation
6. **Lambda Triggers**: Use Lambda triggers for custom workflows and integrations
7. **Account Recovery**: Configure multiple recovery mechanisms for better user experience
8. **Password Policy**: Follow CIS Benchmark (14+ chars, complexity) for security

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Password policy (CIS) | Relaxed | CIS-compliant (14+ chars) | CIS-compliant (14+ chars) |
| MFA | OFF | OPTIONAL | OPTIONAL/ON |
| Advanced security mode | AUDIT | ENFORCED | ENFORCED |
| Deletion protection | Disabled | Enabled | Enabled |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# Cognito User Pool Example
# Demonstrates user pool configuration with security best practices

module "user_pool" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "app-users"
  region      = var.region

  # User pool configuration
  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  # Password policy (CIS compliance requires minimum 14 characters)
  password_policy = {
    minimum_length                   = 14
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"

  # Email configuration
  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Account recovery
  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    }
  ]

  # User attributes
  user_attributes = [
    {
      name                = "email"
      attribute_data_type = "String"
      required            = true
      mutable             = true
    },
    {
      name                = "name"
      attribute_data_type = "String"
      required            = true
      mutable             = true
    }
  ]

  # Lambda triggers - replace with your actual Lambda ARNs
  lambda_triggers = var.lambda_triggers

  tags = {
    Example = "USER_POOL"
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
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_recovery_mechanisms"></a> [account\_recovery\_mechanisms](#input\_account\_recovery\_mechanisms) | Account recovery mechanisms configuration | <pre>list(object({<br/>    name     = string<br/>    priority = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "verified_email",<br/>    "priority": 1<br/>  },<br/>  {<br/>    "name": "verified_phone_number",<br/>    "priority": 2<br/>  }<br/>]</pre> | no |
| <a name="input_advanced_security_mode"></a> [advanced\_security\_mode](#input\_advanced\_security\_mode) | Advanced security mode (OFF, AUDIT, ENFORCED) | `string` | `"AUDIT"` | no |
| <a name="input_alias_attributes"></a> [alias\_attributes](#input\_alias\_attributes) | Attributes that can be used as aliases (email, phone\_number, preferred\_username) | `list(string)` | `[]` | no |
| <a name="input_allow_admin_create_user_only"></a> [allow\_admin\_create\_user\_only](#input\_allow\_admin\_create\_user\_only) | Only allow administrators to create user profiles | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_auto_verified_attributes"></a> [auto\_verified\_attributes](#input\_auto\_verified\_attributes) | Attributes to be auto-verified (email, phone\_number) | `list(string)` | <pre>[<br/>  "email"<br/>]</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_device_configuration"></a> [device\_configuration](#input\_device\_configuration) | Device tracking configuration | <pre>object({<br/>    challenge_required_on_new_device      = bool<br/>    device_only_remembered_on_user_prompt = bool<br/>  })</pre> | <pre>{<br/>  "challenge_required_on_new_device": false,<br/>  "device_only_remembered_on_user_prompt": false<br/>}</pre> | no |
| <a name="input_email_configuration"></a> [email\_configuration](#input\_email\_configuration) | Email configuration for the user pool | <pre>object({<br/>    email_sending_account  = string<br/>    source_arn             = optional(string)<br/>    from_email_address     = optional(string)<br/>    reply_to_email_address = optional(string)<br/>  })</pre> | <pre>{<br/>  "email_sending_account": "COGNITO_DEFAULT",<br/>  "from_email_address": null,<br/>  "reply_to_email_address": null,<br/>  "source_arn": null<br/>}</pre> | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection for the user pool | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_invite_message_template"></a> [invite\_message\_template](#input\_invite\_message\_template) | Invite message template for admin-created users | <pre>object({<br/>    email_subject = string<br/>    email_message = string<br/>    sms_message   = string<br/>  })</pre> | <pre>{<br/>  "email_message": "Your username is {username} and temporary password is {####}.",<br/>  "email_subject": "Your temporary password",<br/>  "sms_message": "Your username is {username} and temporary password is {####}."<br/>}</pre> | no |
| <a name="input_lambda_triggers"></a> [lambda\_triggers](#input\_lambda\_triggers) | Lambda function ARNs for Cognito triggers (pre-signup, post-confirmation, etc.) | `map(string)` | `{}` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-factor authentication configuration (OFF, ON, OPTIONAL) | `string` | `"OPTIONAL"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cognito User Pool | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_password_policy"></a> [password\_policy](#input\_password\_policy) | Password policy configuration for the user pool | <pre>object({<br/>    minimum_length                   = number<br/>    require_lowercase                = bool<br/>    require_uppercase                = bool<br/>    require_numbers                  = bool<br/>    require_symbols                  = bool<br/>    temporary_password_validity_days = number<br/>  })</pre> | <pre>{<br/>  "minimum_length": 14,<br/>  "require_lowercase": true,<br/>  "require_numbers": true,<br/>  "require_symbols": true,<br/>  "require_uppercase": true,<br/>  "temporary_password_validity_days": 7<br/>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this Cognito User Pool.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_deletion\_protection: Development/testing user pools<br/>- disable\_advanced\_security: Cost optimization for non-production environments<br/>- disable\_mfa\_requirement: Demo environments with simplified authentication<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_deletion_protection = optional(bool, false)<br/>    disable_advanced_security   = optional(bool, false)<br/>    disable_mfa_requirement     = optional(bool, false)<br/>    disable_password_complexity = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_advanced_security": false,<br/>  "disable_deletion_protection": false,<br/>  "disable_mfa_requirement": false,<br/>  "disable_password_complexity": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    iam = object({<br/>      enforce_least_privilege  = bool<br/>      block_wildcard_resources = bool<br/>      require_mfa_for_humans   = bool<br/>      require_service_roles    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning         = bool<br/>      require_mfa_delete         = bool<br/>      require_automated_backups  = bool<br/>      block_public_access        = bool<br/>      require_lifecycle_policies = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    high_availability = object({<br/>      require_multi_az           = bool<br/>      require_multi_az_nat       = bool<br/>      enable_cross_region_backup = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_user_attributes"></a> [user\_attributes](#input\_user\_attributes) | User attribute schema configuration (email, name, custom attributes) | <pre>list(object({<br/>    name                     = string<br/>    attribute_data_type      = string<br/>    developer_only_attribute = optional(bool, false)<br/>    mutable                  = optional(bool, true)<br/>    required                 = optional(bool, false)<br/>    min_length               = optional(number)<br/>    max_length               = optional(number)<br/>    min_value                = optional(number)<br/>    max_value                = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_username_attributes"></a> [username\_attributes](#input\_username\_attributes) | Attributes that can be used as username (email, phone\_number) | `list(string)` | <pre>[<br/>  "email"<br/>]</pre> | no |
| <a name="input_username_case_sensitive"></a> [username\_case\_sensitive](#input\_username\_case\_sensitive) | Whether username is case sensitive | `bool` | `false` | no |
| <a name="input_verification_message_template"></a> [verification\_message\_template](#input\_verification\_message\_template) | Verification message template configuration | <pre>object({<br/>    default_email_option  = string<br/>    email_subject         = optional(string)<br/>    email_message         = optional(string)<br/>    email_subject_by_link = optional(string)<br/>    email_message_by_link = optional(string)<br/>    sms_message           = optional(string)<br/>  })</pre> | <pre>{<br/>  "default_email_option": "CONFIRM_WITH_CODE",<br/>  "email_message": "Your verification code is {####}",<br/>  "email_message_by_link": "Please click the link below to verify your email address. {##Verify Email##}",<br/>  "email_subject": "Your verification code",<br/>  "email_subject_by_link": "Your verification link",<br/>  "sms_message": "Your verification code is {####}"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Cognito User Pool |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | ARN of the Cognito User Pool |
| <a name="output_user_pool_creation_date"></a> [user\_pool\_creation\_date](#output\_user\_pool\_creation\_date) | Creation date of the Cognito User Pool |
| <a name="output_user_pool_domain"></a> [user\_pool\_domain](#output\_user\_pool\_domain) | Domain prefix of the Cognito User Pool (if configured) |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | Endpoint of the Cognito User Pool |
| <a name="output_user_pool_estimated_number_of_users"></a> [user\_pool\_estimated\_number\_of\_users](#output\_user\_pool\_estimated\_number\_of\_users) | Estimated number of users in the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | ID of the Cognito User Pool |
| <a name="output_user_pool_last_modified_date"></a> [user\_pool\_last\_modified\_date](#output\_user\_pool\_last\_modified\_date) | Last modified date of the Cognito User Pool |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | Name of the Cognito User Pool |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
