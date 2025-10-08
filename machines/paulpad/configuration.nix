{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { firewall =
        { allowedTCPPortRanges =
            [  { from = 1714; to = 1764; } # KDE Connect
            ];  
          allowedUDPPortRanges =
            [  { from = 1714; to = 1764; } # KDE Connect
            ];
          allowedTCPPorts =
            [ 9300 # Quick Share (Packet)
            ];
        };
    };

  boot =
    { extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      kernelModules = [ "v4l2loopback" ];
      extraModprobeConfig =
        ''options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"'';
    };

  musnix.enable = true;

  hardware =
    { graphics =
        { enable = true;
          extraPackages = with pkgs;
            [ intel-media-driver
              vpl-gpu-rt
            ];
        };
      sane.enable = true;
    };

  environment.systemPackages = with pkgs; [ ragenix ];

  services =
    {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      flatpak.enable = true;

      pulseaudio.enable = false;
      
      pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
          extraConfig =
            { pipewire."10-airplay" =
                { "context.modules" =
                    [ { name = "libpipewire-module-raop-discover"; } ];
                };
              pipewire-pulse."30-network-discover" =
                { "pulse.cmd" =
                    [ { cmd = "load-module"; args = "module-zeroconf-discover"; } ];
                };
            };
        };

      avahi =
        { enable = true;
          # openFirewall = true;
          allowInterfaces = [ "tailscale0" "wlp0s20f3" ];
          nssmdns4 = true;
          publish =
            { enable = true;
              domain = true;
              userServices = true;
              workstation = true;
            };
        };

      printing.enable = true;
      pcscd.enable = true; # for gpg pinentry

      tailscale.enable = true;

      borgbackup.jobs.files =
        { paths =
            [ "/mnt/Future/Documents"
              "/mnt/Future/Media"
              "/mnt/Future/My Media"
              "/mnt/Future/Projects"
            ];
          repo = "borg@metrodorus:/mnt/Storage/Borg/Files";
          encryption =
            { mode = "repokey-blake2";
              passCommand = "cat ${config.age.secrets.borg_passphrase.path}";
            };
          environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
          startAt = "daily";
          extraArgs = [ "--verbose" ];
        };
    };

  programs =
    { steam.enable = true; # doesn't work as user program
      gnupg.agent.enable = true;
      wireshark =
        { enable = true;
          usbmon.enable = true;
        };
    };

  age =
    { identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets.borg_passphrase.file = ../../secrets/encrypted/borg_passphrase.age;
    };
}
