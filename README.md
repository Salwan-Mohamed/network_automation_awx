# Network Automation with AWX for Aruba Switches

This repository contains configuration files for network automation using AWX and Ansible, specifically designed for Aruba switches and controllers.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for Aruba switches using network_cli/ios connection
  - `switches_ssh.ini` - Alternative inventory using basic SSH connection
  - `switches_netconf.ini` - Alternative inventory using NETCONF connection
  - `switches_legacy_ssh.ini` - Inventory with legacy SSH key exchange algorithm support
  - `switches_full_compatibility.ini` - **RECOMMENDED** - Inventory with complete SSH compatibility options
  - `test_standalone.ini` - Minimal test inventory for troubleshooting
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring Aruba switches
  - `config_controller.yml` - Playbook for configuring Aruba Mobility Controller
  - `backup_configs.yml` - Playbook for backing up switch configurations
  - `gather_facts.yml` - Playbook for gathering facts from switches
  - `test_show_running.yml` - Test playbook for displaying running configurations
  - `test_controller_show_running.yml` - Test playbook specifically for the controller
  - `test_raw_connection.yml` - Test playbook using raw SSH commands for compatibility
  - `test_legacy_ssh.yml` - Test playbook for devices with legacy SSH algorithms
  - `basic_ping_test.yml` - **FIRST TEST** - Simple ping test to verify basic connectivity
  - `expect_test.yml` - Interactive SSH session testing using expect module
- `templates/` - Jinja2 templates for generating reports
  - `facts_report.j2` - HTML template for switch facts report

## Inventory Structure

The inventory is organized into several groups:
- `distswitch_N` - Distribution switches in N building
- `distswitch_Dorms` - Distribution switches in Dorms
- `aruba_switches_N` - Access switches in N building
- `aruba_switch__Dorms` - Access switches in Dorms
- `aruba_controller_master` - Aruba controller

## Troubleshooting Approach

We recommend the following step-by-step approach to test connectivity:

1. **Start with Basic Ping Test**:
   - Use `basic_ping_test.yml` with any inventory file
   - This confirms basic network connectivity to the devices
   - No SSH connection is attempted at this stage

2. **Test SSH Connectivity**:
   - Use `expect_test.yml` with `switches_full_compatibility.ini`
   - The expect module allows for interactive SSH sessions
   - This bypasses Ansible network modules entirely

3. **Test with Minimal Inventory**:
   - Use `test_standalone.ini` which only includes one device
   - Test with the `expect_test.yml` playbook
   - This reduces the number of variables to troubleshoot

4. **Once Connectivity is Working**:
   - Move on to more advanced playbooks like `config_switches.yml`

## Connection Methods

This repository provides multiple connection methods for compatibility:

1. **RECOMMENDED: Full SSH Compatibility** (switches_full_compatibility.ini)
   - Complete set of SSH compatibility options for older Aruba devices
   - Includes both key exchange algorithm and host key algorithm settings
   - Based on working parameters from Ansible core setup
   - Complete command: `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa`

2. **Expect-based Connection** (expect_test.yml)
   - Uses the expect module to handle interactive SSH sessions
   - Doesn't rely on Ansible's network modules
   - Can work even when network modules fail

3. **Network CLI with IOS** (switches.ini)
   - Uses `ansible_connection=network_cli` with `ansible_network_os=ios`
   - Works with many network devices even if specific OS modules aren't installed

4. **Basic SSH** (switches_ssh.ini)
   - Uses `ansible_connection=ssh`
   - Most basic connection method, relies on raw commands

5. **NETCONF** (switches_netconf.ini)
   - Uses `ansible_connection=ansible.netcommon.netconf`
   - For devices that support NETCONF API

6. **Legacy SSH Key Exchange** (switches_legacy_ssh.ini)
   - Specifically configured for older Aruba devices with legacy SSH key exchange algorithms
   - Adds `-o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1` to SSH options

## Testing Playbooks

Start troubleshooting with these playbooks, in this order:

### basic_ping_test.yml
- Simplest test that only verifies network connectivity
- No SSH connection is attempted
- Good first step to confirm devices are reachable

### expect_test.yml
- Uses expect module to handle interactive SSH sessions
- Bypasses Ansible network modules entirely
- Useful when regular Ansible network modules aren't working

### test_legacy_ssh.yml
- Specifically designed for older Aruba devices with legacy SSH algorithms
- Includes detailed debugging options

### test_raw_connection.yml
- Compatible testing approach using raw SSH commands
- Tries to fetch basic version and configuration information

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
3. Create an inventory in AWX using the `switches_full_compatibility.ini` file (recommended)
4. Start with `basic_ping_test.yml` to verify connectivity
5. Move to `expect_test.yml` to test SSH interaction
6. Once basic connectivity is verified, proceed with configuration playbooks

## Troubleshooting Connection Issues

The errors you're encountering can be categorized and resolved:

1. **"network os arubaoss is not supported"**
   - Solution: Use `switches_full_compatibility.ini` which uses the generic `ios` network OS

2. **SSH Key Exchange Algorithm Errors**
   - Errors like: `kex error : no match for method kex algos: server [diffie-hellman-group14-sha1]` 
   - Solution: Use inventories with KexAlgorithms configuration

3. **SSH Host Key Algorithm Errors**
   - Errors like: `no matching host key type found. Their offer: ssh-rsa`
   - Solution: Use inventories with HostKeyAlgorithms configuration

4. **Command Not Found Errors**
   - Errors like: `terminal: command not found` or `show: command not found`
   - Solution: Use `expect_test.yml` which handles the interactive console properly

5. **Complete SSH Compatibility Solution**
   - The `switches_full_compatibility.ini` inventory includes ALL required SSH compatibility options
   - Use this with `expect_test.yml` for the most reliable approach

## SSH Compatibility Notes

Older Aruba switches often use legacy SSH implementations with limited algorithm support. Common issues include:

1. **Key Exchange (KEX) Algorithms**: Older devices might only support `diffie-hellman-group14-sha1` or `diffie-hellman-group1-sha1`
2. **Host Key Algorithms**: May only offer `ssh-rsa` which is considered legacy/insecure by modern SSH clients
3. **Public Key Algorithms**: May require `ssh-rsa` to be explicitly enabled
4. **Cipher Algorithms**: May only support older ciphers like `aes128-cbc`, `3des-cbc`, etc.

The `switches_full_compatibility.ini` inventory includes settings to handle all of these issues.

## Requirements

- AWX or Ansible Tower
- SSH access to network devices
- Valid credentials with appropriate permissions
- Python `pexpect` module installed on AWX for expect-based tests

## Security Notes

- The inventory files contain sensitive credential information. In a production environment, use AWX Credential management instead of storing credentials in the inventory file.
- Consider using SSH keys or vault-encrypted passwords for improved security.
- Be aware that enabling legacy SSH algorithms reduces the security of your connections. This should only be used when necessary for compatibility with older devices.