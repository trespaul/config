{ inputs, lib, config, pkgs, ... }:

{
  networking.interfaces.enp2s0.wakeOnLan.enable = true;

  custom.reverse-proxy =
    { enable = true;
      hosts = [ { name = "jelly"; port = "8096"; } ];
    };

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

      borgbackup.repos.files =
        { path = "/mnt/Storage/Borg/Files";
          authorizedKeys =
            [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOj4DSjX238kjfhhKjTk6e+ckMqaevQ1oGAn+zlEY9D3 borg@paulpad" ];
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

  systemd.services.transmission.serviceConfig.BindPaths =
    [ "/mnt/Media" "/mnt/Storage" ];

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
          intel-compute-runtime
          intel-ocl
        ];
    };
}
