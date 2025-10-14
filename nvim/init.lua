
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

    -- resolve ~/.config/nvim symlink to the repo's real path
    local cfg = vim.fn.stdpath("config")  -- ~/.config/nvim
    local cfg_real = vim.fn.resolve(cfg)  -- /path/to/shared-nvim/nvim
    local repo_root = vim.fn.fnamemodify(cfg_real ~= "" and cfg_real or vim.fn.stdpath("config"), ":h")
    --local spec_path = repo_root .. "/traditional/lazy.lua"

    --local spec = dofile(spec_path) -- load the table from this file
    --require("lazy").setup(spec)

    vim.g.__shared_nvim_root = repo_root              -- handy to have

    local spec_path = repo_root .. "/traditional/lazy.lua"
    if vim.loop.fs_stat(spec_path) then
    local ok, spec = pcall(dofile, spec_path)       -- <— ABSOLUTE; not affected by :cd
    if ok then
      require("lazy").setup(spec)
    else
      vim.notify("shared-nvim: failed to load spec: " .. spec, vim.log.levels.ERROR)
    end
    else
      vim.notify("shared-nvim: spec file not found at " .. spec_path, vim.log.levels.ERROR)
    end

    -- declare plugins
    --require("lazy").setup(vim.fn.stdpath("config") .. "/../traditional/lazy.lua")

    -- run per-plugin configs (same files HM reads with builtins.readFile)
    pcall(function() require("plugins.lsp") end)
    pcall(function() require("plugins.telescope") end)
    pcall(function() require("plugins.treesitter") end)
    pcall(function() require("plugins.cmp") end)
    pcall(function() require("plugins.other") end)
end
