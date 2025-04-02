#!/bin/bash

MEM_SIZE_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_SIZE_MB=$((MEM_SIZE_KB / 1024))
SWAP_BS_COUNT=$((MEM_SIZE_MB * 2))
TIMEZONE=""
LOCALE="en_US.UTF-8 UTF-8"
HOSTNAME=""
USERNAME=""
DRIVE=""
EFI_PKG="efibootmgr"
GRUB_EFI="--target=x86_64-efi --efi-directory=/boot/ --bootloader-id=grub"


## Ensuring that fzf is installed 
if [[ ! $(command -v fzf) ]]; then
	pacman -Sy --noconfirm fzf
fi

## Creating a swap file
dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_BS_COUNT
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab


## Selecting Timezone
echo "Select your timezone: "
TIMEZONE=$(find /usr/share/zoneinfo -type f | fzf --prompt="Select your timezone: ")
ln -sf $TIMEZONE /etc/localtime
hwclock --systohc

## Setting Locale
echo "$LOCALE" >> /etc/locale.gen
locale-gen
echo "LANG=$(echo ${LOCALE} | awk '{print $1}')" > /etc/locale.conf

## hostname
echo "hostname: "
read HOSTNAME
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

## root password
echo "root password: "
passwd

## Adding user
echo "Enter username: "
read USERNAME
useradd -G wheel -m $USERNAME
echo "Enter $USERNAME password: "
passwd $USERNAME
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

## grub
echo "Enter your main drive for grub: "
read DRIVE
grub-install $DRIVE
grub-mkconfig -o /boot/grub/grub.cfg
