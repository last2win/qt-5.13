
add_library(Qt5::QWindowsDirect2DIntegrationPlugin MODULE IMPORTED)

_populate_Gui_plugin_properties(QWindowsDirect2DIntegrationPlugin RELEASE "platforms/qdirect2d.lib")
_populate_Gui_plugin_properties(QWindowsDirect2DIntegrationPlugin DEBUG "platforms/qdirect2dd.lib")

list(APPEND Qt5Gui_PLUGINS Qt5::QWindowsDirect2DIntegrationPlugin)
