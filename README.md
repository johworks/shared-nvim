# shared-nvim — one Neovim config, two ways (Home-Manager **and** traditional)

A single public repo you can use:

* **Traditional:** `~/.config/nvim` with `lazy.nvim` managing plugins.
* **Home-Manager (Pattern A):** Nix installs plugins (`pkgs.vimPlugins`) and **reads the same Lua files** from this repo via `builtins.readFile`. No HM symlink to `~/.config/nvim` required.

All editor/Lua config lives here once and is consumed by both paths.

---

## Layout

```
shared-nvim/
├─ README.md
├─ nvim/                         # shared runtime (Lua used by both)
│  ├─ init.lua                   # only bootstraps plugins in traditional mode
│  └─ lua/
│     ├─ core/
│     │  ├─ options.lua
│     │  └─ keymaps.lua
│     └─ plugins/
│        ├─ lsp.lua
│        ├─ cmp.lua
│        ├─ telescope.lua
│        ├─ treesitter.lua
│        └─ other.lua
├─ traditional/
│  ├─ install.sh                 # links ./nvim -> ~/.config/nvim and bootstraps lazy.nvim
│  └─ lazy.lua                   # plugin declarations for lazy.nvim (no config here)
└─ home-manager/
   └─ nvim.nix                   # HM module that reads Lua from this repo and installs plugins via nix
```

> In **traditional** mode, `init.lua` requires `lua/plugins/*.lua`.
> In **HM** mode, the HM module injects those same files with `toLuaFile (repoRoot + "/…")`.

---

## Traditional install

```bash
git clone https://github.com/<you>/shared-nvim.git
cd shared-nvim
./traditional/install.sh
nvim   # lazy.nvim installs plugins on first run
```

---

## Home-Manager install (as a **non-flake** flake input)

This repo doesn’t need to be a flake. Consume it as a *non-flake* input and import the module file from the input.

### 1) Add the input in your **system flake**

```nix
# flake.nix (top-level of your system repo)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";

    # NOTE: non-flake input (flake = false)
    sharedNvim = {
      url = "github:<you>/shared-nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sharedNvim, ... }@inputs: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # Make `inputs` available to modules:
      specialArgs = { inherit inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/laptop/configuration.nix
      ];
    };
  };
}
```

### 2) Import this repo’s HM module in your **home.nix**

```nix
# home.nix (your user HM module)
{ config, pkgs, inputs, ... }:
{
  imports = [
    (inputs.sharedNvim + "/home-manager/nvim.nix")
  ];
}
```

> Inside `home-manager/nvim.nix`, the module sets:
>
> ```nix
> repoRoot = inputs.sharedNvim; # points at this repo
> ```
>
> and uses `builtins.readFile (repoRoot + "/nvim/lua/...")` for the shared Lua.

### 3) Update / override the input when you change this repo

Pinned inputs won’t auto-refresh.

```bash
# update the pin in flake.lock
nix flake update --update-input sharedNvim

# or, while developing locally, override without touching the lock:
sudo nixos-rebuild test --flake .#laptop \
  --override-input sharedNvim path:/absolute/path/to/shared-nvim
```

---

## Verifying which path you’re using

### HM vs traditional

In HM, the module sets `vim.g.__hm_nvim = true`. Check inside Neovim:

```vim
:echo get(g:, '__hm_nvim', v:false)
```

* `v:true` → **HM path** (plugins from `/nix/store`).
* `v:false` → **traditional** (plugins under `~/.local/share/nvim/lazy`).

### Where a plugin came from

```vim
:lua print(vim.api.nvim_get_runtime_file('lua/lspconfig/init.lua', false)[1])
```

* `/nix/store/...` → Nix/HM managed.
* `~/.local/share/nvim/lazy/...` → traditional/lazy.nvim.

(Optional one-liner command you can keep around:)

```lua
vim.api.nvim_create_user_command('SharedNvimWhere', function()
  local hm = (vim.g.__hm_nvim and "HM" or "traditional")
  local src = vim.api.nvim_get_runtime_file('lua/lspconfig/init.lua', false)[1] or 'N/A'
  print(('mode=%s | lspconfig=%s'):format(hm, src))
end, {})
```

---

## Troubleshooting

* **Path concatenation in Nix:** always parenthesize when passing to your `toLuaFile`:

  ```nix
  toLuaFile (repoRoot + "/nvim/lua/plugins/treesitter.lua")
  ```
* **Input name:** avoid hyphens in the input key (`sharedNvim`) or quote everywhere (`inputs."shared-nvim"`).
* **Folder name:** use `plugins/` vs `plugin/` consistently across repo + Nix paths.
* **Skip lazy under HM:** ensure `init.lua` only bootstraps lazy.nvim when `not vim.g.__hm_nvim`.


## License

MIT

