let
  ksevelyar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrgLo+NfYI06fdY1BamC5o2tNeRlw1ZuPAkyy41w0Ir";
  users = [ksevelyar];

  # ssh-keyscan -p 9922 localhost
  cluster-0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl7A0q+qLbbQ8rdlX2XyHQ0xM9PqOa7i26HoMw8q9BS";
  systems = [cluster-0];
in {
  "secrets/murmur.age".publicKeys = users ++ systems;
  "secrets/db-habits.age".publicKeys = users ++ systems;
  "secrets/habits-phoenix.age".publicKeys = users ++ systems;
  "secrets/buzz-phoenix.age".publicKeys = users ++ systems;
  "secrets/wg.age".publicKeys = users ++ systems;
}
