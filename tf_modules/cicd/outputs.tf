output "repository_url" {
  description = "Repository URL"
  value       = aws_codecommit_repository.codecommit.clone_url_ssh
}