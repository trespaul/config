{ config, lib, pkgs, ... }:

let
  repo-watcher = pkgs.concatScript "repo-watcher.nu" [ ./repo-watcher.nu ];
in

{
  options.custom.repo-watcher = lib.mkOption
    { type = lib.types.bool;
      default = false;
      description = "enable repo-watcher.";
    };

    config = lib.mkIf config.custom.repo-watcher
      { systemd.services.repo-watcher = 
          { script = "${pkgs.nushell}/bin/nu ${repo-watcher}";
            startAt = "*:0/30";
            path = with pkgs; [ git ];
            environment.LOG_LEVEL = "10";
            serviceConfig =
              { Type = "oneshot";
                DynamicUser = "yes";
                EnvironmentFile = config.age.secrets.repo-watcher-env.path;
                StandardOutput = "journal";
                StandardError = "journal";
                StateDirectory = "repo-watcher";
              };
          };

        age.secrets.repo-watcher-env.file =
          ../../secrets/encrypted/repo-watcher-env.age;
      };
}
