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
      throttled.enable = false;
      actual.enable = true;

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

      caddy =
        { enable = true;
          globalConfig = "skip_install_trust";
          virtualHosts =
            { "ha.local".extraConfig =
                ''
                  reverse_proxy http://localhost:8123
                  tls internal
                '';
              "actual.local".extraConfig =
                ''
                  reverse_proxy http://localhost:3000
                  tls internal
                '';
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

      home-assistant =
        { enable = true;
          extraComponents = [ "esphome" "isal" "spotify" ];
          config =
            { default_config = {};
              http =
                { trusted_proxies = [ "::1" ];
                  use_x_forwarded_for = true;
                };
            };
        };

    };

  virtualisation.oci-containers.containers =
    let
      volumesDir = "/home/paul/container_volumes";
    in
      { anmari-cms =
          { image = "directus/directus:11.8.0";
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

  age.secrets =
    { cloudflare-tunnel.file =
        ../../secrets/encrypted/cloudflare-tunnel.age;
      cloudflare-cert.file =
        ../../secrets/encrypted/cloudflare-cert.age;
      anmari-cms.file =
        ../../secrets/encrypted/container_anmari-cms_config.age;
    };
}
