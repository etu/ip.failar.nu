{
  description = "etu/ip.failar.nu";

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    version = "0.1.${nixpkgs.lib.substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
  in {
    # Set up an overlay with the ip.failar.nu package
    overlay = final: prev: {
      ip-failar-nu = final.pkgs.buildGoModule {
        name = "ip-failar-nu-${version}";
        src = self;
        vendorSha256 = "sha256-D2/PVtoJGljsfHVNX4Q+ASu5R3PnRakApEn1rZK4lgM=";
      };
    };

    # Set it as default package for all architectures
    defaultPackage = forAllSystems (system: (import nixpkgs {
      inherit system;
      overlays = [ self.overlay ];
    }).ip-failar-nu);
  };
}
