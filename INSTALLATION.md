# Installation Guide

This guide covers all methods to install OneChart in your Kubernetes cluster.

## Method 1: GitHub Pages (Recommended)

The simplest method - no authentication required.

### Add the repository:
```bash
helm repo add onechart https://minkbear.github.io/onechart
helm repo update
```

### Search available charts:
```bash
helm search repo onechart
```

### Install a chart:
```bash
# Install latest version
helm install my-release onechart/onechart

# Install specific version
helm install my-release onechart/onechart --version 0.74.0

# Install with custom values
helm install my-release onechart/onechart -f my-values.yaml
```

### Available charts:
- `onechart/onechart` - Web application deployments
- `onechart/cron-job` - Scheduled job workloads
- `onechart/static-site` - Static website hosting

## Method 2: OCI Registry (GitHub Container Registry)

Modern OCI-based registry format using GitHub Container Registry. No authentication required.

```bash
# Template the chart
helm template my-release oci://ghcr.io/minkbear/onechart --version 0.74.0

# Install the chart
helm install my-release oci://ghcr.io/minkbear/onechart --version 0.74.0

# Pull the chart locally
helm pull oci://ghcr.io/minkbear/onechart --version 0.74.0

# Unpack after pull
helm pull oci://ghcr.io/minkbear/onechart --version 0.74.0 --untar
```

### Available OCI charts:
- `oci://ghcr.io/minkbear/onechart`
- `oci://ghcr.io/minkbear/cron-job`
- `oci://ghcr.io/minkbear/static-site`

## Method 3: Local Installation

For development or offline usage.

### Clone the repository:
```bash
git clone https://github.com/minkbear/onechart.git
cd onechart
```

### Install dependencies:
```bash
helm dependency update charts/onechart
```

### Install from local path:
```bash
helm install my-release charts/onechart/ -f my-values.yaml
```

### Template locally:
```bash
helm template my-release charts/onechart/ -f my-values.yaml
```

## Quick Start Example

```bash
# Add the repository
helm repo add onechart https://minkbear.github.io/onechart

# Create a values file
cat > my-app-values.yaml <<EOF
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

replicas: 2

containerPort: 80

ingress:
  enabled: true
  host: my-app.example.com
  ingressClassName: nginx
  tlsEnabled: true

vars:
  ENV: production
  DEBUG: "false"

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
EOF

# Install the chart
helm install my-app onechart/onechart -f my-app-values.yaml

# Check the deployment
kubectl get pods
kubectl get ingress
```

## Upgrading

```bash
# Using traditional repository
helm repo update
helm upgrade my-release onechart/onechart --version 0.74.0 -f my-values.yaml

# Using OCI
helm upgrade my-release oci://ghcr.io/minkbear/onechart --version 0.74.0 -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall my-release
```

## Troubleshooting

### Repository not found
```bash
# Verify repository is added
helm repo list

# Re-add if needed
helm repo remove onechart
helm repo add onechart https://minkbear.github.io/onechart
helm repo update
```

### Package not found on GHCR
If you get "not found" errors:
1. Check the version exists: Visit https://github.com/minkbear/onechart/packages
2. Verify the package name and version are correct
3. Use GitHub Pages method instead (Method 1)

## Version Information

To see all available versions:

```bash
# GitHub Pages
helm search repo onechart/onechart --versions

# OCI (requires listing via GitHub API)
curl https://ghcr.io/v2/minkbear/onechart/tags/list
```

## Additional Resources

- [Chart Values Documentation](charts/onechart/values.yaml)
- [Examples](website/docs/examples/)
- [GitHub Repository](https://github.com/minkbear/onechart)
