local map = vim.keymap.set

-- Keep search results and half-page scrolling centered.
map("n", "n", "nzzzv", { desc = "Next search result centered", silent = true })
map("n", "N", "Nzzzv", { desc = "Previous search result centered", silent = true })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered", silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered", silent = true })

-- Keep the visual selection active while changing indentation.
map("v", "<", "<gv", { desc = "Indent left and keep selection", silent = true })
map("v", ">", ">gv", { desc = "Indent right and keep selection", silent = true })

-- Use the common Ctrl-/ shortcut as an alias for Neovim's built-in commenting.
map("n", "<C-/>", "gcc", { desc = "Toggle comment line", remap = true })
map("n", "<C-_>", "gcc", { desc = "Toggle comment line", remap = true })
map("x", "<C-/>", "gc", { desc = "Toggle comment selection", remap = true })
map("x", "<C-_>", "gc", { desc = "Toggle comment selection", remap = true })

-- Core leader mappings stay small and easy to remember.
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file", silent = true })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window", silent = true })

-- Disable macro recording; accidental `q` presses are more costly than useful here.
map("n", "q", "<nop>", { desc = "Disable macro recording", silent = true })

map("n", "<leader>g", ":grep ", { desc = "Grep" })

map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Terminal", silent = true })
map("n", "<leader>tv", "<cmd>vsplit | terminal<cr>", { desc = "Vertical terminal", silent = true })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode", silent = true })

-- Move the current line or selected block up/down.
map("n", "<M-Down>", "<cmd>move .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<M-Up>", "<cmd>move .-2<CR>==", { desc = "Move line up", silent = true })
map("i", "<M-Down>", "<Esc><cmd>move .+1<CR>==gi", { desc = "Move line down", silent = true })
map("i", "<M-Up>", "<Esc><cmd>move .-2<CR>==gi", { desc = "Move line up", silent = true })
map("v", "<M-Down>", ":move '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<M-Up>", ":move '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Copy the current line or selected block up/down.
map("n", "<M-S-Down>", "<cmd>copy .<CR>", { desc = "Copy line down", silent = true })
map("n", "<M-S-Up>", "<cmd>copy .-1<CR>", { desc = "Copy line up", silent = true })
map("i", "<M-S-Down>", "<Esc><cmd>copy .<CR>gi", { desc = "Copy line down", silent = true })
map("i", "<M-S-Up>", "<Esc><cmd>copy .-1<CR>gi", { desc = "Copy line up", silent = true })
map("v", "<M-S-Down>", ":copy '><CR>gv", { desc = "Copy selection down", silent = true })
map("v", "<M-S-Up>", ":copy '<-1<CR>gv", { desc = "Copy selection up", silent = true })

-- Navigate through the jump list.
map("n", "<M-Left>", "<C-o>", { desc = "Jump backward", silent = true })
map("n", "<M-Right>", "<C-i>", { desc = "Jump forward", silent = true })
