{pkgs, ...}: {
  home.packages = with pkgs; [slack lastpass-cli awscli];

  # programs.awscli = {
  #   enable = true;

  #   # credentials = {
  #   #   "default" = {
  #   #     "credential_process" = "${pkgs.lastpass-cli}/bin/lpass show --password aws";
  #   #   };
  #   # };

  #   settings = {
  #     "default" = {
  #       region = "us-east-2";
  #     };
  #   };
  # };
}
