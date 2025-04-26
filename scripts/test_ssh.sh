#!/bin/bash
# Test script to verify SSH connectivity to Aruba devices
# Usage: ./test_ssh.sh <hostname/IP> <username> <password>

HOST=$1
USER=$2
PASS=$3

if [ -z "$HOST" ] || [ -z "$USER" ] || [ -z "$PASS" ]; then
  echo "Usage: $0 <hostname/IP> <username> <password>"
  exit 1
fi

echo "Testing SSH connectivity to $HOST with user $USER"

# Create a temporary expect script
cat > /tmp/ssh_test.exp << EOF
#!/usr/bin/expect -f
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa $USER@$HOST
expect {
  "*assword:" { send "$PASS\r" }
  timeout { puts "Connection timed out"; exit 1 }
}
expect {
  ">" { send "show version\r" }
  timeout { puts "Login failed"; exit 1 }
}
expect {
  ">" { send "exit\r" }
  timeout { puts "Command failed"; exit 1 }
}
expect eof
EOF

# Make it executable
chmod +x /tmp/ssh_test.exp

# Run the expect script
/tmp/ssh_test.exp

# Clean up
rm /tmp/ssh_test.exp

echo "Test completed"