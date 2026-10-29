{
  description = "libjnivm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      git-hooks,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      outputsFor =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (pkgs) stdenv;

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
          ];
          buildInputs = [ ];

          commonCmakeFlags = [
            "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
            "-DFETCHCONTENT_SOURCE_DIR_GOOGLETEST=${pkgs.gtest.src}"
          ];

          mkJnivm =
            {
              trace ? false,
              debug ? true,
            }:
            stdenv.mkDerivation {
              pname = "libjnivm";
              version = "git";
              src = lib.cleanSource ./.;

              inherit nativeBuildInputs buildInputs;
              strictDeps = true;

              cmakeFlags = commonCmakeFlags ++ [
                (lib.cmakeBool "JNIVM_ENABLE_TRACE" trace)
                (lib.cmakeBool "JNIVM_ENABLE_DEBUG" debug)
              ];

              doCheck = true;
            };

          libjnivm = mkJnivm { };
          libjnivm-trace = mkJnivm { trace = true; };

          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

          pre-commit = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              treefmt = {
                enable = true;
                package = treefmtEval.config.build.wrapper;
              };
            };
          };

          useMold = system == "x86_64-linux";
        in
        {
          packages = {
            default = libjnivm;
            inherit libjnivm libjnivm-trace;
          };

          checks = {
            inherit libjnivm;
            formatting = treefmtEval.config.build.check self;
          };

          formatter = treefmtEval.config.build.wrapper;

          devShells.default = pkgs.mkShell.override { inherit stdenv; } {
            inherit nativeBuildInputs buildInputs;
            inherit (pre-commit) shellHook;

            packages = [
              treefmtEval.config.build.wrapper
              pkgs.clang-tools
              pkgs.gdb
              pkgs.bear
              pkgs.ccache
              pkgs.gtest
            ]
            ++ lib.optionals useMold [ pkgs.mold ];

            env = {
              CMAKE_GENERATOR = "Ninja";
              CMAKE_EXPORT_COMPILE_COMMANDS = "1";
              FETCHCONTENT_SOURCE_DIR_GOOGLETEST = "${pkgs.gtest.src}";
            }
            // lib.optionalAttrs useMold {
              LDFLAGS = "-fuse-ld=mold";
            };
          };
        };

      perSystem = lib.genAttrs systems outputsFor;
    in
    {
      packages = lib.mapAttrs (_: o: o.packages) perSystem;
      checks = lib.mapAttrs (_: o: o.checks) perSystem;
      formatter = lib.mapAttrs (_: o: o.formatter) perSystem;
      devShells = lib.mapAttrs (_: o: o.devShells) perSystem;
    };
}
