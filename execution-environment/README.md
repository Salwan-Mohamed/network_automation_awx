# Aruba Network Execution Environment

This directory contains the files needed to build a custom AWX Execution Environment for Aruba network automation.

## What is an Execution Environment?

An Execution Environment is a container image used by AWX/Ansible Automation Platform to run Ansible playbooks. It includes Python dependencies, system packages, and custom configurations needed for specific automation tasks.

## Components

- **execution-environment.yml**: Main configuration file for the execution environment
- **requirements.txt**: Python package dependencies
- **bindep.txt**: System package dependencies
- **build.sh**: Helper script to build and push the execution environment

## Key Features

This execution environment includes:

1. **Legacy SSH Support**: Pre-configured SSH settings to work with older Aruba devices:
   - Support for legacy key exchange algorithms (diffie-hellman-group14-sha1)
   - Support for ssh-rsa host keys
   - Support for ssh-rsa public key authentication

2. **Required Python Packages**:
   - pexpect: For handling interactive SSH sessions
   - netaddr: For IP address handling
   - ansible-pylibssh: For improved SSH connectivity
   - jmespath: For JSON data manipulation

3. **System Packages**:
   - openssh-client: For SSH connectivity
   - sshpass: For password-based SSH authentication
   - expect: For interactive automation

## Building the Execution Environment

You can build the execution environment using the provided build script:

```bash
chmod +x build.sh
./build.sh
```

The script will:
1. Check for ansible-builder
2. Build the execution environment
3. Optionally push to a container registry

## Using with AWX

To use this execution environment in AWX:

1. Build and push the image to a container registry accessible by your AWX instance
2. Register the execution environment in AWX (see the ../docs/awx_setup.md document for details)
3. Select this execution environment when creating job templates

## Customization

You can customize the execution environment:

1. Add additional Python packages to requirements.txt
2. Add additional system packages to bindep.txt
3. Add additional build steps to execution-environment.yml

## Troubleshooting

If you encounter issues with the execution environment:

1. Check that your container registry is accessible from your AWX instance
2. Verify that all the SSH parameters are correctly configured
3. Test connectivity with a basic playbook before running more complex automation
4. Check the AWX logs for any container pull or execution errors