{ pkgs, ... }:
pkgs.mkShell {
  name = "ags-dev";

  packages = with pkgs; [
    watchexec
    nodePackages.prettier
    # https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific

    (stdenv.mkDerivation rec {
      pname = "@trivago/prettier-plugin-sort-imports";
      version = "4.3.0";

      src = pkgs.fetchFromGitHub {
        owner = "trivago";
        repo = "prettier-plugin-sort-imports";
        rev = "v${version}";
        hash = "sha256-ClwM8dZtJlaJ549Z0UOpLE5jVd/qq3X25qlYfkIknio=";
      };

      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-tKY+ct/+JXqZBYp+Y5c0r63cubsimQ/ODk/QX5GUTH8=";
      };

      nativeBuildInputs = [
        yarn
        fixup-yarn-lock
        nodejs-slim
      ];

      postPatch = ''
        export HOME=$NIX_BUILD_TOP/fake_home
        yarn config --offline set yarn-offline-mirror $offlineCache
        fixup-yarn-lock yarn.lock
        yarn install --offline --frozen-lockfile --ignore-scripts --no-progress --non-interactive
        patchShebangs node_modules/
      '';

      buildPhase = ''
        runHook preBuild

        export NODE_OPTIONS=--openssl-legacy-provider
        yarn --offline run compile

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mv lib $out

        runHook postInstall
      '';
    })
  ];

}
