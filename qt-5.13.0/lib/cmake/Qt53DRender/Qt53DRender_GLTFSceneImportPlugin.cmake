
add_library(Qt5::GLTFSceneImportPlugin MODULE IMPORTED)

_populate_3DRender_plugin_properties(GLTFSceneImportPlugin RELEASE "sceneparsers/gltfsceneimport.lib")
_populate_3DRender_plugin_properties(GLTFSceneImportPlugin DEBUG "sceneparsers/gltfsceneimportd.lib")

list(APPEND Qt53DRender_PLUGINS Qt5::GLTFSceneImportPlugin)
