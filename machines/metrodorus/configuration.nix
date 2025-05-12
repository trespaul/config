{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "metrodorus";

  services =
    {
        { enable = true;
          settings =
            };
        };
    };
}
