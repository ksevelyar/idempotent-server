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
    ensureDatabases = ["habits"];

    authentication = ''
      local   all             postgres                                peer

      local   habits          habits                                  md5
      host    habits          habits                127.0.0.1/32      md5
    '';
  };

  services.postgresqlBackup = {
    enable = true;

    databases = ["habits"];
  };
}
