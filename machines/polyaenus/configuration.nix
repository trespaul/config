{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "polyaenus";
      firewall =
        { allowedTCPPorts =
            [ 1234        # spotifyd zeroconf
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

  # for headless pipewire
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  services =
    {
      throttled.enable = false;
      actual.enable = true;

      pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;

          # for headless pipewire
          socketActivation = false;
        };

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
          virtualHosts =
            let
              certs = "/var/lib/acme/polyaenus.in.trespaul.com";
            in
              { "home.polyaenus.in.trespaul.com".extraConfig = ''
                    reverse_proxy http://localhost:8123
                    tls ${certs}/cert.pem ${certs}/key.pem
                  '';
                "actual.polyaenus.in.trespaul.com".extraConfig = ''
                    reverse_proxy http://localhost:3000
                    tls ${certs}/cert.pem ${certs}/key.pem
                  '';
                "miniflux.polyaenus.in.trespaul.com".extraConfig = ''
                    reverse_proxy http://localhost:8081
                    tls ${certs}/cert.pem ${certs}/key.pem
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
          extraComponents = [ "esphome" "isal" "spotify" "wake_on_lan" ];
          config =
            { default_config = {};
              http =
                { trusted_proxies = [ "::1" ];
                  use_x_forwarded_for = true;
                };
            };
        };

      miniflux =
        { enable = true;
          config.LISTEN_ADDR = "0.0.0.0:8081";
          adminCredentialsFile = config.age.secrets.miniflux-admin.path;
        };
    };

  virtualisation.oci-containers.containers =
    let
      volumesDir = "/home/paul/container_volumes";
    in
      { anmari-cms =
          { image = "directus/directus:latest";
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
      miniflux-admin.file =
        ../../secrets/encrypted/miniflux-admin.age;
    };
}
