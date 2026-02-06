return {
  -- 1. The Navigation (Seamless movement between Vim and Tmux)
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- 2. The Slime (Sending code to the REPL)
  {
    "jpalardy/vim-slime",
    init = function()
      -- Tell slime to use Tmux
      vim.g.slime_target = "tmux"
      -- Defaults: Use the socket 'default' and send to the 'last' pane used
      vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
      -- Don't ask for confirmation every time (Workflow speed)
      vim.g.slime_dont_ask_default = 1
    end,
    keys = {
      -- Create a custom keybind for "Run Selection"
      -- This maps <leader>r to send the current selection or paragraph
      { "<leader>r", "<Plug>SlimeRegionSend", mode = "x", desc = "Run Selection (Slime)" },
      { "<leader>r", "<Plug>SlimeParagraphSend", mode = "n", desc = "Run Paragraph (Slime)" },
    },
  },
}
