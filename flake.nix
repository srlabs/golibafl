{
  description = "A Nix flake for a development environment with Go, Rust, and Cargo.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Change this to match your system architecture
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShell rec {
        buildInputs = with pkgs; [
          go
          rustup
          cargo
          rustc
        ];
        shellHook = ''
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${builtins.toString (pkgs.lib.makeLibraryPath buildInputs)}";
        '';
      };
    };
}
