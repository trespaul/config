{ config, ... }:
let
  hostname = config.networking.hostName;
  server = "polyaenus";
  isServer = hostname == server;

  serverConfig =
    { role = "server"; };
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
  }
