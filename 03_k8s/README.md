## Kubernetes Configuration
Apply GitOps-style overlays using Kustomize.
- `base/` contains common resources (apps, namespaces).
- `overlays/prod/` and `overlays/test/` are environment-specific.