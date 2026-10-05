terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.2"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "~> 2.7.0"
    }
  }
}