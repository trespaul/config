{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "polyaenus";
      hosts =
        { "100.127.18.104" =
            [      "polyaenus.internal"
              "ntfy.polyaenus.internal"
            ];
        };
      firewall =
        { allowedTCPPorts =
            [ 80 443      # http(s)
              22000       # syncthing
            ];
          allowedUDPPorts =
            [ 22000 21027 # syncthing
            ];
        };
    };

  services =
    {
      openssh =
        { enable = true;
          settings =
            { PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
        };

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
                  "metrodorus".id =
                    "GMZ4RFG-GZ72KB4-UYQ72FZ-JU55O4Z-V3WJFHW-Q2OZTO6-FMG3UQL-SFFQJQA";
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Syncs/Notes";
                      devices = [ "paulpad" "android" "metrodorus" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Syncs/Zotero";
                      devices = [ "paulpad" "android" "metrodorus" ];
                    };
                };
            };
        };

      tailscale =
        { enable = true;
          useRoutingFeatures = "both";
          extraUpFlags =
            [ "--advertise-exit-node"
              "--exit-node-allow-lan-access"
              "--ssh"
            ];
          permitCertUid = "caddy";
        };

      dnsmasq =
        { enable = true;
          # settings = {};
        };

      caddy =
        { enable = true;
          globalConfig = ''auto_https disable_redirects'';
          virtualHosts =
            { "polyaenus.internal".extraConfig =
                ''
                  respond "OK"
                  tls internal
                '';
              "ntfy.polyaenus.internal".extraConfig =
                ''
                  reverse_proxy 127.0.0.1:2586
                  tls internal
                '';
            };
        };

      ntfy-sh =
        { enable = true;
          settings =
            { base-url = "http://ntfy.polyaenus.internal";
              behind-proxy = true;
              listen-http = ":2586";
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
    };

  environment =
    { systemPackages = with pkgs;
        [ nssTools # for caddy
        ];
    };
}
