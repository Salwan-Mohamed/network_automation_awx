# Troubleshooting Guide for Aruba Switch Connectivity

This guide provides step-by-step instructions for troubleshooting SSH connectivity issues with Aruba switches in AWX.

## Latest Developments

We've added several new approaches to help solve the SSH connection issues:

1. **Direct SSH Command Testing** (`direct_ssh_test.yml`) - Execute SSH commands directly with all compatibility options
2. **Global Ansible Configuration** (`ansible.cfg`) - Apply SSH settings globally to all playbooks
3. **Standalone Test Script** (`scripts/test_ssh.sh`) - Test SSH connectivity outside of AWX/Ansible

## Important Notes for AWX

For AWX to use your custom ansible.cfg:

1. In your AWX Project settings, set "Ansible Environment" to:
   ```
   ANSIBLE_CONFIG=/var/lib/awx/projects/_123_network_automation_awx/ansible.cfg
   ```
   (Replace `_123_` with your actual project ID number)

2. Make sure the expect module is installed on your AWX:
   ```
   pip install pexpect
   ```

3. If direct SSH works but Ansible playbooks don't, install legacy SSH algorithms:
   ```
   sudo apt-get install openssh-client-ssh1
   ```

## Step-by-Step Troubleshooting

### 1. Test Direct SSH From AWX Server

First, log into your AWX server and run:

```bash
cd /var/lib/awx/projects/_XXX_network_automation_awx/  # Replace _XXX_ with your project number
chmod +x scripts/test_ssh.sh
./scripts/test_ssh.sh 10.2.127.11 ansibleadmin "An\$12345"
```

This will tell you if basic SSH connectivity works outside of Ansible.

### 2. Test Direct SSH From Ansible

```bash
cd /var/lib/awx/projects/_XXX_network_automation_awx/
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook playbooks/direct_ssh_test.yml -i inventory/test_standalone.ini -v
```

This will show detailed information about the SSH connection process.

### 3. Test with Basic Connectivity

If direct SSH is working:

```bash
cd /var/lib/awx/projects/_XXX_network_automation_awx/
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook playbooks/basic_ping_test.yml -i inventory/test_standalone.ini
```

### 4. Test with Expect Module

```bash
cd /var/lib/awx/projects/_XXX_network_automation_awx/
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook playbooks/expect_test.yml -i inventory/test_standalone.ini
```

## AWX Environment Variables

When creating Job Templates in AWX, add these Environment Variables:

```
ANSIBLE_HOST_KEY_CHECKING=False
ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa'
```

## SSH Key Types and Algorithms

The issue we're facing has three components:

1. **Key Exchange (KEX) Algorithms** - Your Aruba devices only support older algorithms:
   - `diffie-hellman-group14-sha1`
   - `diffie-hellman-group1-sha1`
   - `diffie-hellman-group-exchange-sha1`

2. **Host Key Algorithms** - Your devices only offer `ssh-rsa` host keys

3. **Public Key Algorithms** - Your devices require `ssh-rsa` for public key authentication

Our SSH options are addressing all three:
```
-o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
```

## AWX Container Configuration (Last Resort)

If all else fails, you may need to modify the AWX container's SSH configuration to permanently enable legacy algorithms:

1. Edit `/etc/ssh/ssh_config` in the AWX container
2. Add the following:
   ```
   Host *
       KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1
       HostKeyAlgorithms +ssh-rsa
       PubkeyAcceptedAlgorithms +ssh-rsa
   ```

## Common Error Messages

| Error Message | Solution |
|---------------|----------|
| `network os aruba_aos_controller is not supported` | Use `ios` as the network_os instead |
| `kex error : no match for method kex algos` | Use the KexAlgorithms SSH option |
| `no matching host key type found. Their offer: ssh-rsa` | Use the HostKeyAlgorithms SSH option |
| `terminal: command not found` | Use expect-based connection instead of raw SSH |

## Security Note

Be aware that enabling legacy SSH algorithms reduces the security of your connections. This should only be used when necessary for compatibility with older devices.