PROJECT(MICROSOFT CXX)

ENABLE_LANGUAGE(C)

CMAKE_MINIMUM_REQUIRED(VERSION "2.8")

#SET( CTEST_COST_DATA_FILE "TODO" )
SET( SITE "home.nabla.mobi" )
SET( DROP_SITE "192.168.0.28" )
SET( DROP_LOCATION "/cdash/submit.php?project=MICROSOFT" )

INCLUDE(${PROJECT_SOURCE_DIR}/../../config/Project.cmake)

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

SET( CTEST_MEMORYCHECK_COMMAND "/usr/bin/valgrind" )
#SET( CTEST_MEMORYCHECK_COMMAND_OPTIONS "--tool=callgrind -v" )
#SET( CTEST_MEMORYCHECK_COMMAND_OPTIONS, "--trace-children=yes --leak-check=full" )
#SET(MEMORYCHECK_COMMAND_OPTIONS "--xml=yes --xml-file=test.xml")
  
# Add coverage options for CI
IF(COVERAGE)
	set_target_properties(main_library run_app run_tests PROPERTIES
						  COMPILE_FLAGS "-fprofile-arcs -ftest-coverage"
						  LINK_FLAGS "-coverage")
ENDIF(COVERAGE)

# Just process the sub directories
ADD_SUBDIRECTORY(src)

