{ config, pkgs, ... }:

{
  home =
    { username = "paul";
      homeDirectory = "/home/paul";

      stateVersion = "23.05";

      shellAliases =
        { "l" = "eza -la --icons --git --group-directories-first";
          "la" = "eza -a --icons --git --group-directories-first";
          "lla" = "eza -la --icons --git --group-directories-first";
          "lt" = "eza -laT --icons --git --group-directories-first";
          "x" = "xdg-open";
          "qmv" = "qmv --format destination-only";
          "ffmpeg" = "ffmpeg -hide_banner";
          "ffprobe" = "ffprobe -hide_banner";
          "ip" = "ip -c";
          "sudo" = "sudo -v; sudo ";
          "s" = "kitten ssh";
          "wget" = "wget --hsts-file=.local/share/wget-hsts";
          "fd" = "fd --hidden";
        };

      packages = with pkgs;
        [ # misc cli
          bat eza fd file fzf gawk glow gnupg gnused gnutar jq kitty lf
          libnotify neofetch p7zip parallel renameutils ripgrep slides tealdeer
          tmux unar unzip which xdg-ninja xz yq-go zip zstd
          # networking tools
          dnsutils ldns nmap sshfs
          # nix related
          nix-output-monitor
          # system tools
          btop clinfo glxinfo iftop iotop lsof ltrace strace ethtool lm_sensors
          pciutils usbutils
          # media
          ardour audacity bespokesynth blanket blender calf cardinal darktable
          ffmpeg ghostscript gimp-with-plugins haskellPackages.tidal helvum
          inkscape-with-extensions jbig2dec jbig2enc kdenlive libtiff
          musescore obs-studio pdftk poppler_utils pwvucontrol scantailor spot
          supercollider supercolliderPlugins.sc3-plugins vcv-rack vital vlc
          yt-dlp
          # dev etc.
          android-tools boxes deno ghc haskellPackages.matrix
          haskellPackages.utility-ht hugo python311
          scrcpy
          google-cloud-sdk
            # .withExtraComponents # ( with pkgs.google-cloud-sdk.components; [ ... ] )
          # pentesting
          aircrack-ng crunch hashcat hcxdumptool hcxtools iw macchanger wifite2
          wireshark
          # LSPs
          haskell-language-server ltex-ls marksman
          nil nodePackages.bash-language-server
          nodePackages.typescript-language-server
          python311Packages.beautifulsoup4 vscode-langservers-extracted
          yaml-language-server
          # internet
          bitwarden discord discordo newsflash signal-desktop tailscale
          telegram-desktop tor-browser-bundle-bin transmission-gtk tuba wike
          # desktop environment
          gnomeExtensions.gsconnect gnome.gnome-tweaks
          # documents etc.
          dialect foliate libreoffice-fresh ocrmypdf pandoc
          texliveMedium zotero gnome-decoder eyedropper warp magic-wormhole
          gnome-solanum
          hunspell
            # obsidian 
          # games
          vitetris
          # fonts
          brill fira-code-nerdfont inter noto-fonts-cjk-sans public-sans
          ubuntu_font_family
        ];

      # sessionVariables = # doesn't work here??
      #   { ANDROID_HOME       = "${config.xdg.dataHome}/android";
      #     GNUPGHOME          = "${config.xdg.dataHome}/gnupg";
      #     #IPFS_PATH          = "${config.xdg.dataHome}/ipfs";
      #     IPYTHONDIR         = "${config.xdg.configHome}/ipython";
      #     JUPYTER_CONFIG_DIR = "${config.xdg.configHome}/jupyter";
      #     PYTHONSTARTUP      = "${config.xdg.configHome}/pythonrc";
      #   };

    };

  programs =
    { home-manager.enable = true;

      bat =
        { enable = true;
          config =
            { theme = "gruvbox-dark";
              style = "plain";
            };
        };

      kitty =
        { enable = true;
          theme = "Gruvbox Dark";
          font =
            { name = "FiraCode Nerd Font";
              size = 12;
            };
          extraConfig =
            ''
              background #1D2021
              cursor_shape beam
              cursor_blink_interval 0
              strip_trailing_spaces smart
              scrollback_fill_enlarged_window yes
              touch_scroll_multiplier 3.0
              wayland_titlebar_color background
              hide_window_decorations yes
              tab_bar_style powerline
              tab_powerline_style slanted
            '';
          shellIntegration =
            { enableBashIntegration = true;
              enableZshIntegration = true;
            };
          keybindings = 
            { "kitty_mod+t" = "new_tab_with_cwd";
              "kitty_mod+enter" = "launch --cwd=current";
            };
        };

      yazi = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      helix =
        { enable = true;
          defaultEditor = true;
          settings =
            { theme = "gruvbox_transparent";
              editor =
                { bufferline = "multiple";
                  auto-format = false;
                  cursor-shape.insert = "bar";
                  file-picker.hidden = false;
                  soft-wrap = { enable = true; wrap-indicator = ""; };
                  lsp = { display-inlay-hints = true; display-messages = true; };
                  indent-guides =
                    { render = true;
                      character = "┊";
                    };
                  statusline =
                    { mode = { normal = "N"; insert = "I"; select = "S"; };
                      right =
                        [ "version-control" "diagnostics" "selections"
                          "position" "file-encoding"
                        ];
                    };
                };
                keys.normal =
                  { "esc"   = ["collapse_selection" "keep_primary_selection"];
                    "A-ret" = ":pipe-to ./tidal_send.sh";
                  };
            };
          languages =
            { language =
                [ { name = "tidal";
                    scope = "source.tidal";
                    roots = [];
                    injection-regex = "tidal";
                    file-types = ["tidal"];
                    comment-token = "--";
                    indent = { tab-width = 2; unit = "  "; };
                    grammar = "haskell";
                  }
                  { name = "markdown";
                    language-servers = ["ltex-ls" "marksman"];
                    file-types = ["md"];
                    scope = "text.markdown";
                    roots = [];
                  }
                  { name = "mdx";
                    language-servers = ["marksman"];
                    file-types = ["mdx"];
                    scope = "source.mdx";
                    roots = [];
                    grammar = "markdown";
                  }
                ];
              language-server =
                { ltex-ls =
                    { command = "ltex-ls";
                      config.ltex =
                        { language = "en-ZA";
                          additionalRules.enablePickyRules = true;
                          completionEnabled = true;
                        };
                    };
                };
            };
          themes."gruvbox_transparent" =
            { inherits = "gruvbox_dark_hard";
              "ui.background" = "transparent";
            };
      };

      git =
        { enable = true;
          userName = "Paul Joubert";
          userEmail = "paul@trespaul.com";
        };

      zsh =
        { enable = true;
          dotDir = ".config/zsh";
          enableAutosuggestions = true;
          enableCompletion = true;
          completionInit = "autoload -U compinit && compinit -d ${config.xdg.cacheHome}/zsh/zcompdump-\"$ZSH_VERSION\"";
          enableVteIntegration = true;
          history.path = "${config.xdg.stateHome}/zsh/history";
          syntaxHighlighting.enable = true;
          oh-my-zsh =
            { enable = true;
              plugins = [ "git" "python" "man" "bundler" "dotenv" ];
              theme = "awesomepanda";
            };
        };

      bash =
        { enable = true;
          enableCompletion = true;
          historyFile = "${config.xdg.stateHome}/bash/history";
          initExtra = ''PS1="\n\[\033[1;32m\]➜  \W \[\033[0m\]"'';
        };

      zoxide =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

      fzf =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

      firefox =
        { enable = true;
          profiles.default.userChrome =
            ''
              vbox#titlebar {
                display: none;
              }

              /* auto-hide when fullscreen */
              #main-window[inFullscreen] #sidebar-box,
              #main-window[inFullscreen] #sidebar-splitter {
                display: none !important;
                width: 0px !important;
              }

              /* hide tree style tabs sidebar title */
              #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                display: none;
              }

              /* reduce minimum width of sidebar */
              #sidebar-box {
                min-width: 30px !important;
              }
            '';
        };

    };

  xdg =
  { enable = true;
    configFile = 
      { "python/pythonrc".text =
          ''
            import os
            import atexit
            import readline

            history = os.path.join(os.environ['XDG_CACHE_HOME'], 'python_history')
            try:
                readline.read_history_file(history)
            except OSError:
                pass

            def write_history():
                try:
                    readline.write_history_file(history)
                except OSError:
                    pass

            atexit.register(write_history)
          '';
      };
  };

}
