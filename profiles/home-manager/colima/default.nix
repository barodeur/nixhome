{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-client
    docker-compose
    docker-buildx
  ];

  programs.docker-cli = {
    enable = true;
    settings.cliPluginsExtraDirs = [
      "${pkgs.docker-compose}/libexec/docker/cli-plugins"
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins"
    ];
  };

  services.colima = {
    enable = true;
    profiles.default = {
      isActive = true;
      isService = true;
      mutableSettings = true;
      settings = {
        runtime = "docker";
        cpu = 4;
        memory = 8;
        disk = 100;
        vmType = "vz";
        mountType = "virtiofs";
        rosetta = true;
      };
    };
  };

  launchd.agents.colima-default.config.ProgramArguments = lib.mkBefore [
    "/bin/sh"
    "-c"
    ''/usr/bin/arch -x86_64 /usr/bin/true; PATH="$PATH:/usr/bin" exec "$@"''
    "colima-start"
  ];
}
