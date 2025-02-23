{
  age.secrets.tailscale-authkey =
    { file = ../secrets/encrypted/tailscale-authkey.age;
      mode = "400";
    };
}
