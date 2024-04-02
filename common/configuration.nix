{ inputs, lib, config, pkgs, ... }:

{
  system.stateVersion = "23.11";

  nix.settings =
    { experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "paul" ];
    };

  boot =
    { loader =
        { systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking =
    { networkmanager.enable = true;
    };

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
      opengl =
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
          extraGroups = [ "networkmanager" "wheel" "audio" ];
          shell = pkgs.zsh;
          linger = true;
        };
    };

  programs =
    { zsh.enable = true; # necessary for defaultUserShell
      virt-manager.enable = true;
      gnupg.agent.enable = true;
    };

  virtualisation.libvirtd.enable = true;

  nixpkgs.config =
    { allowUnfree = true;
      permittedInsecurePackages = [];
    };

  environment =
    { variables =
        let
          makePluginPath =
            format:
              ( lib.strings.makeSearchPath format
                [ "$HOME/.nix-profile/lib"
                  "/run/current-system/sw/lib"
                  "/etc/profiles/per-user/$USER/lib"
                ]
              )
              + ":$HOME/.${format}";
        in
          { EDITOR = "hx";
            PAGER = "bat";

            # user paths, not ideal but doesn't work in home.nix?
            ANDROID_HOME       = "/home/paul/.local/share/android";
            GNUPGHOME          = "/home/paul/.local/share/gnupg";
            IPYTHONDIR         = "/home/paul/.config/ipython";
            JUPYTER_CONFIG_DIR = "/home/paul/.config/jupyter";
            PYTHONSTARTUP      = "/home/paul/.config/pythonrc";
            PARALLEL_HOME      = "/home/paul/.config/parallel";
            #ZDOTDIR            = "/home/paul/.config/zsh";

            # audio plugin paths
            DSSI_PATH   = makePluginPath "dssi";
            LADSPA_PATH = makePluginPath "ladspa";
            LV2_PATH    = makePluginPath "lv2";
            LXVST_PATH  = makePluginPath "lxvst";
            VST_PATH    = makePluginPath "vst";
            VST3_PATH   = makePluginPath "vst3";
          };

      shells = with pkgs; [ zsh ];

      systemPackages = with pkgs;
        [ curl
          git
          helix
          wget
          bat
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
      trustedInterfaces = [ "tailscale0" ];
    };

}

