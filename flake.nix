{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/release-23.05;
    npmlock2nix.url = github:nix-community/npmlock2nix;
  };

  outputs = inputs@{ self, nixpkgs, npmlock2nix }: let
    forAllSystems = fn: nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system: fn (import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          npmlock2nix = import npmlock2nix {pkgs = prev;};
        })
      ];
      config = {
        permittedInsecurePackages = [
          "nodejs-16.20.2"
        ];
      };
    }));

  in rec {
    packages = forAllSystems (pkgs: {
      graphile-migrate = pkgs.npmlock2nix.v2.build {
        src = ./.;
        installPhase = "mkdir -p $out/bin && cp dist/index.js $out/bin/graphile-migrate";
        buildCommands = [ "npm run build" ];
      };
    });

    overlays.default = final: prev: {
      inherit (self.packages.${final.system}) graphile-migrate;
    };
  };
}
