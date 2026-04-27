



variable "pipeline_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

# Source
variable "connection_arn" {
  type = string
}

variable "repo_id" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

# Build
variable "codebuild_project_name" {
  type = string
}

# Deploy
variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}