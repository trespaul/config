let
  paul =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv";

  paulpad =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOj4DSjX238kjfhhKjTk6e+ckMqaevQ1oGAn+zlEY9D3";

  polyaenus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV";

  metrodorus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeqoO/8+bb8BmbS854aJC7XGK5lsS5YRQcDYJEhIRPz";

  leontion =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaFnVNMlBL1kPCO9YZjB43y0il6j+ywawQVTvc1qV/P";

  hermarchus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6le6hCVJGJE9ScupP6jq8ab2BntFBFoUQGUvgpYXL2";

  dionysius =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACqFS1APLey6k/gRe/HOmyt87BqhpwJazHFiZmDKqJb";

  all = [ paul paulpad polyaenus metrodorus leontion hermarchus dionysius ];
in
  {
    "encrypted/borg_passphrase.age".publicKeys = [ paul paulpad ];
    "encrypted/cloudflare-tunnel.age".publicKeys = [ paul polyaenus ];
    "encrypted/cloudflare-cert.age".publicKeys = [ paul polyaenus ];
    "encrypted/cloudflare-dns-api-env.age".publicKeys = [ paul polyaenus metrodorus ];
    "encrypted/container_anmari-cms_config.age".publicKeys = [ paul polyaenus ];
    "encrypted/miniflux-admin.age".publicKeys = [ paul polyaenus ];
    "encrypted/repo-watcher-env.age".publicKeys = [ paul polyaenus ];
    "encrypted/tailscale-authkey.age".publicKeys = all;
    "encrypted/k3s_token.age".publicKeys = all;
  }
