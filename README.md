# Network Automation with AWX for Aruba Switches

This repository contains configuration files for network automation using AWX and Ansible, specifically designed for Aruba switches and controllers.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for Aruba switches using network_cli/ios connection
  - `switches_ssh.ini` - Alternative inventory using basic SSH connection
  - `switches_netconf.ini` - Alternative inventory using NETCONF connection
  - `switches_legacy_ssh.ini` - Inventory with legacy SSH key exchange algorithm support
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring Aruba switches
  - `config_controller.yml` - Playbook for configuring Aruba Mobility Controller
  - `backup_configs.yml` - Playbook for backing up switch configurations
  - `gather_facts.yml` - Playbook for gathering facts from switches
  - `test_show_running.yml` - Test playbook for displaying running configurations
  - `test_controller_show_running.yml` - Test playbook specifically for the controller
  - `test_raw_connection.yml` - Test playbook using raw SSH commands for compatibility
  - `test_legacy_ssh.yml` - Test playbook for devices with legacy SSH algorithms
- `templates/` - Jinja2 templates for generating reports
  - `facts_report.j2` - HTML template for switch facts report

## Inventory Structure

The inventory is organized into several groups:
- `distswitch_N` - Distribution switches in N building
- `distswitch_Dorms` - Distribution switches in Dorms
- `aruba_switches_N` - Access switches in N building
- `aruba_switch__Dorms` - Access switches in Dorms
- `aruba_controller_master` - Aruba controller

## Connection Methods

This repository provides multiple connection methods for compatibility:

1. **Network CLI with IOS** (switches.ini)
   - Uses `ansible_connection=network_cli` with `ansible_network_os=ios`
   - Works with many network devices even if specific OS modules aren't installed

2. **Basic SSH** (switches_ssh.ini)
   - Uses `ansible_connection=ssh`
   - Most basic connection method, relies on raw commands

3. **NETCONF** (switches_netconf.ini)
   - Uses `ansible_connection=ansible.netcommon.netconf`
   - For devices that support NETCONF API

4. **Legacy SSH** (switches_legacy_ssh.ini)
   - Specifically configured for older Aruba devices with legacy SSH key exchange algorithms
   - Adds `-o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1` to SSH options

## Testing Playbooks

Before attempting configuration, use the test playbooks to verify connectivity:

### test_legacy_ssh.yml
- Specifically designed for older Aruba devices with legacy SSH key exchange algorithms
- Includes detailed debugging options and multiple command attempts
- Best option for initial testing with older Aruba firmware

### test_raw_connection.yml
- Compatible testing approach using raw SSH commands
- Tries to fetch basic version and configuration information
- Stores output for inspection

### test_show_running.yml
- Uses cli_command module to fetch running configuration
- More structured approach than raw SSH

### test_controller_show_running.yml
- Specifically designed for Aruba Mobility Controller
- Tries multiple command variations to find working syntax

## Configuration Playbooks

Once connectivity is confirmed, use these playbooks:

### config_switches.yml
- Configures basic settings on Aruba switches using CLI commands
- Includes hostname, VLANs, NTP, and syslog configuration

### config_controller.yml
- Specialized playbook for Aruba Mobility Controllers
- Handles their unique command structure

### backup_configs.yml
- Creates backups of device configurations using CLI commands
- Organizes backups by device and group

### gather_facts.yml
- Collects system information, versions, interfaces, and VLANs
- Creates both raw and structured outputs

## Usage with AWX

1. Import this repository into AWX as a Project
2. Sync the project to get the latest playbooks
3. Create separate inventories for each connection method if needed
4. Start with test playbooks before attempting configuration
5. Once connectivity is verified, proceed with configuration playbooks

## Troubleshooting Connection Issues

If you encounter connection problems:

1. **"network os arubaoss is not supported"**
   - Use the `switches.ini` inventory which uses the more common `ios` network OS
   - Or try the `switches_ssh.ini` inventory which uses basic SSH

2. **SSH Key Exchange Algorithm Errors**
   - Errors like: `kex error : no match for method kex algos: server [diffie-hellman-group14-sha1]` 
   - Use the `switches_legacy_ssh.ini` inventory which specifically enables legacy key exchange algorithms
   - Use with the `test_legacy_ssh.yml` playbook for best results

3. **SSH connection failures**
   - Verify IP addresses are correct
   - Confirm credentials are accurate
   - Check that SSH is enabled on the devices
   - Test network connectivity from AWX server to switches
   - For older devices, you may need to adjust the `ansible_ssh_common_args` to include compatible encryption options

4. **Command syntax errors**
   - Aruba command syntax can vary by model and OS version
   - The test playbooks can help identify the correct syntax
   - Review the output logs for specific error messages

5. **Permission issues**
   - Ensure the user has sufficient privileges on the devices
   - Try enabling privileged mode explicitly with `ansible_become=yes`

## SSH Compatibility Notes

Older Aruba switches often use legacy SSH implementations with limited cipher and key exchange algorithm support. Common issues include:

1. **Key Exchange (KEX) Algorithms**: Older devices might only support `diffie-hellman-group14-sha1` or `diffie-hellman-group1-sha1`
2. **Cipher Algorithms**: May only support older ciphers like `aes128-cbc`, `3des-cbc`, etc.
3. **HMAC Algorithms**: May require older HMAC algorithms

The `switches_legacy_ssh.ini` inventory is configured to handle these compatibility issues.

## Requirements

- AWX or Ansible Tower
- SSH access to network devices
- Valid credentials with appropriate permissions

## Security Notes

- The inventory files contain sensitive credential information. In a production environment, use AWX Credential management instead of storing credentials in the inventory file.
- Consider using SSH keys or vault-encrypted passwords for improved security.
- Be aware that enabling legacy SSH algorithms reduces the security of your connections. This should only be used when necessary for compatibility with older devices.