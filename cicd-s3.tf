resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-viet-aws"
  acl    = "private"
} 