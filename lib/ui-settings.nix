let
  mkUiSettings =
    {
      graphical ? false,
      wsl ? false,
      batteryPath ? null,
      temperaturePath ? null,
      networkInterface ? null,
      hyprlockWallpaper ? null,
      hyprlockProfileImage ? null,
      hyprlandMonitors ? [ ",preferred,auto,auto" ],
      hardwareVideoDecode ? false,
    }:
    {
      inherit
        graphical
        wsl
        batteryPath
        temperaturePath
        networkInterface
        hyprlockWallpaper
        hyprlockProfileImage
        hyprlandMonitors
        hardwareVideoDecode
        ;
    };
in
{
  inherit mkUiSettings;

  laptop = mkUiSettings {
    graphical = true;
    batteryPath = "/sys/class/power_supply/BAT1/capacity";
    temperaturePath = "/sys/class/hwmon/hwmon5/temp1_input";
    networkInterface = "wlp*";
    hyprlockWallpaper = "/home/alex/Pictures/wallpapers/current";
    hyprlockProfileImage = "/home/alex/Pictures/profile.png";
    hardwareVideoDecode = true;
    hyprlandMonitors = [
      ",preferred,auto,auto"
      "eDP-1,2256x1504@60,0x0,1.175"
    ];
  };

  desktop = mkUiSettings { graphical = true; };

  wsl = mkUiSettings {
    graphical = false;
    wsl = true;
  };
}
