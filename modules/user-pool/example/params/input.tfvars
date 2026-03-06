# Example input variables
# Copy this file and customize for your environment

namespace   = "example"
environment = "dev"
region      = "us-east-1"

# Lambda triggers - replace with your actual Lambda ARNs
lambda_triggers = {
  pre_sign_up       = "arn:aws:lambda:us-east-1:123456789012:function:pre-signup"
  post_confirmation = "arn:aws:lambda:us-east-1:123456789012:function:post-confirmation"
}
