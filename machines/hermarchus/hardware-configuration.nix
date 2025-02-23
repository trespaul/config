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
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/8daa7a6b-5ee2-41e9-9a03-93a209c11479";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/0BA8-4F24";
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
