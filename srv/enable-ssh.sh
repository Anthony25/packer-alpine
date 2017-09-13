#!/usr/bin/env ash

echo "==> Enabling SSH"

echo root:root | chpasswd

apk add openssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service sshd start
