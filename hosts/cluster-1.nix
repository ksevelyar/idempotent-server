{
  modulesPath,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../sys/tty.nix
    ../sys/aliases.nix
    ../sys/nix.nix
    ../sys/cache.nix

    ../services/journald.nix
    ../services/net/sshd.nix
  ];

  documentation.nixos.enable = false;
  documentation.enable = false;
  documentation.man.generateCaches = false;

  age.secrets.cluster-1-xray.file = ../secrets/cluster-1-xray.age;
  networking.firewall.allowedTCPPorts = [443];
  services.xray = {
    enable = true;
    settingsFile = config.age.secrets.cluster-1-xray.path;
  };

  # FIXME
  age.secrets.amnezia.file = ../secrets/amnezia.age;
  networking.wireguard.enable = false;
  networking.wireguard.interfaces.amnezia = {
    type = "amneziawg";

    ips = ["10.0.0.1/24"];
    listenPort = 1984;

    privateKeyFile = config.age.secrets.amnezia.path;

    extraOptions = {
      Jc = 5;
      Jmin = 10;
      Jmax = 42;
      S1 = 60;
      S2 = 90;
      H4 = 12345;
    };

    peers = [
      {
        publicKey = "CLIENT_PUBLIC_KEY_HERE";
        allowedIPs = ["10.0.0.2/32"];
        persistentKeepalive = 25;
      }
    ];
  };
  networking.firewall.allowedUDPPorts = [1984];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    xray
    zellij
    neovim-unwrapped
    ripgrep
    fzf
    gitMinimal
    curl
    curlie
    bottom
    ncdu
    rsync
    zoxide
    bat
    tealdeer
    tcpdump
  ];

  users.users.ksevelyar = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir ksevelyar@gmail.com"
    ];

    initialHashedPassword = "$y$j9T$H52H7Xta1XhESYb2vE07C/$diE1gF.OIIOCBo6jzKATasjiKwXKhbLCEWmJd.PBZM1";
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir ksevelyar@gmail.com"
      ];
    };
  };
  users.defaultUserShell = pkgs.fish;

  # ip route
  networking = {
    useDHCP = false;
    hostName = "cluster-1";
    interfaces = {
      eth0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            # ip a
            address = "194.154.28.217";
            prefixLength = 24;
          }
        ];
      };
    };

    # ip route | grep default
    defaultGateway = "194.154.28.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  system.stateVersion = "24.05";

  disko.devices.disk.main = {
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          name = "boot";
          size = "1M";
          type = "EF02";
        };
        ESP = {
          type = "EF00";
          size = "500M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
