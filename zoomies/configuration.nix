

# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.framework-11th-gen-intel

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Import home-manager's configuration
    ./home-manager.nix

    # Import disko's configuration
    ./disk-config.nix

    ./pam.nix

    # tuigreet
    ./greetd.nix
  ];

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    optimise.automatic = true;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.wget
    pkgs.dogdns
    inputs.agenix.packages.x86_64-linux.default
    pkgs.wpa_supplicant_gui
    pkgs.overskride
    pkgs.alacritty
    pkgs.zsh
    pkgs.starship
    pkgs.gh
    pkgs.wluma
    pkgs.brightnessctl
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    pkgs.mako
    pkgs.unstable.hyprpicker
    pkgs.notify-desktop
    pkgs.bc
    pkgs.wl-clipboard
    pkgs.psmisc
    pkgs.jq
    pkgs.playerctl
    pkgs.firefox
    pkgs.nautilus
    pkgs.totem
    pkgs.loupe
    pkgs.simple-scan
    pkgs.file-roller
    pkgs.polkit_gnome
    pkgs.fprintd
    pkgs.gitMinimal
    pkgs.udiskie
    pkgs.neofetch
    pkgs.cava
    pkgs.go
    pkgs.unstable.bun
    pkgs.pitivi
    pkgs.lazygit
    pkgs.video-trimmer
    pkgs.ffmpeg
    pkgs.openssl
    pkgs.glow
    pkgs.gnome-online-accounts
    pkgs.gnome-online-accounts-gtk
    (pkgs.chromium.override { enableWideVine = true; })
    pkgs.python3
    pkgs.inkscape
    pkgs.jdk23
    pkgs.unstable.zed-editor
    pkgs.gnome-disk-utility
    pkgs.unstable.amberol
    pkgs.gcc
    pkgs.love
    pkgs.unstable.aseprite
    pkgs.audacity
    pkgs.imagemagick
    pkgs.rustc
    pkgs.cargo
    inputs.ghostty.packages.x86_64-linux.default
    pkgs.baobab
    pkgs.nix-prefetch
    pkgs.hyprpaper
    pkgs.lxde.lxsession
    pkgs.exiftool
    pkgs.zenity
    pkgs.libreoffice
    pkgs.font-manager
    pkgs.cmake
    pkgs.wl-screenrec
    pkgs.libnotify
    pkgs.coreutils
    pkgs.grim
    pkgs.jq
    pkgs.slurp
    pkgs.xdg-user-dirs
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/nat/etc/nixos";
  };

  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
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
  };

  fonts.packages = with pkgs; [
    nerdfonts
    fira
    comic-neue
  ];

  # import the secret
  age.identityPaths = [ "/home/nat/.ssh/nat_id_ed25519" "/etc/ssh/nat_id_ed25519" "/mnt/etc/ssh/nat_id_ed25519" ];
  age.secrets = {
    wifi = {
      file = ../secrets/wifi.age;
      owner = "nat";
    };
    resend = {
      file = ../secrets/resend.age;
      owner = "nat";
    };
    wakatime = {
      file = ../secrets/wakatime.age;
      path = "/home/nat/.wakatime.cfg";
      owner = "nat";
    };
  };

  environment.sessionVariables = {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    NIXOS_OZONE_WL = "1";
  };

  # setup the network
  networking = {
    hostName = "zoomies";
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    wireless = {
      secretsFile = config.age.secrets.wifi.path;
      userControlled.enable = true;
      enable = true;
      networks = {
        "SAAC Sanctuary".pskRaw = "ext:psk_church";
        "Yowzaford".pskRaw = "ext:psk_rhoda";
      };
    };
  };

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    nat = {
      # You can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "lolzthisaintsecure!";
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEBN1C/1EatKLnv84NiVSc7aEDirVfKyfKDmSf1PP5r nat@zoomies"
      ];
      extraGroups = ["wheel" "networkmanager" "audio" "video" "docker" "plugdev" "input" "dialout" "docker"];
    };
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEBN1C/1EatKLnv84NiVSc7aEDirVfKyfKDmSf1PP5r nat@zoomies"
    ];
  };

  programs.hyprland.enable = true;
  services.hypridle.enable = true;

  programs.xwayland.enable = lib.mkForce true;

  virtualisation.docker.enable = true;

  services.udev.packages = [ pkgs.via ];

  security.polkit.enable = true;

  # enable cups
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # enable bluetooth
  hardware.bluetooth.enable = true;

  # enable pipewire
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey=ignore
    HandlePowerKeyLongPress=poweroff
  '';

  # Requires at least 5.16 for working wi-fi and bluetooth.
  # https://community.frame.work/t/using-the-ax210-with-linux-on-the-framework-laptop/1844/89
  boot = {
    kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "5.16") (lib.mkDefault pkgs.linuxPackages_latest);
    loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
