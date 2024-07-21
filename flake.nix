{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      agenix =
        { url = "github:ryantm/agenix";
          inputs.darwin.follows = "";
        };
      home-manager =
        { url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      musnix =
        { url = "github:musnix/musnix";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      deploy-rs =
        { url = "github:serokell/deploy-rs";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      roc =
        { url = "github:roc-lang/roc";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    };

  outputs = { self, nixpkgs, agenix, home-manager, musnix, deploy-rs, roc, ... }:
    { nixosConfigurations =
        let
          mkConfig = { hostname, extraModules ? [] }:
            nixpkgs.lib.nixosSystem
              { system = "x86_64-linux";
                modules =
                  [ ./common/configuration.nix
                    ./machines/${hostname}/configuration.nix
                    agenix.nixosModules.default
                    home-manager.nixosModules.home-manager
                    { home-manager =
                        { useGlobalPkgs = true;
                          useUserPackages = true;
                          extraSpecialArgs = { inherit roc; };
                          users.paul.imports =
                            [ ./common/home.nix
                              ./machines/${hostname}/home.nix
                              agenix.homeManagerModules.default
                              ./secrets/secrets.module.nix
                            ];
                        };
                    }
                  ] ++ extraModules;
              };
        in
          { "paulpad" = mkConfig
              { hostname = "paulpad";
                extraModules = [ musnix.nixosModules.musnix ];
              };
            "polyaenus" = mkConfig
              { hostname = "polyaenus"; };
            "metrodorus" = mkConfig
              { hostname = "metrodorus"; };
          };

      deploy =
        { remoteBuild = true;
          nodes =
            let
              mkNode = hostname:
                { hostname = hostname;
                  interactiveSudo = true;
                  profiles.system =
                    { user = "root";
                      path =
                        deploy-rs.lib.x86_64-linux.activate.nixos
                          self.nixosConfigurations.${hostname};
                    };
                };
            in
              { paulpad    = mkNode "paulpad";    # thinkpad
                polyaenus  = mkNode "polyaenus";  # hp laptop
                metrodorus = mkNode "metrodorus"; # desktop
              };
        };

      checks =
        builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib;
    };
}
