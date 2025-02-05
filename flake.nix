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
      zen-browser =
        { url = "github:omarcresp/zen-browser-flake";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    };

  outputs = { self, nixpkgs, agenix, home-manager, musnix, deploy-rs,
              zen-browser, ... }:
    { nixosConfigurations =
        let
          mkConfig = { hostname, extraModules ? [], extraHomeModules ? [] }:
            nixpkgs.lib.nixosSystem
              { system = "x86_64-linux";
                modules =
                  [ ./common/configuration.nix
                    ./machines/${hostname}/configuration.nix
                    ./machines/${hostname}/hardware-configuration.nix
                    agenix.nixosModules.default
                    home-manager.nixosModules.home-manager
                    { home-manager =
                        { useGlobalPkgs = true;
                          useUserPackages = true;
                          extraSpecialArgs = { inherit zen-browser; };
                          users.paul.imports =
                            [ ./common/home.nix
                              ./machines/${hostname}/home.nix
                              agenix.homeManagerModules.default
                            ] ++ extraHomeModules;
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
              { hostname = "polyaenus";
                extraModules = [ ./machines/polyaenus/secrets.module.nix ];
              };
            "metrodorus" = mkConfig
              { hostname = "metrodorus"; };
            "leontion" = mkConfig
              { hostname = "leontion"; };
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
                leontion   = mkNode "leontion";   # mecer laptop
              };
        };

      checks =
        builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib;
    };
}
