{ config, options, lib, pkgs, utils, ... }:

with lib;
with utils;

let

  cfg = config.ardaxi;
  interfaces = attrValues cfg.interfaces;

  # We must escape interfaces due to the systemd interpretation
  subsystemDevice = interface:
    "sys-subsystem-net-devices-${escapeSystemdPath interface}.device";

  hexChars = stringToCharacters "0123456789abcdef";

  isHexString = s: all (c: elem c hexChars) (stringToCharacters (toLower s));

in

{

  ###### interface

  options = {

    ardaxi.wlanInterfaces = mkOption {
      default = { };
      example = literalExample {
        "wlan-station0" = {
            device = "wlp6s0";
        };
        "wlan-adhoc0" = {
            type = "ibss";
            device = "wlp6s0";
            mac = "02:00:00:00:00:01";
        };
        "wlan-p2p0" = {
            device = "wlp6s0";
            mac = "02:00:00:00:00:02";
        };
        "wlan-ap0" = {
            device = "wlp6s0";
            mac = "02:00:00:00:00:03";
        };
      };
      description =
        ''
          Creating multiple WLAN interfaces on top of one physical WLAN device (NIC).

          The name of the WLAN interface corresponds to the name of the attribute.
          A NIC is referenced by the persistent device name of the WLAN interface that
          <literal>udev</literal> assigns to a NIC by default.
          If a NIC supports multiple WLAN interfaces, then the one NIC can be used as
          <literal>device</literal> for multiple WLAN interfaces.
          If a NIC is used for creating WLAN interfaces, then the default WLAN interface
          with a persistent device name form <literal>udev</literal> is not created.
          A WLAN interface with the persistent name assigned from <literal>udev</literal>
          would have to be created explicitly.
        '';

      type = with types; attrsOf (submodule {

        options = {

          device = mkOption {
            type = types.string;
            example = "wlp6s0";
            description = "The name of the underlying hardware WLAN device as assigned by <literal>udev</literal>.";
          };

          type = mkOption {
            type = types.enum [ "managed" "ibss" "monitor" "mesh" "wds" "__ap" ];
            default = "managed";
            example = "ibss";
            description = ''
              The type of the WLAN interface.
              The type has to be supported by the underlying hardware of the device.
            '';
          };

          meshID = mkOption {
            type = types.nullOr types.string;
            default = null;
            description = "MeshID of interface with type <literal>mesh</literal>.";
          };

          flags = mkOption {
            type = with types; nullOr (enum [ "none" "fcsfail" "control" "otherbss" "cook" "active" ]);
            default = null;
            example = "control";
            description = ''
              Flags for interface of type <literal>monitor</literal>.
            '';
          };

          fourAddr = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Whether to enable <literal>4-address mode</literal> with type <literal>managed</literal>.";
          };

          mac = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "02:00:00:00:00:01";
            description = ''
              MAC address to use for the device. If <literal>null</literal>, then the MAC of the
              underlying hardware WLAN device is used.

              INFO: Locally administered MAC addresses are of the form:
              <itemizedlist>
              <listitem><para>x2:xx:xx:xx:xx:xx</para></listitem>
              <listitem><para>x6:xx:xx:xx:xx:xx</para></listitem>
              <listitem><para>xA:xx:xx:xx:xx:xx</para></listitem>
              <listitem><para>xE:xx:xx:xx:xx:xx</para></listitem>
              </itemizedlist>
            '';
          };

        };

      });

    };

  };


  ###### implementation

  config = {

    services.udev.packages = mkIf (cfg.wlanInterfaces != {}) [
      (pkgs.writeTextFile {
        name = "99-zzz-40-wlanInterfaces.rules";
        destination = "/etc/udev/rules.d/99-zzz-40-wlanInterfaces.rules";
        text =
          let
            # Collect all interfaces that are defined for a device
            # as device:interface key:value pairs.
            wlanDeviceInterfaces =
              let
                allDevices = unique (mapAttrsToList (_: v: v.device) cfg.wlanInterfaces);
                interfacesOfDevice = d: filterAttrs (_: v: v.device == d) cfg.wlanInterfaces;
              in
                genAttrs allDevices (d: interfacesOfDevice d);

            # Convert device:interface key:value pairs into a list, and if it exists,
            # place the interface which is named after the device at the beginning.
            wlanListDeviceFirst = device: interfaces:
              if hasAttr device interfaces
              then mapAttrsToList (n: v: v//{_iName=n;}) (filterAttrs (n: _: n==device) interfaces) ++ mapAttrsToList (n: v: v//{_iName=n;}) (filterAttrs (n: _: n!=device) interfaces)
              else mapAttrsToList (n: v: v // {_iName = n;}) interfaces;

            # Udev script to execute for the default WLAN interface with the persistend udev name.
            # The script creates the required, new WLAN interfaces interfaces and configures the
            # existing, default interface.
            curInterfaceScript = device: current: new: pkgs.writeScript "udev-run-script-wlan-interfaces-${device}.sh" ''
              #!${pkgs.runtimeShell}
              # Change the wireless phy device to a predictable name.
              ${pkgs.iw}/bin/iw phy `${pkgs.coreutils}/bin/cat /sys/class/net/$INTERFACE/phy80211/name` set name ${device}

              # Add new WLAN interfaces
              ${flip concatMapStrings new (i: ''
              ${pkgs.iw}/bin/iw phy ${device} interface add ${i._iName} type managed
              '')}

              # Configure the current interface
              ${pkgs.iw}/bin/iw dev ${device} set type ${current.type}
              ${optionalString (current.type == "mesh" && current.meshID!=null) "${pkgs.iw}/bin/iw dev ${device} set meshid ${current.meshID}"}
              ${optionalString (current.type == "monitor" && current.flags!=null) "${pkgs.iw}/bin/iw dev ${device} set monitor ${current.flags}"}
              ${optionalString (current.type == "managed" && current.fourAddr!=null) "${pkgs.iw}/bin/iw dev ${device} set 4addr ${if current.fourAddr then "on" else "off"}"}
              ${optionalString (current.mac != null) "${pkgs.iproute}/bin/ip link set dev ${device} address ${current.mac}"}
            '';

            # Udev script to execute for a new WLAN interface. The script configures the new WLAN interface.
            newInterfaceScript = device: new: pkgs.writeScript "udev-run-script-wlan-interfaces-${new._iName}.sh" ''
              #!${pkgs.runtimeShell}
              # Configure the new interface
              ${pkgs.iw}/bin/iw dev ${new._iName} set type ${new.type}
              ${optionalString (new.type == "mesh" && new.meshID!=null) "${pkgs.iw}/bin/iw dev ${device} set meshid ${new.meshID}"}
              ${optionalString (new.type == "monitor" && new.flags!=null) "${pkgs.iw}/bin/iw dev ${device} set monitor ${new.flags}"}
              ${optionalString (new.type == "managed" && new.fourAddr!=null) "${pkgs.iw}/bin/iw dev ${device} set 4addr ${if new.fourAddr then "on" else "off"}"}
              ${optionalString (new.mac != null) "${pkgs.iproute}/bin/ip link set dev ${device} address ${new.mac}"}
            '';

            # Udev attributes for systemd to name the device and to create a .device target.
            systemdAttrs = n: ''NAME:="${n}", ENV{INTERFACE}:="${n}", ENV{SYSTEMD_ALIAS}:="/sys/subsystem/net/devices/${n}", TAG+="systemd"'';
          in
          flip (concatMapStringsSep "\n") (attrNames wlanDeviceInterfaces) (device:
            let
              interfaces = wlanListDeviceFirst device wlanDeviceInterfaces."${device}";
              curInterface = elemAt interfaces 0;
              newInterfaces = drop 1 interfaces;
            in ''
            # It is important to have that rule first as overwriting the NAME attribute also prevents the
            # next rules from matching.
            ${flip (concatMapStringsSep "\n") (wlanListDeviceFirst device wlanDeviceInterfaces."${device}") (interface:
            ''ACTION=="add", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", ENV{INTERFACE}=="${interface._iName}", ${systemdAttrs interface._iName}, RUN+="${newInterfaceScript device interface}"'')}

            # Add the required, new WLAN interfaces to the default WLAN interface with the
            # persistent, default name as assigned by udev.
            ACTION=="add", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", NAME=="${device}", ${systemdAttrs curInterface._iName}, RUN+="${curInterfaceScript device curInterface newInterfaces}"
            # Generate the same systemd events for both 'add' and 'move' udev events.
            ACTION=="move", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", NAME=="${device}", ${systemdAttrs curInterface._iName}
          '');
      }) ];

  };

}
