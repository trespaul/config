{ description = "trespaul's nixos flake";

  inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      ragenix =
        { url = "github:yaxitech/ragenix";
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

  outputs = { self, nixpkgs, ragenix, home-manager, musnix, deploy-rs,
              zen-browser, ... }:
    { nixosConfigurations =
        let
          mkConfig = { hostname, extraModules ? [], extraHomeModules ? [] }:
            nixpkgs.lib.nixosSystem
              { system = "x86_64-linux";
                modules =
                  [ ./common/configuration.nix
                    ./common/secrets.module.nix
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
                              ./machines/${hostname}/home.nix
                              ragenix.homeManagerModules.default
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
            "hermarchus" = mkConfig
              { hostname = "hermarchus"; };
            "dionysius" = mkConfig
              { hostname = "dionysius"; };
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
