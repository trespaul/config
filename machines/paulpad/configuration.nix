{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "paulpad";
      firewall =
        { allowedTCPPortRanges =
            [  { from = 1714; to = 1764; } # KDE Connect
            ];  
          allowedUDPPortRanges =
            [  { from = 1714; to = 1764; } # KDE Connect
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

  i18n.inputMethod =
    { enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines;
        [ pinyin ];
    };

  services =
    {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      pulseaudio.enable = false;
      
      pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };

      printing.enable = true;
      pcscd.enable = true; # for gpg pinentry

      tailscale.enable = true;

    };

  programs =
    { steam.enable = true; # doesn't work as user program
      adb.enable = true;
      gnupg.agent.enable = true;
      wireshark =
        { enable = true;
          usbmon.enable = true;
        };
    };

  age =
    { identityPaths = [ "/home/paul/.ssh/id_ed25519" ];
    };
}
