{ config, pkgs, zen-browser, ... }:

{
  home =
    { packages = with pkgs;
        [
          # misc cli
          parallel pinentry-gnome3 slides xdg-ninja yq-go
          # networking tools
          mosh netscanner nmap
          # nix related
          nix-output-monitor rippkgs nix-search nvd
          # media utils
          amberol celluloid ffmpeg helvum pwvucontrol showtime
          # desktop environment
          gnomeExtensions.gsconnect gnome-tweaks gpaste gnome-themes-extra smile
          gnomeExtensions.smile-complementary-extension
          gnome-decoder gnome-solanum
          # document cli utils
          hunspell ghostscript pdftk poppler_utils jbig2dec jbig2enc librsvg
          libtiff ocrmypdf texliveFull
          # internet
          signal-desktop-bin telegram-desktop tuba vesktop warp wike
          bitwarden fractal fragments gnome-connections newsflash packet
          zen-browser.packages.${system}.default
          # audio production
          ardour audacity bespokesynth calf cardinal haskellPackages.tidal
          lsp-plugins musescore plugdata supercollider-with-sc3-plugins vital
          # graphics & video apps
          darktable eyedropper gimp hugin inkscape-with-extensions scrcpy
          # dev
          kubectl kubectl-cnpg
          # LSPs
          haskell-language-server ltex-ls-plus markdown-oxide
          marksman nil nodePackages.bash-language-server
          nodePackages.typescript-language-server vscode-langservers-extracted
          yaml-language-server
          # pentesting
          aircrack-ng bettercap hashcat hcxdumptool hcxtools iw macchanger
          tcpdump wireshark
          # document apps
          dialect errands foliate libreoffice-fresh papers scantailor zotero
          # fonts
          brill inter iosevka noto-fonts-cjk-sans public-sans ubuntu_font_family
        ];

    };

  programs =
    { obs-studio.enable = true;
      gitui.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      tealdeer.enable = true;
      yt-dlp.enable = true;
      gh.enable = true;
      gh-dash.enable = true;
      pandoc.enable = true;

      ghostty =
        { enable = true;
          settings =
            { theme = "GruvboxDarkHard";
              font-family = "Iosevka Extended";
              font-feature = "+NWID";
              cursor-style = "bar";
              cursor-style-blink = false;
              window-decoration = "none";
              gtk-titlebar = false;
            };
        };

      yazi =
        { enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
          settings =
            { manager =
                { sort_by = "natural";
                  sort_dir_first = true;
                  linemode = "mtime";
                  show_hidden = true;
                  show_symlink = true;
                };
            };
        };

      firefox =
        { policies =
            {
              AppAutoUpdate = false;
              DisableAppUpdate = true;
              ManualAppUpdateOnly = true;
            };
        };

      rbw =
        { enable = true;
          settings =
            { email = "paul@trespaul.com";
              pinentry = pkgs.pinentry-gnome3;
              lock_timeout = 600;
              base_url = "https://vault.bitwarden.com/";
              identity_url = "https://identity.bitwarden.com/";
              notifications_url = "https://notifications.bitwarden.com/";
            };
        };

      kubecolor =
        { enable = true;
          enableAlias = true;
        };

      k9s =
        { enable = true;
          settings.k9s =
            { liveViewAutoRefresh = true;
              ui =
                { headless = true;
                  reactive = true;
                };
            };
        };

    };

  dconf =
    { enable = true;
      settings =
        { "org/gnome/desktop/interface" =
            { color-scheme = "prefer-dark";
              clock-show-weekday = true;
              gtk-theme = "Adwaita-dark";
              font-name = "Adwaita Sans 11";
              document-font-name = "Adwaita Sans 11";
              monospace-font-name = "Adwaita Mono 11";
              show-battery-percentage = true;
            };
          "org/gnome/desktop/peripherals/touchpad" =
            { speed = 0.3;
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
            };
          "org/gnome/desktop/peripherals/keyboard" =
            { numlock-state = true;
            };
          "org/gnome/desktop/peripherals/mouse" =
            { natural-scroll = false;
              speed = 0.3;
            };
          "org/gnome/desktop/sound".event-sounds = false;
          "org/gnome/desktop/input-sources".xkb-options =
            [ "terminate:ctrl_alt_bksp"
              "compose:ralt"
              "lv3:rwin_switch"
              "caps:swapescape"
            ];
          "org/gnome/shell".favorite-apps =
            [ "com.mitchellh.ghostty.desktop"
              "org.gnome.Nautilus.desktop"
              "zen.desktop"
              "thunderbird.desktop"
              "vesktop.desktop"
              "zotero.desktop"
            ];
        };
    };
}
