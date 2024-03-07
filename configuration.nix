{ inputs, lib, config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
    ];

  nix.settings =
    { experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "paul" ];
    };
  
  boot =
    { loader =
        { systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      kernelModules = [ "v4l2loopback" ];
      extraModprobeConfig =
        ''
          options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
        '';
      initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking =
    { hostName = "paulpad";
      networkmanager.enable = true;
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
          layout = "za";
          xkbVariant = "";
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

      syncthing =
        { enable = true;
          user = "paul";
          dataDir = "/home/paul/Documents";
          configDir = "/home/paul/.config/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          settings =
            { devices =
                { "pi" = { id = "X"; };
                  "android" = { id = "Y"; };
                };
              folders =
                { "Z" =
                    { path = "/home/paul/Z";
                      devices = [ "pi" "android" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Zotero/storage";
                      devices = [ "pi" "android" ];
                    };
                };
            };
        };

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
          extraGroups = [ "networkmanager" "wheel" ];
          shell = pkgs.zsh;
        };
    };

  programs =
    { zsh.enable = true; # necessary for defaultUserShell
      steam.enable = true; # doesn't work as user program
      virt-manager.enable = true;
    };

  virtualisation.libvirtd.enable = true;

  nixpkgs.config =
    { allowUnfree = true;
      permittedInsecurePackages = [];
    };

  environment =
    { variables =
        let
          makePluginPath = format:
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
      flake = inputs.self.outpath;
      allowReboot = true;
      flags = [ "--update-input" "nixpkgs" "-L" ];
      dates = "02:00";
      randomizeDelaySec = "45min";
    };

  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.firewall =
    { enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];  
      allowedUDPPortRanges =
        [  { from = 1714; to = 1764; } # KDE Connect
        ];
    };  

  system.stateVersion = "23.05";

}
