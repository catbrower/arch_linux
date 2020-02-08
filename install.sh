echo "Make sure that the partitions are setup first."
echo "This script will remake the file system and wipe the drive"
echo "Ensure that you are connected to the internet"
echo "Please enter the drive you wish to install to. Be careful"
read drive

#File system setup
cryptsetup -y -v luksFormat "${drive}1" cryptroot
cryptsetup open "${drive}1" cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mkfs.fat -F32 "${drive}2"
mount /dev/mapper/cryptroot /mnt
mount "${drive}1" /mnt/boot

#Install Arch
pacman -Syy
pacman -S reflector
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
cp ./mkinitcpio.conf /mnt/etc
cp ./grub /mnt/etc/default
cp ./hosts /mnt/etc

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
locale-gen
echo "KEYMAP=en-latin1" >> /etc/vconsole.conf
echo "device" /etc/hostname
echo "Setting root password"
passwd

#install Bootloader
pacman -S grub efibootmgr
mkdir /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /mnt/boot/grub/grub.cfg
mkinitcpio -P

#e734fa5f-15c5-4649-8e8a-0d1b3d17d871