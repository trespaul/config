{ config, pkgs, roc, ... }:

{
  home =
    { packages = with pkgs;
        [
          # audio production
          ardour audacity bespokesynth calf cardinal haskellPackages.tidal
          musescore supercollider-with-sc3-plugins vital
          # graphics & video apps
          blender darktable eyedropper gimp inkscape-with-extensions kdenlive
          scrcpy
          # dev etc.
          android-tools arduino-ide boxes cargo flyctl gleam google-cloud-sdk
          # LSPs
          haskell-language-server ltex-ls markdown-oxide
          marksman nil nodePackages.bash-language-server
          nodePackages.typescript-language-server vscode-langservers-extracted
          yaml-language-server
          # pentesting
          aircrack-ng bettercap crunch dsniff hashcat hcxdumptool hcxtools iw
          macchanger tcpdump wifite2 wireshark
          # internet apps
          beeper discord fractal newsflash signal-desktop telegram-desktop
          tor-browser-bundle-bin transmission_4-gtk tuba wike
          # document cli utils
          ocrmypdf texliveFull librsvg
          # document apps
          dialect errands foliate libreoffice-fresh scantailor zotero
          gnome-decoder gnome-solanum
            # obsidian
          # games
          vitetris
        ];

    };

  programs =
    { obs-studio.enable = true;
      ncspot =
        { enable = true;
          # use_nerdfont = true;
          # notify = true;
          # credentials =
          #   { username = "21wt6kx2cpvurgqvkgwk34jsy";
          #     password_cmd = "cat ${config.age.secrets.spotify.path}";
          #   };
        };
    };
}
