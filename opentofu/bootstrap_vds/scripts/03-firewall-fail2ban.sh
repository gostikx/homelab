#!/bin/bash
set -e

echo "=== 3. Настройка Firewall и Fail2ban ==="

# Установка Fail2ban и утилит в зависимости от пакетного менеджера
if [ -f /etc/debian_version ]; then
    apt-get update && apt-get install -y ufw fail2ban
    
    ufw allow "$NEW_PORT/tcp"
    ufw --force enable

elif [ -f /etc/redhat-release ]; then
    dnf install -y epel-release
    dnf install -y firewalld fail2ban
    
    systemctl enable --now firewalld
    firewall-cmd --permanent --add-port="$NEW_PORT/tcp"
    firewall-cmd --reload
fi

# Базовая настройка Fail2ban (защита нового порта SSH)
cat <<EOT > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = $NEW_PORT
EOT

systemctl enable --now fail2ban
systemctl restart fail2ban
