return {
  { "nvim-mini/mini.base16", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("config.matugen").apply() end,
    },
  },
}
