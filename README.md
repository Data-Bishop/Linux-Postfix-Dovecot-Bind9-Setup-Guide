# Linux Mail Server Setup with Postfix, Dovecot and Bind9

This repository contains a guide and configuration files for setting up a robust, self-hosted mail server on Linux systems using Postfix as the Mail Transfer Agent (MTA) and Dovecot as the IMAP/POP3 server.

## Prerequisites

- A Linux server (this guide was tested on Ubuntu 24.04 LTS)
- Root access to the server
- A domain name (this guide uses a free domain from No-IP)
- Basic knowledge of Linux command line and server administration

## Step-by-Step Guide

### 1. Update and Upgrade System

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install required packages

```bash
sudo apt install -y postfix dovecot-core dovecot-imapd dovecot-pop3d bind9 bind9utils bind9-doc
```

When prompted during Postfix installation, select "Internet Site" and enter your domain name.

### 3. Configure Postfix

Edit the main Postfix configuration file:
```bash
sudo nano /etc/postfix/main.cf
```

Replace the content with the configuration provided in **configs/main.cf**. Make sure to replace your_domain.ddns.net with your actual domain.

### 4. Configure Dovecot

Edit the Dovecot configuration file:
```bash
sudo nano /etc/dovecot/dovecot.conf
```

Replace the content with the configuration provided in **configs/dovecot.conf**.

### 5. Configure BIND9 (if using)

Edit the BIND9 local configuration file:
```bash
sudo nano /etc/bind/named.conf.local
```

Add the content from **configs/named.conf.local**, replacing your_domain.ddns.net with your actual domain.

Create a new zone file:
```bash
sudo nano /etc/bind/db.your_domain.ddns.net
```

Add the content from **configs/db.your_domain.ddns.net**, replacing your_domain.ddns.net and your_server_ip_address with your actual domain and server IP.

### 6. Set Up No-IP Dynamic DNS Client

Install build tools:
```bash
sudo apt install -y build-essential
```

Download and install No-IP DUC:
```bash
cd /usr/local/src/
sudo wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
sudo tar xzf noip-duc-linux.tar.gz
cd noip-2.1.9-1/
sudo make
sudo make install
```

Configure No-IP DUC:
```bash
sudo /usr/local/bin/noip2 -C
```

Follow the prompts to enter your No-IP account details and configure the client.

