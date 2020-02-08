echo "Make sure that the partitions are setup first."
echo "This script will remake the file system and wipe the drive"
echo "Ensure that you are connected to the internet"
echo "Please enter the drive you wish to install to. Be careful"
read drive

#File system setup
cryptsetup -y -v luksFormat "${drive}2"
cryptsetup open "${drive}2" cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mkfs.fat -F32 "${drive}1"
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "${drive}1" /mnt/boot

#Install Arch
echo "Install Arch"
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

#Configure Arch
echo "Configure Arch"
pacman -S xorg xorg-server
pacman -S gnome
systemctl start gdm.service
systemctl enable gdm.service
systemctl enable NetworkManager.service
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
locale-gen
echo "KEYMAP=en-latin1" > /etc/vconsole.conf
echo "device" > /etc/hostname
echo "Setting root password"
passwd

#install Bootloader
pacman -S grub efibootmgr
mkdir /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

exit

#Move config files
echo "Copy files and regen conf"
cp ./mkinitcpio.conf /mnt/etc
cp ./grub /mnt/etc/default
cp ./hosts /mnt/etc

#Regen files
arch-chroot /mnt
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P
