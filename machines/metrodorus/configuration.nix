{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "metrodorus";

  services =
    {
      syncthing =
        { enable = true;
          user = "paul";
          dataDir = "/home/paul/Documents";
          configDir = "/home/paul/.config/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          openDefaultPorts = true;
          settings =
            { devices =
                { "paulpad".id =
                    "LUIFU3Y-QGAT64E-BVKWJ4D-JU72BY7-3ZMCO3N-J2HCB5V-TJUU6CF-IIXZRAU";
                  "android".id =
                    "4RGYVLA-KNPUDSU-BHRUXCO-KFUR64C-5AGTQXQ-RVMX2O5-Z2AD7FI-PAN4GA3";
                  "polyaenus".id =
                    "TIHGOJZ-KCJJ6H4-AVZE5QB-KEXTDDS-NZHVWBK-AGWYM3O-PZH7KNO-FTIJDAK";
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Syncs/Notes";
                      devices = [ "paulpad" "android" "polyaenus" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Syncs/Zotero";
                      devices = [ "paulpad" "android" "polyaenus" ];
                    };
                };
            };
        };
    };
}
