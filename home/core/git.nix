{ userFullName
, userEmail
, ...
}: {
  programs.git = {
    enable = true;
    settings.user = {
      name = userFullName;
      email = userEmail;
    };
  };
}
