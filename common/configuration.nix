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

  boot =
    { loader =
        { systemd-boot =
            { enable = true;
              configurationLimit = 5;
            };
          efi.canTouchEfiVariables = true;
        };
      initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking =
    { networkmanager.enable = true;
    };

  systemd.services =
    { NetworkManager-wait-online.enable = false; };

  time.timeZone = "Africa/Johannesburg";

  i18n =
    { defaultLocale = "en_ZA.UTF-8";
      extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
    };

  services =
    {
      xserver =
        { enable = true;
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
          xkb =
            { layout = "za";
              variant = "";
            };
        };

      pipewire =
        { enable = true;
          wireplumber.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };

      printing.enable = true;
      pcscd.enable = true; # for gpg pinentry
      tailscale.enable = true;
    };

  # for audio
  security.rtkit.enable = true;

  hardware =
    { pulseaudio.enable = false;
      graphics =
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
      users.paul =
        { isNormalUser = true;
          description = "Paul Joubert";
          extraGroups = [ "networkmanager" "wheel" "audio" "dialout" ];
          shell = pkgs.zsh;
          linger = true;
          openssh.authorizedKeys.keys =
            [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyBG5QyF1rZ9M7gm+cPVSpsWyGPgLQNKIrAn/EKmgEv paul@paulpad"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEFnpRtXK1ZW/yfbIx2cKMRCpQGX3r96J9LamQbLmwV paul@polyaenus"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXoAsnGMn7WqPeVZ2KYeghyl4Fb6Ho9nHTxVU9jGBj4 paul@metrodorus"
            ];
        };
    };

  programs =
    { zsh.enable = true; # necessary for defaultUserShell
      virt-manager.enable = true;
      gnupg.agent.enable = true;
      npm.npmrc =
        ''
          prefix=$\{XDG_DATA_HOME}/npm
          cache=$\{XDG_CACHE_HOME}/npm
          init-module=$\{XDG_CONFIG_HOME}/npm/config/npm-init.js
        '';
    };

  virtualisation.libvirtd.enable = true;

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

      shells = with pkgs; [ zsh ];

      systemPackages = with pkgs;
        [ curl
          git
          helix
          wget
          bat
          deploy-rs
        ];
    };

  system.autoUpgrade =
    { enable = true;
      flake = "github:trespaul/config";
      allowReboot = true;
      flags = [ "--update-input" "nixpkgs" "-L" ];
      dates = "02:00";
    };

  networking.firewall =
    { enable = true;
      trustedInterfaces = [ "tailscale0" "virbr0" "vnet2" ];
    };

}

