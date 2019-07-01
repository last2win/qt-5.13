
if (CMAKE_VERSION VERSION_LESS 3.1.0)
    message(FATAL_ERROR "Qt 5 AxContainer module requires at least CMake version 3.1.0")
endif()

get_filename_component(_qt5AxContainer_install_prefix "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

# For backwards compatibility only. Use Qt5AxContainer_VERSION instead.
set(Qt5AxContainer_VERSION_STRING 5.13.0)

set(Qt5AxContainer_LIBRARIES Qt5::AxContainer)

macro(_qt5_AxContainer_check_file_exists file)
    if(NOT EXISTS "${file}" )
        message(FATAL_ERROR "The imported target \"Qt5::AxContainer\" references the file
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

function(_qt5_AxContainer_process_prl_file prl_file_location Configuration lib_deps link_flags)
    set(_lib_deps)
    set(_link_flags)

    get_filename_component(_qt5_install_libs "${_qt5AxContainer_install_prefix}/lib" ABSOLUTE)

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
                        find_library(_Qt5AxContainer_${Configuration}_${_lib}_PATH ${_lib} HINTS ${_search_paths} NO_DEFAULT_PATH)
                    endif()
                    find_library(_Qt5AxContainer_${Configuration}_${_lib}_PATH ${_lib})
                    mark_as_advanced(_Qt5AxContainer_${Configuration}_${_lib}_PATH)
                    if(_Qt5AxContainer_${Configuration}_${_lib}_PATH)
                        list(APPEND _lib_deps
                            ${_Qt5AxContainer_${Configuration}_${_lib}_PATH}
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

macro(_populate_AxContainer_target_properties Configuration LIB_LOCATION IMPLIB_LOCATION)
    set_property(TARGET Qt5::AxContainer APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

    set(imported_location "${_qt5AxContainer_install_prefix}/lib/${LIB_LOCATION}")
    _qt5_AxContainer_check_file_exists(${imported_location})
    set(_deps
        ${_Qt5AxContainer_LIB_DEPENDENCIES}
        ${_Qt5AxContainer_STATIC_${Configuration}_LIB_DEPENDENCIES}
    )
    set_target_properties(Qt5::AxContainer PROPERTIES
        "INTERFACE_LINK_LIBRARIES" "${_deps}"
        "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        # For backward compatibility with CMake < 2.8.12
        "IMPORTED_LINK_INTERFACE_LIBRARIES_${Configuration}" "${_deps}"
    )

    if(NOT CMAKE_VERSION VERSION_LESS "3.13")
        set_target_properties(Qt5::AxContainer PROPERTIES
            "INTERFACE_LINK_OPTIONS" "${_Qt5AxContainer_STATIC_${Configuration}_LINK_FLAGS}"
        )
    endif()

    set(imported_implib "${_qt5AxContainer_install_prefix}/lib/${IMPLIB_LOCATION}")
    _qt5_AxContainer_check_file_exists(${imported_implib})
    if(NOT "${IMPLIB_LOCATION}" STREQUAL "")
        set_target_properties(Qt5::AxContainer PROPERTIES
        "IMPORTED_IMPLIB_${Configuration}" ${imported_implib}
        )
    endif()
endmacro()

if (NOT TARGET Qt5::AxContainer)

    set(_Qt5AxContainer_OWN_INCLUDE_DIRS "")
    set(Qt5AxContainer_PRIVATE_INCLUDE_DIRS "")

    foreach(_dir ${_Qt5AxContainer_OWN_INCLUDE_DIRS})
        _qt5_AxContainer_check_file_exists(${_dir})
    endforeach()

    # Only check existence of private includes if the Private component is
    # specified.
    list(FIND Qt5AxContainer_FIND_COMPONENTS Private _check_private)
    if (NOT _check_private STREQUAL -1)
        foreach(_dir ${Qt5AxContainer_PRIVATE_INCLUDE_DIRS})
            _qt5_AxContainer_check_file_exists(${_dir})
        endforeach()
    endif()

    set(Qt5AxContainer_INCLUDE_DIRS ${_Qt5AxContainer_OWN_INCLUDE_DIRS})

    set(Qt5AxContainer_DEFINITIONS -DQT_AXCONTAINER_LIB)
    set(Qt5AxContainer_COMPILE_DEFINITIONS QT_AXCONTAINER_LIB)
    set(_Qt5AxContainer_MODULE_DEPENDENCIES "AxBase;Widgets;Gui;Core")


    set(Qt5AxContainer_OWN_PRIVATE_INCLUDE_DIRS ${Qt5AxContainer_PRIVATE_INCLUDE_DIRS})

    set(_Qt5AxContainer_FIND_DEPENDENCIES_REQUIRED)
    if (Qt5AxContainer_FIND_REQUIRED)
        set(_Qt5AxContainer_FIND_DEPENDENCIES_REQUIRED REQUIRED)
    endif()
    set(_Qt5AxContainer_FIND_DEPENDENCIES_QUIET)
    if (Qt5AxContainer_FIND_QUIETLY)
        set(_Qt5AxContainer_DEPENDENCIES_FIND_QUIET QUIET)
    endif()
    set(_Qt5AxContainer_FIND_VERSION_EXACT)
    if (Qt5AxContainer_FIND_VERSION_EXACT)
        set(_Qt5AxContainer_FIND_VERSION_EXACT EXACT)
    endif()

    set(Qt5AxContainer_EXECUTABLE_COMPILE_FLAGS "")

    foreach(_module_dep ${_Qt5AxContainer_MODULE_DEPENDENCIES})
        if (NOT Qt5${_module_dep}_FOUND)
            find_package(Qt5${_module_dep}
                5.13.0 ${_Qt5AxContainer_FIND_VERSION_EXACT}
                ${_Qt5AxContainer_DEPENDENCIES_FIND_QUIET}
                ${_Qt5AxContainer_FIND_DEPENDENCIES_REQUIRED}
                PATHS "${CMAKE_CURRENT_LIST_DIR}/.." NO_DEFAULT_PATH
            )
        endif()

        if (NOT Qt5${_module_dep}_FOUND)
            set(Qt5AxContainer_FOUND False)
            return()
        endif()

        list(APPEND Qt5AxContainer_INCLUDE_DIRS "${Qt5${_module_dep}_INCLUDE_DIRS}")
        list(APPEND Qt5AxContainer_PRIVATE_INCLUDE_DIRS "${Qt5${_module_dep}_PRIVATE_INCLUDE_DIRS}")
        list(APPEND Qt5AxContainer_DEFINITIONS ${Qt5${_module_dep}_DEFINITIONS})
        list(APPEND Qt5AxContainer_COMPILE_DEFINITIONS ${Qt5${_module_dep}_COMPILE_DEFINITIONS})
        list(APPEND Qt5AxContainer_EXECUTABLE_COMPILE_FLAGS ${Qt5${_module_dep}_EXECUTABLE_COMPILE_FLAGS})
    endforeach()
    list(REMOVE_DUPLICATES Qt5AxContainer_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5AxContainer_PRIVATE_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5AxContainer_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5AxContainer_COMPILE_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5AxContainer_EXECUTABLE_COMPILE_FLAGS)

    set(_Qt5AxContainer_LIB_DEPENDENCIES "Qt5::AxBase;Qt5::Widgets;Qt5::Gui;Qt5::Core")


    if(NOT Qt5_EXCLUDE_STATIC_DEPENDENCIES)
        _qt5_AxContainer_process_prl_file(
            "${_qt5AxContainer_install_prefix}/lib/Qt5AxContainerd.prl" DEBUG
            _Qt5AxContainer_STATIC_DEBUG_LIB_DEPENDENCIES
            _Qt5AxContainer_STATIC_DEBUG_LINK_FLAGS
        )

        _qt5_AxContainer_process_prl_file(
            "${_qt5AxContainer_install_prefix}/lib/Qt5AxContainer.prl" RELEASE
            _Qt5AxContainer_STATIC_RELEASE_LIB_DEPENDENCIES
            _Qt5AxContainer_STATIC_RELEASE_LINK_FLAGS
        )
    endif()

    add_library(Qt5::AxContainer STATIC IMPORTED)
    set_property(TARGET Qt5::AxContainer PROPERTY IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

    set_property(TARGET Qt5::AxContainer PROPERTY
      INTERFACE_INCLUDE_DIRECTORIES ${_Qt5AxContainer_OWN_INCLUDE_DIRS})
    set_property(TARGET Qt5::AxContainer PROPERTY
      INTERFACE_COMPILE_DEFINITIONS QT_AXCONTAINER_LIB)

    set_property(TARGET Qt5::AxContainer PROPERTY INTERFACE_QT_ENABLED_FEATURES )
    set_property(TARGET Qt5::AxContainer PROPERTY INTERFACE_QT_DISABLED_FEATURES )

    set(_Qt5AxContainer_PRIVATE_DIRS_EXIST TRUE)
    foreach (_Qt5AxContainer_PRIVATE_DIR ${Qt5AxContainer_OWN_PRIVATE_INCLUDE_DIRS})
        if (NOT EXISTS ${_Qt5AxContainer_PRIVATE_DIR})
            set(_Qt5AxContainer_PRIVATE_DIRS_EXIST FALSE)
        endif()
    endforeach()

    if (_Qt5AxContainer_PRIVATE_DIRS_EXIST)
        add_library(Qt5::AxContainerPrivate INTERFACE IMPORTED)
        set_property(TARGET Qt5::AxContainerPrivate PROPERTY
            INTERFACE_INCLUDE_DIRECTORIES ${Qt5AxContainer_OWN_PRIVATE_INCLUDE_DIRS}
        )
        set(_Qt5AxContainer_PRIVATEDEPS)
        foreach(dep ${_Qt5AxContainer_LIB_DEPENDENCIES})
            if (TARGET ${dep}Private)
                list(APPEND _Qt5AxContainer_PRIVATEDEPS ${dep}Private)
            endif()
        endforeach()
        set_property(TARGET Qt5::AxContainerPrivate PROPERTY
            INTERFACE_LINK_LIBRARIES Qt5::AxContainer ${_Qt5AxContainer_PRIVATEDEPS}
        )
    endif()

    _populate_AxContainer_target_properties(RELEASE "Qt5AxContainer.lib" "" )



    _populate_AxContainer_target_properties(DEBUG "Qt5AxContainerd.lib" "" )



    file(GLOB pluginTargets "${CMAKE_CURRENT_LIST_DIR}/Qt5AxContainer_*Plugin.cmake")

    macro(_populate_AxContainer_plugin_properties Plugin Configuration PLUGIN_LOCATION)
        set_property(TARGET Qt5::${Plugin} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

        set(imported_location "${_qt5AxContainer_install_prefix}/plugins/${PLUGIN_LOCATION}")
        _qt5_AxContainer_check_file_exists(${imported_location})
        set_target_properties(Qt5::${Plugin} PROPERTIES
            "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        )
    endmacro()

    if (pluginTargets)
        foreach(pluginTarget ${pluginTargets})
            include(${pluginTarget})
        endforeach()
    endif()




_qt5_AxContainer_check_file_exists("${CMAKE_CURRENT_LIST_DIR}/Qt5AxContainerConfigVersion.cmake")

endif()
