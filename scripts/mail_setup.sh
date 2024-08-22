#!bin/bash

# Exit on any error
set -e

# Update and upgrade system
apt update && apt upgrade -y

# Install needed packages
apt install -y postfix dovecot-core dovecot-imapd dovecot-pop3d bind9 bind9utils bind9-doc

# Set variables
DOMAIN="databishop.ddns.net"  # Replace with your No-IP domain
EMAIL="abasifrekenkanang@gmail.com"   # Replace with your email
SERVER_IP=$(curl -s ifconfig.me)  # Get public IP address

# Configure Postfix
cat > /etc/postfix/main.cf << EOF
myhostname = $DOMAIN
mydestination = $DOMAIN, localhost.localdomain, localhost
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
inet_interfaces = all
inet_protocols = all
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
EOF

# Configure Dovecot
cat > /etc/dovecot/dovecot.conf << EOF
protocols = imap pop3
listen = *
mail_location = mbox:~/mail:INBOX=/var/mail/%u
EOF

# Restart postfix and dovecot
systemctl restart postfix dovecot

# Configure BIND9
cat > /etc/bind/named.conf.local << EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.$DOMAIN";
};
EOF

cat > /etc/bind/db.$DOMAIN << EOF
\$TTL    604800
@       IN      SOA     $DOMAIN. root.$DOMAIN. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $DOMAIN.
@       IN      A       $SERVER_IP
EOF

# Restart BIND9
systemctl restart bind9

# Install No-IP DUC (Dynamic Update Client)
cd /usr/local/src/
curl http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd noip-2.1.9-1/
make
make install

# Configure No-IP (You'll need to enter your No-IP credentials interactively)
/usr/local/bin/noip2 -C

# Start No-IP DUC
/usr/local/bin/noip2

# Send a test email
echo "This is a test email from your new mail server." | mail -s "Test Email" $EMAIL

echo "Setup complete. Please check your email at $EMAIL for a test message."
echo "You should now be able to ping your domain: $DOMAIN"
echo "Note: DNS changes may take some time to propagate."