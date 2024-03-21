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
      initrd.secrets =
        { "/crypto_keyfile.bin" = null;
        };
    };

  networking =
    { hostName = "polyaenus";
      networkmanager.enable = true;
    };

  time.timeZone = "Africa/Johannesburg";

  i18n =
    { defaultLocale = "en_ZA.UTF-8";
      extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
    };


  services =
    {

      logind =
        { lidSwitch = "suspend";
          lidSwitchExternalPower = "lock";
        };
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

      syncthing =
        { enable = true;
          user = "paul";
          dataDir = "/home/paul/Documents";
          configDir = "/home/paul/.config/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          settings =
            { devices =
                { "paulpad".id =
                    "LUIFU3Y-QGAT64E-BVKWJ4D-JU72BY7-3ZMCO3N-J2HCB5V-TJUU6CF-IIXZRAU";
                  "android".id =
                    "4RGYVLA-KNPUDSU-BHRUXCO-KFUR64C-5AGTQXQ-RVMX2O5-Z2AD7FI-PAN4GA3";
                };
              folders =
                { "Notes" =
                    { path = "/home/paul/Syncs/Notes";
                      devices = [ "paulpad" "android" ];
                    };
                  "Zotero storage" =
                    { path = "/home/paul/Syncs/Zotero";
                      devices = [ "paulpad" "android" ];
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
    };


  users =
    { defaultUserShell = pkgs.zsh;
      users.paul =
        { isNormalUser = true;
          description = "Paul Joubert";
          extraGroups = [ "networkmanager" "wheel" "audio" ];
          shell = pkgs.zsh;
        };
    };

  programs =
    { zsh.enable = true; # necessary for defaultUserShell
      steam.enable = true; # doesn't work as user program
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

  #system.autoUpgrade =
  #  { enable = true;
  #    flake = inputs.self.outpath;
  #    allowReboot = true;
  #    flags = [ "--update-input" "nixpkgs" "-L" ];
  #    dates = "02:00";
  #  };

  services.openssh =
  { enable = true;
    settings =
      { PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
  };

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
