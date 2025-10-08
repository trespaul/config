{ config, lib, pkgs, ... }:
{
  options.custom.lix = lib.mkOption
    { type = lib.types.bool;
      default = true;
      description = "use lix instead of cppnix.";
    };
  
  config =
    { nixpkgs.overlays = lib.mkIf config.custom.lix
        [ ( final: prev:
              { inherit (prev.lixPackageSets.git)
                  nixpkgs-review
                  nix-eval-jobs
                  nix-fast-build
                  colmena;
              }
          )
        ];

      nix.package =
        let
          mkIfElse = condition: yes: no: lib.mkMerge
            [ ( lib.mkIf condition yes )
              ( lib.mkIf (!condition) no )
            ];
        in
          mkIfElse config.custom.lix
            pkgs.lixPackageSets.git.lix
            pkgs.nix;
    };
}
