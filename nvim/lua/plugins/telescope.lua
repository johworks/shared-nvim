-- local telescope = require('telescope')
-- local builtin = require('telescope.builtin')
local ok, telescope = pcall(require, "telescope")
if not ok then return end

telescope.setup({
	extensions = {
    	fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    	},
  	},
})

-- set keymaps *after* telescope is available
local tb_ok, tb = pcall(require, "telescope.builtin")
if tb_ok then
    vim.keymap.set('n', '<leader>pf', tb.find_files, { desc = "Telescope: Find files" })
    vim.keymap.set('n', '<leader>pg', tb.live_grep,  { desc = "Telescope: Live grep" })
    vim.keymap.set('n', '<leader>pb', tb.buffers,    { desc = "Telescope: Buffers" })
    vim.keymap.set('n', '<leader>ph', tb.help_tags,  { desc = "Telescope: Help tags" })
    vim.keymap.set('n', '<C-p>', tb.git_files,       { desc = "Telescope: Git files" })
end

telescope.load_extension('fzf')
