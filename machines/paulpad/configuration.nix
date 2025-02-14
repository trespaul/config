{ inputs, lib, config, pkgs, ... }:

{
  boot =
    { extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      kernelModules = [ "v4l2loopback" ];
      extraModprobeConfig =
        ''
          options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
        '';
      initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking.hostName = "paulpad";

  musnix.enable = true;

  services =
    {
      syncthing =
        { enable = true;
          user = "paul";
          dataDir = "/home/paul/Documents";
          configDir = "/home/paul/.config/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          settings =
            { devices =
                { "android".id =
                    "4RGYVLA-KNPUDSU-BHRUXCO-KFUR64C-5AGTQXQ-RVMX2O5-Z2AD7FI-PAN4GA3";
                  "polyaenus".id =
                    "TIHGOJZ-KCJJ6H4-AVZE5QB-KEXTDDS-NZHVWBK-AGWYM3O-PZH7KNO-FTIJDAK";
                  "metrodorus".id =
                    "GMZ4RFG-GZ72KB4-UYQ72FZ-JU55O4Z-V3WJFHW-Q2OZTO6-FMG3UQL-SFFQJQA";
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Notes";
                      devices = [ "android" "polyaenus" "metrodorus" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Zotero/storage";
                      devices = [ "android" "polyaenus" "metrodorus" ];
                    };
                };
            };
        };
    };

  programs =
    { steam.enable = true; # doesn't work as user program
      adb.enable = true;
    };

  networking.firewall =
    { allowedTCPPorts =
        [ 22000       # syncthing
        ];
      allowedUDPPorts =
        [ 22000 21027 # syncthing
        ];
      allowedTCPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];  
      allowedUDPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];
    };
}
