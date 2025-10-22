{
  description = "Typescript development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-pinned.url = "github:nixos/nixpkgs/e89cf1c932006531f454de7d652163a9a5c86668";
  };
  outputs = { nixpkgs, nixpkgs-pinned, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-pinned = nixpkgs-pinned.legacyPackages.${system};
      });
    in
    {
      devShells = forAllSystems ({ pkgs, pkgs-pinned }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bun
              typescript-language-server
              pkgs-pinned.vscode-langservers-extracted
              nodePackages.prettier
            ];
          };
        });
    };
}
