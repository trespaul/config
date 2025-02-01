{ config, pkgs, zen-browser, nix-search, ... }:

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
          "y" = "yazi";
          "qmv" = "qmv --format destination-only";
          "ffmpeg" = "ffmpeg -hide_banner";
          "ffprobe" = "ffprobe -hide_banner";
          "ip" = "ip -c";
          "sudo" = "sudo -v; sudo ";
          "s" = "ssh";
          "wget" = "wget --hsts-file=.local/share/wget-hsts";
          "fd" = "fd --hidden";
          "rp" = "rippkgs";
          "ns" = "nix-search";
          "adb" = "HOME=${config.xdg.dataHome}/android adb";
          "g" = "git";
          "gd" = "git diff";
          "gds" = "git diff --staged";
          "gl" = "git log";
          "gst" = "git status";
          "ga" = "git add";
          "gaa" = "git add --all";
          "gc" = "git commit --verbose";
          "gp" = "git push";
          "sortl" = # sort lines: sort within and throughout lines
            ''tr " " "\n" | sort | paste -s -d " " '';
          "sortli" = # sort lines independently: each line sort separately
            ''split -l 1 --filter 'tr " " "\n" | sort | paste -s -d " "' '';
        };

      packages = with pkgs;
        [ # misc cli
          bat fd file gawk glow gnupg gnused gnutar hyperfine jc libnotify
          libsecret p7zip parallel pinentry-gnome3 psmisc renameutils slides
          unar unzip watchexec which xdg-ninja xz yq-go zip zstd
          # networking tools
          dnsutils ldns netscanner nmap sshfs
          # nix related
          nix-output-monitor rippkgs nix-search.packages.${system}.default
          # system tools
          clinfo glxinfo iftop iotop lsof ltrace strace ethtool lm_sensors
          pciutils usbutils
          # media utils
          eartag ffmpeg helvum pwvucontrol vlc
          # browser
          zen-browser.packages.${system}.default
          # internet utils
          bitwarden tailscale warp magic-wormhole
          # desktop environment
          gnomeExtensions.gsconnect gnome-tweaks gpaste
          gnome-themes-extra smile gnomeExtensions.smile-complementary-extension
          # document cli utils
          hunspell ghostscript pdftk poppler_utils jbig2dec jbig2enc libtiff
          # fonts
          brill inter iosevka noto-fonts-cjk-sans public-sans
          ubuntu_font_family
        ];

      # sessionVariables = # doesn't work here??
      #   { ANDROID_HOME       = "${config.xdg.dataHome}/android";
      #     GNUPGHOME          = "${config.xdg.dataHome}/gnupg";
      #     IPYTHONDIR         = "${config.xdg.configHome}/ipython";
      #     JUPYTER_CONFIG_DIR = "${config.xdg.configHome}/jupyter";
      #     PYTHONSTARTUP      = "${config.xdg.configHome}/pythonrc";
      #   };

    };

  programs =
    { home-manager.enable = true;

      gitui.enable = true;
      jq.enable = true;
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
          # enableNushellIntegration = true;
          git = true;
          icons = "auto";
          extraOptions = [ "--group-directories-first" ];
        };

      ghostty =
        { enable = true;
          settings =
            { theme = "GruvboxDarkHard";
              font-family = "Iosevka Extended";
              cursor-style = "bar";
              cursor-style-blink = false;
              window-decoration = false;
            };
        };
      kitty =
        { enable = true;
          themeFile = "gruvbox-dark-hard";
          settings =
            { font_family =      "Iosevka Light Extended";
              bold_font =        "Iosevka Semibold Extended";
              italic_font =      "Iosevka Light Extended Italic";
              bold_italic_font = "Iosevka Semibold Extended Italic";
              "font_features Iosevka-Light-Extended" =           "+dlig +PURS";
              "font_features Iosevka-Semibold-Extended" =        "+dlig +PURS";
              "font_features Iosevka-Light-Extended-Italic" =    "+dlig +PURS";
              "font_features Iosevka-Semibold-Extended-Italic" = "+dlig +PURS";
              font_size = 12;
              narrow_symbols = "U+279C-U+27BF";
              cursor_shape = "beam";
              cursor_blink_interval = "0";
              strip_trailing_spaces = "smart";
              scrollback_fill_enlarged_window = true;
              touch_scroll_multiplier = "3.0";
              hide_window_decorations = true;
              tab_bar_style = "powerline";
              tab_powerline_style = "slanted";
              allow_remote_control = true;
              enable_audio_bell = false;
            };
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
                  auto-pairs = false;
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
                    "A-ret" =
                      ''
                        :pipe-to kitten @ send-text --match-tab 'title:^tidal' --stdin ':{\n' \
                              && kitten @ send-text --match-tab 'title:^tidal'         ':}\n'
                      '';

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
                    language-servers = ["ltex-ls" "marksman" "markdown-oxide"];
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
                  { name = "roc";
                    scope = "source.roc";
                    injection-regex = "roc";
                    file-types = ["roc"];
                    shebangs = ["roc"];
                    roots = [];
                    comment-token = "#";
                    language-servers = ["roc-ls"];
                    indent = { tab-width = 2; unit = "  "; };
                    auto-format = true;
                    formatter =
                      { command = "roc"; args = [ "format" "--stdin" "--stdout"]; };
                    auto-pairs = { "(" = ")"; "{" = "}"; "[" = "]"; "\"" = "\""; };
                  }
                ];
              language-server =
                { ltex-ls =
                    { command = "ltex-ls";
                      config.ltex =
                        { language = "en-ZA";
                          enabledRules."en-ZA" = [ "CREATIVE_WRITING" "TEXT_ANALYSIS" ];
                          disabledRules."en-ZA" = [ "EN_QUOTES" ];
                          additionalRules =
                            { enablePickyRules = true;
                              motherTongue = "en-ZA";
                            };
                          completionEnabled = true;
                        };
                    };
                  roc-ls =
                    { command = "roc_language_server"; };
                };
              grammar =
                [ { name = "roc";
                    source =
                      { git = "https://github.com/faldor20/tree-sitter-roc.git";
                        rev = "master";
                      };
                  }
                ];
            };
          themes."gruvbox_transparent" =
            { inherits = "gruvbox_dark_hard";
              "ui.background" = { };
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
              plugins = [ "git" "man" "dotenv" "sudo" ];
              theme = "awesomepanda";
            };
        };

      bash =
        { enable = true;
          enableCompletion = true;
          historyFile = "${config.xdg.stateHome}/bash/history";
          initExtra = ''PS1="\n\[\033[1;32m\]➜  \W \[\033[0m\]"'';
        };

      nushell =
        { enable = true;
          configFile.text =
            ''
              $env.config = {
                table: {
                  mode: light
                  index_mode: auto
                }
                filesize: {
                  metric: true
                }
                datetime_format: {
                  normal: "%a %Y-%m-%d %H:%M:%S %z"
                  table:  "%a %Y-%m-%d %H:%M:%S"
                }
                highlight_resolved_externals: true
                show_banner: false
                use_kitty_protocol: true
              }
              $env.GNUPGHOME = "${config.xdg.dataHome}/gnupg"
              $env.EDITOR = "hx"
            '';
          shellAliases = # not taken from home.shellAliases?
            { "l" = "eza -l";
              "la" = "eza -la";
              "lt" = "eza -laT";
              "qmv" = "qmv --format destination-only";
              "ffmpeg" = "ffmpeg -hide_banner";
              "ffprobe" = "ffprobe -hide_banner";
              "ip" = "ip -c";
              "s" = "kitten ssh";
              "wget" = "wget --hsts-file=.local/share/wget-hsts";
              "fd" = "fd --hidden";
              "rp" = "rippkgs";
              "ns" = "nix-search";
              "adb" = "HOME=${config.xdg.dataHome}/android adb";
              "g" = "git";
              "gst" = "git status";
              "ga" = "git add";
              "gaa" = "git add --all";
              "gc" = "git commit --verbose";
              "gp" = "git push";
            };
        };

      atuin =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          flags = [ "--disable-up-arrow" ];
          settings =
            { enter_accept = true;
              dotfiles.enabled = false;
              sync.records = true;
              update_check = false;
              style = "compact";
              inline_height = 15;
              show_help = false;
              show_tabs = false;
              invert = true;
            };
        };

      zoxide =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };

      broot =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };

      starship =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          settings =
            { format =
                "[█](color_orange)$shell$username$hostname[█🭛](bg:color_yellow fg:color_orange)$directory[█🭛](fg:color_yellow bg:color_aqua)$git_branch$git_status[█🭛](fg:color_aqua bg:color_blue)$rust$nodejs$haskell$python[█🭛](fg:color_blue bg:color_bg3)$docker_context[█🭛](fg:color_bg3 bg:color_bg1)$time[█🭛](fg:color_bg1)$line_break$character";
              palette = "gruvbox_dark";
              palettes.gruvbox_dark =
                { color_fg0    = "#fbf1c7";
                  color_bg0    = "#1d2021";
                  color_bg1    = "#3c3836";
                  color_bg3    = "#665c54";
                  color_blue   = "#458588";
                  color_aqua   = "#689d6a";
                  color_green  = "#98971a";
                  color_orange = "#d65d0e";
                  color_purple = "#b16286";
                  color_red    = "#cc241d";
                  color_yellow = "#d79921";
                };
              os.disabled = true;
              hostname.style = "bg:color_orange";
              line_break.disabled = false;
              username =
                { style_user = "bg:color_orange fg:color_fg0";
                  style_root = "bg:color_orange fg:color_fg0";
                  format = "[ $user ]($style)";
                };
              directory =
                { style = "bold fg:color_bg0 bg:color_yellow";
                  format = "[ $path ]($style)";
                  truncation_length = 3;
                  truncation_symbol = "… /";
                  substitutions =
                    { "Documents" = "󰈙 ";
                      "Downloads" = " ";
                      "Music"     = "󰝚 ";
                      "Pictures"  = " ";
                      "Projects"  = "󰲋 ";
                    };
                };
              shell =
                { disabled = false;
                  zsh_indicator = "zsh";
                  bash_indicator = "bash";
                  nu_indicator = "";
                  style = "bg:color_orange";
                  format = "[$indicator]($style)";
                };
              git_branch =
                { symbol = "";
                  style = "bg:color_aqua";
                  format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
                };
              git_status =
                { style = "bg:color_aqua";
                  format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
                };
              nodejs =
                { symbol = "";
                  style = "bg:color_blue";
                  format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
                };
              rust =
                { symbol = "";
                  style = "bg:color_blue";
                  format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
                };
              haskell =
                { symbol = "";
                  style = "bg:color_blue";
                  format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
                };
              python =
                { symbol = "";
                  style = "bg:color_blue";
                  format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
                };
              docker_context =
                { symbol = "";
                  style = "bg:color_bg3";
                  format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
                };
              time =
                { disabled = false;
                  time_format = "%R";
                  format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
                };
              character =
                { disabled = false;
                  success_symbol = "[](bold fg:color_green)";
                  error_symbol = "[](bold fg:color_red)";
                  vimcmd_symbol = "[](bold fg:color_green)";
                  vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
                  vimcmd_replace_symbol = "[](bold fg:color_purple)";
                  vimcmd_visual_symbol = "[](bold fg:color_yellow)";
                };
            };
        };

    };

  # services = { };

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
              "zen.desktop"
              "discord.desktop"
              "zotero.desktop"
              "beeper.desktop"
            ];
        };

    };

  xdg =
    { enable = true;
      configFile =
        { "python/pythonrc".text =
            ''
              def is_vanilla() -> bool:
                  import sys
                  return not hasattr(__builtins__, '__IPYTHON__') and 'bpython' not in sys.argv[0]


              def setup_history():
                  import os
                  import atexit
                  import readline
                  from pathlib import Path

                  if state_home := os.environ.get('XDG_STATE_HOME'):
                      state_home = Path(state_home)
                  else:
                      state_home = Path.home() / '.local' / 'state'

                  history: Path = state_home / 'python_history'

                  readline.read_history_file(str(history))
                  atexit.register(readline.write_history_file, str(history))


              if is_vanilla():
                  setup_history()
            '';

          "npm/npmrc".text =
            ''
              prefix=${config.xdg.dataHome}/npm
              cache=${config.xdg.cacheHome}/npm
              init-module=${config.xdg.configHome}/npm/config/npm-init.js
            '';
        };
    };

}
