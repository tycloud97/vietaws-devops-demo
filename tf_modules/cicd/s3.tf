resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.environment_name}-${var.app_name}-codepipeline-artifacts-${lower(random_string.bucket_suffix.result)}"
}
