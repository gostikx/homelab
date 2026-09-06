#!/bin/bash
set -e

echo "=== 4. Настройка обновлений безопасности ==="

if [ -f /etc/debian_version ]; then
    apt-get install -y unattended-upgrades apt-listchanges
    
    # Включаем автоматический запуск
    echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.map.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.map.d/20auto-upgrades

elif [ -f /etc/redhat-release ]; then
    dnf install -y dnf-automatic
    
    # Настраиваем скачивание и установку только обновлений безопасности (security)
    sed -i 's/upgrade_type = default/upgrade_type = security/' /etc/dnf/automatic.conf
    sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
    
    systemctl enable --now dnf-automatic.timer
fi
