{
  description = "Nix Development Templates";
  outputs = { self }:
    {
      templates = {
        basic = {
          path = ./basic;
          description = "Basic Flake";
        };
        editor = {
          path = ./editor;
          description = "IDE consisting of Helix, Zellij, Yazi";
        };
        elixir = {
          path = ./elixir;
          description = "Elixir development environment";
        };
        dotnet = {
          path = ./dotnet;
          description = "Dotnet development environment";
        };
        gleam = {
          path = ./gleam;
          description = "Gleam development environment";
        };
        typescript = {
          path = ./typescript;
          description = "Typescript development environment";
        };
      };
    };
}
