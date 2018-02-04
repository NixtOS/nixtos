{ pkgs, top }:

{ tag, path, rw }:

{ store }:

{
  build = "";
  options = "-virtfs local,mount_tag=${tag},path=${path},security_model=none${
      if rw then "" else ",readonly"
  }";
}
