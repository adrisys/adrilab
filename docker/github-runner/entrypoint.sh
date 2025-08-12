#!/bin/bash
set -euo pipefail

# GitHub repository and runner configuration
GITHUB_OWNER=${GITHUB_OWNER:-"adrisys"}
GITHUB_REPO=${GITHUB_REPO:-"adrxlab"}
RUNNER_NAME=${RUNNER_NAME:-"self-hosted-terraform-runner"}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,terraform,proxmox,ansible"}
RUNNER_VERSION="${RUNNER_VERSION:-2.327.1}"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN environment variable is required" >&2
  exit 1
fi

echo "Setting up local configuration files..."
[ -f "/home/runner/terraform.tfvars" ] && echo "✓ Found local terraform.tfvars at /home/runner/terraform.tfvars" || echo "⚠ No local terraform.tfvars found. Make sure to mount it as a volume."
[ -f "/home/runner/hosts.yml" ] && echo "✓ Found local hosts.yml at /home/runner/hosts.yml" || echo "⚠ No local hosts.yml found. Make sure to mount it as a volume."
if [ -d "/home/runner/.ssh" ]; then
  echo "✓ Found SSH keys directory"
  chmod 700 /home/runner/.ssh || true
  chmod 600 /home/runner/.ssh/* 2>/dev/null || true
  chown -R runner:runner /home/runner/.ssh 2>/dev/null || true
else
  echo "⚠ No SSH keys found. Make sure to mount ~/.ssh as a volume for Ansible."
fi

# Ensure work directory exists and owned by current user
mkdir -p _work || true
chown -R $(id -u):$(id -g) _work || true

# Download runner only if not present
if [ ! -f "./run.sh" ]; then
  echo "Downloading GitHub Actions runner..."
  curl -fsSL -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
  tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
  rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
else
  echo "Runner already present. Skipping download."
fi

# Install runner dependencies if script exists (non-fatal)
if [ -f "./bin/installdependencies.sh" ]; then
  echo "Installing GitHub Actions runner dependencies (sanitized)..."
  cp ./bin/installdependencies.sh /tmp/installdependencies.sh
  sed -i -E -e "s/libssl1\.1\/g" -e "s/libssl1\.0\.2\/g" -e "s/libssl1\.0\.0\/g" -e "s/libicu7[12]/libicu70/g" /tmp/installdependencies.sh
  chmod +x /tmp/installdependencies.sh
  sudo /tmp/installdependencies.sh || echo "Dependency install had non-fatal errors"
fi

# Configure only if not already configured
if [ ! -f ".runner" ] && [ ! -f ".credentials" ]; then
  echo "Checking for existing runner with the same name and deleting it if found..."
  runners_json=$(curl -fsSL -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners?per_page=100") || runners_json='{}'
  if command -v jq >/dev/null 2>&1; then
    runner_id=$(echo "$runners_json" | jq -r ".runners[]? | select(.name == \"$RUNNER_NAME\") | .id" 2>/dev/null | head -n1)
  else
    runner_id=""
  fi
  if [ -n "${runner_id:-}" ] && [ "$runner_id" != "null" ]; then
    echo "Found existing runner id=$runner_id with name $RUNNER_NAME; attempting delete..."
    curl -fsS -X DELETE -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners/$runner_id" >/dev/null || true
    echo "Delete request sent (ignored errors)."
  fi

  echo "Getting runner registration token..."
  RUNNER_TOKEN=$(curl -fsSL -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners/registration-token" | jq -r .token)
  if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" = "null" ]; then
    echo "ERROR: Failed to get runner registration token" >&2
    exit 1
  fi

  echo "Configuring runner..."
  ./config.sh \
    --url "https://github.com/$GITHUB_OWNER/$GITHUB_REPO" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "_work" \
    --unattended
else
  echo "Runner already configured. Skipping config."
fi

echo "Starting runner..."
exec ./run.sh
