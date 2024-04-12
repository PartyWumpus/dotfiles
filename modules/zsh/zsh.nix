
{ options, config, lib, pkgs, ...}:

{
	programs.zsh = {
		enable = true;
		enableCompletion = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;

		shellAliases = {
			update = "sudo nixos-rebuild switch --flake ~/nixos#${builtins.getEnv "HOSTNAME"} --impure";
			#update = "sudo nixos-rebuild switch --flake ~/nixos#default --impure";
		};

		history.size = 10000;
		history.path = "${config.xdg.dataHome}/zsh/history";

		plugins = [
		{
			name = "powerlevel10k";
			src = pkgs.zsh-powerlevel10k;
			file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
		}
		{
			name = "powerlevel10k-config";
			src = ./plugins;
			file = "p10k.zsh";
		}
		];
	};
}
