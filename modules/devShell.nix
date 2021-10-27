{ config, lib, flake-modules-core-lib, ... }:
let
  inherit (lib)
    filterAttrs
    genAttrs
    mapAttrs
    mkOption
    optionalAttrs
    types
    ;
in
{
  options = {
    flake = {
      devShell = mkOption {
        type = types.lazyAttrsOf types.package;
        default = { };
      };
    };
  };
  config = {
    flake.devShell =
      mapAttrs
        (k: v: v.devShell)
        (filterAttrs
          (k: v: v.devShell != null)
          (genAttrs config.systems config.perSystem)
        );

    perInput = system: flake:
      optionalAttrs (flake?devShell.${system}) {
        devShell = flake.devShell.${system};
      };

    perSystem = system: { config, ... }: {
      _file = ./devShell.nix;
      options = {
        devShell = mkOption {
          type = types.nullOr types.package;
        };
      };
    };
  };
}
