{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "leontion";
      firewall =
        { allowedTCPPorts =
            [ 22000       # syncthing
            ];
          allowedUDPPorts =
            [ 22000 21027 # syncthing
            ];
        };
    };

  services =
    {
      openssh =
        { enable = true;
          settings =
            { PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              PermitRootLogin = "yes";
            };
        };

      logind =
        { lidSwitch = "suspend";
          lidSwitchExternalPower = "lock";
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
}
