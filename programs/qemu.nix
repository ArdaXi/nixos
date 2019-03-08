{ pkgs, ... }:
let inherit (pkgs) stdenv qemu getopt; in
{
    fileSystems."/proc/sys/fs/binfmt_misc" = {
        fsType = "binfmt_misc";
        device = "binfmt_misc";
    };
    environment.etc."binfmt.d/qemu-user.conf".source = stdenv.mkDerivation {
        name = "qemu-binfmt";
        inherit (qemu) src;
        buildInputs = [ getopt ];
        configurePhase = ''
            patchShebangs scripts/qemu-binfmt-conf.sh
        '';
        buildPhase = ''
            mkdir binfmt
            scripts/qemu-binfmt-conf.sh --qemu-path ${qemu}/bin --systemd ALL --exportdir=binfmt
        '';
        installPhase = ''
            cat binfmt/*.conf > $out
        '';
    };
    nix = {
        sandboxPaths = [ "${qemu}" ];
        extraOptions = ''
            extra-platforms = i686-linux aarch64-linux armv5tel-linux armv6l-linux armv7l-linux mips64-linux mipsel-linux
        '';
    };
}
