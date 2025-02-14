{ config, pkgs, ... }:

{
  home =
    { packages = with pkgs;
        [
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
            # obsidian
          # games
          vitetris
        ];

    };

  programs =
    { obs-studio.enable = true;
    };
}
