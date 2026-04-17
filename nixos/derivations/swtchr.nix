{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, wrapGAppsHook4
, gtk4
, gtk4-layer-shell
, librsvg
}:

rustPlatform.buildRustPackage rec {
  pname = "swtchr";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "lostatc";
    repo = "swtchr";
    rev = "v${version}";
    hash = "sha256-zAvkL5qdFN2oSGttjndtn3uLEYVitZvJS1bUF1UG/xg=";
  };

  cargoHash = "sha256-hImlVfvTggGKsnZvjvJ3et8/Oje7Y2/F7HxexI/jUIg=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    librsvg
  ];

  postInstall = ''
    install -Dm444 etc/swtchrd.service -t $out/lib/systemd/user
    substituteInPlace $out/lib/systemd/user/swtchrd.service \
      --replace "ExecStart=%h/.cargo/bin/swtchrd" "ExecStart=$out/bin/swtchrd"
  '';

  meta = with lib; {
    description = "A Gnome-style window switcher for the Sway window manager";
    homepage = "https://github.com/lostatc/swtchr";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "swtchr";
  };
}
