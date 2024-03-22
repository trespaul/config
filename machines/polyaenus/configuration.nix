{ inputs, lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking =
    { hostName = "polyaenus";
      hosts =
        { "100.127.18.104" =
            [ "polyaenus.kamori-carp.ts.net"
              "ntfy.polyaenus.kamori-carp.ts.net"
            ];
        };
    };

  services =
    {
      logind =
        { lidSwitch = "suspend";
          lidSwitchExternalPower = "lock";
        };

      syncthing =
        { enable = true;
          user = "paul";
          dataDir = "/home/paul/Documents";
          configDir = "/home/paul/.config/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          settings =
            { devices =
                { "paulpad".id =
                    "LUIFU3Y-QGAT64E-BVKWJ4D-JU72BY7-3ZMCO3N-J2HCB5V-TJUU6CF-IIXZRAU";
                  "android".id =
                    "4RGYVLA-KNPUDSU-BHRUXCO-KFUR64C-5AGTQXQ-RVMX2O5-Z2AD7FI-PAN4GA3";
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Syncs/Notes";
                      devices = [ "paulpad" "android" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Syncs/Zotero";
                      devices = [ "paulpad" "android" ];
                    };
                };
            };
        };

      tailscale =
        { enable = true;
          useRoutingFeatures = "both";
          extraUpFlags = [ "--advertise-exit-node" ];
          permitCertUid = "caddy";
        };

      dnsmasq =
        { enable = true;
          # settings = {};
        };

      caddy =
        { enable = true;
          virtualHosts =
            {
              "polyaenus.kamori-carp.ts.net".extraConfig =
                ''
                  respond "OK"
                '';

              "ntfy.polyaenus.kamori-carp.ts.net".extraConfig =
                ''
                  reverse_proxy 127.0.0.1:2586
                  @httpget {
                    protocol http
                    method GET
                    path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
                  }
                  redir @httpget https://ntfy.polyaenus.kamori-carp.ts.net
                '';
            };
        };

      ntfy-sh =
        { enable = true;
          settings =
            { base-url = "https://polyaenus.kamori-carp.ts.net";
              behind-proxy = true;
              listen-http = ":2586";
            };
        };
    };

  environment =
    { systemPackages = with pkgs;
        [ nssTools # for caddy
        ];
    };

  services.openssh =
    { enable = true;
      settings =
        { PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
    };

  networking.firewall =
    { allowedTCPPorts =
        [ 80 443 # http(s)
        ];
    };  
}
