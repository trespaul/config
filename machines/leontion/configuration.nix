{ inputs, lib, config, pkgs, ... }:

{
  networking.hostName = "leontion";
  services.throttled.enable = false;
}
