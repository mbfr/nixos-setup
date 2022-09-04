# Installing

Sets up a gnome-based desktop with
- neovim with my vim config + nvim-treesitter
- intellij tied to 2022.2 to prevent annoying autoupgrades
- wayland + nvidia drivers
- rootless docker
- falcon sensor
- encrypted root with zfs
- no annoying extra gnome programs like gnome-weather

Before starting:

- https://nixos.wiki/wiki/Nvidia If you want to set up the nvidia nonfree drivers - read this, and edit the nvidia-offload.nix file
- You probably want to look through all the settings and change things, particularly the hostname, timezone, etc.

## Install

1. Boot nixos live installer and open a root terminal

1. `export EDITOR=vim` (replaces nano, useful for editing commands later on)

1. Open https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/1-preparation.html in browser

1. Copy paste all the instructions after setting the appropriate disk paths UNTIL setting the root password

   Do not pass the 'mirror' options when creating the pools

   If this fails due to pool errors (eg, if you tried this before), do `zpool import -f <pool>` then `zpool destroy <pool>`

1. Put a '}' at the end of /mnt/etc/nixos/zfs.nix (normally put there by the instructions, but we skipped the last few steps)

1. Copy files from this repo into /mnt/etc/nixos

        rsync -av /path/to/repo/*.nix /mnt/etc/nixos/

1. Run nixos install command as specified in the zfs installation instructions

   this might take ~20 minutes

1. Change password

        cd /mnt
        nixos-enter
        passwd michael

1. Exit chroot and run

        umount -Rl /mnt
        sync
        zpool export -a

1. Set swap device as actual swap `mkswap <swap-partition>`

## Enabling falcon

Do this post-installation/reboot

1. Move falcon deb to /opt/CrowdStrike (get from https://forgerock.slack.com/archives/CAVDE5K5M/p1660576127565849)

1. Edit configuration.nix to include falcon.nix

1. Set cid properly in falcon.nix

### TODO

Save falcon cid in nix store with https://github.com/Mic92/sops-nix or something like that

Swap isnt automounted