{ inputs, lib, config, pkgs, ... }:

{
  networking =
    { hostName = "polyaenus";
      firewall =
        { allowedTCPPorts =
            [ 80 443      # http(s)
              22000       # syncthing
              1234        # spotifyd zeroconf

            ];
          allowedUDPPorts =
            [ 22000 21027 # syncthing
              5353        # spotifyd zeroconf
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

      cloudflared =
        { enable = true;
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

    };

  virtualisation.oci-containers.containers =
    let
      volumesDir = "/home/paul/container_volumes";
    in
      { anmari-cms =
          { image = "directus/directus:11.4.0";
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

}
