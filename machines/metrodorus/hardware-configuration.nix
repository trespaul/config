{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot =
    { initrd =
        { kernelModules = [ ];
          availableKernelModules =
            [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/1295414d-7b39-44ec-afff-70b7f59da36c";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/1681-87EF";
          fsType = "vfat";
        };
      "/mnt/Storage" =
        { device = "/dev/disk/by-uuid/5598210a-03ea-4626-937f-7e70950e3533";
          fsType = "btrfs";
          options = [ "compress=zstd" ];
        };
      "/mnt/Media" =
        { device = "/dev/disk/by-uuid/a7cca8b2-0cc7-49f0-a292-67e534b41ca0";
          fsType = "ext4";
        };
    };

  swapDevices =
    [ { device = "/var/lib/swapfile";
        size = 8*1024;
      }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
