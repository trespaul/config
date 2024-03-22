{ inputs, lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Notes";
                      devices = [ "android" "polyaenus" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Zotero/storage";
                      devices = [ "android" "polyaenus" ];
                    };
                };
            };
        };
    };

  programs.steam.enable = true; # doesn't work as user program

  networking.firewall =
    { allowedTCPPorts = [];
      allowedTCPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];  
      allowedUDPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];
    };  
}
