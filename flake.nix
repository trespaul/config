{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      lix =
        { url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
          flake = false;
        };
      lix-module =
        { url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
          inputs.nixpkgs.follows = "nixpkgs";
          inputs.lix.follows = "lix";
        };
      ragenix =
        { url = "github:yaxitech/ragenix";
          inputs.nixpkgs.follows = "nixpkgs";
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
        { url = "github:mrcjkb/zen-browser-flake";
          inputs.nixpkgs.follows = "nixpkgs";
        };
    };

  outputs = { self, nixpkgs, lix-module, ragenix, home-manager, musnix,
              deploy-rs, zen-browser, ... }:
    { nixosConfigurations =
        let
          mkConfig = hostname: { extraModules ? [], extraHomeModules ? [] }:
            nixpkgs.lib.nixosSystem
              { system = "x86_64-linux";
                modules =
                  [ ./common/configuration.nix
                    ./machines/${hostname}/configuration.nix
                    ./machines/${hostname}/hardware-configuration.nix
                    ragenix.nixosModules.default
                    home-manager.nixosModules.home-manager
                    { home-manager =
                        { useGlobalPkgs = true;
                          useUserPackages = true;
                          extraSpecialArgs = { inherit zen-browser; };
                          users.paul.imports =
                            [ ./common/home.nix
                              ragenix.homeManagerModules.default
                            ] ++
                            ( let path = ./machines/${hostname}/home.nix;
                              in ( if builtins.pathExists path then [ path ] else [] )
                            );
                        };
                    }
                  ] ++ extraModules;
              };
        in
          builtins.mapAttrs mkConfig
            { paulpad.extraModules =
                [ lix-module.nixosModules.default
                  musnix.nixosModules.musnix
                ];
              polyaenus.extraModules =
                [ ./modules/headless.nix
                  ./modules/k3s.nix
                  ./modules/acme.nix
                ];
              metrodorus.extraModules =
                [ ./modules/headless.nix
                  ./modules/acme.nix
                ];
              leontion.extraModules =
                [ ./modules/headless.nix
                  ./modules/k3s.nix
                ];
              hermarchus.extraModules =
                [ ./modules/headless.nix
                  ./modules/k3s.nix
                ];
              dionysius.extraModules =
                [ ./modules/headless.nix
                  ./modules/k3s.nix
                ];
            };

      deploy =
        { remoteBuild = true;
          nodes =
            let
              mkNode = hostname:
                { name = hostname;
                  value =
                    { inherit hostname;
                      sshUser = "root";
                      fastConnection = true;
                      profiles.system.path =
                        deploy-rs.lib.x86_64-linux.activate.nixos
                          self.nixosConfigurations.${hostname};
                    };
                };
            in
              builtins.listToAttrs <| builtins.map mkNode
                [ "polyaenus"
                  "metrodorus"
                  "leontion"
                  "hermarchus"
                  "dionysius"
                ];
        };

      checks =
        builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib;
    };
}
