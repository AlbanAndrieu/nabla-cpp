#
# http://root.cern.ch/viewvc/trunk/cint/reflex/cmake/modules/FindCppUnit.cmake
#
# - Find CppUnit
# This module finds an installed CppUnit package.
#
# It sets the following variables:
#  CPPUNIT_FOUND       - Set to false, or undefined, if CppUnit isn't found.
#  CPPUNIT_INCLUDE_DIR - The CppUnit include directory.
#  CPPUNIT_LIBRARY     - The CppUnit library to link against.

FIND_PATH(CPPUNIT_INCLUDE_DIR cppunit/Test.h)
#FIND_PATH(CPPUNIT_INCLUDE_DIR /mingw64/include/cppunit/Test.h)

#FIND_LIBRARY(CPPUNIT_LIBRARY NAMES cppunit)

FIND_LIBRARY(CPPUNIT_LIBRARY_DEBUG NAMES cppunit cppunit_dll cppunitd cppunitd_dll
             PATHS   ${FOO_PREFIX}/lib
                     /usr/lib
                     /usr/lib/x86_64-linux-gnu/
                     /usr/lib64
                     /usr/local/lib
                     /usr/local/lib64
                     /mingw64/lib/
             PATH_SUFFIXES debug )

FIND_LIBRARY(CPPUNIT_LIBRARY_RELEASE NAMES cppunit cppunit_dll
             PATHS   ${FOO_PREFIX}/lib
                     /usr/lib
                     /usr/lib/x86_64-linux-gnu/
                     /usr/lib64
                     /usr/local/lib
                     /usr/local/lib64
                     /mingw64/lib/
             PATH_SUFFIXES release )

if(CPPUNIT_LIBRARY_DEBUG AND NOT CPPUNIT_LIBRARY_RELEASE)
    SET(CPPUNIT_LIBRARY_RELEASE ${CPPUNIT_LIBRARY_DEBUG})
endif(CPPUNIT_LIBRARY_DEBUG AND NOT CPPUNIT_LIBRARY_RELEASE)

SET(CPPUNIT_LIBRARY debug     ${CPPUNIT_LIBRARY_DEBUG}
                     optimized ${CPPUNIT_LIBRARY_RELEASE} )

IF (CPPUNIT_INCLUDE_DIR AND CPPUNIT_LIBRARY)
   SET(CPPUNIT_FOUND TRUE)
ENDIF (CPPUNIT_INCLUDE_DIR AND CPPUNIT_LIBRARY)

IF (CPPUNIT_FOUND)

   # show which CppUnit was found only if not quiet
   IF (NOT CppUnit_FIND_QUIETLY)
      MESSAGE(STATUS "Found CppUnit: ${CPPUNIT_LIBRARY}")
   ENDIF (NOT CppUnit_FIND_QUIETLY)

ELSE (CPPUNIT_FOUND)

   # fatal error if CppUnit is required but not found
   IF (CppUnit_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find CppUnit")
   ENDIF (CppUnit_FIND_REQUIRED)

ENDIF (CPPUNIT_FOUND)
