{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot =
    { initrd =
        { kernelModules = [ ];
          availableKernelModules =
            [ "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
          luks.devices."luks-a3ea800d-33d0-4daf-9eb9-dc44908a768b".device =
            "/dev/disk/by-uuid/a3ea800d-33d0-4daf-9eb9-dc44908a768b";
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/54f4ad96-80a9-4277-8592-59c48e0aa057";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/D1CD-CCE4";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };
    };

  swapDevices =
    [ { device = "/var/lib/swapfile";
        size = 4*1024;
      }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave"; 
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
