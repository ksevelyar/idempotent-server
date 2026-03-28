{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}: let
  agenixKey = pkgs.writeText "agenix-key" (builtins.readFile /home/ksevelyar/.ssh/guest_ed25519_key);
in {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];

  age = {
    identityPaths = ["/root/.ssh/host-agenix-key"];
    secrets.wifi.file = ../secrets/wifi.age;
    secrets.root-password.file = ../secrets/root-password.age;
  };

  boot = {
    consoleLogLevel = 1;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      generic-extlinux-compatible.configurationLimit = 1;
    };
    kernelParams = ["console=tty0"];
    kernelPackages = pkgs.linuxPackages_rpi02w;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    supportedFilesystems = lib.mkForce ["vfat" "ext4"];

    # https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  documentation.enable = false;
  documentation.man.generateCaches = false;
  services.lvm.enable = false;

  environment.systemPackages = with pkgs; [
    rsync
    lm_sensors
    powertop
    # neovim-unwrapped
    zoxide
    bat
    fd
    fzf
    ripgrep
    tealdeer
    bottom
    macchina
  ];

  environment.defaultPackages = [];

  nix = {
    daemonCPUSchedPolicy = "idle";
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs = {
    config.allowUnsupportedSystem = true;
    crossSystem.system = "aarch64-linux";
  };
  nixpkgs.overlays = [
    # https://discourse.nixos.org/t/does-pkgs-linuxpackages-rpi3-build-all-required-kernel-modules/42509
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  system.stateVersion = "25.11";

  services.openssh = {
    enable = true;
    startWhenNeeded = false;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # NOTE: fix setgroups crash on arm
  systemd.services.avahi-daemon.serviceConfig.SystemCallFilter = lib.mkForce [];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set fish_greeting

    set temp (cat /sys/devices/virtual/thermal/thermal_zone0/temp 2>/dev/null)
    test -n "$temp"; and echo "🌡️ "(math -s 0 "$temp / 1000")"C"
  '';

  users.mutableUsers = false;
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir ksevelyar@gmail.com"
      ];
      hashedPasswordFile = config.age.secrets.root-password.path;
    };

    ksevelyar = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir ksevelyar@gmail.com"
      ];
      hashedPasswordFile = config.age.secrets.root-password.path;

      extraGroups = ["wheel"];
    };
  };

  networking = {
    usePredictableInterfaceNames = false;
    hostName = "shodan";

    useDHCP = false;
    interfaces.wlan0.useDHCP = true;

    wireless = {
      enable = true;
      secretsFile = config.age.secrets.wifi.path;
      networks."skynet-2" = {
        pskRaw = "ext:SKYNET_2";
      };
    };
  };

  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [pkgs.raspberrypiWirelessFirmware];
    i2c.enable = true;
    deviceTree = {
      enable = true;
      kernelPackage = pkgs.linuxKernel.packages.linux_rpi3.kernel;
      filter = "*2837*";

      overlays = [
        {
          name = "enable-i2c";
          dtsFile = ./shodan/i2c.dts;
        }
        {
          name = "pwm-2chan";
          dtsFile = ./shodan/pwm.dts;
        }
        {
          name = "spi1-2cs";
          dtsFile = ./shodan/spi.dts;
        }
      ];
    };
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  sdImage = {
    compressImage = false;
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        start_x=0
        gpu_mem=16
        hdmi_group=2
        hdmi_mode=8

        [pi02]
        kernel=u-boot-rpi3.bin

        [all]
        arm_64bit=1
        enable_uart=1
        avoid_warnings=1
      '';
    in ''
      # firmware blobs
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/start*.elf firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup*.dat firmware/

      # config
      cp ${configTxt} firmware/config.txt

      # u-boot
      cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin

      # device tree
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-zero-2-w.dtb firmware/
    '';

    populateRootCommands = ''
      mkdir -p ./files/root/.ssh
      chmod 700 ./files/root/.ssh
      cp "${agenixKey}" ./files/root/.ssh/host-agenix-key
      chmod 600 ./files/root/.ssh/host-agenix-key

      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
