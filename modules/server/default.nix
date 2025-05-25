{
  inputs,
  config,
  pkgs,
  ...
}: {
  # See https://linux.die.net/man/8/pam_ssh_agent_auth
  security.pam.sshAgentAuth.enable = true;

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "05:00";
    };
    flake = "git+ssh://user@git.example.com/user/nixos-config.git";
  };

  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    molly-guard
    vim
  ];

  boot.tmp.cleanOnBoot = true;

  # Use more aggressive OOM
  services.earlyoom = {
    enable = true;
  };

  # Limit journal size
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  # I18n
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking.firewall.logRefusedConnections = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "10m";
  };
}
