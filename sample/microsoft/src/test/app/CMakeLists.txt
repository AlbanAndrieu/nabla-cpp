########## Project setup ##########
#PROJECT(TEST-APP-Run CXX)

# ######### General setup ##########
#COPY_HEADER_LIST(${PROJECT_INCLUDE_DIR} h)

MESSAGE(STATUS "TEST APP: " ${CMAKE_SOURCE_DIR}/src/test/cpp/ )
INCLUDE_DIRECTORIES("${CMAKE_SOURCE_DIR}/src/main/cpp/include")
INCLUDE_DIRECTORIES("${CMAKE_SOURCE_DIR}/src/test/cpp/include")

LIST(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib:${CONAN_LIB_DIRS_BOOST_SYSTEM}:${CMAKE_CURRENT_BINARY_DIR}")

ADD_EXECUTABLE(run_tests run_tests.cpp)

TARGET_LINK_LIBRARIES(run_tests --coverage main_library test_library ${CPPUNIT_LIBRARY})

INSTALL(TARGETS run_tests
  EXPORT  microsoft-install
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

#INSTALL_PROGRAMS(/bin FILES run_tests)

#INCLUDE(CTest)
ENABLE_TESTING()

MESSAGE("  ######  adding test ${BUILDNAME}")

# Add a simple test
#ADD_TEST(MAINTEST ${CTEST_BINARY_DIRECTORY}/run_tests TESTME)
ADD_TEST(NAME MAINTEST COMMAND ${CTEST_BINARY_DIRECTORY}/run_tests)

#ADD_CUSTOM_COMMAND(TARGET run_tests POST_BUILD
#  COMMAND "${PROJECT_INSTALL_DIR}/bin/run_tests")
ADD_CUSTOM_TARGET(tests "${CTEST_BINARY_DIRECTORY}/run_tests" DEPENDS run_tests COMMENT "Running CPPUNIT tests...")

#FOREACH(test ${test_files_to_run_SRCS})
#  MESSAGE("  ######  adding test ${test}")
#
#  GET_FILENAME_COMPONENT(TestName ${test} NAME_WE)
#  ADD_TEST(${TestName} ${PROJECT_INSTALL_DIR}/bin/run_tests ${TestName})
#ENDFOREACH(test)

