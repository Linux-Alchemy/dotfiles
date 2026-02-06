-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Line navigation: Ctrl+0 to end of line, Ctrl+9 to start of line
vim.keymap.set({ "n", "v" }, "<C-0>", "$", { desc = "Go to end of line" })
vim.keymap.set({ "n", "v" }, "<C-9>", "^", { desc = "Go to start of line" })
vim.keymap.set("i", "<C-0>", "<End>", { desc = "Go to end of line" })
vim.keymap.set("i", "<C-9>", "<Home>", { desc = "Go to start of line" })
