{ pkgs, top }:

{
  block-device, # The (linux) block device on which to install GRUB
  config-dir, # The path to the directory (each mount point must be used only
              # once where GRUB will put its config files
  # TODO(high): This has no reason to be there, disks should be just search'd
  config-dir-grub-device, # The device name (for GRUB) the config-dir is on
  config-dir-grub-dir, # The path (with ${config-dir-grub-device} as the root)
                       # to ${config-dir}
  os, # The OS to boot (TODO(high): that's not supposed to be there, but fetched
      # from the profile generations list?)
}:

let
  config = pkgs.writeText "grub.cfg" ''
    # TODO(medium): Handle grub-reboot

    menuentry "NixtOS - Default" {
      # TODO(high): Remove this console=ttyS0 argument if not requested for
      linux ${config-dir-grub-device}/${config-dir-grub-dir}/grub/kernel init=${os}/init console=ttyS0
      initrd ${config-dir-grub-device}/${config-dir-grub-dir}/grub/initrd
    }
  '';
in

pkgs.writeScript "install-grub-bios" ''
  #!/bin/sh

  mkdir -p ${config-dir}/grub

  # TODO(medium): do not copy if it's already there
  cp ${os}/{kernel,initrd} ${config-dir}/grub

  # TODO(medium): Atomically change config
  cp ${config} ${config-dir}/grub/grub.cfg

  # TODO(medium): Do not re-install if it's already installed
  grub-install --boot-directory=${config-dir} ${block-device}
''
