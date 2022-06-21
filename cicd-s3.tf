resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-viet-aws-v2-${lower(random_string.bucket_suffix.result)}"
}
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
}
