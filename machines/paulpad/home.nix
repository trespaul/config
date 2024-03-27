{ config, pkgs, ... }:

{
  home =
    { packages = with pkgs;
        [
          # audio production
          ardour audacity bespokesynth calf cardinal haskellPackages.tidal
          musescore supercollider supercolliderPlugins.sc3-plugins vital
          # graphics & video apps
          blender darktable eyedropper gimp inkscape-with-extensions kdenlive
          scrcpy
          # dev etc.
          android-tools boxes google-cloud-sdk
          # LSPs
          haskell-language-server ltex-ls marksman nil
          nodePackages.bash-language-server
          nodePackages.typescript-language-server vscode-langservers-extracted
          yaml-language-server
          # pentesting
          aircrack-ng bettercap crunch dsniff hashcat hcxdumptool hcxtools iw
          macchanger tcpdump wifite2 wireshark
          # internet apps
          discord newsflash signal-desktop telegram-desktop
          tor-browser-bundle-bin transmission-gtk tuba wike
          # document cli utils
          ocrmypdf
          # document apps
          dialect foliate libreoffice-fresh scantailor zotero gnome-decoder
          gnome-solanum
            # obsidian
          # games
          vitetris
        ];

    };

  programs =
    { obs-studio.enable = true;
    };
}
