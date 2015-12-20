{stdenv, callPackage, kernel, vmwareModules ? [ "vmblock" "vmmon" "vmnet" "vmci" "vsock" ]}:
let
  vmware-workstation = callPackage ../vmware-workstation {};
in
stdenv.mkDerivation rec {
  inherit vmwareModules;

  name = "vmware-modules-${vmware-workstation.version}-${kernel.version}";

  srcs = map (module: vmware-workstation + "/lib/vmware/modules/source/" + module + ".tar") vmwareModules;

  patches = [
    ./304-3.10-01-inode.patch
    ./304-3.10-02-control.patch
    ./304-3.11-00-readdir.patch
    ./304-3.15-00-vsock.patch
    ./304-3.19-02-vmblock-path.patch
    ./304-3.19-04-iovec.patch
    ./304-3.19-05-vmci_qpair.patch
    ./304-3.19-06-vsock.patch
    ./304-3.19-07-vsock.patch 
  ];

  unpackPhase = ''
    local src; for src in $srcs
    do
      tar xf $src
    done
    ls
  '';

  buildPhase = ''
    export VM_KBUILD=yes
    export LINUXINCLUDE=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/include
    local module; for module in $vmwareModules
    do
      cd $module-only
      make
      cd ../
    done
  '';

  installPhase = ''
    local module; for module in $vmwareModules
    do
      install -v -D -m 644 $module.o "$out/lib/modules/${kernel.modDirVersion}/misc/$module.ko"
    done
    #mkdir $out
    #cp -r * $out/
  '';
}
