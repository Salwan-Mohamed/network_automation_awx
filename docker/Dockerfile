# Start from AWX EE base image
FROM quay.io/ansible/awx-ee:latest

# Switch to root
USER root

# Install extra Python libraries
RUN pip3 install --no-cache-dir pexpect paramiko

# Copy collection requirements file
COPY requirements.yml /tmp/requirements.yml

# Install Ansible Collections
RUN ansible-galaxy collection install -r /tmp/requirements.yml -p /usr/share/ansible/collections

# SSH configuration for Aruba switches
RUN mkdir -p /etc/ssh && \
    echo "Host 10.2.127.* 10.16.127.* 10.1.126.*" > /etc/ssh/ssh_config && \
    echo "    KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha1" >> /etc/ssh/ssh_config && \
    echo "    HostKeyAlgorithms +ssh-rsa" >> /etc/ssh/ssh_config && \
    echo "    PubkeyAcceptedAlgorithms +ssh-rsa" >> /etc/ssh/ssh_config && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config

# Global Ansible config
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "host_key_checking = False" >> /etc/ansible/ansible.cfg && \
    echo "timeout = 60" >> /etc/ansible/ansible.cfg && \
    echo "[ssh_connection]" >> /etc/ansible/ansible.cfg && \
    echo "ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" >> /etc/ansible/ansible.cfg && \
    echo "pipelining = True" >> /etc/ansible/ansible.cfg && \
    echo "[paramiko_connection]" >> /etc/ansible/ansible.cfg && \
    echo "look_for_keys = False" >> /etc/ansible/ansible.cfg && \
    echo "[persistent_connection]" >> /etc/ansible/ansible.cfg && \
    echo "connect_timeout = 60" >> /etc/ansible/ansible.cfg && \
    echo "command_timeout = 60" >> /etc/ansible/ansible.cfg

# Return to non-root user
USER 1000
