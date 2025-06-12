{
  services.n8n = {
    enable = true;
    webhookUrl = "https://n8n.lanice.dev/";
  };

  systemd.services.n8n.environment.N8N_PORT = "5588";
}
