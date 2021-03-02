{ pkgs, lib, ... }:

let
  categories = [
    "actions"
    "animations"
    "apps"
    "categories"
    "devices"
    "emblems"
    "emotes"
    "filesystem"
    "intl"
    "legacy"
    "mimetypes"
    "places"
    "status"
    "stock"
  ];
  q = s: ''"${s}"'';
  iconSize = "96";
  iconBasePaths = [
    "${pkgs.gnome3.adwaita-icon-theme}/share/icons/Adwaita/48x48"
    "${pkgs.gnome3.adwaita-icon-theme}/share/icons/Adwaita/${iconSize}x${iconSize}"
  ];
  iconPath = lib.concatStringsSep ":" (lib.concatMap (basePath:
    map (category: "${basePath}/${category}") categories) iconBasePaths);
  defaultUrgency = {
    background = q "#aaaaaa";
    foreground = q "#222222";
    timeout = "60";
  };
  configFile = pkgs.writeText "dunstrc" (lib.generators.toINI {} {
    global = {
      markup = "full";
      font = "SauceCodePro Nerd Font 16";
      format = ''"<i>%a</i>\n<b>%s</b>\n%b"'';
      geometry = "600x5-20+45";
      shrink = "false";
      icon_position = "left";
      min_icon_size = "0";
      max_icon_size = iconSize;
      frame_width = "1";
      frame_color = q "#aaaaaa";
      separator_color = "auto";
      word_wrap = "yes";
      show_indicators = "yes";
      icon_path = iconPath;
      mouse_left_click = "do_action, close_current";
      mouse_middle_click = "close_current";
      mouse_right_click = "close_all";
      separator_height = "5";
      idle_timeout = "60";
    };
    urgency_low = defaultUrgency;
    urgency_normal = defaultUrgency;
    urgency_critical = defaultUrgency;
  });
in
{
  systemd = {
    user.services.dunst = {
      enable = true;
      serviceConfig = {
        ExecStart = [
          ""
          "${pkgs.dunst}/bin/dunst -config ${configFile}"
        ];
      };
    };

    packages = [ pkgs.dunst ];
  };

  services.dbus.packages = [ pkgs.dunst ];

  environment.systemPackages = [ pkgs.dunst ];
}
