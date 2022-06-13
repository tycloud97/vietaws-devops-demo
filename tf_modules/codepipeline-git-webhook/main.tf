
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider
# provider "github" {
# }

module "label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  enabled = var.active
  name    = var.name
  stage   = var.stage
}


resource "aws_codepipeline_webhook" "default" {
  name            = module.label.id
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = var.codebuild_target_pipeline
  authentication_configuration {
    secret_token = var.webhook_secret
  }
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.github_default_branch_name}"
  }
}

resource "github_repository_webhook" "default" {
  count = var.enabled && length(var.github_repositories) > 0 ? length(var.github_repositories) : 0

  repository = var.github_repositories[count.index]
  active     = var.active

  configuration {
    url          = aws_codepipeline_webhook.default.url
    content_type = var.webhook_content_type
    secret       = var.webhook_secret
    insecure_ssl = var.webhook_insecure_ssl
  }

  events = var.events

  lifecycle {
    # This is required for idempotency
    ignore_changes = [configuration[0].secret]
  }
  depends_on = [aws_codepipeline_webhook.default]
}
