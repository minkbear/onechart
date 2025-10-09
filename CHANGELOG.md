# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.74.0] - 2024-10-08

### Added

- **ServiceAccount Template** ([#16f4d3d](https://github.com/minkbear/onechart/commit/16f4d3d))
  - New `serviceaccount.yaml` template for Kubernetes RBAC
  - Support for custom service account configuration
  - Automatic service account creation with optional annotations
  - Comprehensive unit tests for service account scenarios
  - Values configuration under `serviceAccount.*`

- **ExternalSecrets Support** ([#9823c42](https://github.com/minkbear/onechart/commit/9823c42))
  - New `externalsecrets.yaml` template for External Secrets Operator integration
  - Support for multiple external secrets with different backends
  - Backend support: AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, Vault
  - Configurable refresh intervals and secret stores
  - Full unit test coverage
  - Values configuration under `externalSecrets.*`

- **Persistent Volume (PV) Template** ([#049e046](https://github.com/minkbear/onechart/commit/049e046))
  - New `pv.yaml` template for static Persistent Volume provisioning
  - Support for multiple storage types: hostPath, nfs, local, csi
  - Configurable storage class, capacity, and access modes
  - Node affinity support for local volumes
  - Comprehensive test coverage for all PV types
  - Values configuration under `pv.*`

### Fixed

- **Service Account RBAC Conditions** ([#0ccf882](https://github.com/minkbear/onechart/commit/0ccf882))
  - Improved conditional logic in `serviceaccount.yaml` template
  - Fixed RBAC-related rendering issues
  - Updated unit tests for better coverage

- **Helm Chart Packaging Process** ([#c56f9a3](https://github.com/minkbear/onechart/commit/c56f9a3))
  - Streamlined GitHub Actions release workflow
  - Simplified chart packaging and publishing process
  - Improved reliability of automated releases

### Documentation

- Migrated Helm repository from `chart.onechart.dev` to GitHub Pages (`https://minkbear.github.io/onechart`)
- Added comprehensive OCI registry (GHCR) support documentation
- Created `INSTALLATION.md` with three installation methods
- Added `CLAUDE.md` for development guidance
- Added `scripts/push-to-ghcr.sh` for manual GHCR publishing
- Updated all documentation for public GHCR packages (no authentication required)

### Infrastructure

- GitHub Pages configured to serve Helm charts from `docs/` directory
- GHCR packages now public and accessible without authentication
- Automated release workflow for dual publishing (GitHub Pages + GHCR)

## Features Summary for v0.74.0

This release significantly expands OneChart's capabilities for production Kubernetes deployments:

1. **RBAC Integration**: Full service account support with automatic RBAC configuration
2. **Secrets Management**: External Secrets Operator integration for secure credential handling
3. **Storage Management**: Static persistent volume provisioning for stateful workloads
4. **Dual Distribution**: Available via both traditional Helm repository and OCI registry

### Breaking Changes

None. This release is fully backward compatible.

### Upgrade Notes

No special upgrade procedures required. All new features are opt-in via values configuration.

### New Values Configuration

```yaml
# Service Account
serviceAccount:
  enabled: true
  create: true
  name: ""
  annotations: {}

# External Secrets
externalSecrets:
  - name: my-secret
    enabled: true
    backend: aws
    secretStore: aws-secret-store
    refreshInterval: 1h
    data:
      - secretKey: password
        remoteRef:
          key: prod/db/password

# Persistent Volume
pv:
  enabled: true
  name: my-pv
  storageClassName: manual
  capacity: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
```

## Installation

### GitHub Pages (Recommended)
```bash
helm repo add onechart https://minkbear.github.io/onechart
helm install my-release onechart/onechart --version 0.74.0
```

### OCI Registry (GitHub Container Registry)
```bash
helm install my-release oci://ghcr.io/minkbear/onechart --version 0.74.0
```

---

## [Unreleased]

### Changed
- Version bumped to 0.75.0 for next release

---

**Full Changelog**: https://github.com/minkbear/onechart/compare/2c6826f...v0.74.0

[0.74.0]: https://github.com/minkbear/onechart/releases/tag/v0.74.0
[Unreleased]: https://github.com/minkbear/onechart/compare/v0.74.0...HEAD
