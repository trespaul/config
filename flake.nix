{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      import-tree.url = "github:vic/import-tree";
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
                [ { networking.hostName = hostname; }
                  ( inputs.import-tree ./modules )
                  ( inputs.import-tree ./machines/${hostname} )
                  { inherit custom; }
                  inputs.lix-module.nixosModules.default
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
            { paulpad =
                { headless = false;
                  lix = true;
                };
              polyaenus =
                { internet-sharing.enable = true;
                  k3s = true;
                  acme = true;
                  home.spotifyd = true;
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
