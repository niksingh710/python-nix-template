{
  description = "Hello world flake using uv2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    python-flake.url = "github:juspay/python-flake/pull/2/head";
  };

  outputs = inputs@{ python-flake, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [ python-flake.flakeModules.default ];
      perSystem = { self', pkgs, config, ... }: {
        python-project = {
          name = "python-nix-template-env";
          root = ./.;

          # not required, default value is `pkgs.python3`
          # for more options see <https://github.com/juspay/python-flake>
          python = pkgs.python312;
        };

        # Make our app runnable with `nix run`
        # If python-project.name and binary name are the same, we can skip this
        apps = {
          default = {
            type = "app";
            program = "${self'.packages.default}/bin/pnt";
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.devShells.uv2nix ];
          packages = with pkgs;[
            pyright
            python312Packages.python-lsp-server
            python312Packages.python-lsp-ruff

            nil
            nixpkgs-fmt
          ];
        };
      };
    };
}
