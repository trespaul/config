{ config, lib, ... }:

{
  options.custom.internet-sharing =
    { enable = lib.mkOption
        { type = lib.types.bool;
          default = false;
          description = "share internet to connected devices.";
        };
      oInterface = lib.mkOption
        { type = lib.types.str;
          default = "wlp2s0";
          description = "network interface connected to the internet (nat masquerade).";
        };
      iInterface = lib.mkOption
        { type = lib.types.str;
          default = "enp3s0";
          description = "network interface with downstream devices (accept packets).";
        };
    };

  config = lib.mkIf config.custom.internet-sharing.enable
    ( let
        inherit (config.custom.internet-sharing) oInterface iInterface;
      in
        { networking =
            { interfaces.${iInterface} =
                { useDHCP = false;
                  ipv4.addresses =
                    [ { address = "10.0.0.1"; prefixLength = 24; } ];
                };
              nftables.ruleset = # tables named host-* to not conflict with podman
                ''
                  table ip host-nat {
                    chain POSTROUTING {
                      type nat hook postrouting priority 100;
                      oifname "${oInterface}" counter masquerade
                    }
                  }
                  table ip host-filter {
                    chain INPUT {
                      iifname "${iInterface}" counter accept
                    }
                  }
                '';
            };

          services.kea.dhcp4 =
            { enable = true;
              settings =
                { valid-lifetime = 4000;
                  renew-timer = 1000;
                  rebind-timer = 2000;
                  interfaces-config.interfaces = [ iInterface ];
                  subnet4 =
                    [ { id = 1;
                        subnet = "10.0.0.1/24";
                        pools = [ { pool = "10.0.0.2 - 10.0.0.255"; } ];
                      }
                    ];
                  lease-database =
                    { type = "memfile";
                      name = "/var/lib/kea/dhcp4.leases";
                      persist = true;
                    };
                  option-data =
                    [ { name = "routers";
                        data = "10.0.0.1";
                      }
                    ];
                };
            };
        }
    );
}
