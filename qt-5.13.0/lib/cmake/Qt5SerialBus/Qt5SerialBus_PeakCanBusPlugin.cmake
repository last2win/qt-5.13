
add_library(Qt5::PeakCanBusPlugin MODULE IMPORTED)

_populate_SerialBus_plugin_properties(PeakCanBusPlugin RELEASE "canbus/qtpeakcanbus.lib")
_populate_SerialBus_plugin_properties(PeakCanBusPlugin DEBUG "canbus/qtpeakcanbusd.lib")

list(APPEND Qt5SerialBus_PLUGINS Qt5::PeakCanBusPlugin)
