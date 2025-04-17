# Network Automation with AWX for Aruba Switches

This repository contains configuration files for network automation using AWX and Ansible, specifically designed for Aruba switches and controllers.

## Latest Approach: Custom Execution Environment

The most reliable solution for connecting to Aruba switches with AWX is to use a custom execution environment with pre-configured SSH settings. This eliminates the need to pass SSH arguments through Ansible inventory files, which can be problematic.

### Custom Execution Environment Files

- `docker/Dockerfile` - Dockerfile to build a custom AWX execution environment with legacy SSH support
- `docker/build_instructions.md` - Instructions for building and using the custom execution environment
- `inventory/simple_inventory.ini` - Simplified inventory file to use with the custom execution environment

See the [build instructions](docker/build_instructions.md) for details on how to build and use the custom execution environment.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for Aruba switches using network_cli/ios connection
  - `switches_ssh.ini` - Alternative inventory using basic SSH connection
  - `switches_netconf.ini` - Alternative inventory using NETCONF connection
  - `switches_legacy_ssh.ini` - Inventory with legacy SSH key exchange algorithm support
  - `switches_full_compatibility.ini` - Inventory with complete SSH compatibility options
  - `test_standalone.ini` - Minimal test inventory for troubleshooting
  - `simple_inventory.ini` - **RECOMMENDED** - Simplified inventory for use with custom execution environment
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring Aruba switches
  - `config_controller.yml` - Playbook for configuring Aruba Mobility Controller
  - `backup_configs.yml` - Playbook for backing up switch configurations
  - `gather_facts.yml` - Playbook for gathering facts from switches
  - `test_show_running.yml` - Test playbook for displaying running configurations
  - `test_controller_show_running.yml` - Test playbook specifically for the controller
  - `test_raw_connection.yml` - Test playbook using raw SSH commands for compatibility
  - `test_legacy_ssh.yml` - Test playbook for devices with legacy SSH algorithms
  - `basic_ping_test.yml` - Simple ping test to verify basic connectivity
  - `expect_test.yml` - Interactive SSH session testing using expect module
- `templates/` - Jinja2 templates for generating reports
  - `facts_report.j2` - HTML template for switch facts report
- `docker/` - Files for custom execution environment
  - `Dockerfile` - Dockerfile to build a custom AWX execution environment
  - `build_instructions.md` - Instructions for building and using the custom execution environment

## Troubleshooting Approach

We recommend the following step-by-step approach to get AWX working with Aruba switches:

1. **Build and use the custom execution environment**:
   - Follow the instructions in `docker/build_instructions.md`
   - Use the `simple_inventory.ini` inventory file
   - This provides a system-wide solution that bypasses the SSH parameter issues

2. **Start with basic connectivity tests**:
   - Use `basic_ping_test.yml` to verify basic network connectivity
   - Use `expect_test.yml` to test interactive SSH sessions

3. **Move on to more advanced playbooks**:
   - Once connectivity is confirmed, use the configuration playbooks

## Understanding the Issues

Through testing, we've identified several challenges when connecting to Aruba devices with AWX:

1. **Legacy SSH Algorithm Support**: 
   - The Aruba switches require older SSH algorithms (diffie-hellman-group14-sha1, ssh-rsa)
   - Modern SSH clients disable these by default for security reasons

2. **AWX Execution Environment Limitations**:
   - SSH parameters in inventory files aren't always correctly applied in AWX
   - Custom execution environments provide a more reliable solution

3. **Interactive CLI Requirements**:
   - Aruba devices expect interactive terminal sessions
   - Standard Ansible modules may not handle this interaction properly

## Using the Custom Execution Environment

The custom execution environment provides:

1. **Pre-configured SSH settings**:
   - Legacy key exchange algorithms
   - Legacy host key algorithms
   - Disable host key checking

2. **Simplified inventory files**:
   - No need to specify SSH parameters in inventory files
   - See `inventory/simple_inventory.ini` for an example

3. **Additional tools and modules**:
   - Python `pexpect` module for interactive SSH sessions
   - Global Ansible configuration optimized for network devices

## Security Considerations

- The custom execution environment enables legacy SSH algorithms which are considered less secure by modern standards
- This is necessary for compatibility with older network devices
- Limit access to the AWX environment and use strong credentials to mitigate security risks
- Consider network segmentation to restrict access to the management interfaces of network devices