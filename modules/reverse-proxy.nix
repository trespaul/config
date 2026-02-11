{ config, lib, ... }:

{
  options.custom.reverse-proxy =
    { enable = lib.mkOption
        { type = lib.types.bool;
          default = false;
          description = "enable reverse proxy service.";
        };
      hosts = lib.mkOption
        { type = with lib.types; listOf (attrsOf str);
          default = {};
          example = [ { name = "svc1"; port = "1234"; } { name = "svc2"; port = "5678"; } ];
          description = "setup services to be reverse proxied.";
        };
    };

  config.services.caddy = lib.mkIf config.custom.reverse-proxy.enable
    { enable = true;
      virtualHosts =
        let
          subdomain = "${config.networking.hostName}.in.trespaul.com";
          mkHost = { name, port }:
            { name = "${name}.${subdomain}";
              value =
                { useACMEHost = subdomain;
                  extraConfig = "reverse_proxy http://localhost:${port}";
                };
            };
        in
          builtins.listToAttrs <| builtins.map mkHost config.custom.reverse-proxy.hosts;
    };
}
