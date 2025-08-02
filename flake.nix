{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      lix-module =
        { url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
          inputs.nixpkgs.follows = "nixpkgs";
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
          mkConfig = { hostname, extraModules ? [], extraHomeModules ? [] }:
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
                            ] ++ extraHomeModules;
                        };
                    }
                  ] ++ extraModules;
              };
        in
          { "paulpad" = mkConfig
              { hostname = "paulpad";
                extraModules =
                  [ lix-module.nixosModules.default
                    musnix.nixosModules.musnix
                  ];
                extraHomeModules = [ ./machines/paulpad/home.nix ];
              };
            "polyaenus" = mkConfig
              { hostname = "polyaenus";
                extraModules =
                  [ ./modules/headless.nix
                    ./modules/k3s.nix
                    ./modules/acme.nix
                  ];
                extraHomeModules = [ ./machines/polyaenus/home.nix ];
              };
            "metrodorus" = mkConfig
              { hostname = "metrodorus";
                extraModules =
                  [ ./modules/headless.nix
                    ./modules/acme.nix
                  ];
              };
            "leontion" = mkConfig
              { hostname = "leontion";
                extraModules =
                  [ ./modules/headless.nix
                    ./modules/k3s.nix
                  ];
              };
            "hermarchus" = mkConfig
              { hostname = "hermarchus";
                extraModules =
                  [ ./modules/headless.nix
                    ./modules/k3s.nix
                  ];
              };
            "dionysius" = mkConfig
              { hostname = "dionysius";
                extraModules =
                  [ ./modules/headless.nix
                    ./modules/k3s.nix
                  ];
              };
          };

      deploy =
        { remoteBuild = true;
          nodes =
            let
              mkNode = hostname:
                { hostname = hostname;
                  sshUser = "root";
                  fastConnection = true;
                  profiles.system.path =
                    deploy-rs.lib.x86_64-linux.activate.nixos
                      self.nixosConfigurations.${hostname};
                };
            in
              { polyaenus  = mkNode "polyaenus";
                metrodorus = mkNode "metrodorus";
                leontion   = mkNode "leontion";
                hermarchus = mkNode "hermarchus";
                dionysius  = mkNode "dionysius";
              };
        };

      checks =
        builtins.mapAttrs
          (system: deployLib: deployLib.deployChecks self.deploy)
          deploy-rs.lib;
    };
}
