# Android emulator in docker container

[Official documentation](https://github.com/budtmo/docker-android "Go to budtmo/docker-android")

Проверяем что kvm достуен:

```sh
$ lsmod | grep kvm

kvm_intel             417792  4
kvm                  1396736  1 kvm_intel
irqbypass              12288  1 kvm
```

Обновляем пакеты:

```sh
$ sudo apt update
```

Устанавливаем зависимости:

```sh
$ sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```
