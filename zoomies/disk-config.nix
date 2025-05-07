{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          relatime = "on";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        mountpoint = "/";
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
