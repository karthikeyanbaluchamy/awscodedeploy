# output "project_name" {
#   value = aws_codebuild_project.springboot.name
# }

output "project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.springboot.name
}

output "project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.springboot.arn
}

output "role_arn" {
  description = "IAM Role ARN used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}