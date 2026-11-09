{options, pkgs, ...}:

{
  programs.nix-ld = {
    enable = true;
    libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; [
      alsa-lib
      libGL
      libGLU
      libglvnd
      libdrm
      libpulseaudio
      libxkbcommon
      libdecor
      pipewire
      vulkan-loader
      wayland
      libx11
      libxcursor
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxinerama
      libxxf86vm
      libxcb
    ]);
  };

  environment.systemPackages = [
    # Fix for python to use nix-ld libraries and to make pygame, sdl, etc. work out of the box
    (pkgs.writeShellScriptBin "pythonld" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec -a "$0" ${pkgs.python314}/bin/python "$@"
    '')
  ];
}
