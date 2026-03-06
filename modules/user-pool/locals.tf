# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  user_pool_name_base = module.metadata.resource_prefix

  # Construct user pool name from components (with optional attributes)
  user_pool_name = length(var.attributes) > 0 ? "${local.user_pool_name_base}-${join(var.delimiter, var.attributes)}" : local.user_pool_name_base

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Module = "terraform-aws-cognito/user-pool"
    }
  )
}
