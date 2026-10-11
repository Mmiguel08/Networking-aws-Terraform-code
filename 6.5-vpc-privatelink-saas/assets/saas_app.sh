#!/bin/bash
# User data for EC2-C (the "SaaS" service).
# No package installs on purpose: the private subnet has no internet/NAT,
# so we only use what is already on Amazon Linux 2023 (python3).
set -e

mkdir -p /opt/app

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Hello from the SaaS provider (EC2-C in VPC-B) - served via AWS PrivateLink - private IP $IP" > /opt/app/index.html

cat > /etc/systemd/system/saas-app.service <<UNIT
[Unit]
Description=Demo SaaS application
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/app
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now saas-app
