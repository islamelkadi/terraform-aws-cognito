# Example input variables
# Copy this file and customize for your environment

namespace   = "example"
environment = "dev"
region      = "us-east-1"

# Replace with your actual Cognito User Pool Client ID
cognito_client_id = "abc123def456"

# Replace with your actual Cognito User Pool provider name
cognito_provider_name = "cognito-idp.us-east-1.amazonaws.com/us-east-1_ABC123"

# Replace with your actual IAM policy ARNs
authenticated_role_policy_arns = {
  dynamodb = "arn:aws:iam::123456789012:policy/DynamoDBAccess"
  s3       = "arn:aws:iam::123456789012:policy/S3Access"
}

unauthenticated_role_policy_arns = {
  readonly = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
