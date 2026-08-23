{inputs, ...}: {
  age.secrets = {
    resticForgejoTransport.file = "${inputs.self}/secrets/resticForgejoTransport.age";
    resticMailArchiveTransport.file = "${inputs.self}/secrets/resticMailArchiveTransport.age";
    resticForgejoPassword.file = "${inputs.self}/secrets/resticForgejoPassword.age";
  };
}
