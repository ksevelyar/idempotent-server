1. Create a VPS with the latest Ubuntu release. Note the IP address and gateway assigned by the provider.
2. Update the IP address and gateway in `hosts/installer.nix` and `hosts/cluster-1.nix`.
3. Build the installer ISO:

   `nix build .#nixosConfigurations.installer.config.system.build.isoImage`

4. Mount the installer ISO on the VPS.
5. Install the system without secrets:

   `nixos-anywhere -- --flake .#cluster-1 --target-host root@<new-ip> --ssh-port 9922`

6. Unmount the ISO and reboot the VPS.
7. Get the new host’s SSH public key:

   `cat /etc/ssh/ssh_host_ed25519_key.pub`

8. Replace the host public key in `secrets.nix`.
9. Run `agenix --rekey`.
10. Deploy the configuration with secrets:

    `nixos-rebuild switch --flake .#cluster-1 --target-host root@cluster-1`

11. Restart Xray:

    `ssh root@cluster-1 sudo systemctl restart xray.service`
