{ pkgs, top }:

rec {
  nixpkgs = with pkgs.lib;
    if pathExists "${toString pkgs.path}/.version-suffix" then
      substring 0 8 (
        elemAt (
          splitString "." (fileContents "${toString pkgs.path}/.version-suffix")
        ) 1
        )
    else if pathExists "${toString pkgs.path}/.git" then
      substring 0 8 (commitIdFromGitRepo "${toString pkgs.path}/.git")
    else "unknown-version";

  nixtos = with pkgs.lib;
    if pathExists ./version then
      fileContents ./version
    else
      substring 0 8 (commitIdFromGitRepo ../../.git);

  name = "nixtos-${nixtos}-nixpkgs-${nixpkgs}";
}
