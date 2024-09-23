{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, flake-utils, rust-overlay, ... }: 
  flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      rustPlatform = pkgs.makeRustPlatform {
        cargo = pkgs.rust-bin.stable.latest.default;
        rustc = pkgs.rust-bin.stable.latest.default;
      };
      libs = [ ];
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.rust-bin.stable.latest.default
          pkgs.pkg-config
          pkgs.bacon
        ] ++ libs;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
      };
      packages.default = rustPlatform.buildRustPackage {
        pname = "eslauncher2";
        version = "0.9.6";

        src = ./.;

        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = libs;

        cargoLock = {
          lockFile = ./Cargo.lock;
        };
      };
    }
  );
}
