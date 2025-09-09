# Aruba Network Automation Platform

A comprehensive network automation solution for managing Aruba switches and controllers using AWX (Ansible Automation Platform). This platform provides enterprise-grade automation capabilities for configuration management, monitoring, and operational tasks across Aruba network infrastructure.

## 🚀 Features

### Core Capabilities
- **Automated Configuration Management**: Deploy and manage switch configurations at scale
- **Dynamic Interface Configuration**: Intelligent port provisioning based on device types and room assignments
- **Bulk Operations**: Mass enable/disable operations for lab environments
- **Configuration Backup & Restore**: Automated backup scheduling with version control
- **Network Discovery**: Automated facts gathering and inventory management
- **Compliance Monitoring**: Configuration drift detection and remediation

### Advanced Features
- **Custom Execution Environment**: Pre-built container with legacy SSH support for older Aruba devices
- **Multi-Device Support**: Unified management for switches, controllers, and access points
- **Template-Based Provisioning**: Jinja2 templates for consistent configuration deployment
- **Role-Based Access Control**: Integration with AWX RBAC for secure operations
- **Audit Trail**: Complete logging and tracking of all automation activities

## 🏗️ Architecture

### Infrastructure Components
- **AWX Server**: Centralized automation platform
- **Distribution Switches**: Core network infrastructure (Aruba_1)
- **Access Switches**: N Building (aruba_11-18) and Dormitory switches (aruba_FH1-7, etc.)
- **Wireless Controller**: Aruba Mobility Controller (aruba_controller)
- **Custom Execution Environment**: Docker container with legacy SSH compatibility

### Network Topology
```
AWX Server ──┬── Distribution Switches (10.2.127.1, 10.16.127.1)
             ├── N Building Switches (10.2.127.11-18)
             ├── Dormitory Switches (10.16.127.11-20)
             └── Aruba Controller (10.1.126.50)
```

## 📋 Prerequisites

### System Requirements
- **AWX/Ansible Tower**: Version 19.0+ or Ansible Automation Platform 2.0+
- **Python**: 3.8+
- **Docker**: For custom execution environment builds
- **Git**: For version control and project management

### Network Requirements
- SSH access to all target devices (port 22)
- Management VLAN connectivity
- DNS resolution for device hostnames

### Supported Aruba Models
- **Switches**: ArubaOS-Switch (ProVision-based)
- **Controllers**: Aruba Mobility Controllers
- **Access Points**: Campus and Instant APs (via controller)

## 🚀 Quick Start

### 1. Project Setup
```bash
# Clone the repository
git clone <repository-url>
cd network_automation_awx

# Set up AWX project
# Follow instructions in docs/awx_setup.md
```

### 2. Build Custom Execution Environment
```bash
cd execution-environment
chmod +x build.sh
./build.sh

# Push to your container registry
docker push your-registry.com/aruba-network-ee:1.0
```

### 3. Configure AWX
1. Create Project in AWX pointing to this repository
2. Register the custom execution environment
3. Set up inventories using provided inventory files
4. Create job templates for automation tasks

### 4. Run Your First Automation
```bash
# Test connectivity
ansible-playbook playbooks/basic_ping_test.yml -i inventory/simple_inventory.ini

# Gather device facts
ansible-playbook playbooks/gather_facts.yml -i inventory/simple_inventory.ini
```

## 📁 Project Structure

```
network_automation_awx/
├── docs/                          # Documentation
│   ├── awx_setup.md              # AWX configuration guide
│   ├── environment.md            # Network environment details
│   └── environment.svg           # Network topology diagram
├── execution-environment/         # Custom EE definitions
│   ├── execution-environment.yml # EE configuration
│   ├── requirements.txt          # Python dependencies
│   ├── bindep.txt               # System packages
│   └── build.sh                 # Build automation script
├── inventory/                     # Ansible inventories
│   ├── simple_inventory.ini      # Recommended for custom EE
│   ├── switches_full_compatibility.ini
│   └── switches_*.ini           # Various connection methods
├── playbooks/                     # Automation playbooks
│   ├── config_switches.yml      # Switch configuration
│   ├── backup_configs.yml       # Configuration backups
│   ├── dynamic_interface_aruba.yaml # Dynamic port configuration
│   ├── bulk_lab_port_state.yml  # Bulk port operations
│   └── gather_facts.yml         # Device information gathering
├── vars/                         # Variable definitions
│   ├── switch_mapping.yml       # Room-to-switch mapping
│   ├── vlan_mapping.yml         # Device-to-VLAN mapping
│   ├── wall_point_mapping.yml   # Physical port mapping
│   └── lab_*.yml               # Lab-specific configurations
├── templates/                    # Jinja2 templates
└── scripts/                     # Utility scripts
```

## 🔧 Configuration

### Device Mapping
The platform uses YAML-based mapping files for intelligent device management:

- **`vars/switch_mapping.yml`**: Maps rooms to physical switches
- **`vars/vlan_mapping.yml`**: Defines device types and their VLANs
- **`vars/wall_point_mapping.yml`**: Physical port to logical interface mapping
- **`vars/lab_interfaces_mapping.yml`**: Lab-specific interface ranges

### Connection Parameters
Due to legacy SSH requirements of Aruba devices, specific SSH parameters are configured:
- Key Exchange: `diffie-hellman-group14-sha1`
- Host Key Algorithms: `ssh-rsa`
- Public Key Algorithms: `ssh-rsa`

## 🎯 Use Cases

### 1. Dynamic Interface Configuration
Automatically configure switch ports based on device type and location:
```yaml
# Configure PC in room N-G-36, wall point 2/10
room: "n-g-36"
port_number: "2/10"
device_type: "pc"
second_device_type: "phone"  # Optional: phone on same port
```

### 2. Bulk Lab Operations
Enable/disable all ports in a lab environment:
```yaml
# Disable all ports in Lab 37
room: "n-1-37"
port_state: "disable"
```

### 3. Configuration Management
Deploy standardized configurations across all switches:
- VLAN configuration
- NTP settings
- Syslog configuration
- Port security policies

### 4. Monitoring & Compliance
- Automated configuration backups
- Facts gathering for inventory management
- Configuration drift detection

## 🔍 Troubleshooting

### Common Issues

**SSH Connection Failures**
- Verify legacy SSH algorithms are enabled
- Check firewall rules and network connectivity
- Validate credentials and permissions

**Module Not Found Errors**
- Ensure custom execution environment is properly built
- Verify Ansible collections are installed
- Check Python dependencies

**Configuration Failures**
- Validate device mappings in vars/ files
- Check VLAN existence on target switches
- Verify sufficient privileges on target devices

### Debug Tools
```bash
# Test SSH connectivity
./scripts/test_ssh.sh 10.2.127.11 ansibleadmin "password"

# Direct SSH test playbook
ansible-playbook playbooks/direct_ssh_test.yml -i inventory/test_standalone.ini

# Enable verbose output
ansible-playbook playbooks/config_switches.yml -i inventory/simple_inventory.ini -vvv
```

## 📚 Documentation

- **[AWX Setup Guide](docs/awx_setup.md)**: Complete AWX configuration instructions
- **[Environment Overview](docs/environment.md)**: Network topology and device details
- **[Troubleshooting Guide](TROUBLESHOOTING.md)**: Detailed troubleshooting procedures
- **[Execution Environment Guide](execution-environment/README.md)**: Custom EE build instructions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Ansible best practices and coding standards
- Test all playbooks in a lab environment before production
- Update documentation for any new features
- Maintain backward compatibility when possible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Security Considerations

- **Legacy SSH Algorithms**: This platform enables legacy SSH algorithms for device compatibility. Use in controlled network environments only.
- **Credential Management**: Store all credentials in AWX credential stores, never in plain text.
- **Network Segmentation**: Implement proper network segmentation for management traffic.
- **Access Control**: Use AWX RBAC features to limit automation access.
- **Audit Logging**: Enable comprehensive logging for all automation activities.

## 🆘 Support

For issues and questions:
1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review closed issues in the GitHub repository
3. Open a new issue with detailed information about your environment and problem

## 🔄 Roadmap

- [ ] Integration with network monitoring tools
- [ ] Enhanced reporting and dashboards
- [ ] Support for newer Aruba CX switches
- [ ] Automated firmware management
- [ ] Integration with ITSM platforms
- [ ] Advanced security policy automation

---

**Maintained by**: DevOps and Platform Engineering Salwan Mohamed
**Last Updated**: September 2025
