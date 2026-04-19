
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
