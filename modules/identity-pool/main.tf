# Cognito Identity Pool Module
# Creates AWS Cognito Identity Pool for federated identities

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = local.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  allow_classic_flow               = var.allow_classic_flow

  # Cognito Identity Providers (User Pools)
  dynamic "cognito_identity_providers" {
    for_each = var.cognito_identity_providers
    content {
      client_id               = cognito_identity_providers.value.client_id
      provider_name           = cognito_identity_providers.value.provider_name
      server_side_token_check = lookup(cognito_identity_providers.value, "server_side_token_check", false)
    }
  }

  # SAML Identity Providers (list attribute)
  saml_provider_arns = var.saml_provider_arns

  # OpenID Connect Providers (list attribute)
  openid_connect_provider_arns = var.openid_connect_provider_arns

  # Supported Login Providers (Social Identity Providers)
  supported_login_providers = var.supported_login_providers

  tags = local.tags
}

# IAM Role for Authenticated Users
resource "aws_iam_role" "authenticated" {
  count = var.authenticated_role_arn == null ? 1 : 0

  name               = "${local.identity_pool_name}-authenticated"
  assume_role_policy = data.aws_iam_policy_document.authenticated_assume_role[0].json

  tags = merge(
    local.tags,
    {
      Name = "${local.identity_pool_name}-authenticated"
      Type = "authenticated"
    }
  )
}

data "aws_iam_policy_document" "authenticated_assume_role" {
  count = var.authenticated_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

# Attach custom policies to authenticated role
resource "aws_iam_role_policy_attachment" "authenticated" {
  for_each = var.authenticated_role_arn == null ? var.authenticated_role_policy_arns : {}

  role       = aws_iam_role.authenticated[0].name
  policy_arn = each.value
}

# IAM Role for Unauthenticated Users
resource "aws_iam_role" "unauthenticated" {
  count = var.allow_unauthenticated_identities && var.unauthenticated_role_arn == null ? 1 : 0

  name               = "${local.identity_pool_name}-unauthenticated"
  assume_role_policy = data.aws_iam_policy_document.unauthenticated_assume_role[0].json

  tags = merge(
    local.tags,
    {
      Name = "${local.identity_pool_name}-unauthenticated"
      Type = "unauthenticated"
    }
  )
}

data "aws_iam_policy_document" "unauthenticated_assume_role" {
  count = var.allow_unauthenticated_identities && var.unauthenticated_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

# Attach custom policies to unauthenticated role
resource "aws_iam_role_policy_attachment" "unauthenticated" {
  for_each = var.allow_unauthenticated_identities && var.unauthenticated_role_arn == null ? var.unauthenticated_role_policy_arns : {}

  role       = aws_iam_role.unauthenticated[0].name
  policy_arn = each.value
}

# Identity Pool Role Attachment
resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = aws_cognito_identity_pool.this.id

  roles = merge(
    {
      authenticated = var.authenticated_role_arn != null ? var.authenticated_role_arn : aws_iam_role.authenticated[0].arn
    },
    var.allow_unauthenticated_identities ? {
      unauthenticated = var.unauthenticated_role_arn != null ? var.unauthenticated_role_arn : aws_iam_role.unauthenticated[0].arn
    } : {}
  )

  # Role Mappings (optional - for advanced use cases)
  dynamic "role_mapping" {
    for_each = var.role_mappings
    content {
      identity_provider         = role_mapping.value.identity_provider
      ambiguous_role_resolution = lookup(role_mapping.value, "ambiguous_role_resolution", "AuthenticatedRole")
      type                      = role_mapping.value.type

      dynamic "mapping_rule" {
        for_each = lookup(role_mapping.value, "mapping_rules", [])
        content {
          claim      = mapping_rule.value.claim
          match_type = mapping_rule.value.match_type
          role_arn   = mapping_rule.value.role_arn
          value      = mapping_rule.value.value
        }
      }
    }
  }
}

