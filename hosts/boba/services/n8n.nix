{lib, ...}: {
  services.n8n = {
    enable = true;
    environment.WEBHOOK_URL = "https://n8n.lanice.dev/";
    environment.N8N_PORT = "5588";
  };
}
