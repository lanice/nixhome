{
  services.n8n.enable = true;

  systemd.services.n8n.environment.N8N_PORT = "5588";
}
