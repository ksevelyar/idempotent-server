{config, ...}: {
  age.secrets.xray = {
    file = ../../secrets/xray.age;
  };

  services.xray = {
    enable = true;
    settingsFile = config.age.secrets.xray.path;
  };
}
