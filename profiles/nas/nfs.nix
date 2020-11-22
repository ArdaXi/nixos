{ ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export       *(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/media *(insecure,rw,sync,no_subtree_check)
    '';
  };

  fileSystems."/export/media" = {
    device = "/media";
    options = ["bind"];
  };
}
