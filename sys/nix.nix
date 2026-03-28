{pkgs, ...}: {
  nix = {
    package = pkgs.nixVersions.stable;

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;

    settings = {
      experimental-features = ["nix-command" "flakes"];

      # NOTE: fail curl after 5 seconds, rebuild from source if fetching cache fails
      connect-timeout = 5;
      stalled-download-timeout = 5;
      fallback = true;

      substituters = [
        "https://idempotent-server.cachix.org"
      ];
      trusted-public-keys = [
        "idempotent-server.cachix.org-1:0QGOQVYN9UD8Oeb32IcipuxNuM7fIo/+aw/ZDOB5Tos="
      ];
    };
  };
}
