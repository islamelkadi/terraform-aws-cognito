# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  region = module.metadata.region_name

  # Validation: Ensure required parameters are provided based on domain type
  custom_domain_valid = !var.use_custom_domain || (var.custom_domain != null && var.certificate_arn != null)
  prefix_domain_valid = var.use_custom_domain || var.domain_prefix != null

  # Merge tags with defaults
  # Note: Cognito User Pool Domain resources don't support tags directly,
  # but we maintain them for consistency and potential future use
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Module = "terraform-aws-cognito/user-pool-domain"
    }
  )
}

# Validation checks
check "custom_domain_requirements" {
  assert {
    condition     = local.custom_domain_valid
    error_message = "When use_custom_domain is true, both custom_domain and certificate_arn must be provided"
  }
}

check "prefix_domain_requirements" {
  assert {
    condition     = local.prefix_domain_valid
    error_message = "When use_custom_domain is false, domain_prefix must be provided"
  }
}
