# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # intellij and gnome extension from specific version
      ./unstable-packages.nix
      # vim config / vimrc
      ./vim.nix
      # Generated during setup for zfs
      ./zfs.nix
      # Uncomment/modify to enable nvidia drivers/prime
      # ./nvidia-offload.nix
      # uncomment/modify to enable falcon scanner
      # ./falcon.nix
      # Fixes keychrom keys
      ./keychron.nix
    ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  environment.sessionVariables = rec {
       SDL_VIDEODRIVER = "wayland";
       QT_QPA_PLATFORM = "wayland";
       _JAVA_AWT_WM_NONREPARENTING = "1";
       NIXOS_OZONE_WL = "1";
       MOZ_ENABLE_WAYLAND = "1";

       GDK_BACKEND = "wayland,x11";

       XDG_BIN_HOME    = "\${HOME}/.local/bin";
       XDG_DATA_HOME   = "\${HOME}/.local/share";
   };

  hardware.bluetooth.enable = true;

  networking.nameservers = [ "1.1.1.1" "4.4.4.4" "8.8.8.8" "9.9.9.9" "2001:4860:4860::8888" "2001:4860:4860::4444" ];
  networking.networkmanager.dns = "none";
  services.resolved.enable = false;

  networking.hostName = "nixos";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  programs.dconf.enable = true;
  services.xserver.desktopManager.gnome = {
   enable = true;

   # Enable fractional scaling
   extraGSettingsOverrides = ''
     [org.gnome.mutter]
     experimental-features=['scale-monitor-framebuffer']
   '';
   extraGSettingsOverridePackages = with pkgs.gnome; [ mutter ];
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # virtualisation.libvirtd.enable = true;

  # Commented out in favour of rootless docker below
  # virtualisation.docker.enable = true;
  # virtualisation.docker.enableOnBoot = false;
  # virtualisation.docker.daemon.settings = { dns = [ "1.1.1.1" "4.4.4.4" "8.8.8.8" "9.9.9.9" "2001:4860:4860::8888" "2001:4860:4860::4444" ]; };

  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
  virtualisation.docker.rootless.daemon.settings = { dns = [ "1.1.1.1" "4.4.4.4" "8.8.8.8" "9.9.9.9" "2001:4860:4860::8888" "2001:4860:4860::4444" ]; };

  # Start gpg agent at boot with yubikey support (if you want)
  programs.gnupg.dirmngr.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.gnupg.agent.pinentryFlavor = "gnome3";
  # hardware.gpgSmartcards.enable = true;
  # services.yubikey-agent.enable = true;

  security.pam.services.michael.enableGnomeKeyring = true;

  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      docker-compose
      imagemagick
      bc
      git
      vlc
      tmux
      htop
      fd
      bat
      rcm
      sublime3
      firefox
      git-lfs
      google-chrome
      alacritty
      pinentry-gnome
      gnome.gnome-tweaks
      #gnomeExtensions.vertical-overview
      gnomeExtensions.dash-to-panel
      nixos-option
      ripgrep-all
      gnupg
      nodejs-16_x
      rustup

      bazelisk
      maven
      #go_1_18 # Use gvm?
      golangci-lint
      google-cloud-sdk
      kubectl
      kustomize
      kubectx
      bazel-buildtools
      sublime3

      (python310.withPackages(ps: [
        ps.mypy
        ps.isort
        ps.black
        ps.python-lsp-server
      ]))

      gcc
    ];

  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    powerline-go
    exa
    rng-tools

    unzip
    bash-completion
    nix-bash-completions
    fzf
    delta
    ripgrep
    curl
    killall
    file

    pciutils
    coreutils
    binutils
    gnumake
    bison
  ];

  fonts.fonts = with pkgs; [
    ibm-plex
    terminus_font
    terminus_font_ttf
    iosevka
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  system.autoUpgrade.enable = false;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-22.05;
  system.autoUpgrade.allowReboot = false;
  
  # Remove useless gnome packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-console
    gnome-tour
    gnome-connections
    gnome-online-accounts
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    # gedit # text editor
    epiphany # web browser
    geary # email reader
    # evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-weather
    gnome-maps
    gnome-contacts
    gnome-calendar
    gnome-clocks
  ]);

}
