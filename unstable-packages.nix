{ config, pkgs, ... }:
let
  channelRelease = "nixos-22.11pre404023.38e16b192af";  # 2022-08
  channelName = "unstable";
  url = "https://releases.nixos.org/nixos/${channelName}/${channelRelease}/nixexprs.tar.xz";
  sha256 = "0x6ar7pazxwkicj8gyvkdgr7b84qa0p4n9rqqkxc2gny64zzlgna";

  pinnedNixpkgs = import (builtins.fetchTarball {
    inherit url sha256;
  })
  { config = config.nixpkgs.config; };

  baseconfig = { allowUnfree = true; };
  #unstable = import <nixos-unstable> { config = baseconfig; };
in {
  environment.systemPackages = with pkgs; [
      pinnedNixpkgs.jetbrains.idea-ultimate
      pinnedNixpkgs.gnomeExtensions.vertical-workspaces
  ];
}
