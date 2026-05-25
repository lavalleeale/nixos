{ config, pkgs, pkgs-unstable, ... }:
let authentikProxyListenHTTP = "127.0.0.1:9005";
in {
  boot.loader.grub.device = "nodev";
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
  nixpkgs.config.permittedInsecurePackages = [ "mongodb-7.0.25" ];
  virtualisation.vmVariant = {
    virtualisation.memorySize = 8096;
    virtualisation.forwardPorts = [
      {
        host.port = 8000;
        guest.port = 8000;
        from = "host";
      }
      {
        host.port = 9000;
        guest.port = 9000;
        from = "host";
      }
      {
        host.port = 2222;
        guest.port = 22;
        from = "host";
      }
      {
        host.port = 8443;
        guest.port = 8443;
        from = "host";
      }
      {
        host.port = 2283;
        guest.port = 2283;
        from = "host";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 22 80 443 8000 8443 9000 2283 ];
  services = {
    immich = { enable = true; };
    authentik = {
      enable = true;
      # The environmentFile needs to be on the target host!
      # Best use something like sops-nix or agenix to manage it
      environmentFile = config.sops.secrets.authentik-env.path;
      settings = {
        disable_startup_analytics = true;
        disable_update_check = true;
        error_reporting.enabled = false;
        avatars = "initials";
      };
    };
    authentik-proxy = {
      enable = true;
      listenHTTP = authentikProxyListenHTTP;
      environmentFile = config.sops.secrets.authentik-env.path;
    };
    caddy = {
      enable = true;
      configFile = ./caddy/Caddyfile;
    };
    unifi = {
      enable = true;
      openFirewall = true;
      unifiPackage = pkgs-unstable.unifi;
    };
  };
  sops = {
    defaultSopsFile = ./secrets/example.yaml;
    # This will automatically import SSH keys as age keys
    age.keyFile = "/var/lib/sops-nix/key.txt";
    # This is the actual specification of the secrets.
    secrets.authentik-env = { };
  };
  systemd.services.authentik.environment = {
    AUTHENTIK_BOOTSTRAP_EMAIL = "akadmin@localhost";
    AUTHENTIK_BOOTSTRAP_PASSWORD = "test";
  };
  systemd.services.authentik-worker.environment = {
    AUTHENTIK_BOOTSTRAP_EMAIL = "akadmin@localhost";
    AUTHENTIK_BOOTSTRAP_PASSWORD = "test";
  };
  users.users.root.initialPassword = "password";
}
