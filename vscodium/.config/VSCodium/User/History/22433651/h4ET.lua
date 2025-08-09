return {
    {
      "catppuccin/nvim",
      lazy = false,
      name = "catppuccin",
      priority = 1000,
  
      config = function()
        require("catppuccin").setup({
          transparent_background = false:w
          ,
        })
        vim.cmd.colorscheme "catppuccin-mocha"
      end
    }
  }