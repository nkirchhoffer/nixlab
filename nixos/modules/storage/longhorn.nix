{ config, pkgs, ... }:
{
  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };

  systemd.services.iscsid.serviceConfig = {
    PrivateMounts = "yes";
    BindPaths = "/run/current-system/sw/bin:/bin";
  };

  boot.kernelModules = [ "iscsi_tcp" ];

  environment.systemPackages = with pkgs; [
    nfs-utils
    util-linux
  ];

  boot.supportedFilesystems = [ "nfs" ];
}
