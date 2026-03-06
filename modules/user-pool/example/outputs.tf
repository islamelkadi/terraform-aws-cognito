# Outputs for User Pool example

output "user_pool_id" {
  description = "User Pool ID"
  value       = module.user_pool.user_pool_id
}

output "user_pool_arn" {
  description = "User Pool ARN"
  value       = module.user_pool.user_pool_arn
}

output "user_pool_endpoint" {
  description = "User Pool endpoint"
  value       = module.user_pool.user_pool_endpoint
}
