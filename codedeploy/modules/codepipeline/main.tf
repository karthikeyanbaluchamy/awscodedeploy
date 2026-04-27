resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-test-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codepipeline" "this" {
  name           = var.pipeline_name
  role_arn       = aws_iam_role.codepipeline_role.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  #################################
  # Source Stage (GitHub App)
  #################################
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn        = var.connection_arn
        FullRepositoryId     = var.repo_id
        BranchName           = var.branch
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
      }

      run_order = 1
    }
  }

  #################################
  # Build Stage (CodeBuild)
  #################################
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name
      }

      run_order = 1
    }
  }

  #################################
  # Deploy Stage (ECS)
  #################################
  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildOutput"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }

      run_order = 1
    }
  }

  #################################
  # Optional: Retry / Failure Settings
  #################################
  lifecycle {
    ignore_changes = [
      stage
    ]
  }
}