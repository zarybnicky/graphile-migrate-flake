{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/release-23.05;
    npmlock2nix.url = github:nix-community/npmlock2nix;
  };

  outputs = inputs@{ self, nixpkgs, npmlock2nix }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
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
    };
  in rec {
    packages.x86_64-linux = {
      graphile-migrate = pkgs.npmlock2nix.v2.build {
        src = ./.;
        installPhase = "mkdir -p $out/bin && cp dist/index.js $out/bin/graphile-migrate";
        buildCommands = [ "npm run build" ];
      };
    };

    overlays.default = final: prev: {
      inherit (packages.x86_64-linux) graphile-migrate;
    };
  };
}
