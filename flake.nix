{
  description = "Nix Development Templates";
  outputs = { self }:
    {
      templates = {
        basic = {
          path = ./basic;
          description = "Basic Flake";
        };
        dotnet = {
          path = ./dotnet;
          description = "Dotnet development environment";
        };
        editor = {
          path = ./editor;
          description = "IDE consisting of Helix, Zellij, Yazi";
        };
        elixir = {
          path = ./elixir;
          description = "Elixir development environment";
        };
        gleam = {
          path = ./gleam;
          description = "Gleam development environment";
        };
        typescript = {
          path = ./typescript;
          description = "Typescript development environment";
        };
        services = {
          path = ./services;
          description = "Services example with Postgres";
        };
      };
    };
}
