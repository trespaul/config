{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "metrodorus";

  services =
    {
      btrfs.autoScrub =
        { enable = true;
          interval = "weekly";
        };

      beesd.filesystems.Storage =
        { spec = "LABEL=Storage";
          hashTableSizeMB = 2048;
          verbosity = "warning";
          extraOptions = [ "--loadavg-target" "5.0" ];
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

      transmission =
        { enable = true;
          package = pkgs.transmission_4;
          openRPCPort = true;
          settings =
            { incomplete-dir-enabled = true;
              rpc-bind-address = "0.0.0.0";
              rpc-whitelist-enabled = false;
              rpc-host-whitelist-enabled = false;
            };
        };
    };

  systemd.services.transmission.serviceConfig.BindPaths = [ "/mnt/Media" ];

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
