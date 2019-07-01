
add_library(Qt5::QWindowsAudioPlugin MODULE IMPORTED)

_populate_Multimedia_plugin_properties(QWindowsAudioPlugin RELEASE "audio/qtaudio_windows.lib")
_populate_Multimedia_plugin_properties(QWindowsAudioPlugin DEBUG "audio/qtaudio_windowsd.lib")

list(APPEND Qt5Multimedia_PLUGINS Qt5::QWindowsAudioPlugin)
