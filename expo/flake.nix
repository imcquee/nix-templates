{
  description = "MacOS Expo template";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nodejs
              eas-cli
              typescript-language-server
              vscode-langservers-extracted
              cocoapods
              fastlane
              jdk17
              sd
            ];

            shellHook = ''
              export PATH=$(echo $PATH | sd "${pkgs.xcbuild.xcrun}/bin" "")
              unset DEVELOPER_DIR
              export JAVA_HOME="${pkgs.jdk17.home}"
            '';
          };
        }
      );
    };
}
