{
  home-manager.users.paul = { config, pkgs, ... }:
    { home =
        { username = "paul";
          homeDirectory = "/home/paul";

          stateVersion = "23.05";

          shellAliases =
            { "l" = "eza -l";
              "la" = "eza -la";
              "lt" = "eza -laT";
              "qmv" = "qmv --format destination-only";
              "ffmpeg" = "ffmpeg -hide_banner";
              "ffprobe" = "ffprobe -hide_banner";
              "ip" = "ip -c";
              "s" = "ssh";
              "wget" = "wget --hsts-file=${config.xdg.dataHome}/wget-hsts";
              "fd" = "fd --hidden";
              "adb" = "env HOME=${config.xdg.dataHome}/android adb";
              "k" = "kubecolor";
            };

          packages = with pkgs;
            [ # misc cli
              bat fd file gawk gnupg gnused gnutar jc libnotify libsecret psmisc
              renameutils unar watchexec which xz zip zstd
              # networking tools
              dnsutils ldns sshfs
              # system tools
              clinfo mesa-demos iftop iotop lsof ltrace strace ethtool lm_sensors
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

          git =
            { enable = true;
              settings =
                { user =
                    { name = "Paul Joubert";
                      email = "paul@trespaul.com";
                    };
                  core.whitespace = "error";
                  merge.conflictStyle = "diff3";
                };
              signing =
                { key = "8547C047479405D1AF8BA47C394493769D46A76C";
                  signByDefault = true;
                  format = null;
                };
            };

          difftastic =
            { enable = true;
              git.enable = true;
              jujutsu.enable = true;
              options.display = "side-by-side-show-both";
            };

          mergiraf =
            { enable = true;
              enableGitIntegration = true;
              enableJujutsuIntegration = true;
            };

          bash =
            { enable = true;
              enableCompletion = true;
              historyFile = "${config.xdg.stateHome}/bash/history";
              initExtra = ''PS1="\n\[\033[1;32m\]➜  \W \[\033[0m\]"'';
            };

          nushell =
            { enable = true;
              shellAliases = config.home.shellAliases;
              settings =
                { filesize.unit = "metric";
                  highlight_resolved_externals = true;
                  show_banner = false;
                  use_kitty_protocol = true;
                  table =
                    { mode = "light";
                      index_mode = "auto";
                    };
                  datetime_format =
                    { normal = "%a %Y-%m-%d %H:%M:%S %z";
                      table = "%a %Y-%m-%d %H:%M:%S";
                    };
                  completions =
                    { case_sensitive = false;
                      algorithm = "fuzzy";
                      external.enable = true;
                    };
                };
              environmentVariables =
                { GNUPGHOME = "${config.xdg.dataHome}/gnupg";
                  EDITOR = "hx";
                };
              extraConfig = # nu
                ''
                  $env.config.completions.external.completer = {
                    |spans: list<string>|
                      CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans
                      | from json
                  }
                '';
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

    };
}
