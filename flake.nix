{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-24.05;
    npmlock2nix.url = github:nix-community/npmlock2nix;
  };

  outputs = inputs@{ self, nixpkgs, npmlock2nix }: let
    allSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = fn: nixpkgs.lib.genAttrs allSystems (system: fn (import nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
    }));
  in rec {
    packages = forAllSystems (pkgs: {
      inherit (pkgs) graphile-migrate;
      default = pkgs.graphile-migrate;
    });

    overlays.default = final: prev: {
      graphile-migrate = (import npmlock2nix {pkgs = final;}).v2.build {
        src = ./.;
        installPhase = "mkdir -p $out/bin && cp dist/index.js $out/bin/graphile-migrate";
        buildCommands = [ "npm run build" ];
        nodejs = final.nodejs_20;
      };
    };
  };
}
