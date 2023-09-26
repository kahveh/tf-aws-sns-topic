data "aws_caller_identity" "current" {}

locals {
  sns_topic_name              = try(var.topic_name, "sns-topic")
  enable_delivery_status_logs = var.enable_delivery_status_logs
  create_sns_delivery_role    = var.enable_delivery_status_logs && var.delivery_status_lambda_role_arn == ""
  sns_feedback_role           = local.create_sns_delivery_role ? aws_iam_role.sns_delivery_role[0].arn : var.delivery_status_lambda_role_arn

  lambda_failure_feedback_role_arn    = local.enable_delivery_status_logs ? local.sns_feedback_role : null
  lambda_success_feedback_role_arn    = local.enable_delivery_status_logs ? local.sns_feedback_role : null
  lambda_success_feedback_sample_rate = local.enable_delivery_status_logs ? var.delivery_status_lambda_sample_rate : null
}

## SNS Topic
resource "aws_sns_topic" "this" {
  name = local.sns_topic_name

  kms_master_key_id = var.sns_topic_kms_key_id

  lambda_failure_feedback_role_arn    = local.lambda_failure_feedback_role_arn
  lambda_success_feedback_role_arn    = local.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = local.lambda_success_feedback_sample_rate

  tags = var.tags
}

## IAM
data "aws_iam_policy_document" "sns_delivery" {
  count = local.create_sns_delivery_role ? 1 : 0

  statement {
    sid    = "PermitDeliveryStatusMessagesToCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "sns_delivery_role" {
  count = local.create_sns_delivery_role ? 1 : 0

  name                  = var.delivery_status_role_name
  description           = var.delivery_status_role_description
  path                  = var.delivery_status_role_path
  force_detach_policies = var.delivery_status_role_force_detach_policies
  permissions_boundary  = var.delivery_status_role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.sns_delivery[0].json

  tags = merge(var.tags, var.delivery_status_role_tags)
}

data "aws_iam_policy_document" "this" {
  policy_id = "__default_policy"
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermissions",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]
    condition {
      test     = "StringEquals"
      values   = var.sns_account_ids
      variable = "AWS:SourceOwner"
    }
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      aws_sns_topic.this.arn
    ]
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}