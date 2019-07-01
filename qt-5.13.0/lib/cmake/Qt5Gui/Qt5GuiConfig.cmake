
if (CMAKE_VERSION VERSION_LESS 3.1.0)
    message(FATAL_ERROR "Qt 5 Gui module requires at least CMake version 3.1.0")
endif()

get_filename_component(_qt5Gui_install_prefix "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

# For backwards compatibility only. Use Qt5Gui_VERSION instead.
set(Qt5Gui_VERSION_STRING 5.13.0)

set(Qt5Gui_LIBRARIES Qt5::Gui)

macro(_qt5_Gui_check_file_exists file)
    if(NOT EXISTS "${file}" )
        message(FATAL_ERROR "The imported target \"Qt5::Gui\" references the file
   \"${file}\"
but this file does not exist.  Possible reasons include:
* The file was deleted, renamed, or moved to another location.
* An install or uninstall procedure did not complete successfully.
* The installation package was faulty and contained
   \"${CMAKE_CURRENT_LIST_FILE}\"
but not all the files it references.
")
    endif()
endmacro()

function(_qt5_Gui_process_prl_file prl_file_location Configuration lib_deps link_flags)
    set(_lib_deps)
    set(_link_flags)

    get_filename_component(_qt5_install_libs "${_qt5Gui_install_prefix}/lib" ABSOLUTE)

    if(EXISTS "${prl_file_location}")
        file(STRINGS "${prl_file_location}" _prl_strings REGEX "QMAKE_PRL_LIBS[ \t]*=")
        string(REGEX REPLACE "QMAKE_PRL_LIBS[ \t]*=[ \t]*([^\n]*)" "\\1" _static_depends ${_prl_strings})
        string(REGEX REPLACE "[ \t]+" ";" _static_depends ${_static_depends})
        string(REGEX REPLACE "[ \t]+" ";" _standard_libraries "${CMAKE_CXX_STANDARD_LIBRARIES}")
        set(_search_paths)
        string(REPLACE "\$\$[QT_INSTALL_LIBS]" "${_qt5_install_libs}" _static_depends "${_static_depends}")
        foreach(_flag ${_static_depends})
            string(REPLACE "\"" "" _flag ${_flag})
            if(_flag MATCHES "^-l(.*)$")
                # Handle normal libraries passed as -lfoo
                set(_lib "${CMAKE_MATCH_1}")
                foreach(_standard_library ${_standard_libraries})
                    if(_standard_library MATCHES "^${_lib}(\.lib)?$")
                        set(_lib_is_default_linked TRUE)
                        break()
                    endif()
                endforeach()
                if (_lib_is_default_linked)
                    unset(_lib_is_default_linked)
                elseif(_lib MATCHES "^pthread$")
                    find_package(Threads REQUIRED)
                    list(APPEND _lib_deps Threads::Threads)
                else()
                    if(_search_paths)
                        find_library(_Qt5Gui_${Configuration}_${_lib}_PATH ${_lib} HINTS ${_search_paths} NO_DEFAULT_PATH)
                    endif()
                    find_library(_Qt5Gui_${Configuration}_${_lib}_PATH ${_lib})
                    mark_as_advanced(_Qt5Gui_${Configuration}_${_lib}_PATH)
                    if(_Qt5Gui_${Configuration}_${_lib}_PATH)
                        list(APPEND _lib_deps
                            ${_Qt5Gui_${Configuration}_${_lib}_PATH}
                        )
                    else()
                        message(FATAL_ERROR "Library not found: ${_lib}")
                    endif()
                endif()
            elseif(EXISTS "${_flag}")
                # The flag is an absolute path to an existing library
                list(APPEND _lib_deps "${_flag}")
            elseif(_flag MATCHES "^-L(.*)$")
                # Handle -Lfoo flags by putting their paths in the search path used by find_library above
                list(APPEND _search_paths "${CMAKE_MATCH_1}")
            else()
                # Handle all remaining flags by simply passing them to the linker
                list(APPEND _link_flags ${_flag})
            endif()
        endforeach()
    endif()

    string(REPLACE ";" " " _link_flags "${_link_flags}")
    set(${lib_deps} ${_lib_deps} PARENT_SCOPE)
    set(${link_flags} "SHELL:${_link_flags}" PARENT_SCOPE)
endfunction()

macro(_populate_Gui_target_properties Configuration LIB_LOCATION IMPLIB_LOCATION)
    set_property(TARGET Qt5::Gui APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

    set(imported_location "${_qt5Gui_install_prefix}/lib/${LIB_LOCATION}")
    _qt5_Gui_check_file_exists(${imported_location})
    set(_deps
        ${_Qt5Gui_LIB_DEPENDENCIES}
        ${_Qt5Gui_STATIC_${Configuration}_LIB_DEPENDENCIES}
    )
    set_target_properties(Qt5::Gui PROPERTIES
        "INTERFACE_LINK_LIBRARIES" "${_deps}"
        "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        # For backward compatibility with CMake < 2.8.12
        "IMPORTED_LINK_INTERFACE_LIBRARIES_${Configuration}" "${_deps}"
    )

    if(NOT CMAKE_VERSION VERSION_LESS "3.13")
        set_target_properties(Qt5::Gui PROPERTIES
            "INTERFACE_LINK_OPTIONS" "${_Qt5Gui_STATIC_${Configuration}_LINK_FLAGS}"
        )
    endif()

    set(imported_implib "${_qt5Gui_install_prefix}/lib/${IMPLIB_LOCATION}")
    _qt5_Gui_check_file_exists(${imported_implib})
    if(NOT "${IMPLIB_LOCATION}" STREQUAL "")
        set_target_properties(Qt5::Gui PROPERTIES
        "IMPORTED_IMPLIB_${Configuration}" ${imported_implib}
        )
    endif()
endmacro()

if (NOT TARGET Qt5::Gui)

    set(_Qt5Gui_OWN_INCLUDE_DIRS "${_qt5Gui_install_prefix}/include/" "${_qt5Gui_install_prefix}/include/QtGui")
    set(Qt5Gui_PRIVATE_INCLUDE_DIRS
        "${_qt5Gui_install_prefix}/include/QtGui/5.13.0"
        "${_qt5Gui_install_prefix}/include/QtGui/5.13.0/QtGui"
    )

    foreach(_dir ${_Qt5Gui_OWN_INCLUDE_DIRS})
        _qt5_Gui_check_file_exists(${_dir})
    endforeach()

    # Only check existence of private includes if the Private component is
    # specified.
    list(FIND Qt5Gui_FIND_COMPONENTS Private _check_private)
    if (NOT _check_private STREQUAL -1)
        foreach(_dir ${Qt5Gui_PRIVATE_INCLUDE_DIRS})
            _qt5_Gui_check_file_exists(${_dir})
        endforeach()
    endif()

    set(Qt5Gui_INCLUDE_DIRS ${_Qt5Gui_OWN_INCLUDE_DIRS})

    set(Qt5Gui_DEFINITIONS -DQT_GUI_LIB)
    set(Qt5Gui_COMPILE_DEFINITIONS QT_GUI_LIB)
    set(_Qt5Gui_MODULE_DEPENDENCIES "Core")


    set(Qt5Gui_OWN_PRIVATE_INCLUDE_DIRS ${Qt5Gui_PRIVATE_INCLUDE_DIRS})

    set(_Qt5Gui_FIND_DEPENDENCIES_REQUIRED)
    if (Qt5Gui_FIND_REQUIRED)
        set(_Qt5Gui_FIND_DEPENDENCIES_REQUIRED REQUIRED)
    endif()
    set(_Qt5Gui_FIND_DEPENDENCIES_QUIET)
    if (Qt5Gui_FIND_QUIETLY)
        set(_Qt5Gui_DEPENDENCIES_FIND_QUIET QUIET)
    endif()
    set(_Qt5Gui_FIND_VERSION_EXACT)
    if (Qt5Gui_FIND_VERSION_EXACT)
        set(_Qt5Gui_FIND_VERSION_EXACT EXACT)
    endif()

    set(Qt5Gui_EXECUTABLE_COMPILE_FLAGS "")

    foreach(_module_dep ${_Qt5Gui_MODULE_DEPENDENCIES})
        if (NOT Qt5${_module_dep}_FOUND)
            find_package(Qt5${_module_dep}
                5.13.0 ${_Qt5Gui_FIND_VERSION_EXACT}
                ${_Qt5Gui_DEPENDENCIES_FIND_QUIET}
                ${_Qt5Gui_FIND_DEPENDENCIES_REQUIRED}
                PATHS "${CMAKE_CURRENT_LIST_DIR}/.." NO_DEFAULT_PATH
            )
        endif()

        if (NOT Qt5${_module_dep}_FOUND)
            set(Qt5Gui_FOUND False)
            return()
        endif()

        list(APPEND Qt5Gui_INCLUDE_DIRS "${Qt5${_module_dep}_INCLUDE_DIRS}")
        list(APPEND Qt5Gui_PRIVATE_INCLUDE_DIRS "${Qt5${_module_dep}_PRIVATE_INCLUDE_DIRS}")
        list(APPEND Qt5Gui_DEFINITIONS ${Qt5${_module_dep}_DEFINITIONS})
        list(APPEND Qt5Gui_COMPILE_DEFINITIONS ${Qt5${_module_dep}_COMPILE_DEFINITIONS})
        list(APPEND Qt5Gui_EXECUTABLE_COMPILE_FLAGS ${Qt5${_module_dep}_EXECUTABLE_COMPILE_FLAGS})
    endforeach()
    list(REMOVE_DUPLICATES Qt5Gui_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5Gui_PRIVATE_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5Gui_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5Gui_COMPILE_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5Gui_EXECUTABLE_COMPILE_FLAGS)

    set(_Qt5Gui_LIB_DEPENDENCIES "Qt5::Core")


    if(NOT Qt5_EXCLUDE_STATIC_DEPENDENCIES)
        _qt5_Gui_process_prl_file(
            "${_qt5Gui_install_prefix}/lib/Qt5Guid.prl" DEBUG
            _Qt5Gui_STATIC_DEBUG_LIB_DEPENDENCIES
            _Qt5Gui_STATIC_DEBUG_LINK_FLAGS
        )

        _qt5_Gui_process_prl_file(
            "${_qt5Gui_install_prefix}/lib/Qt5Gui.prl" RELEASE
            _Qt5Gui_STATIC_RELEASE_LIB_DEPENDENCIES
            _Qt5Gui_STATIC_RELEASE_LINK_FLAGS
        )
    endif()

    add_library(Qt5::Gui STATIC IMPORTED)
    set_property(TARGET Qt5::Gui PROPERTY IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

    set_property(TARGET Qt5::Gui PROPERTY
      INTERFACE_INCLUDE_DIRECTORIES ${_Qt5Gui_OWN_INCLUDE_DIRS})
    set_property(TARGET Qt5::Gui PROPERTY
      INTERFACE_COMPILE_DEFINITIONS QT_GUI_LIB)

    set_property(TARGET Qt5::Gui PROPERTY INTERFACE_QT_ENABLED_FEATURES accessibility;action;clipboard;colornames;cssparser;cursor;desktopservices;imageformat_xpm;draganddrop;opengl;imageformatplugin;highdpiscaling;im;image_heuristic_mask;image_text;imageformat_bmp;imageformat_jpeg;imageformat_png;imageformat_ppm;imageformat_xbm;movie;pdf;picture;sessionmanager;shortcut;standarditemmodel;systemtrayicon;tabletevent;texthtmlparser;textodfwriter;validator;whatsthis;wheelevent)
    set_property(TARGET Qt5::Gui PROPERTY INTERFACE_QT_DISABLED_FEATURES opengles2;dynamicgl;angle;combined-angle-lib;opengles3;opengles31;opengles32;openvg;vulkan)

    set(_Qt5Gui_PRIVATE_DIRS_EXIST TRUE)
    foreach (_Qt5Gui_PRIVATE_DIR ${Qt5Gui_OWN_PRIVATE_INCLUDE_DIRS})
        if (NOT EXISTS ${_Qt5Gui_PRIVATE_DIR})
            set(_Qt5Gui_PRIVATE_DIRS_EXIST FALSE)
        endif()
    endforeach()

    if (_Qt5Gui_PRIVATE_DIRS_EXIST)
        add_library(Qt5::GuiPrivate INTERFACE IMPORTED)
        set_property(TARGET Qt5::GuiPrivate PROPERTY
            INTERFACE_INCLUDE_DIRECTORIES ${Qt5Gui_OWN_PRIVATE_INCLUDE_DIRS}
        )
        set(_Qt5Gui_PRIVATEDEPS)
        foreach(dep ${_Qt5Gui_LIB_DEPENDENCIES})
            if (TARGET ${dep}Private)
                list(APPEND _Qt5Gui_PRIVATEDEPS ${dep}Private)
            endif()
        endforeach()
        set_property(TARGET Qt5::GuiPrivate PROPERTY
            INTERFACE_LINK_LIBRARIES Qt5::Gui ${_Qt5Gui_PRIVATEDEPS}
        )
    endif()

    _populate_Gui_target_properties(RELEASE "Qt5Gui.lib" "" )



    _populate_Gui_target_properties(DEBUG "Qt5Guid.lib" "" )



    file(GLOB pluginTargets "${CMAKE_CURRENT_LIST_DIR}/Qt5Gui_*Plugin.cmake")

    macro(_populate_Gui_plugin_properties Plugin Configuration PLUGIN_LOCATION)
        set_property(TARGET Qt5::${Plugin} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

        set(imported_location "${_qt5Gui_install_prefix}/plugins/${PLUGIN_LOCATION}")
        _qt5_Gui_check_file_exists(${imported_location})
        set_target_properties(Qt5::${Plugin} PROPERTIES
            "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        )
    endmacro()

    if (pluginTargets)
        foreach(pluginTarget ${pluginTargets})
            include(${pluginTarget})
        endforeach()
    endif()


    include("${CMAKE_CURRENT_LIST_DIR}/Qt5GuiConfigExtras.cmake")


_qt5_Gui_check_file_exists("${CMAKE_CURRENT_LIST_DIR}/Qt5GuiConfigVersion.cmake")

endif()
