{
  services.jitsi-meet = {
    enable = true;
    hostName = "rusty-cluster.net";
    prosody.lockdown = true;
    config = {
      enableWelcomePage = false;
      prejoinPageEnabled = true;
    };
    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
    };
  };
  services.jitsi-videobridge.openFirewall = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8792"
  ];
}
