{ config, lib, pkgs, ... }:
let
  cfg = config.services.ip-failar-nu;

  package = pkgs.buildGoModule {
    name = "ip-failar-nu-20201207";
    src = ./.;
    vendorSha256 = "sha256-D2/PVtoJGljsfHVNX4Q+ASu5R3PnRakApEn1rZK4lgM=";
  };

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
