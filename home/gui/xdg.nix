{ ...
}: {
  # the standard folders every desktop app asks for, declared once so none of them invents its own
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # apps read the file, the shell needs no XDG_*_DIR variables
    setSessionVariables = false;
    # never used on a tiling desktop, null keeps them out of the file and off the disk
    desktop = null;
    templates = null;
    publicShare = null;
    music = null;
    videos = null;
    # the module's own addition to the standard set, repos live where they are
    projects = null;
  };
}
