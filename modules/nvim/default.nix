{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg.configFile."nvim_live".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/nvim/lua-config";
  xdg.configFile."nvim".source = ./lua-config;

  programs.zsh.shellAliases = {
    nvimc = "NVIM_APPNAME=nvim_live nvim";
  };

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    #withPython3 = true;
    extraLuaPackages = luaPkgs: [
      luaPkgs.pathlib-nvim
      luaPkgs.lua-utils-nvim
    ];

    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
      gcc
      lua

      # languages
      (python312.withPackages (ps: [ ps.pynvim ]))

      # lsp packages
      lua-language-server
      nodePackages.typescript-language-server
      rust-analyzer
      pyright
      nixd
    ];
  };

  home.sessionVariables.EDITOR = "nvim";

}
