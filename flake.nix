{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/release-23.05;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus;
    yarnpnp2nix.url = github:madjam002/yarnpnp2nix;
    yarnpnp2nix.inputs.nixpkgs.follows = "nixpkgs";
    yarnpnp2nix.inputs.utils.follows = "utils";
  };

  outputs = inputs@{ self, nixpkgs, utils, yarnpnp2nix }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ self.overlays.default ];
    };
  in rec {
    packages.x86_64-linux = let
      yarnPackages = yarnpnp2nix.lib.x86_64-linux.mkYarnPackagesFromManifest {
        inherit pkgs;
        yarnManifest = import ./yarn-manifest.nix;
      };
    in {
      graphile-migrate = yarnPackages."graphile-migrate-flake@workspace:.";
    };

    overlays.default = self: super: {
      inherit (packages) graphile-migrate;
    };
  };
}
