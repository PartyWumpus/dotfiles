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
	#boot.loader.systemd-boot.enable = true;
	#boot.loader.efi.canTouchEfiVariables = true;

	boot.loader = {
		systemd-boot.enable = false;
		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot";
		};
		grub = {
			devices = [ "nodev" ];
			enable = true;
			efiSupport = true;
			useOSProber = true;
		};
	};

	fileSystems."/mnt" = {
		device = "/dev/disk/by-uuid/f346c230-d657-4376-a161-b29a9055568c";
		fsType = "btrfs";
		options = [
			"noatime"
			"compress=zstd:5"
		];
	};

}
