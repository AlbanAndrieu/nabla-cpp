PROJECT(MICROSOFT LANGUAGES CXX)


ENABLE_LANGUAGE(C)

CMAKE_MINIMUM_REQUIRED(VERSION "3.10")

#SET( CTEST_COST_DATA_FILE "TODO" )
SET( SITE "albandrieu.com" )
SET( DROP_SITE "192.168.1.61" )
SET( DROP_LOCATION "/cdash/submit.php?project=MICROSOFT" )

INCLUDE(${PROJECT_SOURCE_DIR}/../../config/Project.cmake)

# Prepare Conan.io packages
SET(CONAN_BUILD_INFO_FILE ${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
IF(NOT EXISTS ${CONAN_BUILD_INFO_FILE})
  MESSAGE(STATUS "No conan package information available. Trying to fix that!")
  EXECUTE_PROCESS(COMMAND conan install --build=missing ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_QUIET)
ENDIF()

#if conanbuildinfo.cmake not found run
#conan install ../microsoft/ --build boost_system

# Import dependencies via Conan.io
INCLUDE(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
SET(CONAN_SYSTEM_INCLUDES On)
CONAN_BASIC_SETUP()

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
