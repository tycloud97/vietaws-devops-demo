output "bucket_artifact" {
  value = aws_s3_bucket.ami_pipeline_artifact_store.id
}

output "bucket_artifact_domain_name" {
  value = aws_s3_bucket.ami_pipeline_artifact_store.bucket_domain_name
}

output "codebuild_role" {
  value = aws_iam_role.codebuild_assume_role.arn
}

output "codepipeline_role" {
  value = aws_iam_role.codepipeline_role.arn
}