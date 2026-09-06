#!/bin/bash
set -e

echo "=== 1. Настройка пользователя и прав ==="

# Создаем пользователя, если его нет
if ! id -u "$NEW_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$NEW_USER"
    passwd -d "$NEW_USER"
fi

# Настройка SSH-ключей
USER_HOME=$(eval echo ~$NEW_USER)
mkdir -p "$USER_HOME/.ssh"
echo "$PUB_KEY" > "$USER_HOME/.ssh/authorized_keys"
chown -R "$NEW_USER:$NEW_USER" "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
chmod 600 "$USER_HOME/.ssh/authorized_keys"

# Определение административной группы
if getent group wheel >/dev/null 2>&1; then
    ADMIN_GROUP="wheel"
elif getent group sudo >/dev/null 2>&1; then
    ADMIN_GROUP="sudo"
else
    echo "Ошибка: Административная группа не найдена." && exit 1
fi

usermod -aG "$ADMIN_GROUP" "$NEW_USER"
echo "%$ADMIN_GROUP ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
