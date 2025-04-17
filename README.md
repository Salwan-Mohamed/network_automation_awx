# Network Automation with AWX for Aruba Switches

This repository contains configuration files for network automation using AWX and Ansible, specifically designed for Aruba switches.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for Aruba switches, organized by location groups
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring Aruba switches
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

## Playbooks

### config_switches.yml
Configures basic settings on Aruba switches:
- Hostname
- VLANs (Management, Users, Servers)
- NTP settings
- Syslog server
- Saves configuration when modified

### backup_configs.yml
Backs up running configurations:
- Creates timestamped backups
- Organizes backups by inventory group
- Provides detailed backup information

### gather_facts.yml
Collects and reports device information:
- Gathers hardware and software details
- Saves information in JSON format
- Generates HTML report with device summary

## Usage with AWX

1. Import this repository into AWX as a Project
2. Create the following Job Templates:
   - **Configure Switches** - Uses `config_switches.yml`
   - **Backup Configurations** - Uses `backup_configs.yml`
   - **Gather Switch Facts** - Uses `gather_facts.yml`
3. Create a Schedule for regular backups and fact gathering
4. Create an Inventory in AWX, using this repository's inventory file

## Requirements

- AWX or Ansible Tower
- Ansible 2.9+ with Aruba modules
- Network access to all devices in inventory
- Credentials with administrative privileges

## Security Notes

- The inventory file contains sensitive credential information. In a production environment, use AWX Credential management instead of storing credentials in the inventory file.
- Consider using SSH keys or vault-encrypted passwords for improved security.