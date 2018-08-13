{ config, pkgs, ... }:

{
  services.httpd = {
    enable = true;
    documentRoot = "/var/www";
    adminAddr = "admin@localhost";
    enablePHP = true;
    extraConfig = ''
      # Enable the rewrite engine
      RewriteEngine On

      # Short url for wiki pages
      RewriteRule ^/?wiki(/.*)?$ %{DOCUMENT_ROOT}/w/index.php [L]

      # Redirect / to Main Page
      RewriteRule ^/*$ %{DOCUMENT_ROOT}/w/index.php [L]

      # rewrite /entity/ URLs like wikidata per
      # https://meta.wikimedia.org/wiki/Wikidata/Notes/URI_scheme
      RewriteRule ^/?entity/(.*)$ /wiki/Special:EntityData/$1 [R=303,QSA]

      ProxyPass "/sparql"  "http://localhost:9999"
    '';
  };
}
