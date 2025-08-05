# Self-Hosted GitHub Actions Runner

This directory contains a Docker-based self-hosted GitHub Actions runner specifically configured for Terraform operations on virtualized infrastructure. The runner includes Terraform, Node.js, and other necessary tools for automated infrastructure deployment and CI/CD workflows.

## 📋 What's Included

- **Ubuntu 22.04** base image
- **Terraform 1.12.1** for infrastructure as code
- **Node.js 20.x LTS** for GitHub Actions compatibility
- **Docker socket access** for containerized workflows
- **Persistent workspace** for runner data

## 🚀 Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- GitHub repository with Actions enabled
- GitHub Personal Access Token with appropriate permissions

### Step 1: Create GitHub Personal Access Token

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Set expiration and select these permissions:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Admin access to repository hooks)
   - ✅ `workflow` (Update GitHub Action workflows)
4. Copy the generated token (you won't see it again!)

### Step 2: Configure Environment Variables

Create and configure your environment file:

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your GitHub token
echo "GITHUB_TOKEN=your_github_personal_access_token_here" > .env
```

### Step 3: Deploy the Runner

```bash
# Build and start the runner
docker-compose up -d

# Monitor the registration process
docker-compose logs -f github-runner
```

You should see output like:
```
✓ Runner successfully added
✓ Runner connection is good
✓ Settings Saved.
√ Connected to GitHub
```

### Step 4: Verify Registration

1. Navigate to your repository on GitHub
2. Go to **Settings** → **Actions** → **Runners**
3. Confirm your runner appears as "Online" with labels: `self-hosted`, `terraform`, `hypervisor`, `docker`

## 🎯 How to Use the Runner

### Workflows Already Configured

The repository's Terraform workflows are pre-configured to use this self-hosted runner:

- 🔍 **Validate Terraform** - `runs-on: [self-hosted, terraform]`
- 📋 **Plan Terraform Changes** - `runs-on: [self-hosted, terraform]`
- 🚀 **Deploy Infrastructure** - `runs-on: [self-hosted, terraform]`

### Triggering Workflows

**Manual Deployment (Recommended for Testing):**

1. Go to your repository's Actions tab
2. Select the "Terraform Infrastructure" workflow
3. Click "Run workflow" → Select action (`plan` or `apply`) → Run

**Automatic Triggers:**

- Pull requests with `terraform/` changes → Validation + Planning
- Pushes to main with `terraform/` changes → Full deployment

### Monitor Runner Activity

```bash
# Watch runner logs in real-time
docker-compose logs -f github-runner

# Check runner status
docker-compose ps

# View runner resource usage
docker stats github-runner-container
```

## 🏷️ Runner Configuration

**Runner Labels:** `self-hosted`, `terraform`, `hypervisor`, `docker`

**Environment Variables:**
- `GITHUB_OWNER`: Repository owner
- `GITHUB_REPO`: Repository name  
- `RUNNER_NAME`: Custom runner identifier
- `RUNNER_LABELS`: self-hosted,terraform,hypervisor,docker

**Volumes:**
- Docker socket: `/var/run/docker.sock` (for container operations)
- Workspace data: `./runner-data:/home/runner/_work` (persistent job data)## 🛠️ Troubleshooting

### Common Issues and Solutions

**Runner not appearing in GitHub:**

```bash
# Check if the runner is running
docker-compose ps

# View registration logs
docker-compose logs github-runner
```

**Runner shows offline:**

```bash
# Restart the runner service
docker-compose restart github-runner

# Check container health
docker-compose logs -f github-runner
```

**Complete runner reset:**

```bash
# Stop and remove containers
docker-compose down

# Clean up runner data (optional)
sudo rm -rf ./runner-data/*

# Rebuild and restart
docker-compose up -d
```

## 🔒 Security Considerations

- **Network Access**: Runner has access to private network and virtualized infrastructure
- **Credential Management**: Use GitHub Secrets for sensitive data instead of environment variables
- **Isolation**: Consider running on a dedicated VM with restricted network access
- **Updates**: Regularly update the runner image and base OS for security patches
- **Monitoring**: Monitor runner logs for suspicious activity
- **Access Control**: Limit repository access and use branch protection rules
