# NIXOS CONFIGURATION

{ config, lib, pkgs, ... }:

{
  imports =
    [       
      ./hardware-configuration.nix
      ./neovim.nix
    ];

  # Low level stuff.
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
	enable = true;
	device = "nodev";
	efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;

  hardware.cpu.intel.updateMicrocode = true;

  ###############
  # ENVIRONMENT #
  ###############
  networking.networkmanager.enable = true;

  networking.hostName = "tsuyu";

  users.users.haru = {
      extraGroups = [ "wheel" "libvirtd" ];
      isNormalUser = true;
  };

  time.timeZone = "Asia/Jakarta";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    
    wireplumber = {
      enable = true;
      extraConfig = {
        "10-disable-suspend" = {
          "monitor.alsa.rules" = [
            {
               matches = [{ "node.name" = "~alsa_input.*"; } { "node.name"  = "~alsa_output.*"; }];
               actions = { update-props = { "session.suspend-timeout-seconds" = 0; }; };
            }
          ];
        };
      };
    };

  };
    
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.displayManager.ly.enable = true;

  programs.sway = {
    enable = true;
    xwayland.enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    file-roller
    xarchiver
    waybar
    swaybg
    swayidle
    swaylock
    waybar
    pavucontrol
    networkmanagerapplet
    ristretto
    fuzzel
    polkit_gnome
    distrobox
    qemu
    dnsmasq
    libnotify
    mako
    orchis-theme
    google-cursor
    nwg-look
    grim
    slurp
    wlogout
    autotiling
    btop
    foot
    tmux
    emote
      
    (papirus-icon-theme.override {
      color = "black";
    })
     
    vim-full
    wl-clipboard
    rustc
    cargo
    rust-analyzer
    clang
    clang-tools
    python315
    pyright
    lua
    lua-language-server
    bash-language-server
    nil
    git 
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  programs.gnupg.agent = {
    enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [];
    allowedUDPPortRanges = [];
    trustedInterfaces = [ "virbr0" ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
    ];
  };

  services = {
    gvfs.enable = true;
    tumbler.enable = true;
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-tokyonight
        kdePackages.fcitx5-configtool
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  zramSwap = {
    enable = true;
    priority = 80;
    algorithm = "lz4";
    memoryPercent = 50;
  };

 ######################
 # END OF ENVIRONMENT #
 ######################

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
 
  # DONT CHANGE THIS UNLESS YOU KNOW WHAT WILL DO!
  system.stateVersion = "26.05"; # Did you read the comment?

}

