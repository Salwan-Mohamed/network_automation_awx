# Network Automation Environment

This document describes the network automation environment for managing Aruba switches using AWX.

## Overview

The environment consists of:

1. An AWX server running Ansible automation
2. Distribution switches
3. Access switches in the N building
4. Access switches in the dormitories
5. An Aruba Mobility Controller

## AWX Server

The AWX server hosts the Ansible automation platform and contains the following components:

- **ansible.cfg**: Configuration file that specifies SSH connection parameters
- **inventory files**: Define the network devices and their connection parameters
- **playbooks**: Ansible playbooks for different automation tasks

## Network Topology

### Distribution Switches

- **aruba_1**: Distribution switch for both N building and dormitories
  - N building IP: 10.2.127.1
  - Dormitories IP: 10.16.127.1

### N Building Switches

The N building contains the following access switches:
- aruba_11 (10.2.127.11)
- aruba_12 (10.2.127.12)
- aruba_13 (10.2.127.13)
- aruba_14 (10.2.127.14)
- aruba_15 (10.2.127.15)
- aruba_16 (10.2.127.16)
- aruba_17 (10.2.127.17)
- aruba_18 (10.2.127.18)

### Dormitory Switches

The dormitories contain the following access switches:
- aruba_FH1 (10.16.127.11)
- aruba_FH2 (10.16.127.12)
- aruba_FH3 (10.16.127.13)
- aruba_FH4 (10.16.127.14)
- aruba_FH5 (10.16.127.15)
- aruba_FH6 (10.16.127.16)
- aruba_FH7 (10.16.127.17)
- aruba_food_court (10.16.127.18)
- aruba_GYM (10.16.127.19)
- aruba_gate_dorm (10.16.127.20)

### Aruba Controller

- aruba_controller (10.1.126.50)

## SSH Connection Details

All Aruba devices in this environment require special SSH parameters due to their legacy SSH implementation:

### Key Exchange (KEX) Algorithms

The switches only support these legacy key exchange algorithms:
- diffie-hellman-group14-sha1
- diffie-hellman-group1-sha1
- diffie-hellman-group-exchange-sha1

### Host Key Algorithms

The switches only present ssh-rsa host keys, which must be explicitly enabled:
- ssh-rsa

### Public Key Algorithms

The switches require explicit acceptance of ssh-rsa for public key authentication:
- ssh-rsa

## SSH Configuration

To connect to these devices, the following SSH parameters are required:

```
-o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
```

These parameters are configured in the ansible.cfg file and applied to all connections.

## Security Considerations

The SSH parameters used in this environment enable legacy algorithms that are considered insecure by modern standards. This is necessary for compatibility with the Aruba devices, but it should be understood that it reduces the security of the SSH connections.

Recommendations:
- Restrict access to the network management VLAN
- Use strong, unique passwords
- Consider upgrading firmware on the switches if possible to support more secure algorithms
- Implement compensating controls like network segmentation and monitoring