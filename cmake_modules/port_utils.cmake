function(ms_underscores_to_camel_case VarIn VarOut)
  string(REPLACE "_" ";" Pieces ${VarIn})
  foreach(Part ${Pieces})
    string(SUBSTRING ${Part} 0 1 Initial)
    string(SUBSTRING ${Part} 1 -1 Part)
    string(TOUPPER ${Initial} Initial)
    set(CamelCase ${CamelCase}${Initial}${Part})
  endforeach()
  set(${VarOut} ${CamelCase} PARENT_SCOPE)
endfunction()

function(apply_target_properties Target)
  if(ARGV1)
    set(Folder "${ARGV1}")
  endif()
  ms_underscores_to_camel_case(${Target} CamelCaseTargetName)
  set_target_properties(${Target} PROPERTIES PROJECT_LABEL ${CamelCaseTargetName} FOLDER "${Folder}")
endfunction()

macro(list_contains var value)
  set(${var})
  foreach(value2 ${ARGN})
    if(${value} STREQUAL ${value2})
      set(${var} TRUE)
    endif(${value} STREQUAL ${value2})
  endforeach()
endmacro()

function(get_dependency_paths Target HeaderPaths LibPaths)
  set(TargetsHandled ${TargetsHandled} ${Target})

  get_target_property(IncludeDirs ${Target} INTERFACE_INCLUDE_DIRECTORIES)
  set(${HeaderPaths} "${${HeaderPaths}};${IncludeDirs}")

  get_target_property(TargetType ${Target} TYPE)

  if(NOT TargetType STREQUAL "INTERFACE_LIBRARY")
    get_target_property(LibPath ${Target} IMPORTED_LOCATION_RELEASE)
    set(${LibPaths} "${${LibPaths}};${LibPath}")

    get_target_property(CurrentLibs ${Target} INTERFACE_LINK_LIBRARIES)
    if(CurrentLibs)
      foreach(CurrentLib ${CurrentLibs})
        get_target_property(CurrentLibIncludeDirs ${CurrentLib} INTERFACE_INCLUDE_DIRECTORIES)
        if(CurrentLibIncludeDirs)
          list_contains(IsHandled ${CurrentLib} ${TargetsHandled})
          if(NOT IsHandled)
            get_dependency_paths(${CurrentLib} ${HeaderPaths} ${LibPaths})
          endif()
        else()
          if(MSVC OR CMAKE_GENERATOR STREQUAL Xcode)
            get_target_property(CurrentLibPath ${CurrentLib} IMPORTED_LOCATION_RELEASE)
          else()
            get_target_property(CurrentLibPath ${CurrentLib} IMPORTED_LOCATION)
          endif()

          if(CurrentLibPath)
            set(${LibPaths} "${${LibPaths}};${CurrentLibPath}")
          endif()
        endif()
      endforeach()
    endif()
  endif()

  set(TargetsHandled ${TargetsHandled} PARENT_SCOPE)

  string(REGEX REPLACE "^;" "" ${HeaderPaths} "${${HeaderPaths}}")
  list(REMOVE_DUPLICATES ${HeaderPaths})
  set(${HeaderPaths} "${${HeaderPaths}}" PARENT_SCOPE)

  string(REGEX REPLACE "^;" "" ${LibPaths} "${${LibPaths}}")
  set(${LibPaths} "${${LibPaths}}" PARENT_SCOPE)
endfunction()

function(format_list InList OutList)
  set(FormattedList "")
  foreach(InItem ${${InList}})
    set(FormattedList "${FormattedList}\"${InItem}\", \n")
  endforeach()
  string(REGEX REPLACE ", \n$" "" FormattedList ${FormattedList})
  set(${OutList} ${FormattedList} PARENT_SCOPE)
endfunction()

function(set_target_output_path Target FolderPath)
  set_target_properties(${Target} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${FolderPath}"
    LIBRARY_OUTPUT_DIRECTORY "${FolderPath}"
    RUNTIME_OUTPUT_DIRECTORY "${FolderPath}"
  )
  message("-- Added target ${Target}")
endfunction()

