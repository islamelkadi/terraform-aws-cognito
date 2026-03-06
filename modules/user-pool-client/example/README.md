# Cognito User Pool Client Example

This example demonstrates a Cognito User Pool Client configuration for a web application with OAuth 2.0 authorization code flow.

## Features

- OAuth 2.0 authorization code flow
- Client secret generation for server-side apps
- Multiple callback and logout URLs
- Token validity configuration
- User existence error prevention

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Existing Cognito User Pool

## Configuration

This example creates a User Pool Client with:

### OAuth Configuration
- **Flows**: Authorization code flow
- **Scopes**: openid, email, profile, aws.cognito.signin.user.admin
- **Callback URLs**: Production and localhost for development
- **Logout URLs**: Production and localhost for development

### Token Validity
- **Access Token**: 60 minutes
- **ID Token**: 60 minutes
- **Refresh Token**: 30 days

### Security Features
- Client secret enabled for server-side authentication
- User existence error prevention (ENABLED)
- OAuth flows restricted to user pool client

## Use Cases

This configuration is suitable for:
- Web applications with server-side rendering
- Single-page applications with backend API
- Mobile applications with secure token storage

## Outputs

- `client_id` - The User Pool Client ID (use in your application)
- `client_name` - The User Pool Client name
- `client_secret` - The Client secret (sensitive, for server-side use only)

## Integration Example

```javascript
// Example: Using the client in a Node.js application
const AWS = require('aws-sdk');
const cognito = new AWS.CognitoIdentityServiceProvider();

const params = {
  AuthFlow: 'USER_PASSWORD_AUTH',
  ClientId: 'YOUR_CLIENT_ID',
  AuthParameters: {
    USERNAME: 'user@example.com',
    PASSWORD: 'password',
    SECRET_HASH: 'calculated_secret_hash'
  }
};

cognito.initiateAuth(params, (err, data) => {
  if (err) console.log(err);
  else console.log(data.AuthenticationResult);
});
```
