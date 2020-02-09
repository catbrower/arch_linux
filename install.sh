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

#Move config files
cp ./mkinitcpio.conf /mnt/files
cp ./grub /mnt/files
cp ./hosts /mnt/files
cp ./install2.sh /mnt/install.sh

arch-chroot /mnt

