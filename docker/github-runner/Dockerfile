# GitHub Actions Self-Hosted Runner with Terraform
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ALLOW_RUNASROOT=1

# Install dependencies including Node.js and .NET Core dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    sudo \
    ca-certificates \
    gnupg \
    # .NET Core 6.0 dependencies for GitHub Actions runner
    libicu70 \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
ENV TERRAFORM_VERSION=1.12.1
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible with updated versions and collections
RUN python3 -m pip install --upgrade pip \
    && pip3 install "ansible-core>=2.15,<2.17" ansible-lint \
    && ansible-galaxy collection install community.general \
    && ansible --version

# Create runner user
RUN useradd -m -s /bin/bash runner \
    && usermod -aG sudo runner \
    && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory and fix permissions
WORKDIR /home/runner
RUN mkdir -p /home/runner/_work \
    && chown -R runner:runner /home/runner \
    && chmod -R 755 /home/runner

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY setup-runner-files.sh /home/runner/setup-runner-files.sh
RUN chmod +x /entrypoint.sh /home/runner/setup-runner-files.sh

# Install GitHub Actions runner dependencies script
# This will be run after the runner is downloaded in entrypoint.sh
RUN echo '#!/bin/bash\n\
if [ -f "./bin/installdependencies.sh" ]; then\n\
    echo "Installing GitHub Actions runner dependencies..."\n\
    sudo ./bin/installdependencies.sh\n\
fi' > /install-runner-deps.sh && chmod +x /install-runner-deps.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]
