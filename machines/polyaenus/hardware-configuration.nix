{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot =
    { initrd =
        { kernelModules = [ ];
          availableKernelModules =
            [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" ];
          luks.devices."luks-9f520233-8251-4136-a4e7-9c9a67ffd93f".device =
            "/dev/disk/by-uuid/9f520233-8251-4136-a4e7-9c9a67ffd93f";
          secrets."/crypto_keyfile.bin" = null;
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/6fc0e195-3009-440d-810d-b9752fe6d953";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/E54B-1D1C";
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
