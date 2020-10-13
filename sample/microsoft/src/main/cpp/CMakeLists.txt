########## Project setup ##########
#PROJECT(LIB-MainLibrary CXX)

# ######### General setup ##########
#COPY_HEADER_LIST(${PROJECT_INCLUDE_DIR} h)

MESSAGE(STATUS "MAIN CPP: " ${CMAKE_SOURCE_DIR}/src/main/cpp )
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/include")

# ########## MainLibrary executable ##########
# Sources:
SET(main_files_SRCS
    circular_queue.cpp
    Triangle.cpp
)

# Headers:
#SET(main_files_HDRS
#    circular_queue.h
#)
FILE(GLOB main_files_HDRS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.h")
MESSAGE("Found Header Files: ${main_files_HDRS}")

#set(CONAN_INCLUDE_DIRS_BOOST "/home/albandrieu/.conan/data/boost/1.67.0/conan/stable/package/5e8eff81f2db7ac8c8c3d41364df2f92d8c53fdb/include")
#set(CONAN_LIB_DIRS_BOOST "/home/albandrieu/.conan/data/boost/1.67.0/conan/stable/package/5e8eff81f2db7ac8c8c3d41364df2f92d8c53fdb/lib")
#CONAN_LIBS_BOOST
#set(CONAN_LIBS boost_wave boost_container boost_contract boost_exception boost_graph boost_iostreams boost_locale boost_log boost_program_options boost_random boost_regex boost_serialization boost_wserialization boost_signals boost_coroutine boost_fiber boost_context boost_timer boost_thread boost_chrono boost_date_time boost_atomic boost_filesystem boost_system boost_type_erasure boost_log_setup boost_math_c99 boost_math_c99f boost_math_c99l boost_math_tr1 boost_math_tr1f boost_math_tr1l boost_stacktrace_addr2line boost_stacktrace_backtrace boost_stacktrace_basic boost_stacktrace_noop boost_unit_test_framework pthread bz2 z ${CONAN_LIBS})
#set(CONAN_DEFINES "-DBOOST_USE_STATIC_LIBS" ${CONAN_DEFINES})

IF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
  IF(ENABLE_CONAN)
    #MESSAGE("CONAN_LIBS: ${CONAN_LIBS}")
    #SET(CONAN_DEFINES "" ${CONAN_DEFINES})
    #LINK_LIBRARIES(${CONAN_LIBS})
    #INCLUDE(${CMAKE_BINARY_DIR}/conan_paths.cmake)
    #MESSAGE("CONAN_CXX_FLAGS: ${CONAN_CXX_FLAGS}")
    #SET(CONAN_CXX_FLAGS " -DDDD ${CONAN_CXX_FLAGS}")
    IF(MINGW)
      MESSAGE(STATUS "MINGW found : X compiling")
      SET(CMAKE_CXX_FLAGS "-DBOOST_ALL_NO_LIB=1 -DBOOST_CHRONO_STATIC_LINK=1 -DBOOST_SYSTEM_NO_DEPRECATED -DBOOST_SYSTEM_STATIC_LINK=1 -DBOOST_THREAD_USES_CHRONO -DBOOST_THREAD_WIN32 -DBOOST_USE_WINDOWS_H -DWIN32_LEAN_AND_MEAN")
    #-D_GLIBCXX_USE_CXX11_ABI=1
    ENDIF(MINGW)
  ELSE(ENABLE_CONAN)
    LINK_LIBRARIES(boost_system)
  ENDIF(ENABLE_CONAN)
ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
  IF(MINGW)
    LINK_LIBRARIES(libboost_system-mt.a)
  ENDIF(MINGW)
ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")

IF (MINGW)
  ADD_LIBRARY(main_library STATIC ${main_files_SRCS})
ELSE(MINGW)
  ADD_LIBRARY(main_library SHARED ${main_files_SRCS})
ENDIF(MINGW)

SET_TARGET_PROPERTIES(main_library PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_MAJOR_VERSION})

# add install files:
INSTALL(FILES ${main_files_HDRS}
  DESTINATION include
  PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE  )

INSTALL(TARGETS main_library
  EXPORT  microsoft-install
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

# make sure the library gets installed
#INSTALL_TARGETS(/lib main_library)
