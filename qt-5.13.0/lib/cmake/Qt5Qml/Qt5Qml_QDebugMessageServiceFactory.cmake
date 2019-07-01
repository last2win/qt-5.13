
add_library(Qt5::QDebugMessageServiceFactory MODULE IMPORTED)

_populate_Qml_plugin_properties(QDebugMessageServiceFactory RELEASE "qmltooling/qmldbg_messages.lib")
_populate_Qml_plugin_properties(QDebugMessageServiceFactory DEBUG "qmltooling/qmldbg_messagesd.lib")

list(APPEND Qt5Qml_PLUGINS Qt5::QDebugMessageServiceFactory)
