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
# `meta` is further reserved for future NixtOS usage. All other fields can be
# user-defined.
#
# When receiving an extender, `meta.source` will be set to the name of the
# service that generated said extender.

# TODO(high): think about reverse-dependencies. Current idea:
#   rec {
#     logger = logger { ... };
#     foo = foo { logger = logger.interface; ... };
#   }
# Issue: HEAVY! don't want to pass the logger everywhere.
# Other idea: make it a two-step fix-point, first propagating
# reverse-dependencies, then extenders.

# TODO(high): simplify handling of extenders for extended modules

# TODO(low): consider toposorting instead of fixpoint, for error msg & speed?

# TODO(medium): add a callPackage equivalent to avoid writing `dbus = "dbus"`

# TODO(low): consider adding lazy modules
# The point is to avoid the need for the user to have lines like
#   dbus = services.dbus {};
# in their configuration. The idea, for implementation, would be to split the
# “lazy” service set from the user-defined service set, and to use the
# callPackage-like (defined from the to-do item above) to automatically detect
# which dependencies are required.
# Then first do a DFS through the lazy//user package set to identify which
# dependencies are required, and second do the service solving from this service
# set.
# This is to be done iff some people express real-life annoyance at being forced
# to write explicitly all dependencies. But we must be ready to make this change
# at any point in time, without breaking anything else.

########################################################################
#                                                                      #
#             YOU WHO ENTER HERE WISHING TO MODIFY STUFF               #
#                                                                      #
# READ THE ABOVE TO-DO ITEMS AND MAKE SURE NOT TO MAKE THEM IMPOSSIBLE #
#                                                                      #
#              IMPLEMENTATION SIMPLICITY IS A STRENGTH                 #
#                                                                      #
########################################################################

{ pkgs, top }:

# services: map service-name service
# where service = list extending-block -> map service-name service-extension
# where service-extension = extending-block | list extending-block
services:

let
  # sanitize-extension: service-name -> service-extension
  #                     -> list extending-block
  #
  # Adds the `meta.source` attribute (and wraps in a list if need be)
  sanitize-extension = source: ext:
    builtins.map (e:
      e // { meta = e.meta // { inherit source; }; }
    ) (
      if builtins.isList ext then ext
      else [ ext ]
    );

  # all-extenders-from-service: service-name -> service
  #                             -> map service-name (list extending-block)
  #
  # All the extenders that one service generates, sanitized
  all-extenders-from-service = source: service:
    pkgs.lib.mapAttrs (_: ext:
      sanitize-extension source ext
    ) (service (extenders-for source));

  # all-extenders: map service-name (list extending-block)
  #
  # All the extenders, grouped by extended service
  all-extenders = pkgs.lib.foldAttrs (n: a: n ++ a) [] (
    pkgs.lib.mapAttrsToList all-extenders-from-service services
  );

  # extenders-for: service-name -> list extending-block
  #
  # List of all the extenders that target service `service`
  extenders-for = service: all-extenders.${service} or [];

  # TODO(medium) This should be moved to the simplified handling of extenders
  extenders-for-assert-type = service: type:
    map (e: assert e.meta.type == type; e) (extenders-for service);
in
{
  inherit all-extenders extenders-for extenders-for-assert-type;
}
