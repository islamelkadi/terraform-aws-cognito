# Cognito User Pool Module
# Creates AWS Cognito User Pool with security best practices

# Cognito User Pool
resource "aws_cognito_user_pool" "this" {
  name = local.user_pool_name

  # Password Policy (CIS Benchmark: min 14 chars, complexity requirements)
  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_uppercase                = var.password_policy.require_uppercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  # MFA Configuration (optional, TOTP support)
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  # Email Verification Configuration
  auto_verified_attributes = var.auto_verified_attributes

  email_configuration {
    email_sending_account  = var.email_configuration.email_sending_account
    source_arn             = var.email_configuration.source_arn
    from_email_address     = var.email_configuration.from_email_address
    reply_to_email_address = var.email_configuration.reply_to_email_address
  }

  # Verification Messages
  verification_message_template {
    default_email_option  = var.verification_message_template.default_email_option
    email_subject         = var.verification_message_template.email_subject
    email_message         = var.verification_message_template.email_message
    email_subject_by_link = var.verification_message_template.email_subject_by_link
    email_message_by_link = var.verification_message_template.email_message_by_link
    sms_message           = var.verification_message_template.sms_message
  }

  # Account Recovery Settings
  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.account_recovery_mechanisms
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  # User Attributes Schema
  dynamic "schema" {
    for_each = var.user_attributes
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", false)
      mutable                  = lookup(schema.value, "mutable", true)
      required                 = lookup(schema.value, "required", false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []
        content {
          min_length = lookup(schema.value, "min_length", 0)
          max_length = lookup(schema.value, "max_length", 2048)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [1] : []
        content {
          min_value = lookup(schema.value, "min_value", null)
          max_value = lookup(schema.value, "max_value", null)
        }
      }
    }
  }

  # Lambda Triggers
  dynamic "lambda_config" {
    for_each = length(var.lambda_triggers) > 0 ? [1] : []
    content {
      pre_sign_up                    = lookup(var.lambda_triggers, "pre_sign_up", null)
      post_confirmation              = lookup(var.lambda_triggers, "post_confirmation", null)
      pre_authentication             = lookup(var.lambda_triggers, "pre_authentication", null)
      post_authentication            = lookup(var.lambda_triggers, "post_authentication", null)
      pre_token_generation           = lookup(var.lambda_triggers, "pre_token_generation", null)
      user_migration                 = lookup(var.lambda_triggers, "user_migration", null)
      custom_message                 = lookup(var.lambda_triggers, "custom_message", null)
      define_auth_challenge          = lookup(var.lambda_triggers, "define_auth_challenge", null)
      create_auth_challenge          = lookup(var.lambda_triggers, "create_auth_challenge", null)
      verify_auth_challenge_response = lookup(var.lambda_triggers, "verify_auth_challenge_response", null)
      kms_key_id                     = lookup(var.lambda_triggers, "kms_key_id", null)
    }
  }

  # User Pool Add-ons (Advanced Security)
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Username Configuration
  # username_attributes and alias_attributes are mutually exclusive
  username_attributes = length(var.alias_attributes) == 0 ? var.username_attributes : null
  alias_attributes    = length(var.alias_attributes) > 0 ? var.alias_attributes : null
  username_configuration {
    case_sensitive = var.username_case_sensitive
  }

  # Admin Create User Config
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_subject = var.invite_message_template.email_subject
      email_message = var.invite_message_template.email_message
      sms_message   = var.invite_message_template.sms_message
    }
  }

  # Device Configuration
  device_configuration {
    challenge_required_on_new_device      = var.device_configuration.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_configuration.device_only_remembered_on_user_prompt
  }

  # Deletion Protection
  deletion_protection = var.enable_deletion_protection ? "ACTIVE" : "INACTIVE"

  tags = local.tags
}
