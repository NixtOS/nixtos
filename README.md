# NixtOS

NixtOS, the next-generation NixOS that builds on both GuixSD concepts on
steroids and nixpkgs.

The objectives are (from most fundamental to most user-facing):
 * Clearly defined dependencies between modules
 * Modularity in the modules: each module should be possible to take out to
   replace it by another module fulfilling the same interface
 * Mixing modules from multiple release channels (eg. core system from stable,
   but unstable services like matrix-synapse from unstable), feature which
   naturally follows from modularity
