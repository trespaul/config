{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot =
    { initrd =
        { kernelModules = [ ];
          availableKernelModules =
            [ "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "rtsx_usb_sdmmc" ];
        };
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/5f39b966-a6ae-4ee5-ae5a-1ae8622245b5";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/02E4-CE84";
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
