let
  pkgs = import <nixpkgs> {};
  memoricidepkgs = import <memoricidepkgs> {};
  stdenv = pkgs.stdenv;
  elixir = import ./elixir.nix {};
in
{
  developmentEnv = stdenv.mkDerivation rec {
    name = "developmentEnv";
    version = "nightly";
    src = ./.;
    buildInputs = [
      memoricidepkgs.elixir
      pkgs.postgresql93
    ];
  };
}
