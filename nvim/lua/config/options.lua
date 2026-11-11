-- =============================================================================
-- 1. 基本設定
-- =============================================================================
-- マウスの挙動をVimと同じにする（ターミナル側のドラッグコピーを有効にする）
vim.opt.mouse = ""

-- クリップボードは有効（unnamedplus）のまま維持する
vim.opt.clipboard = "unnamedplus"

-- =============================================================================
-- 2. SSH接続のときは、ヤンクを OSC 52 で手元のターミナルへ送る（Neovim 0.10+ の組み込み）
-- =============================================================================
-- サーバに xclip 等がなくても手元のクリップボードに入る。
-- 貼り付けは OSC 52 の読み取りに対応しないターミナル（Windows Terminal など）で固まるので、
-- nvim 内のレジスタから返す。手元からの貼り付けはターミナルの貼り付け（Ctrl+Shift+V）を使う。
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
