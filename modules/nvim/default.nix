{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  tex = (
    pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-basic
        dvisvgm
        dvipng # for preview and export as html
        wrapfig
        amsmath
        ulem
        hyperref
        capt-of
        standalone
        ;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    }
  );
in
{
  xdg.configFile."nvim_live".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/nvim/lua-config";
  xdg.configFile."nvim".source = ./lua-config;

  programs.zsh.shellAliases = {
    nvimc = "NVIM_APPNAME=nvim_live nvim";
  };

  programs.neovim = {
    enable = true;
    #package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    #withPython3 = true;
    extraLuaPackages =
      luaPkgs: with luaPkgs; [
        pathlib-nvim
        lua-utils-nvim
        magick
      ];

    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
      gcc
      lua

      # for image.nvim
      imagemagick
      #ueberzugpp # <- this sucks
      #texlive.combined.scheme-medium
      tex
      typst


      # languages
      (python312.withPackages (ps: [ ps.pynvim ]))

      # lsp packages
      lua-language-server
      nodePackages.typescript-language-server
      rust-analyzer
      pyright
      nixd
      tinymist
    ];
  };

  home.sessionVariables.EDITOR = "nvim";

}
