# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  identity_pool_name_base = module.metadata.resource_prefix

  # Construct identity pool name from components (with optional attributes)
  identity_pool_name = length(var.attributes) > 0 ? "${local.identity_pool_name_base}-${join(var.delimiter, var.attributes)}" : local.identity_pool_name_base

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Module = "terraform-aws-cognito/identity-pool"
    }
  )
}
