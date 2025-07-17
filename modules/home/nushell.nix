{ ... }:
{
  config = {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
      extraConfig = ''
        # Refer to https://www.nushell.sh/cookbook/ssh_agent.html#workarounds
        do --env {
          let ssh_agent_file = (
              $nu.temp-path | path join $"ssh-agent-($env.USER).nuon"
          )

          if ($ssh_agent_file | path exists) {
              let ssh_agent_env = open ($ssh_agent_file)
              if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
                  load-env $ssh_agent_env
                  return
              } else {
                  rm $ssh_agent_file
              }
          }

          let ssh_agent_env = ^ssh-agent -c
              | lines
              | first 2
              | parse "setenv {name} {value};"
              | transpose --header-row
              | into record
          load-env $ssh_agent_env
          $ssh_agent_env | save --force $ssh_agent_file
        }
      '';
    };
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
