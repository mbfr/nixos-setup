{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    systemd-run --user --scope --slice-inherit \
      --setenv=__NV_PRIME_RENDER_OFFLOAD=1 \
      --setenv=__NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 \
      --setenv=__GLX_VENDOR_LIBRARY_NAME=nvidia \
      --setenv=__VK_LAYER_NV_optimus=NVIDIA_only \
      "$@"
  '';
in {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ nvidia-offload ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # 'stable', for new GPUs
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # Old devices
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
   intelBusId = "PCI:00:02:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:02:00:0";
  };
}
