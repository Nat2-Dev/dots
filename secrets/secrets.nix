let
  nat = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEBN1C/1EatKLnv84NiVSc7aEDirVfKyfKDmSf1PP5r nat@zoomies";
  users = [ nat ];

  zoomies = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEBN1C/1EatKLnv84NiVSc7aEDirVfKyfKDmSf1PP5r nat@zoomies";
  systems = [ zoomies ];
in
{
  "wifi.age".publicKeys = [ nat zoomies ];
  "wakatime.age".publicKeys = [ nat zoomies ];
}
