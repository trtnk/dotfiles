#!/usr/bin/env bash
# install-glow.sh  glow を apt なし・sudo なしで ~/.local/bin に入れる
#   配布ページの実行ファイルを取って置くだけ。何度走らせてもよい
#   版は GLOW_VERSION で変えられる（例: GLOW_VERSION=3.0.0 ./install-glow.sh）
set -eu

ver=${GLOW_VERSION:-3.0.0}

case "$(uname -m)" in
  x86_64)        arch=x86_64 ;;
  aarch64|arm64) arch=arm64 ;;
  armv7l|armv6l) arch=arm ;;
  i386|i686)     arch=i386 ;;
  *) echo "未対応のCPUです: $(uname -m)" >&2; exit 1 ;;
esac

url="https://github.com/charmbracelet/glow/releases/download/v${ver}/glow_${ver}_Linux_${arch}.tar.gz"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "取得: $url"
curl -fsSLo "$tmp/glow.tar.gz" "$url" || { echo "取得に失敗しました（版・CPU・ネットワークを確かめてください）" >&2; exit 1; }
tar -xzf "$tmp/glow.tar.gz" -C "$tmp" || { echo "解凍に失敗しました" >&2; exit 1; }

bin=$(find "$tmp" -name glow -type f | head -n1)
if [ -z "$bin" ]; then
  echo "解凍した中に glow がありません。中身:" >&2
  find "$tmp" | head -20 >&2
  exit 1
fi

mkdir -p "$HOME/.local/bin"
install -m 755 "$bin" "$HOME/.local/bin/glow"
echo "入れた: $HOME/.local/bin/glow"
"$HOME/.local/bin/glow" --version
