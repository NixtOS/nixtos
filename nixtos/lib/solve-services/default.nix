# This file defines the service solver for NixtOS.
#
# Here, a service is defined as a function that takes as input a list of
# extending blocks, and outputs a map of service names to extending blocks.
# The returned map will add extending blocks to the extending block list of the
# named services. The map values can be either a set, in which case it is
# directly the extending block, or a list, in which case it is a list of
# extending blocks that will be passed on to the extended service.
#
# An extending block, also called extender, is defined as a map of the format:
#   { meta.type = "..."; # The type of the data, as a string
#     ...                # The data contained
#   }
#
# The "meta.type" argument can be one of the following:
#  * "init": Init service, with a `command` argument
#  * "script": Script, with a `script` argument
#  * "symlink": Symlink, with `file` and `target` arguments
#  * "service": Service, with `name` and `script` arguments
#  * TODO(medium): this should be auto-generated from doc in each module
#  * Anything with a ':' in it, which is defined and used outside of NixtOS. A
#    user should prefix his types with 'user:' for personal use, and services
#    distributed for further use should be prefixed with 'domain.example.org:'
#
# `meta` is further reserved for future NixtOS usage.

# TODO(high): think about reverse-dependencies. Current idea:
#   rec {
#     logger = logger { ... };
#     foo = foo { logger = logger.interface; ... };
#   }
# Issue: HEAVY! don't want to pass the logger everywhere.
# Other idea: make it a two-step fix-point, first propagating
# reverse-dependencies, then extenders.

# TODO(high): simplify handling of extenders for extended modules

{ pkgs, top }:

# services: map service-name service
# where service = list extending-block -> map service-name service-extension
# where service-extension = extending-block | list extending-block
services:

let
  # all-extenders: map service-name (list extending-block)
  all-extenders = pkgs.lib.foldAttrs (n: a: n ++ a) [] (
    pkgs.lib.mapAttrsToList (name: service:
      pkgs.lib.mapAttrs (_: value: # TODO(low): consider removing if perf is hit
        if builtins.isList value then value
        else [ value ]
      ) (service (extenders-for name))
    ) services
  );

  # extenders-for: service-name -> list extending-block
  extenders-for = service: all-extenders.${service} or [];

  # TODO(medium) This should be moved to the simplified handling of extenders
  extenders-for-assert-type = service: type:
    map (e: assert e.meta.type == type; e) (extenders-for service);
in
{
  inherit extenders-for extenders-for-assert-type;
}
