{ pkgs, top }:

{ tag }:

{ store }:

{
  build = "";
  options = "-virtfs local,mount_tag=${tag},path=${store},security_model=none";
}
