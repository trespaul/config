{ config, lib, ... }:
{
  options.custom.home.spotifyd = lib.mkOption
    { type = lib.types.bool;
      default = false;
      description = "enable spotifyd user service.";
    };

  config = lib.mkIf config.custom.home.spotifyd
    {
      networking.firewall =
        { allowedTCPPorts = [ 1234 ];
          allowedUDPPorts = [ 5353 ];
        };

      home-manager.users.paul = { osConfig, ... }:
        { services.spotifyd =
            { enable = true;
              settings.global =
                { device_name = osConfig.networking.hostName;
                  bitrate = 320;
                  cache_path = "/home/paul/.cache/spotifyd";
                  device_type = "a_v_r";
                  zeroconf_port = 1234;
                };
            };
        };
    };
}
