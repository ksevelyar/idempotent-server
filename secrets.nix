let
  ksevelyar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir";
  users = [ksevelyar];

  # cat /etc/ssh/ssh_host_ed25519_key.pub
  cluster-0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl7A0q+qLbbQ8rdlX2XyHQ0xM9PqOa7i26HoMw8q9BS";
  cluster-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHHfAndS9jZNcbGpPtUTXOhyE+R8W1WrdCfpO5KM8zbR root@cluster-1";
  shodan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzl16KXcQuM5E+EXBfCL5l4CT/HlxQnzi2D42VecyHb guest";
  systems = [cluster-0 cluster-1 shodan];
in {
  "secrets/murmur.age".publicKeys = users ++ systems;
  "secrets/db-habits.age".publicKeys = users ++ systems;
  "secrets/habits-phoenix.age".publicKeys = users ++ systems;
  "secrets/buzz-phoenix.age".publicKeys = users ++ systems;
  "secrets/wg.age".publicKeys = users ++ systems;
  "secrets/amnezia.age".publicKeys = users ++ systems;
  "secrets/cluster-1-xray.age".publicKeys = users ++ systems;
  "secrets/root-password.age".publicKeys = users ++ systems;

  "secrets/wifi.age".publicKeys = [shodan ksevelyar];
}
