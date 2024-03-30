# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	#imports =
	#  [ # Include the results of the hardware scan.
	#		 ./hardware-configuration.nix
	#  ];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	fileSystems = {
		"/".options = [ "compress=zstd"];
	};

	services.fprintd = {
		enable = true;
	};
	services.fwupd.enable = true;

	# suspend to RAM (deep) rather than `s2idle`
	boot.kernelParams = [ "mem_sleep_default=deep" ];
	# suspend-then-hibernate
	systemd.sleep.extraConfig = ''
		HibernateDelaySec=30m
		SuspendState=mem
	'';

	services.tlp = {
		enable = true;
		settings = {
			CPU_SCALING_GOVERNOR_ON_AC = "performance";
			CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

			CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
			CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

			CPU_MIN_PERF_ON_AC = 0;
			CPU_MAX_PERF_ON_AC = 100;
			CPU_MIN_PERF_ON_BAT = 0;
			CPU_MAX_PERF_ON_BAT = 20;
		};
	};

	# autosuspends keyboard so unusable
	# also doesn't appear to make huge diff so its okay
	#powerManagement.powertop.enable = true;

	environment.systemPackages = with pkgs; [
		fwupd
	];


}
