{
  description = "0maru's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      usernames = [
        "0maru"
        "3maru"
        "4maru"
      ];
      mapUsernames = f:
        builtins.listToAttrs (map (username: {
          name = username;
          value = f username;
        }) usernames);
      mkHome = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix/home.nix ];
        extraSpecialArgs = { inherit username; };
      };
      mkDarwin = username: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          ./nix/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users = {
              ${username} = import ./nix/home.nix;
            };
          }
        ];
      };
    in
    {
      homeConfigurations = mapUsernames mkHome;
      darwinConfigurations = mapUsernames mkDarwin;
      apps.${system}.darwin-rebuild = {
        type = "app";
        program = "${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild";
        meta.description = "Run darwin-rebuild from the pinned nix-darwin input";
      };
    };
}
