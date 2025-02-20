{
  description = "Flake for kcl dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
    allowFree = true;
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        let
          # TODO: make this work per-system, for the mac folks
          sys =
            if system == "x86_64-linux" then
              "linux-amd64"
            else
              abort "${system} is invalid";
          sha256 =
            if system == "x86_64-linux" then
              "1gs354s0nd60qhcwwq3vmw21n45gy09bvsmz3a6k0b0ldrps1zr6" # v0.11.1
            # "0304qlz8nn0077b7pw798v1nvcpxb671fzd4sijpkn7llvk1nw33" # v0.11.0
            # "13g3xq35by8z0bbivfn5k9hid1bl8nawp0zvyqfqjyifx7pxhn08" # v0.10.8
            else if system == "arm64-macos" then
              ""
            else
              abort "${system} is invalid";

          kcl-ls = pkgs.stdenv.mkDerivation rec {
            pname = "kcl-language-server";
            # version = "0.10.8";
            version = "0.11.1";
            src = builtins.fetchTarball {
              url = "https://github.com/kcl-lang/kcl/releases/download/v${version}/kclvm-v${version}-${sys}.tar.gz";
              sha256 = sha256;
            };
            installPhase = ''
              mkdir -p $out/bin
              install -m755 bin/kcl-language-server $out/bin/kcl-language-server
            '';
          };

          buildDeps = with pkgs; [
            bash
            uutils-coreutils-noprefix
            git
            kcl
            just
            treefmt2
          ];

        in
        {
          packages = {
            default = pkgs.git;
          };

          devenv = {
            shells.default = rec {
              name = "kcl";
              enterShell = ''
                ${lib.getExe' pkgs.figlet "figlet"} -f banner3 ${name} | ${lib.getExe pkgs.dotacat}
              '';

              packages = with pkgs; [
                config.packages.default
                nix-direnv
                nil # nix ls
                kcl-ls # the package we made up above
              ] ++ buildDeps;
            };
          };
        };
    };
}
