{ pkgs }:

rec {
  nixpkgs = with pkgs.lib;
    substring 0 8 (
      elemAt (
        splitString "." (fileContents "${toString pkgs.path}/.version-suffix")
      ) 1
    );
  nixtos = with pkgs.lib;
    if pathExists ./version then
      fileContents ./version
    else
      substring 0 8 (commitIdFromGitRepo ../../.git);
  name = "nixtos-${nixtos}-nixpkgs-${nixpkgs}";
}
