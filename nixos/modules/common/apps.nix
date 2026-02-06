{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    curl
  ];
}