let
  lanice-sencha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwdc+uAZvNnh7OTdtIT1ei1n/S+jZdYBZlDXNkNouo2 lanice@sencha";
  lanice-unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHr1ModaOEBmMoP4IhJim4Uorgg8KIz7pfSPEWzVk1aq lanice@unstable";
  users = [lanice-sencha lanice-unstable];

  unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqPXr49t/nDW8UtCjPVkmIW8qpHCnsYLjnZWYx7vED root@unstable";
  systems = [unstable];
in {
  "porkbun.age".publicKeys = [unstable lanice-unstable lanice-sencha];
}
