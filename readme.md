## Release
```
nix flake update habits-vue
nix flake update habits-axum
```

```
nixos-rebuild switch --flake .#cluster-0 --target-host root@cluster-0
```

## Secrets
```
cd secrets
nix run github:ryantm/agenix -- -e habits-axum.age
```

## Dump db
```
ssh cluster-0
sudo -u postgres psql -U habits -d habits -f /tmp/habits_dev_dump.sql
```
