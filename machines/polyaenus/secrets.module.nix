{
  age.secrets.cloudflare-tunnel =
    { file = ../../secrets/encrypted/cloudflare-tunnel.age;
      owner = "cloudflared";
      mode = "600";
    };
  age.secrets.anmari-cms =
    { file = ../../secrets/encrypted/container_anmari-cms_config.age;
    };
}
