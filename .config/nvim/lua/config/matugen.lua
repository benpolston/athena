-- Wallpaper-driven colour scheme: matugen writes lua/matugen-colors.lua (base16),
-- mini.base16 turns it into highlights. Changing wallpaper sends SIGUSR1 to recolour open nvims.
local M = {}

function M.apply()
  package.loaded["matugen-colors"] = nil
  local ok, palette = pcall(require, "matugen-colors")
  if not ok then
    vim.cmd.colorscheme("tokyonight")
    return
  end
  vim.cmd("highlight clear")
  require("mini.base16").setup({ palette = palette, use_cterm = true })
  vim.g.colors_name = "matugen"
  -- let kitty's translucent background (and Hyprland blur) show through
  for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "LineNr", "FoldColumn" }) do
    vim.api.nvim_set_hl(0, g, vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = g }), { bg = "NONE" }))
  end
end

vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function() vim.schedule(M.apply) end,
})

return M
