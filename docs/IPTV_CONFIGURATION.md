# IPTV (Internet Protocol TV) Port Configuration

This directory contains files for configuring Aruba switch ports for IPTV (Internet Protocol TV) devices based on building location, room number, and desired state.

## Files Overview

### Playbook
- **`iptv_port_configuration.yml`** - Main playbook for IPTV port configuration

### Variable Files
- **`building_switch_mapping.yml`** - Maps building names to switch names
- **`room_port_mapping.yml`** - Maps room numbers to switch ports (needs completion)
- **`building_vlan_mapping.yml`** - Maps building names to VLAN IDs

## Usage

### Required Parameters
- **`building_name`** - Building identifier (e.g., "FH-1", "FH-4")
- **`room_number`** - Room number (e.g., "4211", "5012-1")  
- **`iptv_state`** - Port state: "ON" or "OFF"

### Example Command
```bash
ansible-playbook playbooks/iptv_port_configuration.yml \
  -e "building_name=FH-4" \
  -e "room_number=4211" \
  -e "iptv_state=ON"
```

## Configuration Logic

### Validation Rules
1. **Room-Building Validation**: First digit of room number must match last character of building name
   - Room "4211" ✓ matches Building "FH-4" 
   - Room "5012-1" ✓ matches Building "FH-5"
   - Room "4211" ✗ does NOT match Building "FH-3"

### Port Configuration

#### IPTV State: ON
- Configures port similar to "Case 2" from original playbook
- Sets untagged VLAN based on building mapping
- Enables the port with auto speed-duplex
- Interface name format: `{room_number}_IPTV_ON`
- Port security: learn-mode static, address-limit 1

#### IPTV State: OFF  
- Configures port similar to "Case 4" from original playbook
- Disables the port administratively
- Interface name format: `{room_number}_IPTV_OFF_disable`
- Port security: learn-mode static, address-limit 1

## Mapping Files

### Building to Switch Mapping
```yaml
# building_switch_mapping.yml
building_switch_mapping:
  "FH-1": "aruba_FH1"
  "FH-2": "aruba_FH2"
  # ... etc
```

### Room to Port Mapping (Needs Completion)
```yaml
# room_port_mapping.yml  
room_port_mapping:
  "4211": "2/9"
  "5012-1": "1/3"
  # Add more mappings as needed
```

### Building to VLAN Mapping
```yaml
# building_vlan_mapping.yml
building_vlan_mapping:
  "FH-1": 51
  "FH-4": 54
  # ... etc
```

## Next Steps

1. **Complete room_port_mapping.yml** - Add all room-to-port mappings based on your network documentation
2. **Test the playbook** - Run with known room/building combinations
3. **Add inventory configuration** - Ensure target switches are in your Ansible inventory
4. **Configure AWX** - Create job templates with the required extra variables

## Example Scenarios

### Enable IPTV in Room 4211 (Building FH-4)
```bash
ansible-playbook playbooks/iptv_port_configuration.yml \
  -e "building_name=FH-4" \
  -e "room_number=4211" \
  -e "iptv_state=ON"
```
Result: Port 2/9 on aruba_FH4 configured with VLAN 54, interface name "4211_IPTV_ON"

### Disable IPTV in Room 5012-1 (Building FH-5)  
```bash
ansible-playbook playbooks/iptv_port_configuration.yml \
  -e "building_name=FH-5" \
  -e "room_number=5012-1" \
  -e "iptv_state=OFF"
```
Result: Port 1/3 on aruba_FH5 disabled, interface name "5012-1_IPTV_OFF_disable"
