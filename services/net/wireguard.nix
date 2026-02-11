{config, ...}: {
  networking.firewall.allowedUDPPorts = [51821];

  age.secrets = {
    wg-server-private.file = ../../secrets/wg.age;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.workstation = true;
    reflector = true;
  };

  networking.wireguard.interfaces.skynet = {
    ips = ["10.10.10.1/24"];
    listenPort = 51821;
    privateKeyFile = config.age.secrets.wg-server-private.path;

    peers = [
      {
        publicKey = "B7CWzOkwXw661/rtJa9GBddGon6ldOVEF40+O6pJbDY=";
        allowedIPs = ["10.10.10.2/32"];
        persistentKeepalive = 25;
      }
    ];
  };
}
