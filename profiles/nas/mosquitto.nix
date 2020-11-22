{ ... }:

{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    allowAnonymous = true;
    aclExtraConf = "topic readwrite #";
    users = {
      homeassistant.acl = [
        "topic readwrite homeassistant/#"
        "topic read #"
      ];
    };
  };
}
