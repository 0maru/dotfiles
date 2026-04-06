{ config, pkgs, ... }:

{
  home.username = "0maru";
  home.homeDirectory = "/Users/0maru";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # --------------------------------------------------
    # Languages
    # --------------------------------------------------

    # Go
    go
    gopls

    # JavaScript / TypeScript
    nodejs_22
    bun
    deno

    # Python
    python313
    uv

    # --------------------------------------------------
    # CLI tools
    # --------------------------------------------------

    # Search & file utilities
    ripgrep
    fd
    fzf
    sd
    tree
    eza
    bat
    wget
    zoxide

    # Data processing
    jq
    yq-go
    duckdb

    # Git ecosystem
    git
    delta
    lazygit
    gh
    ghq

    # Shell ecosystem
    sheldon
    starship

    # Editors
    neovim
    vim
    helix

    # Dev tools
    mise
    tmux

    # macOS utilities
    terminal-notifier
  ];
}
