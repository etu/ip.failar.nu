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

    # Set up flake module
    nixosModule = { inputs, options, modulesPath, config, lib }: let
      cfg = config.services.ip-failar-nu;
    in {
      # Set up module options
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
            ExecStart = "${self.defaultPackage.x86_64-linux}/bin/ip.failar.nu";
            Restart = "always";
          };
        };
      };
    };
  };
}
