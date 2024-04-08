{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/master";
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
    };

  outputs = { nixpkgs, agenix, home-manager, musnix, ... }:
    { nixosConfigurations =
        let
          mkConfig = { hostname, extraModules }:
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
            "polyaenus" = mkConfig "polyaenus";
          };
    };
}
