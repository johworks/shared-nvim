local ok, ts = pcall(require, "nvim-treesitter.configs")
if not ok then return end

local is_hm = vim.g__hm_nvim == true

-- Minimal base needed so the runtime ftplugins don't crash on first open
local base = { "lua", "vim", "vimdoc", "query", "regex" }

ts.setup({
  -- HM: Nix provides parsers, so enumerate them explicitly (base + your langs)
  -- Traditional: install the base immediately; other langs can auto-install later
  ensure_installed = is_hm and { "lua", "nix", "bash", "vim", "python", "verilog" } or base,
  auto_install = not is_hm,   -- traditional = true, HM = false
  sync_install = false,

  highlight = { enable = true, additional_vim_regex_highlighting = false },
  incremental_selection = { enable = true },
  indent = { enable = true },
})
