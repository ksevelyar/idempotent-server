{
  modulesPath,
  pkgs,
  config,
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
    ../services/net/nginx.nix
    ../services/net/sshd.nix
    ../services/databases/postgresql.nix
  ];

  age.secrets.db-habits = {
    file = ../secrets/db-habits.age;
    owner = "postgres";
  };

  age.secrets.habits-phoenix = {
    file = ../secrets/habits-phoenix.age;
  };

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
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

  # sudo ip route add 10.0.0.1 dev ens3
  # sudo ip address add 212.109.193.139/32 dev ens3
  # sudo ip route add default via 10.0.0.1 dev ens3
  networking = {
    useDHCP = false;
    hostName = "cluster-0";
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "212.109.193.139";
            prefixLength = 32;
          }
        ];

        ipv4.routes = [
          {
            address = "10.0.0.1";
            prefixLength = 32;
          }
        ];
      };
    };

    nameservers = ["8.8.8.8" "8.8.4.4"];
    defaultGateway = "10.0.0.1";
  };

  system.stateVersion = "24.05";
  documentation.nixos.enable = false;

  # apps
  services.nginx.virtualHosts."api.habits.rusty-cluster.net" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://localhost:4000";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  services.habits-phoenix.enable = true;

  systemd.services.habits-phoenix = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.habits-phoenix.path;
    };
  };
}
