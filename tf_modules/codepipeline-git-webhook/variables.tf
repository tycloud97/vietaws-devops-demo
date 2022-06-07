variable "enabled" {
  type        = bool
  description = "Whether or not to enable this module"
  default     = true
}

variable "name" {
  type    = string
  default = ""
}

variable "stage" {
  type    = string
  default = ""
}

variable "github_repositories" {
  type        = list(string)
  description = "List of repository names which should be associated with the webhook"
  default     = []
}

variable "github_default_branch_name" {
  type        = string
  description = "Github branch to hook up to"
  default     = ""
}

variable "webhook_content_type" {
  type        = string
  description = "Webhook Content Type (e.g. `json`)"
  default     = "json"
}

variable "webhook_secret" {
  type        = string
  description = "Webhook secret"
  default     = ""
}

variable "webhook_insecure_ssl" {
  type        = bool
  description = "Webhook Insecure SSL (e.g. trust self-signed certificates)"
  default     = true
}

variable "active" {
  type        = bool
  description = "Indicate of the webhook should receive events"
  default     = true
}

variable "events" {
  # Full list of events available here: https://developer.github.com/v3/activity/events/types/
  type        = list(string)
  description = "A list of events which should trigger the webhook."
  default     = ["push"]
}

variable "codebuild_target_pipeline" {
  type        = string
  description = "Codebuild Pipeline reference to create a webhook"
  default     = ""
}
