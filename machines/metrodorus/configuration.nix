{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "metrodorus";

  services =
    {
      btrfs.autoScrub =
        { enable = true;
          interval = "weekly";
        };
      caddy =
        { enable = true;
          globalConfig = "skip_install_trust";
          virtualHosts =
            { "jf.local".extraConfig =
                ''
                  reverse_proxy http://localhost:8096
                  tls internal
                '';
            };
        };

      jellyfin.enable = true;
          settings =
            };
        };
    };


  environment.systemPackages = with pkgs;
    [ jellyfin jellyfin-web jellyfin-ffmpeg ];

  # video hardware acceleration

  nixpkgs.config.packageOverrides = pkgs:
    { intel-vaapi-driver =
        pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    };

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  hardware.graphics =
    { enable = true;
      extraPackages = with pkgs;
        [ intel-vaapi-driver
          libva-vdpau-driver
          # intel-compute-runtime
          # intel-compute-runtime-legacy1
          intel-media-sdk
          intel-ocl
        ];
    };
}
