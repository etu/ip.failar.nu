{ config, lib, pkgs, ... }:
let
  cfg = config.services.ip-failar-nu;

  package = pkgs.callPackage ./default.nix { };
in
{
  options.services.ip-failar-nu.enable = lib.mkEnableOption
    "Service that responds over http with the connecting clients IP";

  # Set up module implementation
  config = lib.mkIf cfg.enable {
    systemd.services.ip-failar-nu = {
      description = "ip-failar-nu";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "nobody";
        ExecStart = "${package}/bin/ip.failar.nu";
        Restart = "always";
      };
    };
  };
}
