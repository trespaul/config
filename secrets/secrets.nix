let
  paul =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv";

  polyaenus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV";

  all = [ paul polyaenus ];
in
  {
    "spotify.age".publicKeys = all;
  }
