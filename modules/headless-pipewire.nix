{ config, lib, pkgs, ... }:
{
  options.custom.headless-pipewire =
    { enable = lib.mkOption
        { type = lib.types.bool;
          default = false;
          description = "enable headless pipewire.";
        };
      network = lib.mkOption
        { type = lib.types.bool;
          default = true;
          description = "enable pipewire over the network.";
        };
    };

  config = lib.mkIf config.custom.headless-pipewire.enable
    {
      users.users.paul =
        { linger = true;
          extraGroups = [ "audio" ];
        };

      systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

      services.pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
          socketActivation = false;
        };

      services.avahi = lib.mkIf config.custom.headless-pipewire.network
        { enable = true;
          openFirewall = true;
          nssmdns4 = true;
          publish =
            { enable = true;
              domain = true;
              userServices = true;
              workstation = true;
            };
        };
    };
}
