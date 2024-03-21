{ config, pkgs, ... }:

{
  home =
    { username = "paul";
      homeDirectory = "/home/paul";

      stateVersion = "23.05";

      shellAliases =
        { "l" = "eza -l";
          "la" = "eza -la";
          "lt" = "eza -laT";
          "x" = "xdg-open";
          "qmv" = "qmv --format destination-only";
          "ffmpeg" = "ffmpeg -hide_banner";
          "ffprobe" = "ffprobe -hide_banner";
          "ip" = "ip -c";
          "sudo" = "sudo -v; sudo ";
          "s" = "kitten ssh";
          "wget" = "wget --hsts-file=.local/share/wget-hsts";
          "fd" = "fd --hidden";
          "sortl" = # sort lines: sort witin and throughout lines
            ''tr " " "\n" | sort | paste -s -d " " '';
          "sortli" = # sort lines independently: each line sort separately
            ''split -l 1 --filter 'tr " " "\n" | sort | paste -s -d " "' '';
        };

      packages = with pkgs;
        [ # misc cli
          bat fd file fzf gawk glow gnupg gnused gnutar hyperfine libnotify
          libsecret neofetch p7zip parallel pinentry-gnome3 renameutils slides
          unar unzip which xdg-ninja xz yq-go zip zstd
          # networking tools
          dnsutils ldns netscanner nmap sshfs
          # nix related
          nix-output-monitor
          # system tools
          clinfo glxinfo iftop iotop lsof ltrace strace ethtool lm_sensors
          pciutils usbutils
          # media utils
          ffmpeg vlc
            # pwvucontrol 
            # gimp-with-plugins 
          # internet utils
          bitwarden tailscale warp magic-wormhole
          # desktop environment
          gnomeExtensions.gsconnect gnome.gnome-tweaks gnome-themes-extra
          # document cli utils
          hunspell ghostscript pdftk poppler_utils jbig2dec jbig2enc libtiff
          # fonts
          iosevka
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

      gitui.enable = true;
      jq.enable = true;
      obs-studio.enable = true;
      ripgrep.enable = true;
      tealdeer.enable = true;
      yt-dlp.enable = true;

      bat =
        { enable = true;
          config =
            { theme = "gruvbox-dark";
              style = "plain";
            };
        };

      btop =
        { enable = true;
          settings =
            { color_theme = "gruvbox_dark";
              theme_background = false;
            };
        };

      eza =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          git = true;
          icons = true;
          extraOptions = [ "--group-directories-first" ];
        };
  
      kitty =
        { enable = true;
          theme = "Gruvbox Dark";
          extraConfig =
            ''
              font_family       Iosevka Light Extended
              bold_font         Iosevka Semibold Extended
              italic_font       Iosevka Light Extended Italic
              bold_italic_font  Iosevka Semibold Extended Italic
              font_features     Iosevka-Light-Extended           +dlig +PURS
              font_features     Iosevka-Semibold-Extended        +dlig +PURS
              font_features     Iosevka-Light-Extended-Italic    +dlig +PURS
              font_features     Iosevka-Semibold-Extended-Italic +dlig +PURS

              font_size                       12
              narrow_symbols                  U+279C-U+27BF
              background                      #1D2021
              cursor_shape                    beam
              cursor_blink_interval           0
              strip_trailing_spaces           smart
              scrollback_fill_enlarged_window yes
              touch_scroll_multiplier         3.0
              hide_window_decorations         yes
              tab_bar_style                   powerline
              tab_powerline_style             slanted
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
                    "A-ret" = ":pipe-to kitten @ send-text --match-tab 'title:^tidal' --stdin ':{\n' && kitten @ send-text --match-tab 'title:^tidal' ':}\n'";
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
          delta =
            { enable = true;
              options =
                { features.decorations = true;
                  line-numbers = true;
                };
            };
          signing =
            { key = "8547C047479405D1AF8BA47C394493769D46A76C";
              signByDefault = true;
            };
        };

      pandoc =
        { enable = true;
          # citationStyles = [];
          # defaults = {};
          # templates = {};
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

      texlive =
        { enable = true;
          # packageSet = pkgs.texliveMedium;
        };

      yazi =
        { enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
        };

      zsh =
        { enable = true;
          dotDir = ".config/zsh";
          autosuggestion.enable = true;
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
          colors = # gruvbox dark
            { fg      = "#ebdbb2";
              bg      = "#282828";
              hl      = "#fabd2f";
              "fg+"   = "#ebdbb2";
              "bg+"   = "#3c3836";
              "hl+"   = "#fabd2f";
              info    = "#83a598";
              prompt  = "#bdae93";
              spinner = "#fabd2f";
              pointer = "#83a598";
              marker  = "#fe8019";
              header  = "#665c54";
            };
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

  services =
    {
      spotifyd =
        { enable = true;
          settings.global =
            { username = "21wt6kx2cpvurgqvkgwk34jsy";
              password_cmd = "cat ${config.age.secrets.spotify.path}";
              device_name = "polyaenus";
              bitrate = 320;
              cache_path = "/home/paul/.cache/spotifyd";
              device_type = "a_v_r";
            };
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
