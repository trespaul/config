{ config, pkgs, ... }:

{
  services =
    {
      spotifyd =
        { enable = true;
          settings.global =
            { device_name = "polyaenus";
              bitrate = 320;
              cache_path = "/home/paul/.cache/spotifyd";
              device_type = "a_v_r";
              zeroconf_port = 1234;
            };
        };
    };
}
