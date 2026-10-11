{ ...
}: {
  programs.zathura.enable = true;

  # the pdf default, xdg-open hands them to libreoffice draw otherwise
  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "org.pwmt.zathura.desktop";
  };
}
