<h1 align="center">dotfiles</h1>

<div align="center">

![Arch Linux](https://img.shields.io/badge/Arch_Linux-11111b?style=for-the-badge&logo=arch-linux&logoColor=89b4fa)
![Hyprland](https://img.shields.io/badge/Hyprland-11111b?style=for-the-badge&logo=hyprland&logoColor=89dceb)
<a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-f38ba8?style=for-the-badge&labelColor=11111b" /></a>

</div>

My Arch + Hyprland setup. One wallpaper change re-themes the whole desktop through [matugen](https://github.com/InioX/matugen).

The Waybar layout started from [haikal-hakim/athena](https://github.com/haikal-hakim/athena). Thanks to Haikal for the modular bar.

## What's here

```text
.config/
├── hypr/       # Hyprland (Lua config), hyprlock, hypridle
├── waybar/     # modular bar, with a Tailscale toggle in the connections drawer
├── matugen/    # templates: waybar, wofi, swaync, hyprlock, borders, kitty, cava,
│               #   GTK, KDE/Dolphin, Neovim, SDDM login, Sidra (Apple Music)
├── wofi/       # launcher, keybind cheatsheet, wallpaper picker
├── kitty/      # JetBrainsMono Nerd Font, translucent, matugen colors
├── swaync/     # notification centre with quick-action buttons
├── nvim/       # LazyVim, coloured from the wallpaper
├── sddm/       # login theme matching hyprlock + one-time root setup script
├── kanshi/     # laptop / docked display profiles
├── fastfetch/  # plus custom ASCII art in logos/ (try `fflogos`)
├── starship.toml  btop/  cava/  satty/  thefuck/
└── bash/ctf.sh # CTF helpers, sourced from .zshrc
.local/bin/     # wallpaper, lock screen, screenshot, Tailscale and menu scripts
.zshrc          # zsh + autosuggestions, syntax highlighting, starship
```

## Highlights

| Keys | What it does |
|---|---|
| `Super + W` / `Super + Shift + W` | Next / random wallpaper, using an awww "grow" transition from the cursor, then re-theme everything |
| `Super + Ctrl + W` | Wallpaper picker with a thumbnail grid |
| `Super + Escape` | Lock screen with a clock, greeting, profile picture, now playing, battery and fingerprint unlock |
| `Super + Print` | Screenshot a region and annotate it in satty |
| `Super + Shift + C` | Color picker that copies the hex code |
| `Super + Tab` | Workspace overview (Hyprspace plugin) |
| `Super + N` | Notification centre |
| `Super + Shift + R` / `Super + Ctrl + R` | Record a region / the screen (again = stop) |
| `Super + Shift + B` | Rearrange the notification centre's buttons |
| `Super + /` | Cheatsheet of every keybind, read live from Hyprland |

`showoff` fills a workspace with btop, cava, cbonsai, pipes and fastfetch.

## Packages

```sh
sudo pacman -S hyprland hyprpm hyprlock hypridle waybar wofi kitty swaync kanshi awww matugen \
  zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions starship thefuck \
  fastfetch btop cava satty grim slurp hyprpicker wf-recorder playerctl jq ffmpeg tailscale \
  neovim lazygit ripgrep fd nodejs npm tree-sitter-cli plymouth adw-gtk-theme \
  asciiquarium cmatrix ttf-jetbrains-mono-nerd
yay -S cbonsai pipes.sh sidra-bin

# plugins
hyprpm update
hyprpm add https://github.com/KZDKM/Hyprspace && hyprpm enable Hyprspace
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors && hyprpm enable dynamic-cursors
```

Login screen + boot splash (backs up the current boot image first; `--undo` reverts):

```sh
sudo ~/.config/sddm/setup-login-boot.sh
```

## Install

Back up your own configs first, then:

```sh
git clone https://github.com/<you>/athena && cd athena
cp -r .config/* ~/.config/ && cp -r .local/bin/* ~/.local/bin/ && cp .zshrc ~/
mkdir -p ~/Pictures/Wallpapers   # put wallpapers here, then press Super+W
```

`kanshi/config` and `satty/config.toml` contain settings specific to my machine (monitor scale, screenshot path). Adjust them for yours.

## Keeping it updated

`./sync.sh` copies the live configs from `$HOME` into the repo. Review the changes with `git diff`, then commit.
