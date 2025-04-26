# AWX Setup Guide

This document provides step-by-step instructions for setting up your network automation environment in AWX.

## 1. Create the Project in AWX

1. Log in to your AWX console
2. Navigate to **Projects** in the left menu
3. Click the **+** (Add) button to create a new project
4. Fill in the project details:
   - **Name**: Network Automation AWX
   - **Description**: Aruba network automation project
   - **Organization**: Your organization
   - **SCM Type**: Git
   - **SCM URL**: `https://github.com/Salwan-Mohamed/network_automation_awx.git`
   - **SCM Branch**: main
   - **SCM Update Options**: Check "Clean", "Update on Launch" and "Update Revision on Launch"
5. Click **Save**

## 2. Create the Execution Environment

### Option 1: Build and Push from Command Line

1. Clone the repository:
   ```bash
   git clone https://github.com/Salwan-Mohamed/network_automation_awx.git
   cd network_automation_awx/execution-environment
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

3. Edit the `build.sh` script to update the `REGISTRY_URL` variable to point to your container registry.

4. Run the build script:
   ```bash
   ./build.sh
   ```

5. When prompted, choose whether to push to your registry.

### Option 2: Build in AWX

If your AWX has the ability to build execution environments:

1. In AWX, navigate to **Administration** → **Execution Environments**
2. Click the **+** (Add) button
3. Fill in the details:
   - **Name**: Aruba Network EE
   - **Image**: Leave blank if building a new image
   - **Pull**: Always pull
   - **Description**: Execution environment for Aruba network automation
4. Click the **New image** tab
5. Fill in the build details:
   - **Source Control URL**: `https://github.com/Salwan-Mohamed/network_automation_awx.git`
   - **Source Control Branch**: main
   - **Source Control Refspec**: Leave blank
   - **Execution Environment File**: execution-environment/execution-environment.yml
   - **Build Context Directory**: execution-environment
6. Click **Save**

## 3. Register the Execution Environment in AWX

If you built the environment using Option 1 (command line):

1. Create a Container Registry credential:
   - Go to **Credentials** and click the **+** (Add) button
   - Select **Container Registry** as the credential type
   - Fill in your registry details and credentials
   - Click **Save**

2. Create a new Execution Environment:
   - Navigate to **Administration** → **Execution Environments**
   - Click the **+** (Add) button
   - Fill in the details:
     - **Name**: Aruba Network EE
     - **Image**: your-registry.com/aruba-network-ee:1.0
     - **Pull**: Always pull
     - **Description**: Execution environment for Aruba network automation
     - **Credential**: Select the Container Registry credential you created
   - Click **Save**

## 4. Create Inventory in AWX

1. Navigate to **Inventories** in the left menu
2. Click the **+** (Add) button and select **Inventory**
3. Fill in the inventory details:
   - **Name**: Aruba Network Devices
   - **Description**: Inventory for Aruba switches and controller
   - **Organization**: Your organization
4. Click **Save**

5. Once created, click on the inventory name to view its details
6. Click on the **Sources** tab
7. Click the **+** (Add) button to add a source
8. Fill in the source details:
   - **Name**: Aruba Network Source
   - **Source**: Sourced from a Project
   - **Project**: Select the "Network Automation AWX" project
   - **Inventory File**: inventory/switches_updated.ini
   - **Update Options**: Check "Update on project update" and "Overwrite"
9. Click **Save**

10. Click the **Sync** button to sync the inventory

## 5. Create Job Templates

### Basic Ping Test Job Template

1. Navigate to **Templates** in the left menu
2. Click the **+** (Add) button and select **Job Template**
3. Fill in the details:
   - **Name**: Test Aruba Connectivity
   - **Job Type**: Run
   - **Inventory**: Aruba Network Devices
   - **Project**: Network Automation AWX
   - **Execution Environment**: Aruba Network EE
   - **Playbook**: playbooks/basic_ping_test.yml
   - **Credentials**: Add your SSH credential
   - **Variables**: 
     ```yaml
     ---
     ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa'
     ```
4. Click **Save**

### Configuration Job Template

1. Create another job template
2. Fill in the details:
   - **Name**: Configure Aruba Switches
   - **Job Type**: Run
   - **Inventory**: Aruba Network Devices
   - **Project**: Network Automation AWX
   - **Execution Environment**: Aruba Network EE
   - **Playbook**: playbooks/config_switches.yml
   - **Credentials**: Add your SSH credential
   - **Variables**: Same as above
3. Click **Save**

### Backup Job Template

1. Create another job template
2. Fill in the details:
   - **Name**: Backup Aruba Configurations
   - **Job Type**: Run
   - **Inventory**: Aruba Network Devices
   - **Project**: Network Automation AWX
   - **Execution Environment**: Aruba Network EE
   - **Playbook**: playbooks/backup_configs.yml
   - **Credentials**: Add your SSH credential
   - **Variables**: Same as above
3. Click **Save**

## 6. Run and Test

1. Start with the Test Aruba Connectivity job template
2. Click **Launch** and monitor the output
3. If successful, proceed with the other job templates

## Troubleshooting

If you encounter SSH connection issues:

1. Check the SSH connection parameters in the job template variables
2. Verify that the execution environment has the necessary SSH compatibility settings
3. Try running the test script directly on the AWX server:
   ```bash
   cd /var/lib/awx/projects/_XXX_network_automation_awx/
   chmod +x scripts/test_ssh.sh
   ./scripts/test_ssh.sh 10.2.127.11 ansibleadmin "An$12345"
   ```
4. Review the TROUBLESHOOTING.md file in the repository for more detailed troubleshooting steps