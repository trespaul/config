{ ... }:
{
  home-manager.users.paul.programs.helix =
    { enable = true;
      defaultEditor = true;
      settings =
        { theme = "gruvbox_transparent";
          editor =
            { bufferline = "multiple";
              auto-format = false;
              cursor-shape.insert = "bar";
              file-picker.hidden = false;
              soft-wrap =
                { enable = true;
                  wrap-indicator = "";
                };
              lsp =
                { display-inlay-hints = true;
                  display-messages = true;
                };
              inline-diagnostics.cursor-line = "hint";
              indent-guides =
                { render = true;
                  character = "┊";
                };
            };
            keys.normal =
              { "esc"   = ["collapse_selection" "keep_primary_selection"];
                "D"     = ["select_mode" "goto_line_end" "delete_selection"];
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
                language-servers = ["ltex-ls-plus" "marksman" "markdown-oxide"];
                file-types = ["md" "mdx"];
                scope = "text.markdown";
                roots = [];
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
              { name = "typst";
                language-servers = [ "tinymist" "ltex-ls-plus" ];
              }
              { name = "html";
                language-servers = [ "vscode-html-language-server" "tailwindcss-ls" ];
              }
              { name = "css";
                language-servers = [ "vscode-css-language-server" "tailwindcss-ls" ];
              }
              { name = "jsx";
                language-servers = [ "typescript-language-server" "tailwindcss-ls" ];
              }
              { name = "tsx";
                language-servers = [ "typescript-language-server" "tailwindcss-ls" ];
              }
            ];
          language-server =
            { ltex-ls-plus =
                { command = "ltex-ls-plus";
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
              rust-analyzer.config =
                { cargo.features = "all";
                  check.command = "clippy";
                };
              tailwindcss-ls =
                { command = "tailwindcss-language-server";
                  args = [ "--stdio" ];
                };
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
}
