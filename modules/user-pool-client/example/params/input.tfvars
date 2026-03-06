# Example input variables
# Copy this file and customize for your environment

namespace   = "example"
environment = "dev"
region      = "us-east-1"

# Replace with your actual Cognito User Pool ID
user_pool_id = "us-east-1_ABC123"

# Replace with your actual callback and logout URLs
callback_urls = [
  "https://example.com/callback",
  "http://localhost:3000/callback"
]

logout_urls = [
  "https://example.com/logout",
  "http://localhost:3000/logout"
]
