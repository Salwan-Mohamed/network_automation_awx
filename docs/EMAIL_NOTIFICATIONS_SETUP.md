# Email Notifications Setup for AWX on Minikube

This guide explains how to configure email notifications for the PTV configuration playbook when running AWX on minikube in Ubuntu.

## Email Notification Features

The PTV playbook now includes comprehensive email notifications for:

✅ **Input validation failures**
✅ **Room/building mismatch errors** 
✅ **Missing building mappings**
✅ **Missing room mappings**
✅ **Missing VLAN mappings**
✅ **Switch configuration failures (ON state)**
✅ **Switch configuration failures (OFF state)**
✅ **Configuration save warnings**
✅ **Successful completion notifications**

## Email Configuration Options

### Option 1: Local SMTP Server (Recommended for Testing)

For development/testing in minikube, you can set up a local SMTP server:

#### Install and Configure Postfix on Ubuntu Host

```bash
# Install postfix
sudo apt update
sudo apt install postfix mailutils

# During installation, choose "Internet Site" and set hostname

# Configure postfix for local delivery
sudo nano /etc/postfix/main.cf

# Add/modify these lines:
mydestination = localhost, localhost.localdomain
inet_interfaces = all
mynetworks = 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# Restart postfix
sudo systemctl restart postfix
sudo systemctl enable postfix
```

#### Forward emails to external address

```bash
# Create alias to forward to your email
echo "root: salwan.mohamed@su.edu.eg" | sudo tee -a /etc/aliases
sudo newaliases
```

### Option 2: External SMTP Server

Configure the playbook to use your organization's SMTP server by modifying the variables:

```yaml
vars:
  notification_email: "salwan.mohamed@su.edu.eg"
  smtp_server: "mail.su.edu.eg"  # Your university's SMTP server
  smtp_port: 587                 # or 25, 465 depending on config
  email_from: "awx-automation@su.edu.eg"
```

### Option 3: Gmail SMTP (Requires App Password)

```yaml
vars:
  notification_email: "salwan.mohamed@su.edu.eg"
  smtp_server: "smtp.gmail.com"
  smtp_port: 587
  email_from: "your-gmail@gmail.com"
```

## AWX Configuration

### 1. Add SMTP Configuration to AWX Settings

In AWX web interface:
1. Go to **Settings** → **System**
2. Configure email settings:
   - **Email Host**: localhost (or your SMTP server)
   - **Email Port**: 587
   - **Email Host User**: (leave blank for local)
   - **Email Host Password**: (leave blank for local)
   - **Email Use TLS**: False (for local)

### 2. Kubernetes Network Configuration

Since AWX runs in minikube, ensure email traffic can reach your SMTP server:

#### For Local SMTP Server

```bash
# Get minikube IP
minikube ip

# Allow email traffic from minikube network
sudo ufw allow from $(minikube ip)/24 to any port 25
sudo ufw allow from $(minikube ip)/24 to any port 587

# Check if postfix is listening
sudo netstat -tlnp | grep :25
```

#### Minikube Service Configuration

Create a service to expose your host SMTP server to the minikube cluster:

```yaml
# Create smtp-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: host-smtp
  namespace: awx
spec:
  type: ExternalName
  externalName: host.minikube.internal
  ports:
  - port: 587
    targetPort: 587
```

```bash
kubectl apply -f smtp-service.yaml
```

### 3. Job Template Configuration

When creating the AWX job template:

1. **Extra Variables** (optional override):
```yaml
smtp_server: "host-smtp.awx.svc.cluster.local"
smtp_port: 587
notification_email: "salwan.mohamed@su.edu.eg"
```

2. **Environment Variables** (if needed):
```yaml
SMTP_SERVER: "localhost"
```

## Testing Email Notifications

### Test Local SMTP Server

```bash
# Test from Ubuntu host
echo "Test email body" | mail -s "Test Subject" salwan.mohamed@su.edu.eg

# Check mail logs
sudo tail -f /var/log/mail.log
```

### Test from AWX Container

```bash
# Get AWX task pod
kubectl get pods -n awx

# Test from inside AWX pod
kubectl exec -it <awx-task-pod> -n awx -- bash
python3 -c "
import smtplib
from email.mime.text import MIMEText

msg = MIMEText('Test from AWX')
msg['Subject'] = 'AWX Email Test'
msg['From'] = 'awx@test.local'
msg['To'] = 'salwan.mohamed@su.edu.eg'

s = smtplib.SMTP('localhost', 587)
s.send_message(msg)
s.quit()
print('Email sent successfully')
"
```

### Test PTV Playbook with Intentional Failure

```bash
# Run with invalid parameters to trigger email
ansible-playbook playbooks/ptv_port_configuration.yml \
  -e "building_name=INVALID" \
  -e "room_number=9999" \
  -e "ptv_state=ON"
```

## Email Template Customization

You can customize email templates by modifying the `body` section in each notification task:

```yaml
- name: Send email notification for validation failure
  mail:
    to: "{{ notification_email }}"
    from: "{{ email_from }}"
    subject: "PTV Configuration Failed - Invalid Parameters"
    body: |
      Your custom email template here...
      
      Error: {{ error_message }}
      Time: {{ ansible_date_time.iso8601 }}
      AWX Job: {{ tower_job_id | default('N/A') }}
```

## Troubleshooting

### Common Issues

1. **Email not sending from AWX**
   - Check AWX logs: `kubectl logs -f <awx-task-pod> -n awx`
   - Verify SMTP server accessibility from pod
   - Check firewall rules

2. **Emails going to spam**
   - Configure proper SPF/DKIM records
   - Use authenticated SMTP server
   - Set proper From address

3. **Connection refused errors**
   - Verify SMTP server is running: `sudo systemctl status postfix`
   - Check network connectivity between AWX and SMTP server
   - Verify port configuration

### Debug Commands

```bash
# Check AWX network connectivity
kubectl exec -it <awx-task-pod> -n awx -- nslookup host.minikube.internal

# Check SMTP port connectivity
kubectl exec -it <awx-task-pod> -n awx -- telnet localhost 587

# Check AWX logs for email errors
kubectl logs -f <awx-task-pod> -n awx | grep -i mail
```

## Security Considerations

1. **Use TLS/SSL** for external SMTP servers
2. **Secure credentials** if using authenticated SMTP
3. **Limit network access** to SMTP ports
4. **Monitor email logs** for security events

## Production Recommendations

For production environments:

1. Use your organization's official SMTP server
2. Configure proper DNS/SPF records
3. Use authenticated SMTP with credentials stored in AWX credentials
4. Set up email rate limiting
5. Configure log rotation for mail logs
6. Use monitoring for email delivery failures

The updated PTV playbook now provides comprehensive error reporting via email, making it easier to troubleshoot issues when running automation tasks through AWX.
