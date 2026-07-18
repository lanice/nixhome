{lib, ...}: {
  # LLM chat frontend for roleplay/character cards. State (characters, chats,
  # per-user settings) lives in /var/lib/SillyTavern/data.
  services.sillytavern = {
    enable = true;
    port = 8100;
    # listen stays at its default (false), so SillyTavern binds localhost only
    # and is reachable solely through the nginx vhost at tavern.lanice.dev.
    # Whitelist mode off: it would otherwise reject requests based on the
    # X-Forwarded-For tailnet IP that nginx passes along.
    whitelist = false;
  };

  # The module symlinks config.yaml to ${package}/…/sillytavern/config.yaml,
  # but the 1.18.0 package ships no such file (defaults live in default/), so
  # the symlink dangles and SillyTavern's attempt to seed its config through
  # it dies with EROFS in the store. Drop the symlink rule; on startup
  # SillyTavern writes a mutable config.yaml (defaults + migrations) itself.
  systemd.tmpfiles.settings.sillytavern."/var/lib/SillyTavern/config.yaml" =
    lib.mkForce {};
  # Declarative config overrides. SillyTavern resolves every config key from
  # SILLYTAVERN_<KEY> (key uppercased, dots -> underscores) before falling
  # back to config.yaml, so values set here always win over the mutable file.
  systemd.services.sillytavern.environment = {
    SILLYTAVERN_ENABLEUSERACCOUNTS = "true";
  };

  systemd.services.sillytavern.preStart = ''
    if [ -L /var/lib/SillyTavern/config.yaml ]; then
      rm /var/lib/SillyTavern/config.yaml
    fi
  '';
}
