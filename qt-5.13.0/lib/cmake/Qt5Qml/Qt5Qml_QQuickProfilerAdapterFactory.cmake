
add_library(Qt5::QQuickProfilerAdapterFactory MODULE IMPORTED)

_populate_Qml_plugin_properties(QQuickProfilerAdapterFactory RELEASE "qmltooling/qmldbg_quickprofiler.lib")
_populate_Qml_plugin_properties(QQuickProfilerAdapterFactory DEBUG "qmltooling/qmldbg_quickprofilerd.lib")

list(APPEND Qt5Qml_PLUGINS Qt5::QQuickProfilerAdapterFactory)
