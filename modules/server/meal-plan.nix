{ config
, lib
, pkgs
, username
, ...
}:
let
  # flips the timers on, the services run by hand either way
  scheduled = false;

  # the prompt is the approval for that task's writes
  prompts = {
    propose = "Use the meal-plan skill: propose the plan for next week (Monday to Sunday). This scheduled run is the approval for writing the meal plan entries. Reply only with the summary.";
    list = "Use the meal-plan skill: build the shopping list for the week starting next Monday from the plan as it is now. This scheduled run is the approval for adding the shopping list items. Reply only with the summary.";
  };

  # only the tools the skill needs, everything else is denied without a prompt
  run = name: title: pkgs.writeShellScript "meal-plan-${name}" ''
    summary=$(claude -p "${prompts.${name}}" --output-format text \
      --tools "Bash,Read,Skill" \
      --allowedTools "Bash(curl *)" "Bash(jq *)" "Bash(python3 *)" "Read" "Skill" \
      --permission-mode dontAsk --permission-prompts none \
      --max-budget-usd 2) # a brake for a run that loops, the subscription pays
    ntfy-send "${title}" "$summary" default
  '';

  service = name: title: description: {
    inherit description;
    # claude from the user profile, ntfy-send from the system profile
    path = [ "/etc/profiles/per-user/${username}" "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
      # the skills and the mealie token live in this user's setup
      EnvironmentFile = config.sops.templates."claude.env".path;
      # nothing of a run lands in the home
      RuntimeDirectory = "meal-plan-${name}";
      WorkingDirectory = "/run/meal-plan-${name}";
      ExecStart = run name title;
    };
  };

  timer = calendar: {
    wantedBy = lib.optional scheduled "timers.target";
    timerConfig = {
      OnCalendar = calendar;
      # a box that was off at the time runs it on the next boot
      Persistent = true;
    };
  };
in
{
  # the long-lived token from `claude setup-token`
  sops.secrets."claude-oauth-token".owner = username;
  sops.templates."claude.env" = {
    content = "CLAUDE_CODE_OAUTH_TOKEN=${config.sops.placeholder."claude-oauth-token"}";
    owner = username;
  };

  systemd.services = {
    meal-plan-propose = service "propose" "Meal plan proposed" "propose next week's meal plan in mealie";
    meal-plan-list = service "list" "Shopping list built" "build the shopping list from the week's meal plan";
  };

  systemd.timers = {
    meal-plan-propose = timer "Fri 07:00";
    meal-plan-list = timer "Sat 07:00";
  };
}
