#!/usr/bin/env bash
# install-tools.sh  apt のパッケージが古い環境（Ubuntu 22.04 など）で、sudo なしに必要なコマンドを ~/.local に入れる
#   neovim（0.10 以上）・glow・mdserve を、公式の配布物から入れる。すでに足りているものは飛ばす。何度走らせてもよい
#   tmux・git・ripgrep・fzf・python3 は apt のもので足りる:  sudo apt install tmux git ripgrep fzf python3
#   版は環境変数で変えられる: NVIM_VERSION（既定 0.11.6）・GLOW_VERSION（3.0.0）・MDSERVE_VERSION（1.1.0）
set -eu

here=$(cd "$(dirname "$0")" && pwd)
nvim_ver=${NVIM_VERSION:-0.11.6}
mdserve_ver=${MDSERVE_VERSION:-1.1.0}
bindir="$HOME/.local/bin"
optdir="$HOME/.local/opt"
mkdir -p "$bindir" "$optdir"

machine=$(uname -m)
case "$machine" in
  x86_64)        nvim_arch=x86_64; md_arch=x86_64 ;;
  aarch64|arm64) nvim_arch=arm64;  md_arch=aarch64 ;;
  *) echo "未対応のCPUです: $machine" >&2; exit 1 ;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

download() { curl -fsSLo "$2" "$1" || { echo "取得に失敗しました: $1" >&2; exit 1; }; }

# nvim が 0.10 以上か（$1 = nvim のパス）
nvim_ok() {
  local v
  v=$("$1" --version 2>/dev/null | sed -n '1s/^NVIM v\([0-9]*\.[0-9]*\).*/\1/p')
  [ -n "$v" ] && [ "$(printf '%s\n0.10\n' "$v" | sort -V | head -n1)" = "0.10" ]
}

# ---------- neovim ----------
if [ -x "$bindir/nvim" ] && nvim_ok "$bindir/nvim"; then
  echo "nvim: 済み（$bindir/nvim）"
elif command -v nvim >/dev/null && nvim_ok "$(command -v nvim)"; then
  echo "nvim: 済み（$(command -v nvim)）"
else
  url="https://github.com/neovim/neovim/releases/download/v${nvim_ver}/nvim-linux-${nvim_arch}.tar.gz"
  echo "nvim: 取得 $url"
  download "$url" "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp" || { echo "nvim の解凍に失敗しました" >&2; exit 1; }
  src=$(find "$tmp" -type f -name nvim -path '*/bin/nvim' | head -n1)
  [ -n "$src" ] || { echo "解凍した中に bin/nvim がありません" >&2; exit 1; }
  dir=$(dirname "$(dirname "$src")")
  rm -rf "$optdir/nvim-${nvim_ver}"
  mv "$dir" "$optdir/nvim-${nvim_ver}"
  ln -sfn "$optdir/nvim-${nvim_ver}/bin/nvim" "$bindir/nvim"
  echo "nvim: 入れた $bindir/nvim"
  "$bindir/nvim" --version | head -n1
fi

# ---------- glow ----------
if [ -x "$bindir/glow" ] || command -v glow >/dev/null; then
  echo "glow: 済み"
else
  "$here/install-glow.sh"
fi

# ---------- mdserve（ビルド済みの実行ファイル。Rust は要らない） ----------
if [ -x "$bindir/mdserve" ] || command -v mdserve >/dev/null; then
  echo "mdserve: 済み"
else
  url="https://github.com/jfernandez/mdserve/releases/download/v${mdserve_ver}/mdserve-${md_arch}-unknown-linux-musl"
  echo "mdserve: 取得 $url"
  download "$url" "$tmp/mdserve"
  install -m 755 "$tmp/mdserve" "$bindir/mdserve"
  echo "mdserve: 入れた $bindir/mdserve"
  "$bindir/mdserve" --version || true
fi

echo
echo "済み。新しいシェルを開くと、$bindir が PATH に入ります（install.sh のあと）"
