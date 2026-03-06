# Complete Cognito Identity Pool Example

This example demonstrates a full-featured Cognito Identity Pool configuration with all available options.

## Features

- Cognito User Pool integration with server-side token check
- Social identity providers (Google, Facebook)
- Unauthenticated access for guest users
- Custom IAM policies for authenticated and unauthenticated roles
- Advanced role mappings based on token claims
- Security control overrides with justification

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Highlights

### Identity Providers

```hcl
# Cognito User Pool
cognito_identity_providers = [
  {
    client_id               = "example-client-id"
    provider_name           = "cognito-idp.us-east-1.amazonaws.com/us-east-1_EXAMPLE"
    server_side_token_check = true
  }
]

# Social providers
supported_login_providers = {
  "accounts.google.com" = "example-google-client-id"
  "graph.facebook.com"  = "example-facebook-app-id"
}
```

### IAM Role Policies

```hcl
# Authenticated users - full access
authenticated_role_policy_arns = {
  dynamodb = "arn:aws:iam::123456789012:policy/DynamoDBAccess"
  s3       = "arn:aws:iam::123456789012:policy/S3Access"
}

# Unauthenticated users - read-only
unauthenticated_role_policy_arns = {
  readonly = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

### Advanced Role Mappings

```hcl
role_mappings = [
  {
    identity_provider         = "cognito-idp.us-east-1.amazonaws.com/us-east-1_EXAMPLE:example-client-id"
    type                      = "Rules"
    ambiguous_role_resolution = "Deny"
    mapping_rules = [
      {
        claim      = "custom:role"
        match_type = "Equals"
        role_arn   = "arn:aws:iam::123456789012:role/AdminRole"
        value      = "admin"
      }
    ]
  }
]
```

### Security Control Overrides

```hcl
security_control_overrides = {
  allow_unauthenticated_access = true
  justification                = "Public application requires guest access for demo features"
}
```

## Outputs

- `identity_pool_id` - ID of the Cognito Identity Pool
- `identity_pool_arn` - ARN of the Cognito Identity Pool
- `authenticated_role_arn` - ARN of the authenticated IAM role
- `unauthenticated_role_arn` - ARN of the unauthenticated IAM role

## Security Considerations

### Unauthenticated Access

This example enables unauthenticated access for demonstration purposes. In production:

- Only enable if your application requires guest access
- Grant minimal permissions to unauthenticated users
- Document the business justification
- Monitor usage and implement rate limiting

### Role Mappings

The advanced role mappings demonstrate how to assign different IAM roles based on user attributes:

- `custom:role = admin` → AdminRole (elevated permissions)
- `custom:role = user` → UserRole (standard permissions)
- `ambiguous_role_resolution = "Deny"` → Deny access if claim doesn't match

### IAM Policies

Follow the principle of least privilege:

- Authenticated users: Grant only necessary permissions
- Unauthenticated users: Read-only access to public resources
- Use resource-level permissions where possible

## Notes

- This example uses placeholder values for demonstration
- Replace ARNs and IDs with actual resource references
- Customize policies based on your application requirements
- Test role mappings thoroughly before production deployment
