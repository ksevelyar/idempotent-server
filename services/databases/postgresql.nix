{pkgs, ...}: {
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_16;

    ensureUsers = [
      {
        name = "habits";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "habits"
    ];

    identMap = ''
      superuser_map      root      postgres
      superuser_map      postgres  postgres

      superuser_map      /^(.*)$   \1
    '';
  };

  services.postgresqlBackup = {
    enable = true;

    databases = ["habits"];
  };
}
