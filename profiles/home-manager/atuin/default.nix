{ config, lib, pkgs, ... }:

let
  atuin = "${config.home.profileDirectory}/bin/atuin";
  hook = {
    matcher = "^Bash$";
    hooks = [{ type = "command"; command = "${atuin} hook claude-code"; }];
  };
  events = [ "PreToolUse" "PostToolUse" "PostToolUseFailure" ];
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    daemon.enable = true;
    settings = {
      update_check = false;
      enter_accept = true;
      threads.capture = true;
    };
  };

  home.activation.atuinSocketDir = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    run mkdir -p ${lib.escapeShellArg (dirOf config.programs.atuin.settings.daemon.socket_path)}
  '';

  home.activation.atuinClaudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    [ -s "$settings" ] || echo '{}' > "$settings"
    tmp=$(mktemp)
    ${lib.getExe pkgs.jq} --argjson hook ${lib.escapeShellArg (builtins.toJSON hook)} '
      reduce ${builtins.toJSON events}[] as $e (.;
        .hooks[$e] = ([(.hooks[$e] // [])[]
          | select(any(.hooks[]?; .command | test("atuin hook claude-code")) | not)] + [$hook]))
    ' "$settings" > "$tmp"
    if cmp -s "$tmp" "$settings"; then rm "$tmp"; else run mv "$tmp" "$settings"; fi
  '';
}
