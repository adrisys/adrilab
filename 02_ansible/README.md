# Ansible Playbooks

This directory contains Ansible playbooks and related files for managing infrastructure.

## Directory Structure

- **inventory/**: Contains inventory files for different environments (prod/test).
  - **prod/**: Production environment inventory and variables.
  - **test/**: Test environment inventory and variables.
  
- **playbooks/**: Contains the main playbooks for configuration and deployment.
  - **site.yml**: The main playbook for orchestrating tasks.
  - **webservers.yml**: Playbook for configuring web servers.
  - **database.yml**: Playbook for configuring database servers.

- **roles/**: Contains reusable roles for different tasks.
  - **common/**: Common tasks and configurations.
  - **webserver/**: Tasks and configurations specific to web servers.

## Usage

To run a playbook, use the following command:

```
ansible-playbook playbooks/<playbook_name>.yml
```

Replace `<playbook_name>` with the desired playbook (e.g., `site`, `webservers`, or `database`). 

Ensure that you have the necessary inventory files set up in the `inventory/` directory for the environment you wish to target.