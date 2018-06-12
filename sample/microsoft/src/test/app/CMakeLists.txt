########## Project setup ##########
#PROJECT(TEST-APP-Run CXX)

# ######### General setup ##########
#COPY_HEADER_LIST(${PROJECT_INCLUDE_DIR} h)

MESSAGE(STATUS "TEST APP: " ${CMAKE_SOURCE_DIR}/src/test/cpp/ )
INCLUDE_DIRECTORIES("${CMAKE_SOURCE_DIR}/src/main/cpp/include")
INCLUDE_DIRECTORIES("${CMAKE_SOURCE_DIR}/src/test/cpp/include")

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
ADD_TEST(TEST ${PROJECT_INSTALL_DIR}/bin/run_tests TEST)
