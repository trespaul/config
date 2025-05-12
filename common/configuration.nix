{ inputs, lib, config, pkgs, ... }:

{
  system.stateVersion = "23.11";

  nix =
    { settings =
        { experimental-features = [ "nix-command" "flakes" "cgroups" ];
          trusted-users = [ "paul" ];
          auto-optimise-store = true;
          use-xdg-base-directories = true;
          use-cgroups = true;
          warn-dirty = false;
          substituters =
            [ "https://nix-community.cachix.org"
              "https://deploy-rs.cachix.org"
            ];
          trusted-public-keys =
            [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
            ];
        };
      gc =
        { automatic = true;
          dates = "weekly";
          options = "--delete-older-than 5d";
          persistent = true;
        };
    };

  boot =
    { loader =
        { systemd-boot =
            { enable = true;
              editor = false;
              configurationLimit = 5;
            };
          efi.canTouchEfiVariables = true;
        };
      initrd.systemd.enable = true;
      tmp.useTmpfs = true;
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
    { NetworkManager-wait-online.enable = false;
      nix-daemon.environment.TMPDIR = "/var/tmp"; # don't use tmpfs
    };

  time.timeZone = "Africa/Johannesburg";

  i18n =
    { defaultLocale = "en_ZA.UTF-8";
      extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
    };

  services =
    {
      thermald.enable = true;
      throttled.enable = lib.mkDefault true;
      dbus.implementation = "broker";
      power-profiles-daemon.enable = false;

      auto-cpufreq =
        { enable = true;
          settings =
            { charger.governor = "performance";
              battery =
                { governor = "powersave";
                  enable_thresholds = true;
                  start_threshold = 60;
                  stop_threshold = 80;
                };
            };
        };

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
              intel-media-sdk
              intel-vaapi-driver
              libva-vdpau-driver
            ];
        };
      bluetooth.enable = true;
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
                  [ "networkmanager" "wheel" "audio" "dialout"
                    "adbusers" "wireshark"
                  ];
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
