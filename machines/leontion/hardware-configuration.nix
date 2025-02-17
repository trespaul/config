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
          luks.devices."luks-741ee4af-bd7b-4836-a4e8-ffdd20de1a53".device =
            "/dev/disk/by-uuid/741ee4af-bd7b-4836-a4e8-ffdd20de1a53";
          secrets."/crypto_keyfile.bin" = null;
        };
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/8f095a7c-e302-45fd-9067-e8794f490fa5";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/E80D-46E9";
          fsType = "vfat";
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
