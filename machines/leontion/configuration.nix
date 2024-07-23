{ inputs, lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot =
    { initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking.hostName = "leontion";

  services =
    {
      openssh =
        { enable = true;
          settings =
            { PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
        };

      tailscale =
        { enable = true;
          useRoutingFeatures = "both";
          extraUpFlags =
            [ "--advertise-exit-node"
              "--exit-node-allow-lan-access"
              "--ssh"
            ];
        };
    };

  networking.firewall =
    { allowedTCPPorts =
        [ 22000       # syncthing
        ];
      allowedUDPPorts =
        [ 22000 21027 # syncthing
        ];
    };
}
