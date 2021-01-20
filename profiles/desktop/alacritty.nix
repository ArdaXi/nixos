{ config, pkgs, ... }:

let
  defaultFont = {
    family = "SauceCodePro Nerd Font";
  };
  zero = {
    x = 0;
    y = 0;
  };
in
{
  environment.etc."xdg/alacritty/alacritty.yml".text = builtins.toJSON {
    env.TERM = "xterm-256color";

    window = {
      dimensions = {
        columns = 0;
        lines = 0;
      };

      padding = {
        x = 2;
        y = 2;
      };

      decorations = "none";
      dynamic_title = true;
    };

    draw_bold_text_with_bright_colors = true;

    font = {
      normal = defaultFont;
      bold = defaultFont;
      italic = defaultFont;

      size = 15.5;

      offset = zero;
      glyph_offset = zero;
    };

    colors = {
      primary = {
        background = "0x002b36";
        foreground = "0x839496";
      };

      normal = {
        black = "0x073642";
        red = "0xdc322f";
        green = "0x859900";
        yellow = "0xb58900";
        blue = "0x268bd2";
        magenta = "0xd33682";
        cyan = "0x2aa198";
        white = "0xeee8d5";
      };

      bright = {
        black = "0x002b36";
        red = "0xcb4b16";
        green = "0x586e75";
        yellow = "0x657b83";
        blue = "0x839496";
        magenta = "0x6c71c4";
        cyan = "0x93a1a1";
        white = "0xfdf6e3";
      };
    };

    bell = {
      animation = "EaseOutExpo";
      duration = 0;
    };

    background_opacity = 1.0;

    mouse_bindings = [
      { mouse = "Middle"; action = "PasteSelection"; }
    ];

    mouse = {
      double_click.threshold = 300;
      triple_click.threshold = 300;
      hide_when_typing = false;
    };

    selection.semantic_escape_chars = ",│`|:\"' ()[]{}<>";

    cursor.style = "Block";

    live_config_reload = true;
  };
}
