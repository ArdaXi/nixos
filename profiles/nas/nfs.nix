{ ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export             *(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/media       *(insecure,rw,sync,no_subtree_check,crossmnt,fsid=1)
      /export/media/tv    *(insecure,rw,sync,no_subtree_check,nohide,fsid=2)
      /export/media/films *(insecure,rw,sync,no_subtree_check,nohide,fsid=3)
    '';
  };

  fileSystems."/export/media" = {
    device = "/media";
    options = ["rbind"];
  };
}
