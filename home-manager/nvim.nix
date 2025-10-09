{ config, pkgs, inputs, ... }: 
{
  # Enable and configure neovim
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF \n${builtins.readFile file}\nEOF\n";
    repoRoot = inputs.shared-nvim; 
  in
  {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Load options first
    extraLuaConfig = ''
        -- Tell init.lua we're under Home-Manager so it skips lazy.nvim
        vim.g.__hm_nvim = true
        ${builtins.readFile (repoRoot + "/nvim/lua/core/options.lua")}
        ${builtins.readFile (repoRoot + "/nvim/lua/core/keymaps.lua")}
    '';

    # Package dependencies
    extraPackages = with pkgs; [
		# Clipboards
		xclip         # x11
		wl-clipboard  # wayland

		# LSPs
		lua-language-server
		nixd
        pyright

        # For telescope
        ripgrep
    ];

    plugins = with pkgs.vimPlugins; [

		# Add LSP support
		{
			plugin = nvim-lspconfig;
			config = toLuaFile repoRoot + "/nvim/lua/plugin/lsp.lua";
		}

		# Nice plugin to make comments better
		{
			plugin = comment-nvim;
			config = toLua "require(\"Comment\").setup()";
		}

		{
			plugin = gruvbox-nvim;
			config = "colorscheme gruvbox";
		}

		neodev-nvim

		nvim-cmp
		{
			plugin = nvim-cmp;
			config = toLuaFile repoRoot + "/nvim/lua/plugin/cmp.lua";
		}

		{
			plugin = telescope-nvim;
			config = toLuaFile repoRoot + "/nvim/lua/plugin/telescope.lua";
		}

		# I believe this is meant to help with performance
		# in large code bases
		telescope-fzf-native-nvim

		cmp_luasnip
		cmp-nvim-lsp

		luasnip
		friendly-snippets

		lualine-nvim
		nvim-web-devicons

		{
			plugin = (nvim-treesitter.withPlugins (p: [
				p.tree-sitter-nix
				p.tree-sitter-vim
				p.tree-sitter-bash
				p.tree-sitter-lua
				p.tree-sitter-python
			]));
			config = toLuaFile repoRoot + "/nvim/lua/plugin/treesitter.lua";
		}

		vim-nix

    ];

  };  # End nvim configuations
}
