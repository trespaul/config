let
  paulpad =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv";

  polyaenus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV";

  metrodorus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXoAsnGMn7WqPeVZ2KYeghyl4Fb6Ho9nHTxVU9jGBj4";

  leontion =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhucnrXXBvpgafmk1eJ+DUaTRnNldiAdxm1d7+Xzclv";

  hermarchus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6le6hCVJGJE9ScupP6jq8ab2BntFBFoUQGUvgpYXL2";

  dionysius =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXPB6LC4/qZt+OS8bkd2SUYnLK3ua/lnW1aXKElgOBN";

  all = [ paulpad polyaenus metrodorus leontion hermarchus dionysius ];
in
  {
    "encrypted/cloudflare-tunnel.age".publicKeys = [ paulpad polyaenus ];
    "encrypted/container_anmari-cms_config.age".publicKeys = [ paulpad polyaenus ];
  }
