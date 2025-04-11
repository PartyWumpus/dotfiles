# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "laptop";

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      configurationLimit = 20;
      devices = [ "nodev" ];
      enable = true;
      efiSupport = true;
      useOSProber = true;
    };
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
  };

  # fingerprint
  services.fprintd.enable = true;
  services.fwupd.enable = true;

  boot.kernelParams = [
    "amd_pstate=passive"
    # suspend to RAM (deep) rather than `s2idle`
    #"mem_sleep_default=deep"
    # fix suspend
    #"rtc_cmos.use_acpi_alarm=1"
  ];

  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=10m
    SuspendState=mem
  '';

  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitchExternalPower = "suspend-then-hibernate";
  services.logind.lidSwitchDocked = "ignore";

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  # for framework 16 led thingy
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0020", MODE="0660", TAG+="uaccess"
  '';

  # autosuspends keyboard so unusable
  # also doesn't appear to make huge diff so its okay
  #powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [ fwupd ];

}
