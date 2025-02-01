{
  age =
    { identityPaths =
        [ "/home/paul/.ssh/id_ed25519"
          "/etc/ssh/ssh_host_ed25519_key"
        ];
      secrets =
        { cloudflare-tunnel =
            { file = ../../secrets/cloudflare-tunnel.age;
              owner = "cloudflared";
              mode = "600";
            };
          anmari-cms =
            { file = ../../secrets/container_anmari-cms_config.age;
            };
        };
    };
}
