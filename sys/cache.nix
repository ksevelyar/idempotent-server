{
  config,
  pkgs,
  ...
}: {
  nix = {
    settings = {
      substituters = [
        "https://idempotent-server.cachix.org"
      ];
      trusted-public-keys = [
        "idempotent-server.cachix.org-1:0QGOQVYN9UD8Oeb32IcipuxNuM7fIo/+aw/ZDOB5Tos="
      ];
    };
  };
}
