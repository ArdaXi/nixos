# NixOS config
This is my personal collection of configuration for NixOS machines. It is
intended to be sanely structured and relatively easy to follow.

## How to use
You'll want your own repository for this. Generally, I follow the NixOS Manual
until right after the nixos-generate-config, copy
`/etc/nixos/hardware-configuration.nix` to a safe place, clone this repo as
`/etc/nixos/` and turn that `hardware-configuration.nix` file into a file in
the machines folder. All that's left then is to run
`echo -n HOST > /etc/nixos/hostname` with the name of the file in `machines`.

## Structure
This repository is currently divided up in machines and profiles. Machines are
per-machine declarations, such as what device the bootloader lives on, and
specific hardware support. Profiles are generic functional declarations of
packages I want installed and configurations for them.

### Machines
#### Hiro
Hiro is my main laptop. The configuration is for a Luks-encrypted ZFS pool,
which is booted in UEFI-mode using gummiboot. It includes the default, desktop
and project profiles, see below.

#### Raven
Raven was the machine I used to develop these profiles in a VM before fully
switching over. It is incomplete and will likely be deleted soon.

### Profiles
#### Default
The default profile is intended to go on any machine I control, desktops and
servers. It sets up my user with my SSH key, internationalization, OpenSSH,
NetworkManager, and installs a bunch of packages I like to have available.

#### Desktop
The desktop profile goes on all my machines that end up being used with a
monitor, such as desktops and laptops. It sets up the X server, the SLiM
display manager set to auto-login to my user and boot into awesome, and
various packages I like to use.

#### Project
I set up the project profile because I tend to end up having to install a
bunch of packages for a project or a job that I won't need any more once I'm
done with it. Most of these things go into a nix-shell, but some I need
globally available. By putting them in a separate profile I know exactly what
file to go through and clear out when I stop working somewhere.
