{
  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "virtual-slab";
        "netbios name" = "virtual-slab";
        security = "user";
        "hosts allow" = "10.0.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      zed = {
        path = "/home/whatever/mnt/storage";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "whatever";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
