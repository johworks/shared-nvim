local ok, ts = pcall(require, "nvim-treesitter.configs")
if not ok then return end

local is_nix_packpath = vim.o.packpath:find("/nix/store", 1, true) ~= nil
local is_hm = vim.g.__hm_nvim == true or is_nix_packpath

-- Minimal base needed so the runtime ftplugins don't crash on first open
local base = { "lua", "vim", "vimdoc", "query", "regex" }

ts.setup({
  parser_install_dir = is_hm and (vim.fn.stdpath("data") .. "/treesitter-parsers") or nil,

  -- HM: Nix provides parsers through withPlugins, so do not run the installer.
  -- Traditional: install the base immediately; other langs can auto-install later
  ensure_installed = is_hm and {} or base,
  auto_install = not is_hm,   -- traditional = true, HM = false
  sync_install = false,

  highlight = { enable = true, additional_vim_regex_highlighting = false },
  incremental_selection = { enable = true },
  indent = { enable = true },
})
