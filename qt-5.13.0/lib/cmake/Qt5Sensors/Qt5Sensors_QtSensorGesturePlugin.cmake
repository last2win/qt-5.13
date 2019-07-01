
add_library(Qt5::QtSensorGesturePlugin MODULE IMPORTED)

_populate_Sensors_plugin_properties(QtSensorGesturePlugin RELEASE "sensorgestures/qtsensorgestures_plugin.lib")
_populate_Sensors_plugin_properties(QtSensorGesturePlugin DEBUG "sensorgestures/qtsensorgestures_plugind.lib")

list(APPEND Qt5Sensors_PLUGINS Qt5::QtSensorGesturePlugin)
