{
  description = "etu/ip.failar.nu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = flake-utils.lib.flattenTree {
        default = pkgs.buildGoModule (let
          version = "1.0.${nixpkgs.lib.substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
        in {
          pname = "ip-failar-nu";
          inherit version;

          src = ./.;

          vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";
        });
      };

      formatter = pkgs.alejandra;

      devShells = flake-utils.lib.flattenTree {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.gnumake
            pkgs.delve # debugging
            pkgs.go # language
            pkgs.gopls # language server
          ];
        };
      };

      # Set up flake module
      nixosModules.default = {
        options,
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.ip-failar-nu;
        pkg = self.packages.${system}.default;
      in {
        # Set up module options
        options.services.ip-failar-nu.enable =
          lib.mkEnableOption
          "Service that responds over http with the connecting clients IP";

        # Set up module implementation
        config = lib.mkIf cfg.enable {
          systemd.services.ip-failar-nu = {
            description = "ip-failar-nu";
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              User = "nobody";
              ExecStart = "${pkg}/bin/ip.failar.nu";
              Restart = "always";
            };
          };
        };
      };
    });
}
