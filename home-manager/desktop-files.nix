{config, pkgs, ...}:
{
  # Custom desktop files
  xdg.desktopEntries = {
    whatsapp = {
      name = "Whatsapp";
      genericName = "Message";
      exec = "firefox -new-window https://web.whatsapp.com/";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };
}