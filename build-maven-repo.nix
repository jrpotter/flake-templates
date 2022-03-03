{ lib, stdenv, maven }:
with stdenv; mkDerivation {
  name = "build-maven-repo";
  buildInputs = [ maven ];
  src = ./.;

  # Builds the maven repostiory as a fixed output derivation. Though it would be
  # nice to use the `buildMaven` utility, I am getting several `ulimit`-related
  # issues. Refer to the following links for more details:
  #
  # https://ryantm.github.io/nixpkgs/languages-frameworks/maven/
  # https://fzakaria.com/2020/07/20/packaging-a-maven-application-with-nix.html
  buildPhase = ''
    runHook preBuild
    mvn -Dmaven.repo.local=$out package
    runHook postBuild
  '';

  # Keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with
  # `lastModified` timestamps inside.
  installPhase = ''
    runHook preInstall
    find $out -type f \
      -name \*.lastUpdated -or \
      -name resolver-status.properties -or \
      -name _remote.repositories \
      | tr '\n' '\0' | xargs -0 rm
      # For reasons I don't understand, `resolver-status.properties` files are
      # not removed when using the `-delete` flag. Though it opens up another
      # process, just use `xargs rm` instead. Substitute newlines with NUL
      # characters just in case a filename has a space in it.
    runHook postInstall
  '';

  dontFixup = true;

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-v3PzPStF7vBk6FHZn1jAIQfplZ7AfQj/b+t8snTUKmg=";
}
