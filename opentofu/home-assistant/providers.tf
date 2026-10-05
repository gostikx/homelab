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
    # http = {
    #   source  = "hashicorp/http"
    #   version = ">= 3.4"
    # }
    # local = {
    #   source  = "hashicorp/local"
    #   version = ">= 2.5"
    # }
  }
}
