#!/usr/bin/env bash
# One-time root setup: matching SDDM login theme + Plymouth boot splash.
# Run with:  sudo ~/.config/sddm/setup-login-boot.sh
# Undo:      sudo ~/.config/sddm/setup-login-boot.sh --undo
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
USER_NAME=${SUDO_USER:?run via sudo from your user}
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
SRC="$USER_HOME/.config/sddm/hyprland-match"
THEME_DIR=/usr/share/sddm/themes/hyprland-match
UKI=/boot/EFI/Linux/arch-linux.efi
BACKUP_UKI=/boot/EFI/Linux/arch-linux-before-splash.efi

if [[ ${1:-} == --undo ]]; then
  rm -f /etc/sddm.conf.d/10-theme.conf
  [[ -f /etc/mkinitcpio.conf.before-splash ]] && cp /etc/mkinitcpio.conf.before-splash /etc/mkinitcpio.conf
  [[ -f /etc/kernel/cmdline.before-splash ]] && cp /etc/kernel/cmdline.before-splash /etc/kernel/cmdline
  mkinitcpio -P
  echo "Undone. SDDM is back to its default theme and Plymouth is out of the boot image."
  exit
fi

echo "==> 1/5 Backing up the current (working) boot image"
if [[ ! -f $BACKUP_UKI ]]; then
  cp "$UKI" "$BACKUP_UKI"
fi
cp -n /etc/mkinitcpio.conf /etc/mkinitcpio.conf.before-splash
cp -n /etc/kernel/cmdline /etc/kernel/cmdline.before-splash
# Explicit GRUB entry for the backup image, in case GRUB's UKI list is ambiguous
if ! grep -q before-splash /etc/grub.d/40_custom; then
  cat >> /etc/grub.d/40_custom <<'EOF'
menuentry "Arch Linux (backup: before boot splash)" {
    insmod fat
    insmod chain
    search --no-floppy --set=root --file /EFI/Linux/arch-linux-before-splash.efi
    chainloader /EFI/Linux/arch-linux-before-splash.efi
}
EOF
fi

echo "==> 2/5 Plymouth: hook + quiet splash"
if ! grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
  # must come before 'encrypt' so it can show the disk password prompt
  sed -i -E '/^HOOKS=/ s/\budev\b/udev plymouth/' /etc/mkinitcpio.conf
fi
grep -E '^HOOKS=' /etc/mkinitcpio.conf
for w in quiet splash; do
  grep -qw "$w" /etc/kernel/cmdline || sed -i "1 s/\$/ $w/" /etc/kernel/cmdline
done
cat /etc/kernel/cmdline
plymouth-set-default-theme bgrt   # ThinkPad logo + spinner + password box

echo "==> 3/5 Rebuilding boot image"
if ! mkinitcpio -P; then
  echo "!! mkinitcpio failed, restoring previous config"
  cp /etc/mkinitcpio.conf.before-splash /etc/mkinitcpio.conf
  cp /etc/kernel/cmdline.before-splash /etc/kernel/cmdline
  mkinitcpio -P
  exit 1
fi
[[ -f /boot/grub/grub.cfg ]] && grub-mkconfig -o /boot/grub/grub.cfg

echo "==> 4/5 Installing SDDM theme"
rm -rf "$THEME_DIR"
install -d "$THEME_DIR"
install -m644 "$SRC"/Main.qml "$SRC"/metadata.desktop "$SRC"/theme.conf "$THEME_DIR"/
# Colours + wallpaper are written here by your user session (matugen / cycle-wallpaper)
install -d -o "$USER_NAME" -g "$USER_NAME" -m755 /var/lib/hyprsddm
ln -sf /var/lib/hyprsddm/theme.conf.user "$THEME_DIR/theme.conf.user"
install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=hyprland-match\n' > /etc/sddm.conf.d/10-theme.conf

echo "==> 5/5 Seeding wallpaper, avatar and colours"
wp=$(cat "$USER_HOME/.cache/current-wallpaper" 2>/dev/null || true)
[[ -f $wp ]] && install -o "$USER_NAME" -m644 "$wp" /var/lib/hyprsddm/wallpaper
[[ -f $USER_HOME/.face ]] && install -o "$USER_NAME" -m644 "$USER_HOME/.face" /var/lib/hyprsddm/face.png

echo
echo "Done. Backup boot entry: 'Arch Linux (backup: before boot splash)' in the GRUB menu."
