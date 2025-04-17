# Network Automation with AWX for Aruba Switches

This repository contains configuration files for network automation using AWX and Ansible, specifically designed for Aruba switches and controllers.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for Aruba switches, organized by location groups
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring Aruba switches
  - `config_controller.yml` - Playbook for configuring Aruba Mobility Controller
  - `backup_configs.yml` - Playbook for backing up switch configurations
  - `gather_facts.yml` - Playbook for gathering facts from switches
- `templates/` - Jinja2 templates for generating reports
  - `facts_report.j2` - HTML template for switch facts report

## Inventory Structure

The inventory is organized into several groups:
- `distswitch_N` - Distribution switches in N building
- `distswitch_Dorms` - Distribution switches in Dorms
- `aruba_switches_N` - Access switches in N building
- `aruba_switch__Dorms` - Access switches in Dorms
- `aruba_controller_master` - Aruba controller

## Device Types and Compatibility

This repository is configured for:
- Aruba OS switches (using ansible_network_os=arubaoss)
- Aruba Mobility Controllers (using ansible_network_os=aruba_aos_controller)

## Playbooks

### config_switches.yml
Configures basic settings on Aruba switches using direct CLI commands:
- Hostname
- VLANs (Management, Users, Servers)
- NTP settings
- Syslog server
- Saves configuration when modified

### config_controller.yml
Specialized playbook for configuring Aruba Mobility Controllers:
- Hostname configuration
- NTP settings
- Syslog configuration
- WLAN information gathering

### backup_configs.yml
Backs up running configurations using CLI commands:
- Creates timestamped backups
- Organizes backups by inventory group
- Provides detailed backup information

### gather_facts.yml
Collects and reports device information via CLI commands:
- System information
- Version information
- Interface details
- VLAN configuration
- Saves information in both raw and JSON formats

## Usage with AWX

1. Import this repository into AWX as a Project
2. Create the following Job Templates:
   - **Configure Switches** - Uses `config_switches.yml` with the switches inventory
   - **Configure Controller** - Uses `config_controller.yml` with the controller inventory
   - **Backup Configurations** - Uses `backup_configs.yml`
   - **Gather Switch Facts** - Uses `gather_facts.yml`
3. Create a Schedule for regular backups and fact gathering
4. Create an Inventory in AWX, using this repository's inventory file

## Troubleshooting

If you encounter issues:
- Verify network connectivity to devices
- Ensure proper credentials in inventory or AWX credentials
- Check that switches are running compatible Aruba OS versions
- Verify proper terminal type settings
- Console output will provide specific error messages for troubleshooting

## Requirements

- AWX or Ansible Tower
- Ansible 2.9+ with Aruba modules
- Network access to all devices in inventory
- Credentials with administrative privileges

## Security Notes

- The inventory file contains sensitive credential information. In a production environment, use AWX Credential management instead of storing credentials in the inventory file.
- Consider using SSH keys or vault-encrypted passwords for improved security.