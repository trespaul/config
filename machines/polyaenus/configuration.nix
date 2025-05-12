{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "polyaenus";
      firewall =
        { allowedTCPPorts =
            [ 80 443      # http(s)
              1234        # spotifyd zeroconf
            ];
          allowedUDPPorts =
            [ 5353        # spotifyd zeroconf
            ];
        };
      interfaces."enp3s0" = # internet sharing
        { useDHCP = false;
          ipv4.addresses =
            [ { address = "10.0.0.1"; prefixLength = 24; } ];
        };
      nftables =
        { ruleset = # internet sharing
            ''
              table ip host-nat {
                chain POSTROUTING {
                  type nat hook postrouting priority 100;
                  oifname "wlp2s0" counter masquerade
                }
              }
              table ip host-filter {
                chain INPUT {
                  iifname "enp3s0" counter accept
                }
              }
            '';
        };
    };

  services =
    {
      kea.dhcp4 = # internet sharing
        { enable = true;
          settings =
            { valid-lifetime = 4000;
              renew-timer = 1000;
              rebind-timer = 2000;
              interfaces-config.interfaces = [ "enp3s0" ];
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

        { enable = true;
            };
        };

      transmission =
        { enable = true;
          openRPCPort = true;
          settings =
            { download-dir = "/home/paul/Downloads";
              incomplete-dir = "/home/paul/Downloads/incomplete";
              rpc-enabled = true;
              rpc-bind-address = "0.0.0.0";
              rpc-whitelist-enabled = true;
              rpc-whitelist = "127.0.0.1,100.*.*.*";
              rpc-host-whitelist-enabled = false;
              encryption = 1;
            };
        };

      cloudflared =
        { enable = true;
          certificateFile = config.age.secrets.cloudflare-cert.path;
          tunnels =
            { "d93b31cb-ab3b-420a-ace5-7d752ef90089" =
                { credentialsFile = config.age.secrets.cloudflare-tunnel.path;
                  default = "http_status:404";
                  ingress =
                    { "anmari.trespaul.com" = "http://127.0.0.1:8080";
                    };
                };
            };
        };

    };

  virtualisation.oci-containers.containers =
    let
      volumesDir = "/home/paul/container_volumes";
    in
      { anmari-cms =
          { image = "directus/directus:11.4.0";
            autoStart = true;
            ports = [ "8080:8055" ];
            volumes =
              [ "${volumesDir}/anmari-cms/database:/directus/database"
                "${volumesDir}/anmari-cms/uploads:/directus/uploads"
                "${volumesDir}/anmari-cms/extensions:/directus/extensions"
              ];
            environmentFiles = [ config.age.secrets.anmari-cms.path ];
          };
      };

}
