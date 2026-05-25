{ lib, options, pkgs, inputs, ... }:
let
  initLuaConfig = ''
      -- Tell init.lua we're under Home-Manager so it skips lazy.nvim
      vim.g.__hm_nvim = true
      ${builtins.readFile (inputs.shared-nvim + "/nvim/lua/core/options.lua")}
      ${builtins.readFile (inputs.shared-nvim + "/nvim/lua/core/keymaps.lua")}
  '';
in
{
  # Enable and configure neovim
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF \n${builtins.readFile file}\nEOF\n";
    repoRoot = inputs.shared-nvim; 
  in
  ({
    enable = true;
    withRuby = true;
    withPython3 = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

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
			type = "viml";
			config = toLuaFile (repoRoot + "/nvim/lua/plugins/lsp.lua");
		}

		# Nice plugin to make comments better
		{
			plugin = comment-nvim;
			type = "viml";
			config = toLua "require(\"Comment\").setup()";
		}

		{
			plugin = gruvbox-nvim;
			type = "viml";
			config = "colorscheme gruvbox";
		}

		{
			plugin = neodev-nvim;
		}
		{
			plugin = nvim-cmp;
			type = "viml";
			config = toLuaFile (repoRoot + "/nvim/lua/plugins/cmp.lua");
		}

		{
			plugin = telescope-nvim;
			type = "viml";
			config = toLuaFile (repoRoot + "/nvim/lua/plugins/telescope.lua");
		}

		# I believe this is meant to help with performance
		# in large code bases
		{
			plugin = telescope-fzf-native-nvim;
		}

		{
			plugin = cmp_luasnip;
		}
		{
			plugin = cmp-nvim-lsp;
		}

		{
			plugin = luasnip;
		}
		{
			plugin = friendly-snippets;
		}

		{
			plugin = lualine-nvim;
		}
		{
			plugin = nvim-web-devicons;
		}

		{
			plugin = (nvim-treesitter.withPlugins (p: [
				p.tree-sitter-nix
				p.tree-sitter-vim
				p.tree-sitter-bash
				p.tree-sitter-lua
				p.tree-sitter-python
				p.tree-sitter-vimdoc
				p.tree-sitter-query
				p.tree-sitter-regex
				p.tree-sitter-systemverilog
			]));
			type = "viml";
			config = toLuaFile (repoRoot + "/nvim/lua/plugins/treesitter.lua");
		}

		{
			plugin = vim-nix;
		}

    ];

  } // lib.optionalAttrs (options.programs.neovim ? initLua) {
    initLua = initLuaConfig;
  } // lib.optionalAttrs (!(options.programs.neovim ? initLua)) {
    extraLuaConfig = initLuaConfig;
  });  # End nvim configuations
}
