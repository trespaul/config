let
  paulpad =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv";

  polyaenus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV";

  metrodorus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXoAsnGMn7WqPeVZ2KYeghyl4Fb6Ho9nHTxVU9jGBj4";

  all = [ paulpad polyaenus metrodorus ];
in
  {
    "spotify.age".publicKeys = all;
  }
