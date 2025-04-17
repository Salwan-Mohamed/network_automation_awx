# Building a Custom AWX Execution Environment

This document explains how to build and use a custom AWX Execution Environment with legacy SSH support.

## Prerequisites

- Docker installed on a build machine
- Access to your AWX instance with admin privileges
- Container registry (Docker Hub, quay.io, or a private registry)

## Building the Custom Execution Environment

1. Navigate to the docker directory:
```
cd docker
```

2. Build the Docker image:
```
docker build -t your-registry/aruba-legacy-ee:latest .
```

3. Push the Docker image to your registry:
```
docker push your-registry/aruba-legacy-ee:latest
```

## Registering the Execution Environment in AWX

1. Log in to your AWX instance as an admin
2. Navigate to Administration → Execution Environments
3. Click the "+" button to add a new Execution Environment
4. Fill in the details:
   - Name: Aruba Legacy EE
   - Image: your-registry/aruba-legacy-ee:latest
   - Pull: Always
5. Click "Save"

## Using the Custom Execution Environment

1. Edit your Job Templates 
2. Under "Execution Environment", select "Aruba Legacy EE"
3. Save the Job Template
4. Run the job

## What This Execution Environment Provides

This custom execution environment includes:

1. **Legacy SSH Support**: Pre-configured to work with older SSH algorithms
   - KexAlgorithms: Added support for diffie-hellman-group14-sha1, diffie-hellman-group1-sha1, diffie-hellman-group-exchange-sha1
   - HostKeyAlgorithms: Added support for ssh-rsa
   - PubkeyAcceptedAlgorithms: Added support for ssh-rsa

2. **Global Configuration**: System-wide SSH and Ansible configurations for network devices

3. **Additional Python Packages**: Includes pexpect for interactive SSH sessions

## Simplified Inventory File

When using this execution environment, you can use a simpler inventory file as the SSH parameters are configured globally:

```ini
[all:vars]
ansible_user=ansibleadmin
ansible_password=An$12345

[aruba_switches]
aruba_11 ansible_host=10.2.127.11
aruba_12 ansible_host=10.2.127.12
# etc.
```

## Troubleshooting

If you encounter issues with the execution environment:

1. Check the container logs:
```
docker logs <container_id>
```

2. Test the SSH connection manually from inside the container:
```
docker exec -it <container_id> ssh ansibleadmin@10.2.127.11
```

3. Verify the SSH configuration was applied correctly:
```
docker exec -it <container_id> cat /etc/ssh/ssh_config
```