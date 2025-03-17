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
          "y" = "yazi";
          "qmv" = "qmv --format destination-only";
          "ffmpeg" = "ffmpeg -hide_banner";
          "ffprobe" = "ffprobe -hide_banner";
          "ip" = "ip -c";
          "s" = "ssh";
          "wget" = "wget --hsts-file=${config.xdg.dataHome}/wget-hsts";
          "fd" = "fd --hidden";
          "rp" = "rippkgs";
          "ns" = "nix-search";
          "adb" = "env HOME=${config.xdg.dataHome}/android adb";
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
        };

      packages = with pkgs;
        [ # misc cli
          bat fd file gawk gnupg gnused gnutar jc libnotify libsecret psmisc
          renameutils unar watchexec which xz zip zstd
          # networking tools
          dnsutils ldns sshfs
          # system tools
          clinfo glxinfo iftop iotop lsof ltrace strace ethtool lm_sensors
          pciutils usbutils
          # internet utils
          magic-wormhole
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
              base_10_sizes = true;
            };
        };

      eza =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          git = true;
          icons = "auto";
          extraOptions = [ "--group-directories-first" ];
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
                  end-of-line-diagnostics = "hint";
                  inline-diagnostics.cursor-line = "warning";
                  indent-guides = { render = true; character = "┊"; };
                };
                keys.normal =
                  { "esc"   = ["collapse_selection" "keep_primary_selection"]; };
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
          extraConfig =
            ''
              $env.GNUPGHOME = "${config.xdg.dataHome}/gnupg"
              $env.EDITOR = "hx"

              let carapace_completer = { |spans: list<string>|
                carapace $spans.0 nushell ...$spans
                | from json
                | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
              }

              let multiple_completers = { |spans|
                # alias completions fix
                let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)
                let spans = (if $expanded_alias != null  {
                  $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
                } else { $spans })

                match $spans.0 {
                  _ => $carapace_completer
                } | do $in $spans
              }

              $env.config = {
                table: {
                  mode: light
                  index_mode: auto
                }
                filesize: {
                  unit: metric
                }
                datetime_format: {
                  normal: "%a %Y-%m-%d %H:%M:%S %z"
                  table:  "%a %Y-%m-%d %H:%M:%S"
                }
                completions: {
                  case_sensitive: false
                  algorithm: "fuzzy"
                  external: {
                    enable: true
                    completer: $multiple_completers
                  }
                }
                highlight_resolved_externals: true
                show_banner: false
                use_kitty_protocol: true
              }
            '';
          shellAliases = config.home.shellAliases;
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

      carapace =
        { enable = true;
          enableNushellIntegration = true;
        };

      starship =
        { enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          settings =
            { format =
                "[█](color_orange)$shell$username$hostname[█🭛](bg:color_yellow fg:color_orange)$directory[█🭛](fg:color_yellow bg:color_aqua)$git_branch$git_status[█🭛](fg:color_aqua bg:color_blue)$rust$nodejs$haskell$python[█🭛](fg:color_blue bg:color_bg3)$docker_context[█🭛](fg:color_bg3 bg:color_bg1)$time[█🭛](fg:color_bg1)$nix_shell$line_break$character";
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
              hostname =
                { style = "bg:color_orange";
                  format = "[$ssh_symbol$hostname]($style)";
                };
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
                  truncation_symbol = "…/";
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
