{ config, pkgs, ... }:

{
  services.languagetool = {
    enable = true;
    port = 9111;
    public = true;
    allowOrigin = "";
    settings = {
      languageModel = "/var/lib/languagetool/ngrams";
     #  --word2vecModel /var/lib/languagetool/word2vec
    };
  };
}
