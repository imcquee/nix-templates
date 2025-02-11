{
  description = "Basic flake template with a dev shell and an app";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }:
        let
          layoutFile = pkgs.writeText "layout.kdl" ''
            pane_frames false
            default_shell "fish"
            layout {
              pane {
                command "hx"
                args "."
              }
            }
            keybinds {
              shared {
                bind "Alt y" {
                  Run "nix" "run" ".#yazizj" {
                    in_place true
                  }
                }
                bind "Alt g" { 
                  Run "zellij" "run" "-cf" "--width" "80%" "--height" "80%" "--x" "10%" "--y" "10%" "--" "lazygit" {
                    close_on_exit true
                  }
                }
              }
            }
          '';
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ cowsay ];
            shellHook = ''
              if ! ps aux | grep -q '[z]ellij'; then
                zellij -l ${layoutFile}
              fi
            '';
          };
        });
      apps = forAllSystems ({ pkgs }: {
        yazizj = {
          type = "app";
          program = "${pkgs.writeScript "yazizj" ''
                  #!/bin/sh
                  yazi
                  $EDITOR .
                ''}";
        };
      });
    };
}
