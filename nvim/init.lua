
local is_hm = vim.g.__hm_nvim == true  -- HM sets this in extraLuaConfig

--shared core
require("core.options")
require("core.keymaps")
-- Question: Not sure what autocmds are, I don't have this file
--pcall(function() require("core.autocmds") end)

if not is_hm then
    -- bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if vim.fn.empty(vim.fn.glob(lazypath)) == 1 then
        vim.fn.system({ "git", "clone", "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git", lazypath })
    end
    vim.opt.rtp:prepend(lazypath)

    -- declare plugins
    require("lazy").setup(vim.fn.stdpath("config") .. "/../traditional/lazy.lua")

    -- run per-plugin configs (same files HM reads with builtins.readFile)
    pcall(function() require("plugins.lsp") end)
    pcall(function() require("plugins.telescope") end)
    pcall(function() require("plugins.treesitter") end)
    pcall(function() require("plugins.cmp") end)
    pcall(function() require("plugins.other") end)
end
