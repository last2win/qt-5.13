
add_library(Qt5::QGifPlugin MODULE IMPORTED)

_populate_Gui_plugin_properties(QGifPlugin RELEASE "imageformats/qgif.lib")
_populate_Gui_plugin_properties(QGifPlugin DEBUG "imageformats/qgifd.lib")

list(APPEND Qt5Gui_PLUGINS Qt5::QGifPlugin)
