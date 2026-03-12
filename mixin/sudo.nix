{ ... }: {
  systemd.enableEmergencyMode = false;
  security.sudo.wheelNeedsPassword = false;
}
