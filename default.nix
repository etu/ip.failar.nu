{ pkgs ? import <nixpkgs> {}, ... }:

let
  version = "20201220";
in pkgs.buildGoModule {
  pname = "ip-failar-nu";
  inherit version;

  src = ./.;

  vendorSha256 = "sha256-D2/PVtoJGljsfHVNX4Q+ASu5R3PnRakApEn1rZK4lgM=";
}
