{
  services.espanso.matches.base.matches = [
    {
      trigger = ":euro";
      replace = "€";
    }
    {
      trigger = ":shrug";
      replace = "¯\\_(ツ)_/¯";
    }
    {
      trigger = ":dadjoke";
      replace = "{{output}}";
      vars = [
        {
          name = "output";
          type = "shell";
          params = {
            cmd = "curl -H 'Accept: text/plain' https://icanhazdadjoke.com/";
          };
        }
      ];
    }
  ];
}
