#!/usr/bin/env ash

echo "==> Enabling SSH"

echo root:root | chpasswd

apk add openssh
sed -i 's/.*PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
service sshd start
