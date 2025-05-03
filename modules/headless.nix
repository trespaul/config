{ config, lib, ... }:
{
  services =
    {
      auto-cpufreq.settings.charger.governor = lib.mkDefault "powersave";

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
          authKeyFile = config.age.secrets.tailscale-authkey.path;
          extraUpFlags =
            [ "--advertise-exit-node"
            ];
        };

    };

  age.secrets.tailscale-authkey =
    { file = ../secrets/encrypted/tailscale-authkey.age;
      mode = "400";
    };
}
