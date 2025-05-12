{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "metrodorus";

  services =
    {
      btrfs.autoScrub =
        { enable = true;
          interval = "weekly";
        };
          settings =
            };
        };
    };
}
