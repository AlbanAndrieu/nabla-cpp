# Just process the sub directories
ADD_SUBDIRECTORY(main)

if(BUILD_TESTING)
  ADD_SUBDIRECTORY(test)
endif()
