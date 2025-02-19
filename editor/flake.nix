{
  description = "Development environment with Helix configuration";
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
          # Create a derivation for the Helix config
          helixConfig = pkgs.runCommand "helix-config" { } ''
            mkdir -p $out/.helix
            cat > $out/.helix/config.toml << EOF
            theme = "catppuccin_mocha"
            [editor]
            true-color = true
            [keys.normal]
            A-g = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- lazygit"
            [keys.normal.A-y]
            y = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nix run .#yaziPicker open"
            v = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nix run .#yaziPicker vsplit"
            h = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nix run .#yaziPicker hsplit"
            EOF
          '';

          layoutFile = pkgs.writeText "layout.kdl" ''
            pane_frames false
            default_shell "fish"
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
              helix
              yazi
              zellij
            ];

            shellHook = ''
              ln -sfn ${helixConfig}/.helix .
              if [ -z "$ZELLIJ" ] || [ "$ZELLIJ" -ne 0 ]; then
                zellij -l ${layoutFile}
              fi
            '';
          };
        });

      apps = forAllSystems ({ pkgs }: {
        yaziPicker = {
          type = "app";
          program = toString (pkgs.writeScript "yaziPicker" ''
            #!/usr/bin/env bash
            paths=$(yazi --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)
            if [[ -n "$paths" ]]; then
              zellij action toggle-floating-panes
              zellij action write 27 # send <Escape> key
              zellij action write-chars ":$1 $paths"
              zellij action write 13 # send <Enter> key
            else
              zellij action toggle-floating-panes
            fi
          '');
        };
      });
    };
}
