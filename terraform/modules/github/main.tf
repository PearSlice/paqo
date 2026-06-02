locals {
  repo_secret_keys = toset(keys(var.repo_secrets))
  env_secret_keys = toset(keys(var.env_secrets))
}


# ─── Fetch repo data ──────────────────────────────────────────────────────────
data "github_repository" "repo" {
  name = var.github_repo
}

# ─── Ensure the environment exists ───────────────────────────────────────────
resource "github_repository_environment" "env" {
  repository  = data.github_repository.repo.name
  environment = var.environment_name
}

# ─── Repository secrets ───────────────────────────────────────────────────────
resource "github_actions_secret" "repo" {
  for_each = local.repo_secret_keys

  repository      = data.github_repository.repo.name
  secret_name     = each.key
  plaintext_value = var.repo_secrets[each.key]
}

# ─── Environment secrets (production) ────────────────────────────────────────
resource "github_actions_environment_secret" "env" {
  for_each = local.env_secret_keys

  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.env.environment
  secret_name     = each.key
  plaintext_value = var.env_secrets[each.key]
}