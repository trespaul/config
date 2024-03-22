{ config, pkgs, ... }:

{
  services =
    {
      spotifyd =
        { enable = true;
          settings.global =
            { username = "21wt6kx2cpvurgqvkgwk34jsy";
              password_cmd = "cat ${config.age.secrets.spotify.path}";
              device_name = "polyaenus";
              bitrate = 320;
              cache_path = "/home/paul/.cache/spotifyd";
              device_type = "a_v_r";
            };
        };
    };
}
