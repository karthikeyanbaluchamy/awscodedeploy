resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-springboot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codeconnections:UseConnection",
          "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection"
        ]
        Resource = "arn:aws:codestar-connections:us-east-1:905418049972:connection/6f04d26e-7bd7-41e4-aa3c-91efa7dea52c"
      },

      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "springboot" {
  name         = "springboot-build"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/karthikeyanbaluchamy/awsspringcode.git"
    git_clone_depth = 1
    buildspec = "buildspec.yaml"
    auth {
      type     = "CODECONNECTIONS"
      resource = "arn:aws:codestar-connections:us-east-1:905418049972:connection/6f04d26e-7bd7-41e4-aa3c-91efa7dea52c"
    }
  }

  source_version = "main"

  

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO"
      value = var.ecr_repo_url
    }
    environment_variable {
               name  = "DOCKER_USERNAME"
               type  = "PLAINTEXT"
               value = "karthikeyan.baluchamy@outlook.com"
            }
           environment_variable {
               name  = "DOCKER_PASSWORD"
               type  = "PLAINTEXT"
               value = "Vidhya1982"
            }
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/springboot-build"
      stream_name = "build-log"
    }
  }

  depends_on = [aws_iam_role_policy.codebuild_policy]
}