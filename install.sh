#!/usr/bin/env bash
# install.sh  dotfiles をホームへシンボリックリンクで張る。何度走らせてもよい
#   既にあるファイルは .backup/<時刻>/ に退避してから張る（リポジトリ内・git に入らない）
#   足りないコマンドは最後に一覧で出す（入れはしない）
set -eu
here=$(cd "$(dirname "$0")" && pwd)
bk="$here/.backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$here/$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$bk/$(dirname "${dst#"$HOME"/}")"
    mv "$dst" "$bk/${dst#"$HOME"/}"
    echo "退避: $dst → $bk/${dst#"$HOME"/}"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "張った: $dst"
}

link tmux/tmux.conf "$HOME/.tmux.conf"
link nvim "$HOME/.config/nvim"
link glow/glow.yml "$HOME/.config/glow/glow.yml"
for f in "$here"/bin/*; do
  link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
done

# ~/.bashrc の最後に1行だけ足す（中身は書き換えない）
line=". \"$here/bash/init.sh\""
if ! grep -qF "$line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# dotfiles\n%s\n' "$line" >> "$HOME/.bashrc"
  echo "足した: ~/.bashrc の最後に $line"
fi

# tmux のプラグインマネージャ。プラグイン本体は tmux の中で Prefix + I
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 古いシェルでは PATH が通っていないので、確認の間だけ足す（cargo install したものを拾う）
PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
missing=()
for c in tmux nvim git rg fzf glow mdserve python3; do
  command -v "$c" >/dev/null || missing+=("$c")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo
  echo "足りないコマンド: ${missing[*]}"
  echo "  Ubuntu / Debian: sudo apt install tmux git neovim ripgrep fzf glow cargo python3"
  echo "  nvim が 0.10 より古い: https://github.com/neovim/neovim/releases"
  echo "  glow が apt にない: $here/install-glow.sh"
  echo "  mdserve: cargo install mdserve（ブラウザ表示用。なくても mdview は glow で表示する）"
fi
echo
echo "済み。新しいシェルを開き、tmux の中で Prefix + I でプラグインを入れる"
