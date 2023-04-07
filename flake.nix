{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hl = pkgs.haskell.lib.compose;
        haskellPackages = pkgs.haskellPackages;
        trv = nixpkgs.lib.trivial;
        root = ./.;
        project = extraModifiers: returnShellEnv:
          haskellPackages.developPackage {
            inherit root;
            returnShellEnv = returnShellEnv;
            modifier = (trv.flip trv.pipe) ([
              hl.enableStaticLibraries
              hl.justStaticExecutables
              hl.disableExecutableProfiling
            ] ++ extraModifiers);
          };
      in {
        packages.default = project [ ] false;
        devShell = project [
          (hl.addBuildTools (with haskellPackages; [
            haskell-language-server
            cabal-install
            yesod-bin
            implicit-hie
            hlint
            hpack
          ]))
          (hl.overrideCabal (old: {
            shellHook = (old.shellHook or "") + ''
              echo "Generating .cabal file from package.yaml using hpack, \
              remember to regenerate if you change package.yaml! \
              Although nix build dont care about it, \
              its mostly for helping haskell-language-server." | ${pkgs.cowsay}/bin/cowsay

              hpack

              export CABAL_CONFIG="$(pwd)/cabal_config"
            '';
          }))
        ] true;
      }) // {
        overlay = final: prev: {
           # p_name_here = self.packages.${final.system}.default;
        };
      };
}
