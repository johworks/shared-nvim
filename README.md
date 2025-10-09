# shared-nvim — one Neovim config, two ways (Home-Manager **and** traditional)

A single public repo that you can use:

* **Traditional**: `~/.config/nvim` with `lazy.nvim` managing plugins.
* **Home-Manager (HM)**: Nix manages plugins (`pkgs.vimPlugins`), HM injects the *same* Lua via `extraLuaConfig`/`toLuaFile`.
  No HM symlink to `~/.config/nvim` is required (Pattern A).

The Lua code (options, keymaps, per-plugin setup) lives here once and is consumed by both paths.

---

## TL;DR

* **Traditional**:

  ```bash
  git clone https://github.com/<you>/shared-nvim.git
  cd shared-nvim && ./traditional/install.sh
  nvim   # lazy.nvim bootstraps plugins on first run
  ```

* **Home-Manager** (Nix):
  Import `home-manager/nvim.nix` in your HM config, set `repoRoot` to this repo’s path, and `home-manager switch`.

---

## Layout

```
shared-nvim/
├─ README.md
├─ nvim/                         # shared runtime (Lua used by both paths)
│  ├─ init.lua                   # only runs plugin bootstrap in *traditional* mode
│  └─ lua/
│     ├─ core/
│     │  ├─ options.lua
│     │  └─ keymaps.lua
│     └─ plugins/               # per-plugin configs (safe to require from both)
│        ├─ lsp.lua
│        ├─ cmp.lua
│        ├─ telescope.lua
│        ├─ treesitter.lua
│        └─ other.lua
├─ traditional/
│  ├─ install.sh                 # symlink nvim/ to ~/.config/nvim and bootstrap lazy.nvim
│  └─ lazy.lua                   # plugin *declarations* for lazy.nvim (no config here)
└─ home-manager/
   └─ nvim.nix                   # HM module that reads the same Lua and installs plugins via nix
```

> The **same** `nvim/lua/plugins/*.lua` files configure plugins in both paths.
> In traditional mode we `require()` them from `init.lua`.
> In HM mode we `builtins.readFile` them into `programs.neovim.plugins.[].config`.

---

## Traditional install

1. Clone this repo anywhere, then:

```bash
cd shared-nvim
./traditional/install.sh
```

2. Start Neovim:

```bash
nvim
```

* First run clones `lazy.nvim` and installs plugins listed in `traditional/lazy.lua`.
* Heavy/native plugins (e.g. `telescope-fzf-native`) may need `make`. If `make` isn’t available, the entry is skipped (see `cond` in `lazy.lua` if you want that behavior).

---

## Home-Manager install (Pattern A)

You **do not** need HM to stage `~/.config/nvim`. HM will:

* Install Neovim & plugins from Nix.
* Inject the same Lua from this repo via heredocs.

Use the provided module and point `repoRoot` to this repo’s path (absolute or relative inside your monorepo).

**`home-manager/nvim.nix` (included here) expects this variable:**

```nix
# inside home-manager/nvim.nix (edit this in your copy)
let
  # Set this to where *this* repo lives relative to your HM module.
  repoRoot = ../.;  # adjust to your tree
in
{
  programs.neovim = {
    enable = true;

    # Let init.lua know we're under HM so it *won't* do lazy.nvim bootstrap
    extraLuaConfig = ''
      vim.g.__hm_nvim = true
      ${builtins.readFile (repoRoot + "/nvim/lua/core/options.lua")}
      ${builtins.readFile (repoRoot + "/nvim/lua/core/keymaps.lua")}
    '';

    # Runtime tools you want on PATH
    extraPackages = with pkgs; [
      xclip wl-clipboard
      lua-language-server nixd pyright
      ripgrep
    ];

    # Plugins installed by Nix; configs are pulled from the same repo files:
    plugins = with pkgs.vimPlugins; [
      { plugin = nvim-lspconfig; config = "lua <<EOF\n" + builtins.readFile (repoRoot + "/nvim/lua/plugins/lsp.lua") + "\nEOF\n"; }
      { plugin = comment-nvim;   config = ''lua <<EOF
        require("Comment").setup()
      EOF
      ''; }
      { plugin = gruvbox-nvim;   config = "colorscheme gruvbox"; }

      neodev-nvim

      nvim-cmp
      { plugin = nvim-cmp;       config = "lua <<EOF\n" + builtins.readFile (repoRoot + "/nvim/lua/plugins/cmp.lua") + "\nEOF\n"; }

      { plugin = telescope-nvim; config = "lua <<EOF\n" + builtins.readFile (repoRoot + "/nvim/lua/plugins/telescope.lua") + "\nEOF\n"; }
      telescope-fzf-native-nvim

      cmp_luasnip
      cmp-nvim-lsp
      luasnip
      friendly-snippets

      lualine-nvim
      nvim-web-devicons

      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix p.tree-sitter-vim p.tree-sitter-bash
          p.tree-sitter-lua p.tree-sitter-python
        ]));
        config = "lua <<EOF\n" + builtins.readFile (repoRoot + "/nvim/lua/plugins/treesitter.lua") + "\nEOF\n";
      }

      vim-nix
    ];
  };

  programs.home-manager.enable = true;
}
```

**Import it** from your user’s HM config (NixOS or standalone):

```nix
{ ... }:
{
  imports = [
    # If this repo is a subdir of your big system repo, point to it directly:
    ./path/to/shared-nvim/home-manager/nvim.nix
  ];
}
```

Then activate:

```bash
home-manager switch
# or if embedded in a NixOS module, `sudo nixos-rebuild switch`
```

---

## How the two paths avoid double-config

* HM sets `vim.g.__hm_nvim = true` in `extraLuaConfig`.
* `nvim/init.lua` checks this flag and **skips** `lazy.nvim` bootstrap + `require("plugins.*")` when HM is in charge.
* HM injects each plugin’s config block via `plugins = [ { plugin = ..., config = "...lua heredoc..." } ]`.

This keeps responsibilities clean:

* **Traditional** → `init.lua` does plugin bootstrap + `require("plugins/…")`.
* **HM** → Nix installs plugins and injects configs; `init.lua` only sets core options/keymaps.

---

## Updating plugins

* **Traditional**: edit `traditional/lazy.lua`.
* **HM**: edit the plugin list under `programs.neovim.plugins`.
* **Configs** (LSP, TS, Telescope, CMP, …) are in `nvim/lua/plugins/*.lua` and shared by both.

Tip: keep the two plugin lists logically in sync. If you add/remove a plugin, update both places.

---

## Troubleshooting

* **“Plugins configured twice”**: ensure `vim.g.__hm_nvim = true` is set in HM’s `extraLuaConfig`, and that your `init.lua` only `require("plugins.*")` when **not** under HM.
* **“HM can’t find Lua files”**: fix `repoRoot` in `home-manager/nvim.nix` to the correct path to this repo.
* **Native plugins failing (fzf-native/treesitter)**: you may need a compiler (`gcc`) at build time; either add it to `home.packages` for HM or remove/guard the plugin.

---

## FAQ

**Why not have HM place this repo at `~/.config/nvim`?**
You don’t need to for Pattern A. HM reads the same Lua files via `builtins.readFile` and manages plugins itself, while the traditional path uses `lazy.nvim`.

**Can I use this on locked-down systems without Nix?**
Yes, use the **traditional** path (`install.sh`). HM requires Nix.

---

## License

MIT (or your preference).

