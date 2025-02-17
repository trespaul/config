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
          luks.devices."luks-2c70f851-15b6-42ea-84e8-6692e2abe680".device =
            "/dev/disk/by-uuid/2c70f851-15b6-42ea-84e8-6692e2abe680";
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/6a928690-b8fb-434d-9b7b-7863601ce56f";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/03B7-3C8A";
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
