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
          luks.devices."luks-e1477bc2-1cca-469b-81ae-760226db7445" =
            { device = "/dev/disk/by-uuid/e1477bc2-1cca-469b-81ae-760226db7445";
              allowDiscards = true;
            };
          secrets."/crypto_keyfile.bin" = null;
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
      "/mnt/Future" =
        { device = "/dev/disk/by-uuid/75c29c38-e000-49b6-95a3-3d2def9841ff";
          fsType = "ext4";
          options = [ "x-gvfs-show" ];
        };
    };

  swapDevices =
    [ { device = "/var/lib/swapfile";
        size = 16*1024;
      }
    ];

  environment.etc.crypttab.text =
    let
      uuid = "cf11b689-fd00-4b01-a774-2c198132d05f";
    in
      "luks-${uuid} UUID=${uuid} /future.key";

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
