# COSMIC frosted glass configuration

## Finding

COSMIC 1.4 stores frosted-glass controls in **version 2** of each theme-builder component and its generated active-theme component:

- `com.system76.CosmicTheme.{Dark,Light}.Builder`
- `com.system76.CosmicTheme.{Dark,Light}`

The v2 entries are:

- `frosted`: a blur-strength enum. `Medium` is the upstream default.
- `frosted_panel`: blur the panel.
- `frosted_applets`: blur applet popups.
- `frosted_system_interface`: blur COSMIC system surfaces.
- `frosted_windows`: blur application windows.

COSMIC Settings exposes the four booleans as independent toggles and exposes the blur strength as a 14-step slider. See the [COSMIC Settings 1.4 frosted-glass drawer](https://github.com/pop-os/cosmic-settings/blob/epoch-1.4.0/cosmic-settings/src/pages/desktop/appearance/drawer.rs#L619-L668).

The persisted schema comes from libcosmic's `ThemeBuilder`, which is explicitly version 2 and defines `frosted` plus the four surface booleans. See the [COSMIC 1.4 libcosmic theme model](https://github.com/pop-os/libcosmic/blob/96a82045d75b0f4eefcf1f668b305d8397c4f351/cosmic-theme/src/model/theme.rs#L844-L914). `BlurStrength::Medium` is the default; the supported enum variants are documented in the [same source](https://github.com/pop-os/libcosmic/blob/96a82045d75b0f4eefcf1f668b305d8397c4f351/cosmic-theme/src/model/theme.rs#L1644-L1694).

## Runtime prerequisites

The blur is a compositor effect, not transparency alone. `cosmic-comp` 1.3 or newer must own the running Wayland session; applying a NixOS switch does not replace an already-running compositor, so the first upgrade requires logging out and back in. The compositor exposes the blur capability through the [background-effect protocol handler](https://github.com/pop-os/cosmic-comp/blob/epoch-1.4.0/src/wayland/handlers/background_effect.rs), and libcosmic applications request it only when their surface type's frosted flag is enabled; see the [libcosmic blur gating](https://github.com/pop-os/libcosmic/blob/96a82045d75b0f4eefcf1f668b305d8397c4f351/src/core.rs#L558-L589).

Non-libcosmic GTK, Electron, and browser windows do not request this COSMIC blur effect. `Medium` also remains mostly opaque, so a dark low-detail wallpaper makes the result subtle even when it is functioning.

## Repository impact

The existing Catppuccin RON files contain the old v1 field `is_frosted: true`. That field is not sufficient for COSMIC 1.4's v2 controls. The pinned cosmic-manager revision still writes imported theme builders as schema version 1; see its [hard-coded `version = 1`](https://github.com/HeitorAugustoLN/cosmic-manager/blob/1630bbf792a95baffbd3169885580cd53a7027d8/modules/appearance.nix#L1378-L1411).

Therefore, changing only the legacy theme RON would either leave the v2 switches disabled or require migrating the entire custom theme to the changed v2 palette schema. Writing only the v2 builder is also insufficient here: cosmic-manager's `build-theme` activation uses cosmic-ctl 1.5, whose [builder implementation](https://github.com/cosmic-utils/cosmic-ctl/blob/v1.5.0/src/commands/build_theme.rs) is compiled against an older libcosmic and consequently regenerates only the v1 active theme.

The narrow, compatible solution is to keep the Catppuccin theme in v1 and apply the frosted-glass entries to both the v2 builders and the generated v2 active themes after cosmic-manager runs.

## Applied values

```ron
frosted = Medium
frosted_panel = true
frosted_applets = true
frosted_system_interface = true
frosted_windows = true
```

Both dark and light builders and active themes receive the settings, matching COSMIC Settings' behavior when it stages appearance changes for both themes.
