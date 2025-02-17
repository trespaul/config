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
          luks.devices."luks-610e95b4-a88a-4da3-b7ab-692e1cf2b4e0".device =
            "/dev/disk/by-uuid/610e95b4-a88a-4da3-b7ab-692e1cf2b4e0";
          secrets."/crypto_keyfile.bin" = null;
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/5931abbf-10a5-4177-b33e-cc73c361dc31";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/31DE-3341";
          fsType = "vfat";
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
