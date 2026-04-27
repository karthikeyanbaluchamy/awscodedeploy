
provider "aws" {
	  region = "us-east-1
  
}

module "ecr" {
  source = "./modules/ecr"
  name   = "my-app-repo"
}

module "codebuild" {
  source        = "./modules/codebuild"
  aws_region =var.regiondata
  ecr_repo_url = module.ecr.repository_url
}


module "ecs_fargate" {
  source = "./modules/ecs-fargate"

  ecs_cluster_name = "springboot-app-cluster"
  ecs_service_name = "Spring-demo-task-defination-service"

  container_image = "${module.ecr.repository_url}:latest"

  subnet_ids = ["subnet-08e7f33ce126ce03f", "subnet-0c8e91d3533cfe5bf"]
  vpc_id     = "vpc-0a1eff56652c3f949"
}

module "codepipeline" {
  source = "./modules/codepipeline"

  pipeline_name = "springbootpipeline"

  role_arn        = "arn:aws:iam::905418049972:role/AWSCodePipelineServiceRole-us-east-1-test"
  artifact_bucket = "codepipeline-us-east-1-526ca0b6f11f-42fa-9685-ccedd266c1af"

  # Source
  connection_arn = "arn:aws:codeconnections:us-east-1:905418049972:connection/59775662-7e3b-4bc3-b928-b0675fb933f4"
  repo_id        = "karthikeyanbaluchamy/awsspringcode"
  branch         = "main"

  # Build
  codebuild_project_name = module.codebuild.project_name

  # Deploy
  ecs_cluster_name =  module.ecs_fargate.cluster_id
  ecs_service_name = module.ecs_fargate.service_name
}
