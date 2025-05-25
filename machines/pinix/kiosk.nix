{
  config,
  pkgs,
  lib,
  ...
}: let
  kiosk-command = pkgs.writeShellScriptBin "kiosk" ''
    # Disable screen blanking and standby
    ${pkgs.xorg.xset}/bin/xset s noblank
    ${pkgs.xorg.xset}/bin/xset s off
    ${pkgs.xorg.xset}/bin/xset -dpms

    # Hide mouse
    ${pkgs.unclutter}/bin/unclutter -idle 0.5 -root &

    ${pkgs.chromium}/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk https://example.com/dashboard
  '';
in {
  environment.systemPackages = [kiosk-command];
}
