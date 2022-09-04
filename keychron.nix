{ config, pkgs, ... }:

let
  keychron-set-key = pkgs.writeShellScriptBin "keychron-set-key" ''
    echo 0 > /sys/module/hid_apple/parameters/fnmode
  '';
in {
  environment.systemPackages = [ keychron-set-key ];

  boot.initrd.services.udev.rules = ''
  ACTION=="add", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="0250", RUN+="/run/current-system/sw/bin/keychron-set-key"
  '';
}

