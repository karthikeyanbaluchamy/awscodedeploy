resource "aws_ecr_repository" "this" {
  name = "springboot-app"
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# resource "aws_codestarconnections_connection" "github" {
#   name          = "github-connection"
#   provider_type = "GitHub"
# }