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
  for_each = var.repo_secrets

  repository      = data.github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}

# ─── Environment secrets (production) ────────────────────────────────────────
resource "github_actions_environment_secret" "env" {
  for_each = var.env_secrets

  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.env.environment
  secret_name     = each.key
  plaintext_value = each.value
}
