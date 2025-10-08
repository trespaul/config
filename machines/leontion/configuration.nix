{ inputs, lib, config, pkgs, ... }:

{
  services.throttled.enable = false;

  custom.reverse-proxy =
    { enable = true;
      hosts =
        [ { name = "miniflux"; port = "8081"; }
          { name = "home";     port = "8123"; }
        ];
    };

  virtualisation.oci-containers.containers =
    { anmari-cms =
        { image = "directus/directus:latest";
          autoStart = true;
          ports = [ "8080:8055" ];
          volumes =
            [ "anmari-cms-database:/directus/database"
              "anmari-cms-uploads:/directus/uploads"
              "anmari-cms-extensions:/directus/extensions"
            ];
          environmentFiles = [ config.age.secrets.anmari-cms.path ];
        };
    };

  services =
    {
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

      miniflux =
        { enable = true;
          config.LISTEN_ADDR = "0.0.0.0:8081";
          adminCredentialsFile = config.age.secrets.miniflux-admin.path;
        };

      home-assistant =
        { enable = true;
          extraComponents = [ "esphome" "isal" "spotify" "wake_on_lan" "ibeacon" "apple_tv" "google_translate" "met" "radio_browser" "shopping_list" "zeroconf" ];
          config =
            { default_config = {};
              http =
                { trusted_proxies = [ "::1" ];
                  use_x_forwarded_for = true;
                };
            };
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
