#!/bin/bash
set -e

echo "=== 2. Харденинг SSH ==="

# Меняем конфигурацию
sed -i "s/^#\?Port [0-9]*/Port $NEW_PORT/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Перезапуск демона в зависимости от системы управления инициализацией
if systemctl is-active --quiet ssh.socket; then
    systemctl daemon-reload && systemctl restart ssh.socket
elif systemctl list-unit-files | grep -q sshd.service; then
    systemctl restart sshd
else
    systemctl restart ssh
fi
