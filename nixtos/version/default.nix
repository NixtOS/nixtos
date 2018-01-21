{ pkgs }:

rec {
  # TODO: make the version of nixpkgs less *long*
  nixpkgs = pkgs.lib.fileContents "${toString pkgs.path}/.version-suffix";
  nixtos = pkgs.lib.substring 0 8 (pkgs.lib.commitIdFromGitRepo ../../.git);
  name = "nixtos-${nixtos}-nixpkgs-${nixpkgs}";
}
