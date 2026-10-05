terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 4.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}
