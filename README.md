# One chart to rule them all

A generic Helm chart for your application deployments.

Because no-one can remember the Kubernetes yaml syntax.

https://gimlet.io/docs/reference/onechart-reference


## Quick Start

### Installation

Add the Helm repository:

```bash
helm repo add onechart https://minkbear.github.io/onechart
helm repo update
```

### Basic Usage

```bash
# Install with simple configuration
helm install my-app onechart/onechart \
  --set image.repository=nginx \
  --set image.tag=1.21

# Or use a values file
helm install my-app onechart/onechart -f values.yaml
```

### Example values.yaml

```yaml
image:
  repository: my-app
  tag: v1.0.0

replicas: 2

ingress:
  enabled: true
  host: my-app.example.com
  ingressClassName: nginx

vars:
  ENV: production
  DATABASE_URL: postgres://...
```

## Installation Methods

OneChart is available through multiple channels:

### 📦 GitHub Pages (Recommended)
```bash
helm repo add onechart https://minkbear.github.io/onechart
helm install my-app onechart/onechart --version 0.74.0
```

### 🐳 OCI Registry (GitHub Container Registry)
```bash
helm install my-app oci://ghcr.io/minkbear/onechart --version 0.74.0
```

### 📚 Available Charts
- **onechart** - Web applications and APIs
- **cron-job** - Scheduled job workloads
- **static-site** - Static website hosting

For detailed installation instructions, see [INSTALLATION.md](INSTALLATION.md).

## Features

- ✅ Production-ready Kubernetes deployments
- ✅ Service Account & RBAC support
- ✅ External Secrets integration (AWS, GCP, Azure, Vault)
- ✅ Persistent Volume management
- ✅ Ingress with TLS support
- ✅ Auto-scaling (HPA)
- ✅ Pod Disruption Budgets
- ✅ Prometheus monitoring integration
- ✅ And much more!

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Contribution Guidelines

Thank you for your interest in contributing to the Gimlet project.

Below are some guidelines and best practices for contributing to this repository:

### Issues

If you are running a fork of OneChart and would like to upstream a feature, please open a pull request for it.

### New Features

If you are planning to add a new feature to OneChart, please open an issue for it first. Helm charts are prone to having too many features, and OneChart want to keep the supported use-cases in-check. Proposed features have to be generally applicable, targeting newcomers to the Kubernetes ecosystem.

### Pull Request Process

* Fork the repository.
* Create a new branch and make your changes.
* Open a pull request with detailed commit message and reference issue number if applicable.
* A maintainer will review your pull request, and help you throughout the process.

## Development

Development of OneChart does not differ from developing a regular Helm chart.

The source for OneChart is under `charts/onechart` where you can locate the `Chart.yaml`, `values.yaml` and the templates.

We write unit tests for our helm charts. Pull requests are only accepted with proper test coverage.

The tests are located under `charts/onechart/test` and use the https://github.com/helm-unittest/helm-unittest Helm plugin to run the tests.

For installation, refer to the CI workflow at `.github/workflows/build.yaml`.

## For Maintainers

- **Release Process**: See [RELEASE.md](RELEASE.md)
- **Development Guide**: See [CLAUDE.md](CLAUDE.md)
- **Changelog**: See [CHANGELOG.md](CHANGELOG.md)
