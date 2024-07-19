{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot =
    { initrd =
        { kernelModules = [ ];
          availableKernelModules =
            [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
          luks.devices."luks-e1477bc2-1cca-469b-81ae-760226db7445".device =
            "/dev/disk/by-uuid/e1477bc2-1cca-469b-81ae-760226db7445";
        };
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
  };

  fileSystems =
    { "/" =
        { device = "/dev/disk/by-uuid/66837d26-00e4-42b2-ac6f-e5ee13628c87";
          fsType = "ext4";
        };
      "/boot" =
        { device = "/dev/disk/by-uuid/F096-4EE6";
          fsType = "vfat";
        };
    };

  swapDevices =
    [ { device = "/var/lib/swapfile";
        size = 16*1024;
      }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
