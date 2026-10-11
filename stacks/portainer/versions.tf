terraform {
  required_version = ">= 1.6.0"

  backend "local" {}

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "~> 2.7.0"
    }
  }
}
