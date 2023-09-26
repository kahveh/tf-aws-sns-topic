variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "topic_name" {
  description = "The name of the SNS topic to create"
  type        = string
  default     = null
}

variable "sns_topic_kms_key_id" {
  description = "ARN of the KMS key used for enabling SSE on the topic"
  type        = string
  default     = ""
}

variable "enable_delivery_status_logs" {
  description = "Whether to enable SNS delivery status logs"
  type        = bool
  default     = false
}

variable "delivery_status_lambda_role_arn" {
  description = "IAM role for SNS delivery status logs.  If this is set then a role will not be created for you."
  type        = string
  default     = ""
}


variable "delivery_status_lambda_sample_rate" {
  description = "The percentage of successful deliveries to log"
  type        = number
  default     = 100
}

variable "delivery_status_role_name" {
  description = "Name of the IAM role to use for SNS delivery status logging"
  type        = string
  default     = null
}

variable "delivery_status_role_description" {
  description = "Description of IAM role to use for SNS delivery status logging"
  type        = string
  default     = null
}

variable "delivery_status_role_path" {
  description = "Path of IAM role to use for SNS delivery status logging"
  type        = string
  default     = null
}

variable "delivery_status_role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it."
  type        = bool
  default     = true
}

variable "delivery_status_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by SNS delivery status logging"
  type        = string
  default     = null
}

variable "delivery_status_role_tags" {
  description = "A map of tags to assign to IAM the SNS delivery status role"
  type        = map(string)
  default     = {}
}

variable "sns_account_ids" {
  type    = list(string)
  default = null
}