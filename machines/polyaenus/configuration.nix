{ inputs, lib, config, pkgs, ... }:

{
  services =
    {
      throttled.enable = false;
      actual.enable = true;
    };
}
