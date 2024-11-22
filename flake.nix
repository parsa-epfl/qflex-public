{
  description = "A flake for building QEMU";

  # Each time this url is changed, please rerun `nix flake lock --update-input nixpkgs` to update the lock file
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in 
  {

    devShells.${system}.default = pkgs.llvmPackages_18.stdenv.mkDerivation {
      pname = "qemu-qflex";
      version = "8";
      src = ".";

      buildInputs = [
        pkgs.ninja
        pkgs.glib
        pkgs.pkg-config
        pkgs.pixman
        pkgs.capstone
        pkgs.libslirp
        pkgs.libgcrypt
        pkgs.python3
        pkgs.git
	      pkgs.pbzip2

        pkgs.flex
        pkgs.bison

        pkgs.conan
        pkgs.cmake
        pkgs.boost
      ];

      # This property is not required by mkDerivation, but appears as a environmental variable.
      # So I can run $configurationPhase in the shell.
      configurationPhase = ''
        ./configure --target-list=aarch64-softmmu --disable-gtk --enable-capstone
      '';

      configurationPhaseWithExtSnapshots = ''
        ./configure --target-list=aarch64-softmmu --disable-gtk --enable-capstone --enable-snapext
      '';

      # Also this one.
      buildPhase = ''
        ninja -C build
      '';

      shellHook = ''
        echo Under Nix build environment.
      '';
    };
  };
}
