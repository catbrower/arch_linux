#Configure Arch
echo "Configure Arch"
timedatectl set-timezone America/New_York
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo myarch > /etc/hostname

echo "Set root password"
passwd

#install Bootloader
mkdir /boot/efi
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

#Move files
cp /files/mkinitcpio.conf /etc
cp /files/hosts /etc
cp /files/grub /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

pacman -S xorg xorg-server
pacman -S gnome
systemctl start gdm.service
systemctl enable gdm.service
systemctl enable NetworkManager.service
