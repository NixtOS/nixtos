# This file defines the service solver for NixtOS.
#
# Here, a service is defined as a function that takes as input a list of
# extending blocks, and outputs a list of extenders.
#
# An extending block is defined as a map of the format:
#   { type = "..."; # The type of the data, as a string
#     ...           # The data contained
#   }
#
# The "type" argument can be one of the following:
#  * "init": Init service, with a `command` argument
#  * "script": Script, with a `script` argument
#  * "symlink": Symlink, with `file` and `target` arguments
#  * Anything with a ':' in it, which is defined and used outside of NixtOS. A
#    user should prefix his types with 'user:' for personal use, and services
#    distributed for further use should be prefixed with 'domain.example.org:'
#
# An extender is an extending block along with the name of the service it
# extends. It is a map of the format:
#   { extends = "..."; # The service being extended
#     data = {};       # The associated extending block
#   }

{ pkgs }:

services:

let
  all-extenders = builtins.concatLists (
    pkgs.lib.mapAttrsToList (service: extenders:
      extenders (extenders-for service)
    ) services
  );

  extenders-for = service:
    pkgs.lib.concatMap (e:
      if builtins.isList e.data then e.data
      else [ e.data ]
    ) (
      builtins.filter (e: e.extends == service) all-extenders
    );

  extenders-for-assert-type = service: type:
    map (e: assert e.type == type; e) (extenders-for service);
in
{
  inherit extenders-for extenders-for-assert-type;
}
