let
  paulpad =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv";

  polyaenus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV";

  metrodorus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXoAsnGMn7WqPeVZ2KYeghyl4Fb6Ho9nHTxVU9jGBj4";

  leontion =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaFnVNMlBL1kPCO9YZjB43y0il6j+ywawQVTvc1qV/P";

  hermarchus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6le6hCVJGJE9ScupP6jq8ab2BntFBFoUQGUvgpYXL2";

  dionysius =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACqFS1APLey6k/gRe/HOmyt87BqhpwJazHFiZmDKqJb";

  all = [ paulpad polyaenus metrodorus leontion hermarchus dionysius ];
in
  {
    "encrypted/cloudflare-tunnel.age".publicKeys = [ paulpad polyaenus ];
    "encrypted/cloudflare-cert.age".publicKeys = [ paulpad polyaenus ];
    "encrypted/container_anmari-cms_config.age".publicKeys = [ paulpad polyaenus ];
    "encrypted/tailscale-authkey.age".publicKeys = all;
    "encrypted/k3s_token.age".publicKeys = all;
  }
