# CTF / security-research shell helpers. Sourced from ~/.bashrc.
# Only point these tools at systems you own or are authorised to test.

export PATH="$HOME/.local/bin:$(ruby -e 'puts Gem.user_dir' 2>/dev/null)/bin:$PATH"
export SECLISTS=/usr/share/seclists          # wordlists (AUR: seclists)
export WORDLIST=$SECLISTS/Discovery/Web-Content/raft-medium-words.txt

# ---------- nicer basics ----------
alias ll='eza -lah --git --group-directories-first'
alias la='eza -a'
alias lt='eza -T --level=2'
alias b='bat --style=plain'
alias ..='cd ..'
alias ...='cd ../..'
alias please='sudo $(fc -ln -1)'
alias ports='ss -tulpn'
alias myip='ip -brief -4 addr'
alias vpnip='ip -4 -o addr show tun0 2>/dev/null | awk "{print \$4}" | cut -d/ -f1'
alias hexd='hexyl'
alias j='jobs'

# Kali-style names for impacket (Arch installs them as <name>.py), so writeup commands work as written.
# (bash aliases only expand in interactive shells; use the .py name inside scripts)
for _f in /usr/bin/{psexec,smbexec,wmiexec,atexec,dcomexec,secretsdump,smbserver,smbclient,GetNPUsers,GetUserSPNs,getTGT,getST,ticketer,lookupsid,mssqlclient,ntlmrelayx,rpcdump,samrdump,addcomputer,rbcd,reg,services,findDelegation,GetADUsers,raiseChild}.py; do
  [ -e "$_f" ] && alias "impacket-$(basename "$_f" .py)=$(basename "$_f")"
done; unset _f

# ---------- serving / receiving files ----------
alias serve='python3 -m http.server 8000'                  # share the current dir on :8000
alias listen='nc -lvnp'                                    # listen <port>
alias smbserve='smbserver.py share . -smb2support'   # quick SMB share of the cwd

# ---------- recon ----------
alias nmapq='nmap -sC -sV -T4'                                       # nmapq <host>
nmapfull() { nmap -p- --min-rate 3000 -T4 -oN "nmap-allports.txt" "$1" && \
  nmap -sC -sV -p "$(grep -oP '^\d+(?=/tcp\s+open)' nmap-allports.txt | paste -sd,)" -oN nmap-detail.txt "$1"; }
alias dirs='feroxbuster -w $WORDLIST -u'                             # dirs http://host
alias fuzz='ffuf -w $WORDLIST -u'                                    # fuzz http://host/FUZZ

# ---------- pwn / RE ----------
alias gdbp='pwndbg'                                        # gdb + pwndbg (plain gdb stays untouched)
alias rop='ROPgadget --binary'
alias strs='strings -n 8'
alias elf='readelf -h'
pwnt() { pwn template "$1" > solve.py && chmod +x solve.py; }      # pwnt ./binary

# ---------- forensics / misc ----------
alias exif='exiftool'
alias bw='binwalk -e'
alias hashid='john --list=formats | tr "," "\n" | grep -i'
b64d() { echo -n "$1" | base64 -d; echo; }
b64e() { echo -n "$1" | base64; }
rot13() { echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'; }

extract() {
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;; *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz|*.txz)   tar xJf "$1" ;; *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;; *.zip|*.jar|*.apk) unzip "$1" ;; *.7z) 7z x "$1" ;;
    *.gz) gunzip "$1" ;; *.bz2) bunzip2 "$1" ;; *.xz) unxz "$1" ;; *.rar) unrar x "$1" ;;
    *) echo "don't know how to extract '$1'" ;;
  esac
}

# ---------- CTF workspace ----------
ctf() {  # ctf <name>  -> ~/ctf/<name>/{recon,loot,exploit,notes}
  [ -n "$1" ] || { echo "usage: ctf <name>"; return 1; }
  mkdir -p ~/ctf/"$1"/{recon,loot,exploit,notes} && cd ~/ctf/"$1" || return
}

# ---------- reverse-shell reachability (your firewall blocks incoming by default) ----------
vpn-open()  { sudo ufw allow in on "${1:-tun0}" comment 'CTF VPN' && echo "incoming allowed on ${1:-tun0}"; }
vpn-close() { sudo ufw delete allow in on "${1:-tun0}" && echo "incoming closed on ${1:-tun0}"; }

# tty stabilise reminder (paste on target after catching a shell)
alias tty-help='echo "python3 -c '"'"'import pty;pty.spawn(\"/bin/bash\")'"'"'  ->  Ctrl-Z  ->  stty raw -echo; fg  ->  export TERM=xterm"'
