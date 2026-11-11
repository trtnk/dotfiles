-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 1. Ctrl + j で Esc（挿入モード、ビジュアルモード、コマンドラインモード、ターミナルモード共通）
vim.keymap.set({ "i", "v", "c", "t" }, "<C-j>", "<Esc>", { desc = "Exit mode with Ctrl+j" })

-- 2. ; と : の入れ替え（ノーマルモード ＆ ビジュアルモード）
vim.keymap.set({ "n", "v" }, ";", ":", { nowait = true, desc = "Enter command mode" })
vim.keymap.set({ "n", "v" }, ":", ";", { nowait = true, desc = "Repeat last f/t jump" })

-- vim-tmux-navigator用の強制上書き設定
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { silent = true, desc = "Tmux Left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { silent = true, desc = "Tmux Down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { silent = true, desc = "Tmux Up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true, desc = "Tmux Right" })
