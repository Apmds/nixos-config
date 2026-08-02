{pkgs, ...}:

{
  programs.swayimg = {
    enable = true;
    initLua = ''
      swayimg.text.set_size(32)
      swayimg.text.set_foreground(0xffff0000)
      swayimg.viewer.set_window_background(0x00000000)
      swayimg.viewer.set_default_scale("fit")
      swayimg.viewer.set_image_background(0x00000000)
    '';
  };
}
