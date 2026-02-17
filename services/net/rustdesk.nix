{pkgs, ...}: {
  environment.systemPackages = [pkgs.rustdesk-server];

  networking.firewall.allowedTCPPorts = [21115 21116 21117];
  networking.firewall.allowedUDPPorts = [21116];

  systemd.services.hbbs = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    serviceConfig = {
      StateDirectory = "rustdesk";
      WorkingDirectory = "/var/lib/rustdesk";
      Restart = "always";
      RestartSec = 2;
      ExecStart = "${pkgs.rustdesk-server}/bin/hbbs -r rusty-cluster.net:21117";
    };
  };

  systemd.services.hbbr = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    serviceConfig = {
      StateDirectory = "rustdesk";
      WorkingDirectory = "/var/lib/rustdesk";
      Restart = "always";
      RestartSec = 2;
      ExecStart = "${pkgs.rustdesk-server}/bin/hbbr";
    };
  };
}
