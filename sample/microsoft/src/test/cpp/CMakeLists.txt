########## Project setup ##########
#PROJECT(TEST-LIB-TestLibrary CXX)

# ######### General setup ##########
#COPY_HEADER_LIST(${PROJECT_INCLUDE_DIR} h)

MESSAGE(STATUS "TEST CPP: " ${CMAKE_SOURCE_DIR}/src/test/cpp )
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/include")

MESSAGE(STATUS "TEST CPP 2: " ${CMAKE_SOURCE_DIR}/src/main/cpp/include)
INCLUDE_DIRECTORIES("${CMAKE_SOURCE_DIR}/src/main/cpp/include")

# ########## TestLibrary executable ##########
# Sources:

SET(test_files_to_run_SRCS
    circular_queueTest.cpp
    TriangleTest.cpp
)

SET(test_files_SRCS
    ${test_files_to_run_SRCS}
    circular_queueThread.cpp
    cppunitTest.cpp  # use to test failure in CPPUnit
)

# Headers:
#SET(test_files_HDRS
#    circular_queueTest.h
#    cppunitTest.h
#)
FILE(GLOB test_files_HDRS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.h")
MESSAGE("Found Header Files: ${test_files_HDRS}")

LINK_LIBRARIES(main_library ${CPPUNIT_LIBRARY} boost_thread boost_date_time)
#${Boost_LIBRARIES}  boost_thread-gcc34-mt-1_41 boost_date_time-gcc34-mt-1_41

ADD_LIBRARY(test_library SHARED ${test_files_SRCS})

SET_TARGET_PROPERTIES(test_library PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_MAJOR_VERSION})

# add install files:
INSTALL(FILES ${test_files_HDRS}
  DESTINATION include-test
  PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE  )

INSTALL(TARGETS test_library
  EXPORT  microsoft-install
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)
