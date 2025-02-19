{
  description = "Dotnet development environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }:
        let
          layoutFile = pkgs.writeText "layout.kdl" ''
            layout {
              pane {
                command "hx"
                args "."
              }
            }
          '';
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              dotnetCorePackages.sdk_9_0
              omnisharp-roslyn
              netcoredbg
            ];

            shellHook = ''
              if [ -z "$ZELLIJ" ] || [ "$ZELLIJ" -ne 0 ]; then
                zellij -l ${layoutFile}
              fi
            '';
          };
        });
    };
}
