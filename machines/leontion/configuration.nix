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

  services =
    {
      postgresql =
        { enable = true;
          package = pkgs.postgresql_18;
        };

      cloudflared =
        { enable = true;
          certificateFile = config.age.secrets.cloudflare-cert.path;
          tunnels =
            { "d93b31cb-ab3b-420a-ace5-7d752ef90089" =
                { credentialsFile = config.age.secrets.cloudflare-tunnel.path;
                  default = "http_status:404";
                  ingress =
                    { "auth.trespaul.com" =
                        { service = "https://127.0.0.1:8443";
                          originRequest.originServerName = "kanidm";
                        };
                    };
                };
            };
        };

      miniflux =
        { enable = true;
          config =
            { LISTEN_ADDR = "0.0.0.0:8081";
              OAUTH2_PROVIDER = "oidc";
              OAUTH2_CLIENT_ID = "miniflux";
              OAUTH2_REDIRECT_URL = "https://miniflux.leontion.in.trespaul.com/oauth2/oidc/callback";
              OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.trespaul.com/oauth2/openid/miniflux";
              OAUTH2_USER_CREATION = 1;
              DISABLE_LOCAL_AUTH = 1;
            };
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
      miniflux-admin.file =
        ../../secrets/encrypted/miniflux-admin.age;
   };
}
