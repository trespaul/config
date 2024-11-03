{
  age =
    { secrets =
        { spotify.file = ./spotify.age; 
          cloudflare-tunnel.file = ./cloudflare-tunnel.age;
        };
    };
}
