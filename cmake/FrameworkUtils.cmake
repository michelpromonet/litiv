
macro(xfix_list_tokens list_name prefix suffix)
    set(${list_name}_TMP)
    foreach(l ${${list_name}})
        list(APPEND ${list_name}_TMP ${prefix}${l}${suffix} )
    endforeach(l ${${list_name}})
    set(${list_name} "${${list_name}_TMP}")
    unset(${list_name}_TMP)
endmacro(xfix_list_tokens)

macro(append_internal_list list_name value)
    if(${list_name})
        set(${list_name} "${${list_name}};${value}" CACHE INTERNAL "Internal list variable")
    else(${list_name})
        set(${list_name} "${value}" CACHE INTERNAL "Internal list variable")
    endif(${list_name})
endmacro(append_internal_list)

macro(initialize_internal_list list_name)
    set(${list_name} "" CACHE INTERNAL "Internal list variable")
endmacro(initialize_internal_list)

macro(litiv_module name)
    project(litiv_${name})
    append_internal_list(litiv_modules ${name})
    append_internal_list(litiv_projects litiv_${name})
    set(LITIV_CURRENT_MODULE_NAME ${name})
    set(LITIV_CURRENT_PROJECT_NAME litiv_${name})
endmacro(litiv_module)

macro(set_eval name)
    if(${ARGN})
        set(${name} 1)
    else(${ARGN})
        set(${name} 0)
    endif(${ARGN})
endmacro(set_eval)

macro(target_compil_litiv_dependencies name)
    set_property(TARGET ${name} PROPERTY CXX_STANDARD 11)
    set_property(TARGET ${name} PROPERTY CXX_STANDARD_REQUIRED ON)
endmacro(target_compil_litiv_dependencies name)

macro(target_link_litiv_dependencies name)
    target_link_libraries(${name} ${OpenCV_LIBRARIES})
    if(USE_GLSL)
        target_link_libraries(${name} ${GLFW_LIBRARIES})
        target_link_libraries(${name} ${OPENGL_LIBRARIES})
        target_link_libraries(${name} ${GLEW_LIBRARIES})
        target_link_libraries(${name} ${GLM_LIBRARIES})
    endif(USE_GLSL)
    if(USE_CUDA)
        # @@@@ add cuda package
        message(FATAL_ERROR "Missing CUDA target link libraries")
    endif(USE_CUDA)
    if(USE_OPENCL)
        # @@@@ add opencl package
        message(FATAL_ERROR "Missing OpenCL target link libraries")
    endif(USE_OPENCL)
    target_compil_litiv_dependencies(${name})
endmacro(target_link_litiv_dependencies name)

macro(try_runcheck_and_set_success name)
    if(NOT (${USE_${name}}))
        try_run(${name}_RUN_RESULT ${name}_COMPILE_RESULT ${CMAKE_CURRENT_BINARY_DIR}/cmake/checks/ ${CMAKE_CURRENT_BINARY_DIR}/cmake/checks/${name}.cpp LINK_LIBRARIES ${OpenCV_LIBRARIES})
        set_eval(USE_${name} (${name}_RUN_RESULT AND ${name}_COMPILE_RESULT))
    endif(NOT (${USE_${name}}))
    message(STATUS USE_${name}=${USE_${name}})
endmacro(try_runcheck_and_set_success)

macro(try_cvhardwaresupport_runcheck_and_set_success name)
    set(CV_HARDWARE_SUPPORT_CHECK_FLAG_NAME ${name})
    configure_file(
        "${CMAKE_SOURCE_DIR}/cmake/checks/cvhardwaresupport_check.cpp.in"
        "${CMAKE_BINARY_DIR}/cmake/checks/${name}.cpp"
    )
    try_runcheck_and_set_success(${name})
endmacro(try_cvhardwaresupport_runcheck_and_set_success)

macro(get_subdirectory_list result dir)
    file(GLOB children RELATIVE ${dir} ${dir}/*)
    set(dirlisttemp "")
    foreach(child ${children})
        if(IS_DIRECTORY ${dir}/${child})
            list(APPEND dirlisttemp ${child})
        endif(IS_DIRECTORY ${dir}/${child})
    endforeach(child ${children})
    set(${result} ${dirlisttemp})
endmacro(get_subdirectory_list result dir)
