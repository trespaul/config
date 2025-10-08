{ inputs, lib, config, pkgs, ... }:

{
  # for headless pipewire
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  services =
    {
      throttled.enable = false;
      actual.enable = true;

      pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;

          # for headless pipewire
          socketActivation = false;

          # for network sink
          extraConfig.pipewire-pulse."30-network-publish" =
            { "pulse.cmd" =
                [ { cmd = "load-module"; args = "module-native-protocol-tcp"; }
                  { cmd = "load-module"; args = "module-zeroconf-publish"; }
                ];
            };
        };

      avahi =
        { enable = true;
          openFirewall = true;
          # allowInterfaces = [ "tailscale0" ];
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
