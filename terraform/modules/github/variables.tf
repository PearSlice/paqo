variable "github_repo" {
  description = "Repository name (without owner prefix)"
  type        = string
}

variable "environment_name" {
  description = "GitHub environment name (e.g. production)"
  type        = string
}

variable "repo_secrets" {
  description = "Map of repository-level secrets"
  type        = map(string)
  sensitive   = true
}

variable "env_secrets" {
  description = "Map of environment-level secrets"
  type        = map(string)
  sensitive   = true
}
