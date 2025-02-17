{ config, pkgs, zen-browser, ... }:

{
  home =
    { packages = with pkgs;
        [
          # misc cli
          parallel pinentry-gnome3 slides xdg-ninja yq-go
          # networking tools
          netscanner nmap
          # nix related
          nix-output-monitor rippkgs nix-search
          # media utils
          ffmpeg helvum pwvucontrol vlc
          # desktop environment
          gnomeExtensions.gsconnect gnome-tweaks gpaste gnome-themes-extra smile
          gnomeExtensions.smile-complementary-extension
          # document cli utils
          hunspell ghostscript pdftk poppler_utils jbig2dec jbig2enc libtiff
          # browser
          zen-browser.packages.${system}.default
          # internet utils
          bitwarden warp
          # audio production
          ardour audacity bespokesynth calf cardinal haskellPackages.tidal
          musescore supercollider-with-sc3-plugins vital
          # graphics & video apps
          darktable eyedropper gimp hugin inkscape-with-extensions kdenlive
          scrcpy
          # LSPs
          haskell-language-server ltex-ls markdown-oxide
          marksman nil nodePackages.bash-language-server
          nodePackages.typescript-language-server vscode-langservers-extracted
          yaml-language-server
          # pentesting
          aircrack-ng bettercap hashcat hcxdumptool hcxtools iw macchanger
          tcpdump wireshark
          # internet apps
          beeper discord fractal newsflash signal-desktop telegram-desktop
          transmission_4-gtk tuba wike
          # document cli utils
          ocrmypdf texliveFull librsvg
          # document apps
          dialect errands foliate libreoffice-fresh scantailor zotero
          gnome-decoder gnome-solanum
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
      k9s.enable = true;
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

      broot =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
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

    };

  dconf =
    { enable = true;
      settings =
        { "org/gnome/desktop/interface" =
            { color-scheme = "prefer-dark";
              clock-show-weekday = true;
              gtk-theme = "Adwaita-dark";
              monospace-font-name = "Iosevka Light Expanded 11";
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
              "zen-browser.desktop"
              "discord.desktop"
              "zotero.desktop"
              "beeper.desktop"
            ];
        };
    };
}
