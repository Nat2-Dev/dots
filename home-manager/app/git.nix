{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # git config
  programs.git = {
    enable = true;
    userName = "Nat";
    userEmail = "hellohumans963@gmail.com";
    aliases = {
      c = "commit";
      p = "push";
      ch = "checkout";
      pushfwl = "push --force-with-lease --force-if-includes";
    };
    extraConfig = {
      branch.sort = "-committerdate";
      pager.branch = false;
      column.ui = "auto";
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowedSigners";
      user.signingKey = "~/.ssh/nat_id_ed25519.pub";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
