{ inputs, lib, config, pkgs, ... }:

{
  system.stateVersion = "23.11";

  nix =
    { settings =
        { experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "paul" ];
          auto-optimise-store = true;
          use-xdg-base-directories = true;
        };
      gc =
        { automatic = true;
          dates = "weekly";
          options = "--delete-older-than 5d";
          persistent = true;
        };
    };

  boot.loader =
    { systemd-boot =
        { enable = true;
          editor = false;
          configurationLimit = 5;
        };
      efi.canTouchEfiVariables = true;
    };

  networking =
    { networkmanager.enable = true;
      nftables.enable = true;
      firewall =
        { enable = true;
          trustedInterfaces = [ "tailscale0" "virbr0" "vnet2" ];
        };
    };

  powerManagement =
    { enable = true;
      powertop.enable = true;
    };

  systemd.services =
    { NetworkManager-wait-online.enable = false; };

  time.timeZone = "Africa/Johannesburg";

  i18n =
    { defaultLocale = "en_ZA.UTF-8";
      extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
    };

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services =
    {
      thermald.enable = true;

      tlp =
        { enable = true;
          settings =
            { TLP_DEFAULT_MODE = "AC";
              CPU_BOOST_ON_AC = 1;
              CPU_BOOST_ON_BAT = 0;
              CPU_SCALING_GOVERNOR_ON_AC = "performance";
              CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
              CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
              CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
              START_CHARGE_THRESH_BAT0 = 60;
              STOP_CHARGE_THRESH_BAT0 = 80;
              NATACPI_ENABLE = 1;
              TPACPI_ENABLE = 1;
              TPSMAPI_ENABLE = 1;
            };
        };

      power-profiles-daemon.enable = false;

      system76-scheduler =
        { enable = true;
          settings.cfsProfiles.enable = true;
        };

      xserver.xkb =
        { layout = "za";
          variant = "";
        };

    };

  # for audio
  security.rtkit.enable = true;

  hardware =
    { graphics =
        { enable = true;
          extraPackages = with pkgs;
            [ intel-media-driver
              #intel-ocl
              intel-compute-runtime
            ];
        };
    };

  users =
    { defaultUserShell = pkgs.zsh;
      users =
        let 
          authorizedKeys =
            [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv paul@paulpad" ];
        in
          { root.openssh.authorizedKeys.keys = authorizedKeys;
            paul =
              { isNormalUser = true;
                description = "Paul Joubert";
                extraGroups =
                  [ "networkmanager" "wheel" "audio" "dialout" "adbusers" ];
                shell = pkgs.nushell;
                linger = true;
                openssh.authorizedKeys.keys = authorizedKeys;
              };
          };
    };

  programs =
    { zsh.enable = true; # necessary for defaultUserShell
      virt-manager.enable = true;
      npm.npmrc =
        ''
          prefix=$\{XDG_DATA_HOME}/npm
          cache=$\{XDG_CACHE_HOME}/npm
          init-module=$\{XDG_CONFIG_HOME}/npm/config/npm-init.js
        '';
    };

  virtualisation =
    { libvirtd.enable = true;
      containers.enable = true;
      oci-containers.backend = "podman";
      podman =
        { enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
    };


  nixpkgs.config =
    { allowUnfree = true;
      permittedInsecurePackages = [];
    };

  environment =
    { variables =
        { EDITOR = "hx";
          PAGER = "bat";

          # user paths, not ideal here but doesn't work in home.nix?
          ANDROID_HOME          = "/home/paul/.local/share/android";
          ANDROID_USER_HOME     = "/home/paul/.local/share/android";
          GNUPGHOME             = "/home/paul/.local/share/gnupg";
          IPYTHONDIR            = "/home/paul/.config/ipython";
          JUPYTER_CONFIG_DIR    = "/home/paul/.config/jupyter";
          PYTHONSTARTUP         = "/home/paul/.config/python/pythonrc";
          PARALLEL_HOME         = "/home/paul/.config/parallel";
          CABAL_CONFIG          = "/home/paul/.config/cabal/config";
          CABAL_DIR             = "/home/paul/.local/share/cabal";
          CARGO_HOME            = "/home/paul/.local/share/cargo";
          NODE_REPL_HISTORY     = "/home/paul/.local/share/node_repl_history";
          RENPY_PATH_TO_SAVES   = "/home/paul/.local/share/renpy";
          NPM_CONFIG_USERCONFIG = "/home/paul/.config/npm/npmrc";
          FLY_CONFIG_DIR        = "/home/paul/.local/state/fly";
        };

      shells = with pkgs; [ zsh nushell ];

      systemPackages = with pkgs;
        [ curl
          git
          helix
          wget
          bat
          deploy-rs
        ];
    };
}

