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
    };

  outputs = inputs@{ self, nixpkgs, agenix, home-manager, ... }:
    { nixosConfigurations =
        {
          "paulpad" = nixpkgs.lib.nixosSystem
            { system = "x86_64-linux";
              modules =
                [ ./machines/paulpad/configuration.nix
                  agenix.nixosModules.default
                  home-manager.nixosModules.home-manager
                  { home-manager =
                      { useGlobalPkgs = true;
                        useUserPackages = true;
                        users.paul.imports =
                          [ ./machines/paulpad/home.nix
                            agenix.homeManagerModules.default
                            ./secrets/secrets.module.nix
                          ];
                      };
                  }
                ];
            };

          "polyaenus" = nixpkgs.lib.nixosSystem
            { system = "x86_64-linux";
              modules =
                [ ./machines/polyaenus/configuration.nix
                  agenix.nixosModules.default
                  home-manager.nixosModules.home-manager
                  { home-manager =
                      { useGlobalPkgs = true;
                        useUserPackages = true;
                        users.paul.imports =
                          [ ./machines/polyaenus/home.nix
                            agenix.homeManagerModules.default
                            ./secrets/secrets.module.nix
                          ];
                      };
                  }
                ];
            };
        };
    };
}
