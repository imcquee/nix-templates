{
  description = "Nix Development Templates";
  outputs = {
    templates = {
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
