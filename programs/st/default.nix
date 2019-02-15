{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (st.override { conf = builtins.readFile ./config.h; })
  ];
}
