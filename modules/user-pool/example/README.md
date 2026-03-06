# Cognito User Pool Example

This example demonstrates a comprehensive Cognito User Pool configuration with security best practices.

## Features

- Email and username aliases
- Strong password policy (12+ characters, complexity requirements)
- Optional MFA with software tokens (TOTP)
- Email verification
- Account recovery via verified email
- Custom user attributes
- Lambda triggers for signup and confirmation
- Secure defaults

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Lambda functions for triggers (optional)

## Configuration

This example creates a User Pool with:

### Authentication
- **Alias Attributes**: Email and preferred username
- **Auto-Verified**: Email addresses
- **MFA**: Optional (users can enable TOTP)

### Password Policy
- Minimum length: 12 characters
- Requires: lowercase, uppercase, numbers, symbols
- Temporary password validity: 7 days

### Account Recovery
- Primary method: Verified email
- Users can reset password via email

### User Attributes
- **Required**: email, name
- **Mutable**: Both can be changed after signup

### Lambda Triggers
- **Pre Sign-up**: Custom validation before user registration
- **Post Confirmation**: Actions after user confirms email

## Security Best Practices

1. **Strong Password Policy**: 12+ characters with complexity requirements
2. **Email Verification**: Auto-verify email addresses
3. **Optional MFA**: Users can enable additional security
4. **Account Recovery**: Secure password reset via verified email
5. **Lambda Triggers**: Custom validation and post-signup actions

## Use Cases

This configuration is suitable for:
- Web and mobile applications
- B2C applications with user registration
- Applications requiring email verification
- Applications with optional MFA

## Outputs

- `user_pool_id` - The User Pool ID (use for client configuration)
- `user_pool_arn` - The User Pool ARN
- `user_pool_endpoint` - The User Pool endpoint URL

## Next Steps

After creating the User Pool:

1. Create a User Pool Client (see user-pool-client example)
2. Configure a User Pool Domain (see user-pool-domain example)
3. Set up Lambda triggers for custom logic
4. Configure email templates and branding
5. Test user registration and authentication flows
