{ config, pkgs, ... }:
let
  nurpkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
  onePassPath = "~/.1password/agent.sock";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "stafford";
  home.homeDirectory = "/home/stafford";

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    settings."org/gnome/shell" = {
      favorite-apps = [ "1password.desktop" "org.gnome.Terminal.desktop" "firefox.desktop" ];
    };
    settings."org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ "<super>1" ];
      switch-to-application-2 = [ "<super>2" ];
      switch-to-application-3 = [ "<super>3" ];
      switch-to-application-4 = [ "<super>4" ];
    };
  };



  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    signal-desktop
    nixpkgs-fmt
    gnome-extension-manager
    gnomeExtensions.dash-to-dock
    gnomeExtensions.random-wallpaper
    vlc
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/stafford/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.firefox =
    {
      enable = true;
      package = pkgs.firefox.override
        {
          nativeMessagingHosts = [
            pkgs.gnome-browser-connector
          ];
        };
      profiles = {
        stafford = {
          extensions = with nurpkgs.repos.rycee.firefox-addons; [
            ublock-origin
            onepassword-password-manager
          ];
        };
      };
    };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
    userSettings = {
      "editor.minimap.enabled" = false;
      "security.workspace.trust.untrustedFiles" = "open";
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
    };
    keybindings = [
      {
        key = "alt+right";
        command = "workbench.action.navigateForward";
        when = "canNavigateForward";
      }
      {
        key = "alt+left";
        command = "workbench.action.navigateBack";
        when = "canNavigateBack";
      }
      {
        key = "ctrl+shift+s";
        command = "-workbench.action.files.saveLocalFile";
        when = "remoteFileDialogVisible";
      }
      {
        key = "ctrl+shift+s";
        command = "workbench.action.files.saveAll";
      }
      {
        key = "ctrl+shift+alt+up";
        command = "editor.action.insertCursorAbove";
        when = "editorTextFocus";
      }
      {
        key = "shift+alt+up";
        command = "-editor.action.insertCursorAbove";
        when = "editorTextFocus";
      }
      {
        key = "shift+alt+up";
        command = "editor.action.copyLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+alt+up";
        command = "-editor.action.copyLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+alt+down";
        command = "editor.action.insertCursorBelow";
        when = "editorTextFocus";
      }
      {
        key = "shift+alt+down";
        command = "-editor.action.insertCursorBelow";
        when = "editorTextFocus";
      }
      {
        key = "shift+alt+down";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+alt+down";
        command = "-editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
    ];
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source /home/stafford/.config/op/plugins.sh
      cd ~/git
      export SSH_AUTH_SOCK=~/.1password/agent.sock
    '';
  };

  programs.git = {
    enable = true;
    userName = "Stafford Williams";
    userEmail = "stafford.williams@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.ssh = {
    enable = true;
  };
}
