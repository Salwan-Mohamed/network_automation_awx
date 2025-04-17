# Network Automation with AWX

This repository contains configuration files for network automation using AWX and Ansible.

## Directory Structure

- `inventory/` - Contains inventory files defining network devices
  - `switches.ini` - Inventory file for network switches
- `playbooks/` - Contains Ansible playbooks
  - `config_switches.yml` - Playbook for configuring switches

## Usage

1. Update the inventory file with your network devices
2. Customize the playbooks as needed
3. Import this repository into AWX
4. Create a job template in AWX pointing to the desired playbook

## Requirements

- AWX or Ansible Tower
- Network modules for your devices (ios, nxos, etc.)
