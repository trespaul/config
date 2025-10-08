{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      import-tree.url = "github:vic/import-tree";
      ragenix =
        { url = "github:yaxitech/ragenix";
          inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = inputs@{ self, nixpkgs, deploy-rs, ... }:
    { nixosConfigurations =
        let
          mkConfig = hostname: custom: nixpkgs.lib.nixosSystem
            { system = "x86_64-linux";
              modules =
                # all modules external and internal are imported automatically;
                # they must be configured in `custom` config (given below in
                # the machine attrs) or in machine-specific ./machines/….nix
                [ { networking.hostName = hostname; }
                  # internal modules:
                  ( inputs.import-tree ./modules )
                  ( inputs.import-tree ./machines/${hostname} )
                  { inherit custom; }
                  # external:
                  inputs.ragenix.nixosModules.default
                  inputs.musnix.nixosModules.musnix
                  inputs.home-manager.nixosModules.home-manager
                  { home-manager =
                      { useGlobalPkgs = true;
                        useUserPackages = true;
                        extraSpecialArgs = { inherit (inputs) zen-browser; };
                        users.paul.imports =
                          [ inputs.ragenix.homeManagerModules.default ];
                      };
                  }
                ];
            };
        in
          builtins.mapAttrs mkConfig
            # { hostname = custom };
            { paulpad =
                { headless = false; };
              polyaenus =
                { internet-sharing.enable = true;
                  k3s = true;
                  acme = true;
                  home.spotifyd = true;
                  repo-watcher = true;
                };
              metrodorus =
                { acme = true; };
              leontion =
                { k3s = true; };
              hermarchus =
                { k3s = true; };
              dionysius =
                { k3s = true; };
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

      checks = builtins.mapAttrs
        ( system: deployLib: deployLib.deployChecks self.deploy )
        deploy-rs.lib;
    };
}
