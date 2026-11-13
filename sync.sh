#!/usr/bin/env bash
# Copy the live configs from $HOME into this repo.
# Usage: ./sync.sh   then review with `git status` / `git diff` and commit.
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_DIRS=(hypr waybar wofi kitty swaync matugen kanshi fastfetch btop satty bash sddm nvim)
CONFIG_FILES=(starship.toml cava/config thefuck/settings.py)
BIN=(cycle-wallpaper wallpaper-picker screenshot-edit lock-info waybar-tailscale cheatsheet power-menu screen-record showoff apply-kde-colors fflogos panel-buttons)
HOME_FILES=(.zshrc)

for d in "${CONFIG_DIRS[@]}"; do
  rm -rf ".config/$d"
  mkdir -p ".config/$d"
  cp -a "$HOME/.config/$d/." ".config/$d/"
done
for f in "${CONFIG_FILES[@]}"; do
  mkdir -p ".config/$(dirname "$f")"
  cp -a "$HOME/.config/$f" ".config/$f"
done
mkdir -p .local/bin
for f in "${BIN[@]}"; do cp -a "$HOME/.local/bin/$f" ".local/bin/$f"; done
for f in "${HOME_FILES[@]}"; do cp -a "$HOME/$f" "$f"; done

# Drop backups, caches and the retired hyprpaper config
find .config \( -name '*.bak' -o -name '*.bak[0-9]*' -o -name '*.orig' -o -name '__pycache__' -o -name 'hyprpaper.conf' -o -name '*.pre-extras' \) -prune -exec rm -rf {} +

echo "Synced. Review with: git status"
