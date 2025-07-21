{ config, ... }:
{
  security.acme =
    let
      domain = "${config.networking.hostName}.in.trespaul.com";
    in
      { acceptTerms = true;
        defaults.email = "acme@trespaul.com";
        certs.${domain} =
          { group = config.services.caddy.group;
            domain = domain;
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "cloudflare";
            dnsResolver = "1.1.1.1:53";
            dnsPropagationCheck = true;
            environmentFile = config.age.secrets.cloudflare-dns-api-env.path;
          };
      };

  age.secrets.cloudflare-dns-api-env.file =
    ../secrets/encrypted/cloudflare-dns-api-env.age;
}
