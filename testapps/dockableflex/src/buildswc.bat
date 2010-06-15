@echo off

compc -source-path . -include-file defaults.css defaults.css -include-file ResizeButton.swf ResizeButton.swf -namespace http://dockable.goozo.net manifest.xml -include-namespaces http://dockable.goozo.net -o Dockable.swc  

pause
