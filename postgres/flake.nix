{
  description = "Portabl Postgres service";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };
  outputs =
    {
      nixpkgs,
      process-compose-flake,
      services-flake,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
            dbName = "default";
            servicesMod = (import process-compose-flake.lib { inherit pkgs; }).evalModules {
              modules = [
                services-flake.processComposeModules.default
                (
                  { config, ... }:
                  {
                    services.postgres."pg1" = {
                      enable = true;
                      dataDir = "./.databases";
                      initialDatabases = [
                        {
                          name = dbName;
                        }
                      ];
                    };
                    settings.processes.pgweb =
                      let
                        pgcfg = config.services.postgres.pg1;
                      in
                      {
                        environment.PGWEB_DATABASE_URL = pgcfg.connectionURI { inherit dbName; };
                        environment.PGWEB_PORT = "8081";
                        command = pkgs.pgweb;
                        depends_on."pg1".condition = "process_healthy";
                      };
                    settings.processes.test = {
                      command = pkgs.writeShellApplication {
                        name = "pg1-test";
                        runtimeInputs = [ config.services.postgres.pg1.package ];
                        text = ''
                          echo 'SELECT version();' | psql -h 127.0.0.1 ${dbName}
                        '';
                      };
                      depends_on."pg1".condition = "process_healthy";
                    };
                  }
                )
              ];
            };
          in
          f { inherit pkgs servicesMod; }
        );
    in
    {
      packages = forAllSystems (
        { pkgs, servicesMod }:
        {
          default = servicesMod.config.outputs.package;
        }
      );
    };
}
