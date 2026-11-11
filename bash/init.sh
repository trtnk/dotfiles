# dotfiles のシェル設定。~/.bashrc の最後から読まれる（install.sh が1行足す）
# ディストリ既定の ~/.bashrc はそのまま残し、自分の追加だけをここに置く

# 履歴を多めに（既定の 1000 では足りない）
HISTSIZE=50000
HISTFILESIZE=100000

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

export PATH="$HOME/.local/bin:$PATH"

# 入っていれば読む（uv・cargo・nvm）
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# WSL のときだけ: 今のフォルダを Windows のエクスプローラで開く
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias e='/mnt/c/Windows/explorer.exe .'
fi

# マシンごとの設定（git に入れない。見本は bash/bashrc.local.example）
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
