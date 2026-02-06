{ lib, pkgs, ... }:
{
  imports = [
    ./disk-config.nix
    ../../modules/common/apps.nix
    ../../modules/k3s/server.nix
    ../../modules/storage/longhorn.nix
  ];

  networking.hostName = "knix-3";
  networking = {
    interfaces = {
      eno1.ipv4.addresses = [{
        address = "192.168.2.203";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.2.1";
      interface = "eno1";
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    enableIPv6 = false;
  };

  services.k3s = {
    enable = true;
    role = "server";
    token = "homelab-k3s-cluster-secret";
    serverAddr = "https://192.168.2.201:6443";
    extraFlags = toString [
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
      "--node-ip 192.168.2.203"
    ];
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys =
  [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0BO5wrRZ9V3SWNnSS4VQ1VH1x+XuQyzE15mZ5q87Cl+yd3DmwMRoahaU9grDAgvL9tTZC03X8vzwpM9Tc+Vu77iY0W9DdO142037XOR+UyzaPB+VqNiKfmgdmnYvtiapqa8+ngP/GWYeSgB3MpnzJ/djcubqY2WvGyGlBHKqQMlNoWnQM4EsaJVGQFsFFyDmColq2Azf5vluiL/MznB/J2H++tx2YA2ItXelbqNeHXUEn0jq9HIWk/6N38fhrJL40YZf4q40rzLxhfzuobZhkuc6pQYGQT/xJjbvbomOw4RB4fKMz7Tkfjp4plOQBMUkVQQck+i3rlYSlzfpfUD2E5tIQpFJr6pdyNlM3ewwaImmET9Nb1hEtcIAP/VBfCWBlb0g2jUXNT5PhzZvsWPcabzbuWE564Bui7xQicKNhzaXXlV5Tp8QSkgKtOysHuZgvU1FX3mG7gTuuITQc7pONS4rMCWKcuGDLXIt7UyzKpVfrzjNzOleLyg1eICfO6yc= fed"
  ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 8;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}