# Catppuccin themes: Frappe (dark) + Latte (light) with Lavender accent
{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;

  # Helpers for concise color definitions
  rgb = r: g: b: {
    red = r;
    green = g;
    blue = b;
  };
  rgba = r: g: b: a: {
    red = r;
    green = g;
    blue = b;
    alpha = a;
  };

  cornerRadii = {
    radius_0 = mkRON "tuple" [0.0 0.0 0.0 0.0];
    radius_xs = mkRON "tuple" [4.0 4.0 4.0 4.0];
    radius_s = mkRON "tuple" [8.0 8.0 8.0 8.0];
    radius_m = mkRON "tuple" [16.0 16.0 16.0 16.0];
    radius_l = mkRON "tuple" [32.0 32.0 32.0 32.0];
    radius_xl = mkRON "tuple" [160.0 160.0 160.0 160.0];
  };

  spacing = {
    space_none = 0;
    space_xxxs = 4;
    space_xxs = 8;
    space_xs = 12;
    space_s = 16;
    space_m = 24;
    space_l = 32;
    space_xl = 48;
    space_xxl = 64;
    space_xxxl = 128;
  };
in {
  wayland.desktopManager.cosmic.appearance.theme = {
    mode = "dark";

    dark = {
      palette = mkRON "enum" {
        variant = "Dark";
        value = [
          {
            name = "Catppuccin-Frappe-Lavender";
            blue = rgba 0.54901961 0.66666667 0.93333333 1.0;
            red = rgba 0.90588235 0.50980392 0.51764706 1.0;
            green = rgba 0.65098039 0.81960784 0.53725490 1.0;
            yellow = rgba 0.89803922 0.78431373 0.56470588 1.0;
            gray_1 = rgba 0.16078431 0.17254902 0.23529412 1.0;
            gray_2 = rgba 0.18823529 0.20392157 0.27450980 1.0;
            gray_3 = rgba 0.25490196 0.27058824 0.34901961 1.0;
            neutral_0 = rgba 0.13725490 0.14901961 0.20392157 1.0;
            neutral_1 = rgba 0.16078431 0.17254902 0.23529412 1.0;
            neutral_2 = rgba 0.18823529 0.20392157 0.27450980 1.0;
            neutral_3 = rgba 0.25490196 0.27058824 0.34901961 1.0;
            neutral_4 = rgba 0.31764706 0.34117647 0.42745098 1.0;
            neutral_5 = rgba 0.38431373 0.40784314 0.50196078 1.0;
            neutral_6 = rgba 0.45098039 0.47450980 0.58039216 1.0;
            neutral_7 = rgba 0.51372549 0.54509804 0.65490196 1.0;
            neutral_8 = rgba 0.58039216 0.61176471 0.73333333 1.0;
            neutral_9 = rgba 0.64705882 0.67843137 0.80784314 1.0;
            neutral_10 = rgba 0.70980392 0.74901961 0.88627451 1.0;
            bright_green = rgba 0.65098039 0.81960784 0.53725490 1.0;
            bright_red = rgba 0.90588235 0.50980392 0.51764706 1.0;
            bright_orange = rgba 0.93725490 0.62352941 0.46274510 1.0;
            ext_warm_grey = rgba 0.58039216 0.61176471 0.73333333 1.0;
            ext_orange = rgba 0.93725490 0.62352941 0.46274510 1.0;
            ext_yellow = rgba 0.89803922 0.78431373 0.56470588 1.0;
            ext_blue = rgba 0.54901961 0.66666667 0.93333333 1.0;
            ext_purple = rgba 0.72941176 0.73333333 0.94509804 1.0;
            ext_pink = rgba 0.95686275 0.72156863 0.89411765 1.0;
            ext_indigo = rgba 0.79215686 0.61960784 0.90196078 1.0;
            accent_blue = rgba 0.54901961 0.66666667 0.93333333 1.0;
            accent_red = rgba 0.90588235 0.50980392 0.51764706 1.0;
            accent_green = rgba 0.65098039 0.81960784 0.53725490 1.0;
            accent_warm_grey = rgba 0.58039216 0.61176471 0.73333333 1.0;
            accent_orange = rgba 0.93725490 0.62352941 0.46274510 1.0;
            accent_yellow = rgba 0.89803922 0.78431373 0.56470588 1.0;
            accent_purple = rgba 0.72941176 0.73333333 0.94509804 1.0;
            accent_pink = rgba 0.95686275 0.72156863 0.89411765 1.0;
            accent_indigo = rgba 0.79215686 0.61960784 0.90196078 1.0;
          }
        ];
      };
      inherit cornerRadii spacing;
      bg_color = mkRON "optional" (rgba 0.18823529 0.20392157 0.27450980 1.0);
      text_tint = mkRON "optional" (rgb 0.77647059 0.81568627 0.96078431);
      accent = mkRON "optional" (rgb 0.72941176 0.73333333 0.94509804);
      success = mkRON "optional" (rgb 0.65098039 0.81960784 0.53725490);
      warning = mkRON "optional" (rgb 0.89803922 0.78431373 0.56470588);
      destructive = mkRON "optional" (rgb 0.90588235 0.50980392 0.51764706);
      window_hint = mkRON "optional" (rgb 0.72941176 0.73333333 0.94509804);
      neutral_tint = mkRON "optional" (rgb 0.51372549 0.54509804 0.65490196);
      primary_container_bg = mkRON "optional" (rgba 0.25490196 0.27058824 0.34901961 1.0);
      secondary_container_bg = mkRON "optional" (rgba 0.31764706 0.34117647 0.42745098 1.0);
      is_frosted = false;
      gaps = mkRON "tuple" [0 8];
      active_hint = 3;
    };

    light = {
      palette = mkRON "enum" {
        variant = "Light";
        value = [
          {
            name = "Catppuccin-Latte-Lavender";
            blue = rgba 0.11764706 0.40000000 0.96078431 1.0;
            red = rgba 0.82352941 0.05882353 0.22352941 1.0;
            green = rgba 0.25098039 0.62745098 0.16862745 1.0;
            yellow = rgba 0.87450980 0.55686275 0.11372549 1.0;
            gray_1 = rgba 0.90196078 0.91372549 0.93725490 1.0;
            gray_2 = rgba 0.93725490 0.94509804 0.96078431 1.0;
            gray_3 = rgba 0.80000000 0.81568627 0.85490196 1.0;
            neutral_0 = rgba 0.86274510 0.87843137 0.90980392 1.0;
            neutral_1 = rgba 0.90196078 0.91372549 0.93725490 1.0;
            neutral_2 = rgba 0.93725490 0.94509804 0.96078431 1.0;
            neutral_3 = rgba 0.80000000 0.81568627 0.85490196 1.0;
            neutral_4 = rgba 0.73725490 0.75294118 0.80000000 1.0;
            neutral_5 = rgba 0.67450980 0.69019608 0.74509804 1.0;
            neutral_6 = rgba 0.61176471 0.62745098 0.69019608 1.0;
            neutral_7 = rgba 0.54901961 0.56078431 0.63137255 1.0;
            neutral_8 = rgba 0.48627451 0.49803922 0.57647059 1.0;
            neutral_9 = rgba 0.42352941 0.43529412 0.52156863 1.0;
            neutral_10 = rgba 0.36078431 0.37254902 0.46666667 1.0;
            bright_green = rgba 0.25098039 0.62745098 0.16862745 1.0;
            bright_red = rgba 0.82352941 0.05882353 0.22352941 1.0;
            bright_orange = rgba 0.99607843 0.39215686 0.04313725 1.0;
            ext_warm_grey = rgba 0.48627451 0.49803922 0.57647059 1.0;
            ext_orange = rgba 0.99607843 0.39215686 0.04313725 1.0;
            ext_yellow = rgba 0.87450980 0.55686275 0.11372549 1.0;
            ext_blue = rgba 0.11764706 0.40000000 0.96078431 1.0;
            ext_purple = rgba 0.44705882 0.52941176 0.99215686 1.0;
            ext_pink = rgba 0.91764706 0.46274510 0.79607843 1.0;
            ext_indigo = rgba 0.53333333 0.22352941 0.93725490 1.0;
            accent_blue = rgba 0.11764706 0.40000000 0.96078431 1.0;
            accent_red = rgba 0.82352941 0.05882353 0.22352941 1.0;
            accent_green = rgba 0.25098039 0.62745098 0.16862745 1.0;
            accent_warm_grey = rgba 0.48627451 0.49803922 0.57647059 1.0;
            accent_orange = rgba 0.99607843 0.39215686 0.04313725 1.0;
            accent_yellow = rgba 0.87450980 0.55686275 0.11372549 1.0;
            accent_purple = rgba 0.44705882 0.52941176 0.99215686 1.0;
            accent_pink = rgba 0.91764706 0.46274510 0.79607843 1.0;
            accent_indigo = rgba 0.53333333 0.22352941 0.93725490 1.0;
          }
        ];
      };
      inherit cornerRadii spacing;
      bg_color = mkRON "optional" (rgba 0.93725490 0.94509804 0.96078431 1.0);
      text_tint = mkRON "optional" (rgb 0.29803922 0.30980392 0.41176471);
      accent = mkRON "optional" (rgb 0.44705882 0.52941176 0.99215686);
      success = mkRON "optional" (rgb 0.25098039 0.62745098 0.16862745);
      warning = mkRON "optional" (rgb 0.87450980 0.55686275 0.11372549);
      destructive = mkRON "optional" (rgb 0.82352941 0.05882353 0.22352941);
      window_hint = mkRON "optional" (rgb 0.44705882 0.52941176 0.99215686);
      neutral_tint = mkRON "optional" null;
      primary_container_bg = mkRON "optional" null;
      secondary_container_bg = mkRON "optional" null;
      is_frosted = false;
      gaps = mkRON "tuple" [0 8];
      active_hint = 3;
    };
  };
}
