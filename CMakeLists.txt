cmake_minimum_required(VERSION 3.20.0)
project(dpp VERSION 1.0.0)

message(STATUS "Generator .............. ${CMAKE_GENERATOR}")
message(STATUS "Build Type ............. ${CMAKE_BUILD_TYPE}")

# QPCPP framework directory
# NOTE:
# Adjust this path for a different relative path
# between your project and the QPCPP folder
#
set(QPCPP_DIR ../../qpcpp)

# --------------------------------------------------------------------
# QP Port directory
#
# NOTE:
# For POSIX hosts (Linux, MacOS), you can choose:
# - the single-threaded QP/C++ port (win32-qv) or
# - the multithreaded QP/C++ port (win32).
#
set(QP_PORT_DIR ${QPCPP_DIR}/ports/posix-qv)
#set(QP_PORT_DIR ${QPCPP_DIR}/ports/posix)
# TODO: use a conditional statement to select which on to use
# during build time


# --------------------------------------------------------------------
# QSPY configurations
#
# option to turn QSPY software tracing ON or OFF
# NOTE: change of the option might require re-building the project
#
option(QSPY "QSPY software tracing" ON)


include(cross.cmake)

set(Source_Files
    "main.cpp"
    "bsp.cpp"
    "philo.cpp"
    "table.cpp"
    ${QPCPP_DIR}/src/qf/qep_hsm.cpp
    ${QPCPP_DIR}/src/qf/qep_msm.cpp
    ${QPCPP_DIR}/src/qf/qf_act.cpp
    ${QPCPP_DIR}/src/qf/qf_actq.cpp
    ${QPCPP_DIR}/src/qf/qf_defer.cpp
    ${QPCPP_DIR}/src/qf/qf_dyn.cpp
    ${QPCPP_DIR}/src/qf/qf_mem.cpp
    ${QPCPP_DIR}/src/qf/qf_ps.cpp
    ${QPCPP_DIR}/src/qf/qf_qact.cpp
    ${QPCPP_DIR}/src/qf/qf_qeq.cpp
    ${QPCPP_DIR}/src/qf/qf_qmact.cpp
    ${QPCPP_DIR}/src/qf/qf_time.cpp
    ${QP_PORT_DIR}/qf_port.cpp 
)

# QPCPP configuration with QSPY...
if(QSPY)
    add_compile_definitions(Q_SPY)

    set(Qspy_Files
        ${QPCPP_DIR}/src/qs/qs.cpp
        ${QPCPP_DIR}/src/qs/qs_rx.cpp
        ${QPCPP_DIR}/src/qs/qs_fp.cpp
        ${QPCPP_DIR}/src/qs/qutest.cpp
        ${QPCPP_DIR}/src/qs/qs_64bit.cpp
        ${QPCPP_DIR}/include/qstamp.cpp
    )
    set(ALL_FILES # # add qspy sources
        ${Source_Files}
        ${Qspy_Files}
    )
else()
    set(ALL_FILES ${Source_Files})
endif()

unset(USE_MY_LIB CACHE) # <---- this is the important!!. 

add_executable(${PROJECT_NAME}
    ${ALL_FILES}
)

target_link_libraries(${PROJECT_NAME} pthread)

# ! add include dir here.
target_include_directories(${PROJECT_NAME} PUBLIC
    ${QPCPP_DIR}/include
    ${QP_PORT_DIR}
)



#------------------------------------------------------------------------
# remote target params
#
set(BOARD_IP 192.168.0.30)
set(PORT_NO 3000)
set(TARGET_DIR /home/lab1)
set(TARGET_BINARY ${PROJECT_NAME})

#------------------------------------------------------------------------
# post build steps.
#
add_custom_target(build ALL)
add_custom_target(build_and_debug ALL DEPENDS ${TARGET_BINARY}) 
add_custom_target(build_and_deploy ALL DEPENDS ${TARGET_BINARY})

message(STATUS "Deploy executable ${PROJECT_NAME} to remote ${BOARD_IP}:${PORT_NO} ${TARGET_DIR} ") 
# copy the binary to the target and start gdb and binary file.
# !!! these commands are added to the makefile and run when it is executed.
add_custom_command(TARGET build_and_deploy POST_BUILD
    COMMAND echo "Deploying executable to remote ${BOARD_IP}:${PORT_NO} ${TARGET_DIR} "
    COMMAND scp ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} root@${BOARD_IP}:${TARGET_DIR}
)
add_custom_command(TARGET build_and_debug POST_BUILD
    COMMAND echo "Deploying executable to remote ${BOARD_IP}:${PORT_NO} ${TARGET_DIR} "
    COMMAND scp ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} root@${BOARD_IP}:${TARGET_DIR}
    COMMAND echo "Starting GDB server...... "

    COMMAND ssh -t root@${BOARD_IP} 'gdbserver :${PORT_NO} ./../../${TARGET_DIR}/${PROJECT_NAME}'
)