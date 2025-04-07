{
  description = "Rust dev environment with Python and Go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [rust-overlay.overlays.default];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        # Create a derivation that vendors your Go dependencies.
        goDeps = pkgs.buildGoModule {
          pname = "harness";
          version = "0.1.0";
          src = ./harnesses/promql;
          vendor = false;
          modSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          # Do not attempt to build a binary—just run vendoring.
          buildPhase = "true";
          installPhase = ''
            mkdir -p $out
            cp -r . $out/
          '';
        };
        devDeps = with pkgs; [
          rustToolchain
          cargo
          (python3.withPackages (ps: [ps.requests]))
          go
        ];

        cargoToml = pkgs.lib.importTOML ./Cargo.toml;
        pname = cargoToml.package.name;
        version = cargoToml.package.version;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = devDeps;
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          inherit pname version;
          src = ./.;
          cargoLock = {lockFile = ./Cargo.lock;};
          buildInputs = devDeps;
          nativeBuildInputs = devDeps;
          preConfigure = ''
            # Set writable temporary directories
            export HOME=$(mktemp -d)
            export GOPATH=${goDeps}
            export GOCACHE=$(mktemp -d)
            # Use vendored Go modules
            export GOPROXY=off
            export GOFLAGS="-mod=vendor"
          '';
        };
      }
    );
}
