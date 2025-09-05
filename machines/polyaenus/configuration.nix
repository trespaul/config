{ inputs, lib, config, pkgs, ... }:

{
  # for headless pipewire
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  custom.reverse-proxy =
    { enable = true;
      hosts =
        [ { name = "home";     port = "8123"; }
          { name = "actual";   port = "3000"; }
          { name = "miniflux"; port = "8081"; }
        ];
    };

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

          # for network sink
          extraConfig.pipewire-pulse."30-network-publish" =
            { "pulse.cmd" =
                [ { cmd = "load-module"; args = "module-native-protocol-tcp"; }
                  { cmd = "load-module"; args = "module-zeroconf-publish"; }
                ];
            };
        };

      avahi =
        { enable = true;
          openFirewall = true;
          # allowInterfaces = [ "tailscale0" ];
          nssmdns4 = true;
          publish =
            { enable = true;
              domain = true;
              userServices = true;
              workstation = true;
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
