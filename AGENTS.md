# AGENTS.md

These instructions apply to this repository.

## Default Workflow
- Keep changes scoped to the user request.
- Do not revert unrelated local changes.
- Prefer updating existing scripts/workflows over introducing one-off commands.

## Terraform Module Docs (Required)
- After any change under `modules/**` (except README-only edits), run:
  `./generate-docs.sh --all`
- Stage any resulting `modules/*/README.md` updates in the same commit.
- Before finalizing, verify there are no `modules/**` code changes without corresponding generated docs updates.

## Validation
- For edited Terraform files, run `terraform fmt` on changed files.

## Flux configurations
- When adding or changing a flux configuration (`azapi_resource` of type
  `Microsoft.KubernetesConfiguration/fluxConfigurations`), set each kustomization's
  `syncIntervalInSeconds = 3600`. Keep `ociRepository.syncIntervalInSeconds = 300`
  and `retryIntervalInSeconds = 300`: a new artifact triggers a reconcile through
  the source, so the kustomization interval only controls drift correction.
- Leave intervals that are deliberately different as they are, e.g. the one-year
  linkerd `post-deploy` interval.
