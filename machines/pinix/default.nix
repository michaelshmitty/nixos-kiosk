{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./kiosk.nix
  ];

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    consoleLogLevel = 0;
    kernelParams = ["quiet"];
    initrd.verbose = false;
    plymouth.enable = true;
  };

  networking = {
    usePredictableInterfaceNames = false;
    hostName = "kiosk-pi";
    wireless = {
      enable = true;
      interfaces = ["wlan0"];
      networks = {
        "SSID" = {
          pskRaw = "CHANGEME";
        };
      };
    };
    interfaces.wlan0.ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = ["192.168.1.1"];
  };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3lock
        i3status
      ];
    };

    # NOTE: This kiosk uses a display in portrait mode
    xrandrHeads = [
      {
        monitorConfig = ''Option "Rotate" "left"'';
        output = "HDMI-1";
      }
    ];
  };

  services.displayManager.defaultSession = "none+i3";
  services.displayManager.autoLogin = {
    enable = true;
    user = "kioskuser";
  };

  users = {
    mutableUsers = true;
    users = {
      kioskuser = {
        isNormalUser = true;
        home = "/home/kioskuser";
        extraGroups = ["video" "input"];
        description = "Kiosk user";
        openssh.authorizedKeys.keys = [
          "YOUR PUBLIC SSH KEY"
        ];
      };

      root = {
        openssh.authorizedKeys.keys = [
          "YOUR PUBLIC SSH KEY"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    chromium
    htop
    unclutter
  ];

  system.stateVersion = "24.11";
}
