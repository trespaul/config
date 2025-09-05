{ config, lib, ... }:
{
  options.custom.lix = lib.mkOption
    { type = lib.types.bool;
      default = false;
      description = "use lix instead of cppnix.";
    };
  
  config.lix.enable = config.custom.lix;
}
