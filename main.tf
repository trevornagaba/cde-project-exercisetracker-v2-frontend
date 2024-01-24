terraform {
  cloud {
    organization = "trevornagaba"
    workspaces {
      name = "cde-project-exercisetracker-frontend"
    }
  }
  ## Used to provision infrastrcture; in this case aws
  ## These can be foound in the terraform registry 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}