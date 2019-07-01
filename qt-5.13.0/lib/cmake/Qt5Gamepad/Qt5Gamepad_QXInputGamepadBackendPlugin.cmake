
add_library(Qt5::QXInputGamepadBackendPlugin MODULE IMPORTED)

_populate_Gamepad_plugin_properties(QXInputGamepadBackendPlugin RELEASE "gamepads/xinputgamepad.lib")
_populate_Gamepad_plugin_properties(QXInputGamepadBackendPlugin DEBUG "gamepads/xinputgamepadd.lib")

list(APPEND Qt5Gamepad_PLUGINS Qt5::QXInputGamepadBackendPlugin)
