#!/usr/bin/env zsh
# curl -sSL https://gist.github.com/dbrentley/5e8f68a66ce304daa4636824b52f8d58/raw | zsh
# curl -sSL https://shorturl.at/fvJT8 | zsh

loadkeys en
# /usr/share/kbd/consolefonts
setfont ter-u16n

timedatectl
echo -e "d\n\nd\nw\n" | fdisk /dev/sda
echo -e "n\n\n\n\n+4G\nn\n\n\n\n\nw\nt\n1\n82\nw\n" | fdisk /dev/sda
mkswap /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
swapon /dev/sda1

pacstrap -K /mnt base linux linux-firmware git networkmanager vim openssh openbox \
    xorg xorg-apps xorg-xinit sudo grub ttf-dejavu ttf-liberation xfce4-terminal \
    xfce4-panel otf-commit-mono-nerd obconf chromium picom lxappearance
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

useradd -m dbrent
usermod -d /home/dbrent -m dbrent
usermod -a -G wheel dbrent
echo "dbrent:Password123!" | chpasswd

echo "exec openbox-session" > /home/dbrent/.xinitrc
echo arch > /etc/hostname
echo "Xft.dpi: 92" > /home/dbrent/.Xresources
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

mkdir -p /home/dbrent/.config/openbox
mkdir -p /home/dbrent/gtk-3.0

cp -R openbox ~/.config/
cp -R gtk-3.0 ~/.config/

mkdir /home/dbrent/.themes
git clone https://github.com/numixproject/numix-gtk-theme-dark.git /home/dbrent/.themes/numix
chown -R dbrent:dbrent /home/dbrent

systemctl enable NetworkManager
systemctl enable sshd

systemctl start NetworkManager
systemctl start sshd

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P
exit
umount /mnt

#xrandr --output eDP1 --dpi 192
