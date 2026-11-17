{
  modulesPath,
  pkgs,
  config,
  ...
}: let
  update_duckdns = pkgs.writeShellApplication {
    name = "update-duckdns";
    runtimeInputs = [pkgs.curl];
    text = ''
      duckdns_token="$(<"${config.age.secrets.duckdns.path}")"

      printf '%s' "$duckdns_token" | curl \
        --fail \
        --silent \
        --show-error \
        --get \
        --data-urlencode "domains=ducks-never-forgive" \
        --data-urlencode "token@-" \
        --data-urlencode "ip=" \
        "https://www.duckdns.org/update"
    '';
  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../sys/tty.nix
    ../sys/aliases.nix
    ../sys/nix.nix

    ../services/journald.nix
    ../services/net/sshd.nix
  ];

  documentation.nixos.enable = false;
  documentation.enable = false;
  documentation.man.cache.enable = false;

  age.secrets.cluster-1-xray.file = ../secrets/cluster-1-xray.age;
  age.secrets.duckdns = {
    file = ../secrets/duckdns.age;
    mode = "0400";
  };

  networking.firewall.allowedTCPPorts = [1443 443];
  services.xray = {
    enable = true;
    settingsFile = config.age.secrets.cluster-1-xray.path;
  };

  systemd.services.xray = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig.ExecStartPre = ["+${update_duckdns}/bin/update-duckdns"];
  };

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
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "89.124.88.77";
            prefixLength = 24;
          }
        ];
      };
    };

    # ip route | grep default
    defaultGateway = "89.124.88.1";
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
