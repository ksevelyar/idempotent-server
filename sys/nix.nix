{pkgs, ...}: {
  nix = {
    package = pkgs.nixVersions.stable;

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;

    settings = {
      experimental-features = ["nix-command" "flakes"];

      # NOTE: fail curl after 15 seconds, rebuild from source if fetching cache fails
      connect-timeout = 15;
      stalled-download-timeout = 15;
      fallback = true;

      extra-substituters = [
        "https://idempotent-server.cachix.org"
      ];
      extra-trusted-public-keys = [
        "idempotent-server.cachix.org-1:0QGOQVYN9UD8Oeb32IcipuxNuM7fIo/+aw/ZDOB5Tos="
      ];
    };
  };
}
