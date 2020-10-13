PROJECT(MICROSOFT LANGUAGES CXX)

ENABLE_LANGUAGE(C)

CMAKE_MINIMUM_REQUIRED(VERSION "3.10")

#SET( CTEST_COST_DATA_FILE "TODO" )
SET( SITE "albandrieu.com" )
SET( DROP_SITE "192.168.1.61" )
SET( DROP_LOCATION "/cdash/submit.php?project=MICROSOFT" )

SET(CMAKE_ECLIPSE_VERSION "4.15")

INCLUDE(${PROJECT_SOURCE_DIR}/../../config/Project.cmake)

OPTION(ENABLE_CONAN "Enable building using conan" ON)
SET(CONAN_DISABLE_CHECK_COMPILER true)

IF(MINGW)
  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")

    # See https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/CrossCompiling
    #SET(CMAKE_CROSSCOMPILE ON CACHE BOOL "is crosscompiled" FORCE)

    #SET(CMAKE_SYSTEM_NAME Windows)
    #SET(CMAKE_SYSTEM_NAME Generic)
    #SET(CMAKE_SYSTEM_NAME WindowsStore)
    SET(CMAKE_SYSTEM_VERSION 10.0)

    ## which compilers to use for C and C++
    #SET(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
    #SET(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
    #SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)
	#
    ## here is the target environment located
    #SET(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
	#
    ## adjust the default behaviour of the FIND_XXX() commands:
    ## search headers and libraries in the target environment, search
    ## programs in the host environment
    #set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    #set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    #set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
	#
    #MESSAGE("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
    #MESSAGE("CMAKE_SYSTEM: ${CMAKE_SYSTEM}")
  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    SET(ENABLE_CONAN OFF)
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
ENDIF(MINGW)

IF(ENABLE_CONAN)
  # Prepare Conan.io packages
  SET(CONAN_BUILD_INFO_FILE ${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
  IF(NOT EXISTS ${CONAN_BUILD_INFO_FILE})
    MESSAGE(STATUS "No conan package information available. Trying to fix that!")
    #EXECUTE_PROCESS(COMMAND conan install --build=missing ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_QUIET)
    EXECUTE_PROCESS(COMMAND conan install --build=missing ${CMAKE_CURRENT_SOURCE_DIR}
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  ENDIF()

  #if conanbuildinfo.cmake not found run
  #conan install ../microsoft/ --build boost_system

  # Import dependencies via Conan.io
  #INCLUDE(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
  INCLUDE(${PROJECT_SOURCE_DIR}/conanbuildinfo.cmake)

  SET(CONAN_SYSTEM_INCLUDES ON)
  CONAN_BASIC_SETUP()
ELSE(ENABLE_CONAN)
  MESSAGE(STATUS "Conan not initialed")
ENDIF(ENABLE_CONAN)

SET(EXPORT_FILE microsoft-build.cmake)

INSTALL(EXPORT microsoft-install
        DESTINATION lib/microsoft-${PROJECT_VERSION_FULL}
        FILE microsoft-install.cmake)

MESSAGE( STATUS "PROJECT_INSTALL_DIR: " ${PROJECT_INSTALL_DIR} )
MESSAGE( STATUS "PROJECT_BINARY_DIR: " ${PROJECT_BINARY_DIR} )
MESSAGE( STATUS "PROJECT_SOURCE_DIR: " ${PROJECT_SOURCE_DIR} )
MESSAGE( STATUS "CMAKE_BINARY_DIR:         " ${CMAKE_BINARY_DIR} )
MESSAGE( STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR} )
MESSAGE( STATUS "CMAKE_SOURCE_DIR:         " ${CMAKE_SOURCE_DIR} )
MESSAGE( STATUS "CMAKE_CURRENT_SOURCE_DIR: " ${CMAKE_CURRENT_SOURCE_DIR} )

USE_CXX11()

# Just process the sub directories
ADD_SUBDIRECTORY(src)
