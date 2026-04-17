
provider "aws" {
  region = "us-east-1"
    access_key = "AKIA5FTY7BG2KXSHH5EG"
  secret_key = "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"
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
