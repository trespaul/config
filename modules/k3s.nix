{ config, lib, ... }:
{
  options.custom.k3s = lib.mkOption
    { type = lib.types.bool;
      default = false;
      description = "add to k3s cluster.";
    };

  config = lib.mkIf config.custom.k3s
    ( let
        hostname = config.networking.hostName;
        server = "polyaenus";
        isServer = hostname == server;

        serverConfig =
          { role = "server";
            extraFlags =
              [ "--secrets-encryption" ];
            manifests =
              { longhorn.source = builtins.fetchurl
                  { url = "https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/deploy/longhorn.yaml";
                    sha256 = "1kcdpd1sjm15parxpk611xf6vi2ppcxv019fip611mq9f1kj92kr";
                  };
                # cnpg-operator.source = builtins.fetchurl
                #   { url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml";
                #     sha256 = "0hffc08ph73h05rzlhdp8ics37wylbnv2cih392hfrgg3y043qgc";
                #   };
                # secrets.yaml linked by ragenix; see below
              };
          };
        agentConfig =
          { role = "agent";
            serverAddr = "https://${server}:6443";
          };
      in
        {
          services =
            { k3s =
                { enable = true;
                  tokenFile = config.age.secrets.k3s_token.path;
                } // ( if isServer then serverConfig else agentConfig );

              # for longhorn
              openiscsi =
                { enable = true;
                  name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${hostname}";
                };
            };

          networking.firewall =
            { allowedTCPPorts =
                [ 10250 ] # kubelet metrics
                ++
                ( if isServer
                  then [ 6443 ] # supervisor and api server
                  else []
                );
              allowedUDPPorts = [ 8472 ]; # flannel vxlan
            };

          # for longhorn: link bin dir to expected location
          systemd.tmpfiles.rules =
            [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" ];

          age.secrets =
            { k3s_token.file = ../secrets/encrypted/k3s_token.age;
            };
            # //
            # ( if isServer
            #   then
            #     { k3s_secrets =
            #         { file = ../../secrets/encrypted/k3s_secrets.age;
            #           path = "/var/lib/rancher/k3s/server/manifests/secrets.yaml"
            #           # mode/owner/group...
            #         };
            #     }
            #   else {}
            # );
        }
    );
}
