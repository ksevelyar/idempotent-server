## Release
```
nix flake update habits-vue
nix flake update habits-phoenix
```

```
nixos-rebuild switch --flake .#cluster-0 --target-host root@cluster-0
```

## Secrets
```
cd secrets
nix run github:ryantm/agenix -- -e habits-phoenix.age
```

## Iex
```
ssh root@cluster-0
set -a
. /run/agenix.d/37/habits-phoenix

/nix/store/*habits-phoenix-0.1.0/bin/habits remote
```

## Dump db
```
ssh cluster-0
sudo -u postgres psql -U habits -d habits -f /tmp/habits_dev_dump.sql
```
