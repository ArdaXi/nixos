{ config, lib, pkgs, ... }:

{
  options = {
    security.pam.services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options.u2fPin = lib.mkOption {
          default = false;
          type = lib.types.bool;
        };
        options.text = lib.mkOption {
          apply = v: if config.u2fPin then builtins.replaceStrings [ "pam_u2f.so" ] [ "pam_u2f.so pinverification=1" ] v else v;
          };
      }));
    };
  };
  config = {
    environment.systemPackages = [ pkgs.pam_u2f ];

    security.doas = {
      enable = true;
      extraRules = [ 
        {
          groups = [ "wheel" ];
          persist = true;
        }
      ];
    };

    security.pam.u2f.cue = true;

    security.pam.services = {
      sudo.u2fAuth = true;
      doas = {
        u2fAuth = true;
#        u2fPin = true;
      };
    };
  };
}
