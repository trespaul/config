{ config, lib, pkgs, ... }:

{
  options.custom.kanidm =
    { enable = lib.mkOption
        { type = lib.types.bool;
          default = false;
          description = "enable kanidm.";
        };
    };

  config = lib.mkIf config.custom.kanidm.enable
    { services.kanidm =
        { package = pkgs.kanidm_1_10;
          server =
            { enable = true;
              settings =
                { bindaddress = "127.0.0.1:8443";
                  tls_chain = ./kanidm.chaim.pem;
                  tls_key = config.age.secrets."kanidm.key.pem".path;
                  domain = "auth.trespaul.com";
                  origin = "https://auth.trespaul.com";
                  http_client_address_info.x-forward-for = [ "127.0.0.0/8" ];
                  online_backup =
                    { versions = 3;
                      schedule = "00 00 * * 1"; # Mondays 00:00 UTC
                    };
                };
            };
        };

      age.secrets."kanidm.key.pem" =
        { file = ../secrets/encrypted/kanidm.key.pem.age;
          mode = "400";
          owner = "kanidm";
        };
    };
}
