terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }
}