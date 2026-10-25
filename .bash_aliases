alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias picomc='nano ~/.config/picom/picom.conf' # edit config
alias i3conf='nano ~/.config/i3/config'

# yazi: cd into the folder you were in when you quit
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# monitor layouts via autorandr
#   monitor            show profiles (current one is marked)
#   monitor auto       pick by what's plugged in
#   monitor both|docked|mobile
monitor() {
  case "${1:-}" in
    "")   autorandr 2>/dev/null ;;
    auto) autorandr --change --force 2>/dev/null ;;
    *)    autorandr --load "$1" 2>/dev/null ;;
  esac
}
