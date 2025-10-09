#!/bin/bash
set -e

# Script to manually push Helm charts to GitHub Container Registry (GHCR)
# Usage: ./scripts/push-to-ghcr.sh [version]

GITHUB_USERNAME="minkbear"
GHCR_REGISTRY="ghcr.io/${GITHUB_USERNAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get version from argument or Chart.yaml
if [ -n "$1" ]; then
  VERSION="$1"
else
  VERSION=$(grep '^version:' charts/onechart/Chart.yaml | awk '{print $2}')
fi

echo -e "${GREEN}=== Pushing Helm Charts to GHCR ===${NC}"
echo -e "Version: ${YELLOW}${VERSION}${NC}"
echo -e "Registry: ${YELLOW}${GHCR_REGISTRY}${NC}"
echo ""

# Check if logged in to GHCR
echo -e "${YELLOW}Checking GHCR authentication...${NC}"
if ! helm registry login ${GHCR_REGISTRY%%/*} 2>/dev/null; then
  echo -e "${RED}Not logged in to GHCR!${NC}"
  echo ""
  echo "Please login first:"
  echo "  echo \$GITHUB_TOKEN | helm registry login ghcr.io --username ${GITHUB_USERNAME} --password-stdin"
  echo ""
  echo "Create a token at: https://github.com/settings/tokens/new"
  echo "Required scopes: write:packages, read:packages"
  exit 1
fi

echo -e "${GREEN}✓ Authenticated${NC}"
echo ""

# Check if packaged charts exist
CHARTS=("onechart" "cron-job" "static-site")
MISSING_CHARTS=()

for CHART in "${CHARTS[@]}"; do
  CHART_FILE="docs/${CHART}-${VERSION}.tgz"
  if [ ! -f "${CHART_FILE}" ]; then
    MISSING_CHARTS+=("${CHART}")
  fi
done

if [ ${#MISSING_CHARTS[@]} -gt 0 ]; then
  echo -e "${RED}Missing packaged charts:${NC}"
  for CHART in "${MISSING_CHARTS[@]}"; do
    echo "  - ${CHART}-${VERSION}.tgz"
  done
  echo ""
  echo "Run 'make package' first to create the chart archives"
  exit 1
fi

# Push charts to GHCR
for CHART in "${CHARTS[@]}"; do
  CHART_FILE="docs/${CHART}-${VERSION}.tgz"
  echo -e "${YELLOW}Pushing ${CHART}...${NC}"

  if helm push "${CHART_FILE}" "oci://${GHCR_REGISTRY}"; then
    echo -e "${GREEN}✓ Successfully pushed ${CHART}${NC}"
  else
    echo -e "${RED}✗ Failed to push ${CHART}${NC}"
    exit 1
  fi
  echo ""
done

echo -e "${GREEN}=== All charts pushed successfully! ===${NC}"
echo ""
echo "Charts are now available at:"
for CHART in "${CHARTS[@]}"; do
  echo "  oci://${GHCR_REGISTRY}/${CHART}:${VERSION}"
done
echo ""
echo -e "${YELLOW}Note: Packages are private by default.${NC}"
echo "To make them public:"
echo "  1. Go to: https://github.com/${GITHUB_USERNAME}/onechart/packages"
echo "  2. Select each package"
echo "  3. Settings → Change visibility to Public"
echo ""
echo "Test installation:"
echo "  helm install my-release oci://${GHCR_REGISTRY}/onechart --version ${VERSION}"
