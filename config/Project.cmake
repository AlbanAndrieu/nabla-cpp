#
# File generated by CMakeBuilder
#
#

SET(CMAKE_BUILD_TYPE "debug")

IF(CMAKE_COMPILER_IS_GNUCC)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
ENDIF(CMAKE_COMPILER_IS_GNUCC)
IF(CMAKE_COMPILER_IS_GNUCXX)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

OPTION(BUILD_SHARED_LIBS "Build shared libraries." ON)

SET(CMAKE_COLOR_MAKEFILE ON)
SET(CMAKE_VERBOSE_MAKEFILE ON)

SET(EXECUTABLE_OUTPUT_PATH bin/${CMAKE_BUILD_TYPE})

# AIX                           AIX
# BSD/OS                        BSD/OS
# FreeBSD                       FreeBSD
# HP-UX                         HP-UX
# IRIX                          IRIX
# Linux                         Linux
# NetBSD                        NetBSD
# OpenBSD                       OpenBSD
# OFS/1 (Digital Unix)          OSF1
# SCO OpenServer 5              SCO_SV
# SCO UnixWare 7                UnixWare
# SCO UnixWare (pre release 7)  UNIX_SV
# SCO XENIX                     Xenix
# Solaris                       SunOS
# SunOS                         SunOS
# Tru64                         Tru64
# Ultrix                        ULTRIX
# cygwin                        CYGWIN_NT-5.1
# MacOSX                        Darwin

MESSAGE("OS is : ${CMAKE_SYSTEM}-${CMAKE_SYSTEM_VERSION} ${CMAKE_UNAME} ${CMAKE_HOST_UNIX} ${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_PROCESSOR} ")

#default /usr/local
#SET(CMAKE_INSTALL_PREFIX  /usr/local)

SET(PROJECT_BUILD_TYPE ${CMAKE_BUILD_TYPE})

IF(DEFINED ENV{PROJECT_SRC})
  MESSAGE("PROJECT_SRC is defined to : $ENV{PROJECT_SRC}")
  SET(DEV_SOURCE_DIR $ENV{PROJECT_SRC})
ELSE()
  MESSAGE("PROJECT_SRC is NOT defined")
  SET(DEV_SOURCE_DIR ${CMAKE_SOURCE_DIR}/..)
  MESSAGE(STATUS "DEV_SOURCE_DIR setted to environement values")
ENDIF()

MESSAGE("DEV_SOURCE_DIR is ${DEV_SOURCE_DIR}")

IF(DEFINED ENV{PROJECT_TARGET_PATH})
  MESSAGE("PROJECT_TARGET_PATH is defined to : $ENV{PROJECT_TARGET_PATH}")
  #SET(DEV_BINARY_DIR "$ENV{PROJECT_TARGET_PATH}")
  SET(DEV_BINARY_DIR "${CMAKE_BINARY_DIR}")
ELSE()
  MESSAGE("PROJECT_TARGET_PATH is NOT defined")
  SET(DEV_BINARY_DIR "${CMAKE_BINARY_DIR}/target")
  MESSAGE(STATUS "PROJECT_TARGET_PATH setted to environement values")
ENDIF()
MESSAGE("DEV_BINARY_DIR is ${DEV_BINARY_DIR}")

SET(PROJECT_SOURCE_DIR "${DEV_SOURCE_DIR}")
MESSAGE("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")
SET(PROJECT_BINARY_DIR "${DEV_BINARY_DIR}")
MESSAGE("PROJECT_BINARY_DIR is ${PROJECT_BINARY_DIR}")

IF(DEFINED ENV{PROJECT_THIRDPARTY_PATH})
  MESSAGE("PROJECT_THIRDPARTY_PATH is defined to : $ENV{PROJECT_THIRDPARTY_PATH}")
  SET(PROJECT_THIRDPARTY_PATH "$ENV{PROJECT_THIRDPARTY_PATH}")
ELSE()
  MESSAGE("PROJECT_THIRDPARTY_PATH is NOT defined")
  SET(PROJECT_THIRDPARTY_PATH "thirdparty")
  MESSAGE(STATUS "PROJECT_THIRDPARTY_PATH setted to environement values")
ENDIF()
MESSAGE("PROJECT_THIRDPARTY_PATH is ${PROJECT_THIRDPARTY_PATH}")
SET(PROJECT_THIRDPARTY_PATH_LOCAL "${PROJECT_THIRDPARTY_PATH}")

SET(DATABASE_ROOT "${PROJECT_THIRDPARTY_PATH_LOCAL}/database")

MESSAGE("CMAKE_SYSTEM is ${CMAKE_SYSTEM}")

IF(UNIX)

  MESSAGE(STATUS "UNIX found")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    MESSAGE(STATUS "Linux found")
    SET(ARCH linux)
    SET(MACHINE x86Linux)

    SET(CMAKE_CXX_FLAGS "-g -Wall -pthread")
    SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined")
    ADD_DEFINITIONS(-Dlinux -DP100)

  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    MESSAGE(STATUS "Linux not found")
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")
    MESSAGE(STATUS "SunOS found")
    SET(ARCH solaris)
    SET(MACHINE sun4sol)

    ADD_DEFINITIONS(-Dsolaris -DSYSV -DSVR4 -DP100 -DDEBUG -DANSI_C -D_POSIX_THREADS -mt -xildoff -DOWTOOLKIT_WARNING_DISABLED)

  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")
    MESSAGE(STATUS "SunOS not found")
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")

  IF("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")
    MESSAGE(STATUS "SunOS-5.10 found")
    SET(ARCH solaris)
    SET(MACHINE x86sol)

  ELSE("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")
    MESSAGE(STATUS "SunOS-5.10 not found")
  ENDIF("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN")
    MESSAGE(STATUS "CYGWIN found")
    SET(ARCH cygwin)
    SET(MACHINE x86Linux)

    SET(CYGWIN_HOME "$ENV{CYGWIN_HOME}")
    SET(CMAKE_LEGACY_CYGWIN_WIN32 0)

    SET(GCC_VERSION 3.4.4)

    #For Eclipse to avoid : Unresolved inclusion add this to the include path
    #INCLUDE_DIRECTORIES("${CYGWIN_HOME}/lib/gcc/i686-pc-cygwin/${GCC_VERSION}/include/c++")
    #LINK_DIRECTORIES("${CYGWIN_HOME}/lib/gcc/i686-pc-cygwin/${GCC_VERSION}/debug")

    SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined")

    ADD_DEFINITIONS(-Dcygwin -Dlinux -DP100)
    ADD_DEFINITIONS(-DDEBUG -DNOMINMAX)
    ADD_DEFINITIONS(-DEXCEPTION_EXPORTS)

  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN")
    MESSAGE(STATUS "CYGWIN not found")
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN")

ELSE(UNIX)
  MESSAGE(STATUS "UNIX not found")
ENDIF(UNIX)

IF(MINGW)

  MESSAGE(STATUS "MINGW found")
  SET(ARCH linux)
  SET(MACHINE x86Linux)

  INCLUDE_DIRECTORIES("C:\\cygwin\\usr\\include")
  LINK_DIRECTORIES("C:\\cygwin\\lib")

  ADD_DEFINITIONS(-Dlinux -DuseTao -DACE_HAS_EXCEPTIONS -D_TEMPLATES_ENABLE_ -D_REENTRANT -DEffix_Infra_HAS_BOOL)

ELSE(MINGW)
  MESSAGE(STATUS "MINGW not found")

ENDIF(MINGW)

SET(PROJECT_INCLUDE_DIR ${PROJECT_BINARY_DIR}/include)
SET(PROJECT_INSTALL_DIR ${PROJECT_BINARY_DIR})
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR})
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

#SET(PROJECT_INCLUDE_DIR ${PROJECT_BINARY_DIR}/install/${MACHINE}/${PROJECT_BUILD_TYPE}/include)
#SET(PROJECT_INSTALL_DIR ${PROJECT_BINARY_DIR}/install/${MACHINE}/${PROJECT_BUILD_TYPE})
#SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib/${MACHINE}/${PROJECT_BUILD_TYPE})
#SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin/${MACHINE}/${PROJECT_BUILD_TYPE})

SET(CORBA_PC_DIR ${PROJECT_BINARY_DIR}/project/corba/${MACHINE}/${PROJECT_BUILD_TYPE})

MESSAGE(STATUS "MACHINE is ${MACHINE}")

MAKE_DIRECTORY(${PROJECT_INCLUDE_DIR})
MAKE_DIRECTORY(${CORBA_PC_DIR})

OPTION(BUILD_SHARED_LIBS "Build PROJECT shared libraries." OFF)

#IF(WIN32)
#  ADD_DEFINITIONS("-DWIN32")
#ENDIF(WIN32)

MESSAGE(STATUS "Project source directory is ${PROJECT_SOURCE_DIR}")
MESSAGE(STATUS "Project include directory is ${PROJECT_INCLUDE_DIR}")

CONFIGURE_FILE(${PROJECT_SOURCE_DIR}/config/config.h.in ${PROJECT_INCLUDE_DIR}/config.h)
MESSAGE(STATUS "configured ${PROJECT_SOURCE_DIR}/config/config.h.in --> ${PROJECT_INCLUDE_DIR}/config.h")

SET(MOVE_FILE_COMMAND mv)
SET(COPY_FILE_COMMAND cp)

INCLUDE(${PROJECT_SOURCE_DIR}/config/ProjectVersion.cmake)

INCLUDE(${PROJECT_SOURCE_DIR}/config/ProjectMacro.cmake)

OPTION(ENABLE_TESTS "Enable building of tests" ON)

IF( ENABLE_TESTS )
  INCLUDE(${PROJECT_SOURCE_DIR}/config/FindCppUnit.cmake)
ENDIF(ENABLE_TESTS )

#Inclusion
# See ${PROJ_SOURCE_DIR}/config for special inclusion
INCLUDE(FindBoost)
INCLUDE(FindGettext)
INCLUDE(FindLibXml2)
#INCLUDE(FindX11)
#INCLUDE(FindQt3)
INCLUDE(FindZLIB)
INCLUDE(FindDoxygen)

#HOW TO USE
#cmake -DWITH_GUI=ON -DDATA_DIR=/home/me/datadir .

IF (NOT DATA_DIR)
  SET(DATA_DIR "/usr/share/mydatadir")
ENDIF(NOT DATA_DIR)
MESSAGE(STATUS "Data are in directory ${DATA_DIR}")

INCLUDE_DIRECTORIES(${PROJECT_INCLUDE_DIR})
#INCLUDE_DIRECTORIES(${CMAKE_INSTALL_PREFIX})

IF(UNIX)

  MESSAGE(STATUS "UNIX found")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")
    MESSAGE(STATUS "SunOS found")

    SET(TIBCO_VERSION "8.1.2")
    SET(XERCES_VERSION "3_0_1")

    #Inclusion de CORBA
    SET(CORBA_VERSION "")

    SET(JAVA_AWT_INCLUDE_DIRECTORIES ${PROJECT_THIRDPARTY_PATH}/j2se/${MACHINE}/jdk1.5/include)
    SET(JAVA_INCLUDE_PATH ${PROJECT_THIRDPARTY_PATH}/j2se/${MACHINE}/jdk1.5/include/solaris)
    SET(JAVA_INCLUDE_PATH2 ${PROJECT_THIRDPARTY_PATH}/j2se/${MACHINE}/jdk1.5/include/solaris)
    SET(JAVA_JVM_LIBRARY_DIRECTORIES ${PROJECT_THIRDPARTY_PATH}/j2se/${MACHINE}/jdk1.5/jre/lib/sparc)

    SET(JAVA_AWT_LIBRARY ${JAVA_JVM_LIBRARY_DIRECTORIES}/libjawt.so ${JAVA_JVM_LIBRARY_DIRECTORIES}/xawt/libmawt.so)
    SET(JAVA_JVM_LIBRARY ${JAVA_JVM_LIBRARY_DIRECTORIES}/libjvm.so)

  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")
    MESSAGE(STATUS "SunOS not found")
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")

  IF("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")
    MESSAGE(STATUS "SunOS-5.10 found")
    SET(MACHINE x86sol)

  ELSE("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")
    MESSAGE(STATUS "SunOS-5.10 not found")
  ENDIF("${CMAKE_SYSTEM}" MATCHES "SunOS-5.10")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    MESSAGE(STATUS "Linux found")

    LINK_DIRECTORIES(/usr/lib)

    SET(BOOST_OUTPUT_PATH ${PROJECT_BINARY_DIR}/install/${MACHINE}/${PROJECT_BUILD_TYPE}/lib/boost-${BOOST_VERSION})
    LINK_DIRECTORIES(${BOOST_OUTPUT_PATH})

    #z boost_thread-gcc-mt intl ncurses
    SET(Boost_LIBRARIES boost_thread-mt boost_system)

    SET(ZLIB_LIBRARY_DIRS z)
    SET(Gettext_LIBRARY_DIRS intl ncurses)
    SET(LIBXML_LIBRARY_DIRS xml2)

    #LINK_DIRECTORIES(${Gettext_LIBRARY_DIRS})

    #Inclusion de CORBA
    #INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers)
    #INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/TAO)
    #INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/TAO/orbsvcs)

    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib)

    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/include)

    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/lib)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/lib3p)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug)

    #INCLUDE_DIRECTORIES(${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/OCI/include)
    #LINK_DIRECTORIES(${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/OCI/lib/MSVC/vc71)

    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/artix30/${MACHINE}/artix/3.0/include)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/artix30/${MACHINE}/bin)

  ELSE(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    MESSAGE(STATUS "Linux not found")
  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN")
    MESSAGE(STATUS "CYGWIN found")

    #SET(LIB_PREFIX lib)
    #SET(LIB_STATIC_SUFFIX .a)
    #SET(LIB_DYNAMIC_SUFFIX .dll)

    LINK_DIRECTORIES(/usr/lib)

    SET(BOOST_OUTPUT_PATH ${PROJECT_BINARY_DIR}/install/${MACHINE}/${PROJECT_BUILD_TYPE}/lib/boost-${BOOST_VERSION})
    LINK_DIRECTORIES(${BOOST_OUTPUT_PATH})

    #z boost_thread-gcc-mt intl ncurses
    #SET(Boost_LIBRARIES boost_thread-gcc-mt)
    SET(Boost_LIBRARIES boost_thread-gcc34-mt-1_41)
    SET(ZLIB_LIBRARY_DIRS z)
    SET(Gettext_LIBRARY_DIRS intl ncurses)
    #SET(LIBXML_LIBRARY_DIRS LIBXML2_LIBRARIES)
    SET(LIBXML_LIBRARY_DIRS xml2)

    #LINK_DIRECTORIES(${Gettext_LIBRARY_DIRS})

    #Inclusion de CORBA
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers)
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/TAO)
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/TAO/orbsvcs)

    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib)

    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/include)

    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/lib)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/lib3p)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug)

    INCLUDE_DIRECTORIES(${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/OCI/include)
    LINK_DIRECTORIES(${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/OCI/lib/MSVC/vc71)

    #${JAVA_JVM_LIBRARY_DIRECTORIES}/xawt/libmawt.so
    #SET(JAVA_AWT_LIBRARY ${JAVA_JVM_LIBRARY_DIRECTORIES}/jawt.dll)
    #SET(JAVA_JVM_LIBRARY ${JAVA_JVM_LIBRARY_DIRECTORIES}/jvm.dll)

    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/artix30/${MACHINE}/artix/3.0/include)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/artix30/${MACHINE}/bin)

  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "CYGWIN")

  IF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")

    LINK_DIRECTORIES(/usr/lib)

    SET(LIB_PREFIX lib)
    SET(LIB_STATIC_SUFFIX .a)
    SET(LIB_DYNAMIC_SUFFIX .so)

    #QT_USE_FILE
    #SET(QT_INCLUDE_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/include)
    #SET(QT_BINARY_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/bin)
    #SET(QT_LIBRARY_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/debug/lib)
    #SET(QT_PLUGINS_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/plugins)
    #SET(QT_TRANSLATIONS_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/translations)
    #SET(QT_DOC_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/doc)
    #SET(QT_MKSPECS_DIR ${TOOLS_ROOT}/qt/${QT_VERSION}/${MACHINE}/opt/mkspecs)

    #INCLUDE(${QT_INCLUDE_DIR})
    #LINK_DIRECTORIES(${QT_LIBRARY_DIR})

    #SET(Qt3_FOUND)

    #Inclusion de CORBA
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/corba/tao/${CORBA_VERSION}${MACHINE}/ACE_wrappers)
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/corba/tao/${CORBA_VERSION}${MACHINE}/ACE_wrappers/TAO)
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/corba/tao/${CORBA_VERSION}${MACHINE}/ACE_wrappers/TAO/orbsvcs)

    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/corba/tao/${CORBA_VERSION}${MACHINE}/lib/${MACHINE}.mt/debug/shared)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/corba/tao/${CORBA_VERSION}${MACHINE}/lib/${MACHINE}.mt/gcc/opt/shared)

    #Inclusion de BOOST
    SET(Boost_INCLUDE_DIRS ${PROJECT_THIRDPARTY_PATH}/boost/${BOOST_VERSION}/include)
    MESSAGE(STATUS "Boost_INCLUDE_DIRS : ${Boost_INCLUDE_DIRS}")
    SET(Boost_LIBRARY_DIRS ${PROJECT_THIRDPARTY_PATH}/boost/${BOOST_VERSION}/lib/${MACHINE}/debug/shared)
    MESSAGE(STATUS "Boost_LIBRARY_DIRS : ${Boost_LIBRARY_DIRS}")
    #SET(Boost_FOUND TRUE)

    #Inclusion de XERCES
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/xml/xerces/c++/${XERCES_VERSION}/${MACHINE}/include)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/xml/xerces/c++/${XERCES_VERSION}/${MACHINE}/lib)

    #Inclusion de CPPUNIT
    INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/cppunit/${CPPUNIT_VERSION}/include)
    LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH}/cppunit/${CPPUNIT_VERSION}/lib/${MACHINE}/gcc/debug/shared)

    #Inclusion de LIBXML2
    #INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/libxml2/${XML2_VERSION}/winnt/include)
    #LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/libxml2/${XML2_VERSION}/winnt/lib)

    #INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/include)

  ENDIF(CMAKE_HOST_SYSTEM_NAME MATCHES "SunOS")

ELSE(UNIX)
  MESSAGE(STATUS "UNIX not found")
ENDIF(UNIX)

  #Inclusion de ENVIRONNEMENT
  LINK_DIRECTORIES(${LIBRARY_OUTPUT_PATH})

  #Inclusion de TIBCO
  INCLUDE_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/include)
  LINK_DIRECTORIES(${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/lib)

IF(CYGWIN)

  SET(BASECORBA ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libACE.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_AnyTypeCode.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_BiDirGIOP.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DynamicAny.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DynamicInterface.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IDL_BE.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IDL_FE.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IFR_Client.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IORManip.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IORTable.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Messaging.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_PortableServer.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTCORBA.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTPortableServer.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_SmartProxies.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Strategies.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_TypeCodeFactory.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Utils.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNaming.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNaming_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNaming_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Codeset.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libACE_ETCL.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libACE_ETCL_Parser.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libACE_Monitor_Control.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_AV.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CodecFactory.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Compression.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosConcurrency.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosConcurrency_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosConcurrency_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosEvent.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosEvent_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosEvent_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosLifeCycle.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosLifeCycle_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosLoadBalancing.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNotification.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNotification_MC.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNotification_MC_Ext.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNotification_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosNotification_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosProperty.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosProperty_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosProperty_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTime.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTime_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTime_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTrading.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTrading_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CosTrading_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CSD_Framework.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_CSD_ThreadPool.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DiffServPolicy.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsEventLogAdmin.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsEventLogAdmin_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsEventLogAdmin_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsLogAdmin.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsLogAdmin_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsLogAdmin_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsNotifyLogAdmin.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsNotifyLogAdmin_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_DsNotifyLogAdmin_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_EndpointPolicy.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ETCL.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FaultTolerance.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FT_ClientORB.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FT_ServerORB.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FTORB_Utils.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FTRT_ClientORB.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FTRT_EventChannel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_FtRtEvent.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IFR_BE.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IFRService.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ImR_Activator_IDL.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ImR_Client.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ImR_Locator_IDL.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_IORInterceptor.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Monitor.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Notify_Service.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ObjRefTemplate.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_PI.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_PI_Server.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_PortableGroup.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ReplicationManagerLib.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RT_Notification.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTCORBA.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTCORBAEvent.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEvent.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEvent_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEvent_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEventLogAdmin.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEventLogAdmin_Serv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTEventLogAdmin_Skel.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTSched.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTSchedEvent.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_RTScheduler.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Security.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Svc_Utils.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_TC.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_TC_IIOP.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_TypeCodeFactory.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Utils.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_Valuetype.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libTAO_ZIOP.dll)

                #${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libUTF16_UCS2.dll
                #${PROJECT_THIRDPARTY_PATH_LOCAL}/tao/ACE_wrappers/lib/libDynServer.dll

ELSE(CYGWIN)

  SET(BASECORBA ACE ACE_RMCast TAO TAO_BiDirGIOP TAO_DynamicAny TAO_DynamicInterface TAO_IDL_BE TAO_IDL_FE TAO_IFR_Client TAO_IORManip TAO_IORTable TAO_Messaging TAO_PortableServer TAO_RTCORBA TAO_RTPortableServer TAO_SmartProxies TAO_Strategies TAO_TypeCodeFactory TAO_Utils TAO_CosNaming TAO_Codeset)

ENDIF(CYGWIN)

#MESSAGE(STATUS "BASECORBA : ${BASECORBA}")

IF(CYGWIN)

  SET(BASETIBCO ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/libeay32.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/ssleay32.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrv.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvcm.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvcmq.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvcom.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvft.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvj.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvjsd.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvsd.dll
                ${PROJECT_THIRDPARTY_PATH_LOCAL}/tibco/tibrv/${TIBCO_VERSION}/${MACHINE}/bin/tibrvsdcom.dll)

ELSE(CYGWIN)

  SET(BASETIBCO tibrv tibrvcm tibrvcmq tibrvft)

ENDIF(CYGWIN)

IF(CYGWIN)

  SET(BASELIBXML2 ${PROJECT_THIRDPARTY_PATH_LOCAL}/libxml2/${XML2_VERSION}/winnt/lib/libxml2.dll
                  ${PROJECT_THIRDPARTY_PATH_LOCAL}/libxml2/${XML2_VERSION}/winnt/lib/libiconv2.dll)

  SET(BASELIBXML2 ${LIBXML_LIBRARY_DIRS})

ELSE(CYGWIN)

  SET(BASELIBXML2 xml2)

ENDIF(CYGWIN)

IF(CYGWIN)

  SET(BASESYBASE ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libct.dll
                 ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libcobct.dll
                 ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libcs.dll
                 ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libsybdb.dll
                 ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libxadtm.dll
                 ${PROJECT_THIRDPARTY_PATH_LOCAL}/database/sybase/openclient/${SYBASE_SERVER_VERSION}/ESD_${SYBASE_ESD_VERSION}/${MACHINE}/dll/debug/libblk.dll)

ELSE(CYGWIN)

  SET(BASESYBASE ct
                 cobct
                 cs
                 sybdb
                 xadtm
                 blk)

ENDIF(CYGWIN)

IF(CYGWIN)

  SET(BASEORACLE ${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/BIN/oci.dll
                 ${ORACLE_HOME}/app/oracle/product/${ORACLE_VERSION}/server/BIN/ociw32.dll)

ELSE(CYGWIN)

  SET(BASEORACLE oci
                 ociw32)

ENDIF(CYGWIN)

  SET(BASEXERCES xerces-c)

OPTION(WITH_GUI "Compil graphic unser interface" ON)

IF(WITH_GUI)
  MESSAGE(STATUS "Graphic user interface compilation activated")
  FIND_PACKAGE(X11)

  IF(X11_FOUND)
    MESSAGE(STATUS "X11 available")
    INCLUDE_DIRECTORIES(${X11_INCLUDE_DIR})
  ELSE(X11_FOUND)
    MESSAGE(STATUS "X11 not found")
  ENDIF(X11_FOUND)

  #FIND_PACKAGE(Qt3)

  #IF(Qt3_FOUND)
  #  MESSAGE(STATUS "Qt3 available")
  #  INCLUDE(${QT_USE_FILE})
  #  INCLUDE_DIRECTORIES(${QT_INCLUDES})
  #ELSE(Qt3_FOUND)
  #  MESSAGE(STATUS "Qt3 not found")
  #ENDIF(Qt3_FOUND)

ENDIF(WITH_GUI)

#FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(ZLIB)

IF(ZLIB_FOUND)
  MESSAGE(STATUS "ZLIB available")
  INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR})
  #LINK_DIRECTORIES(${ZLIB_LIBRARY_DIRS})
ELSE(ZLIB_FOUND)
  MESSAGE(STATUS "ZLIB not found")
ENDIF(ZLIB_FOUND)

#FIND_PACKAGE(
#	Boost
#	1.31.0
#	REQUIRED signals
#)

FIND_PACKAGE(
	Boost
)

#ADD_DEFINITIONS("-pthread")

IF(Boost_FOUND)
  MESSAGE(STATUS "Boost available")
  SET(Boost_USE_STATIC_LIBS OFF)
  SET(Boost_USE_MULTITHREAD ON)
  #SET(Boost_LIBRARIES boost_thread)

  MESSAGE(STATUS "${Boost_LIBRARIES}")

  INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS})
  LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
ELSE(Boost_FOUND)
  MESSAGE(STATUS "Boost not found")

ENDIF(Boost_FOUND)

#FIND_PACKAGE(LibXml2 REQUIRED)
FIND_PACKAGE(LibXml2)

IF(LIBXML2_FOUND)
  MESSAGE(STATUS "LIBXML2 available")
  INCLUDE_DIRECTORIES(${LIBXML2_INCLUDE_DIR})
  LINK_DIRECTORIES(${LIBXML2_LIBRARY_DIRS})
ELSE(LIBXML2_FOUND)
  MESSAGE(STATUS "LIBXML2 not found")
ENDIF(LIBXML2_FOUND)

OPTION( ENABLE_CORBA "Enable CORBA" ON)

INCLUDE(${PROJECT_SOURCE_DIR}/config/FindTAO.cmake)

IF(FOUND_TAO)
  MESSAGE(STATUS "TAO available")
  MESSAGE(STATUS " dans ${TAO_DIR} et ${ACE_DIR}")

  ADD_DEFINITIONS(${CORBA_CFLAGS} -DuseTao -D_TEMPLATES_ENABLE_ -D_REENTRANT)
ELSE(FOUND_TAO)
  MESSAGE(STATUS "TAO not found")
ENDIF(FOUND_TAO)

IF (MINGW)
  MESSAGE(STATUS "JNI not searched")
ELSE(MINGW)
  #INCLUDE(FindJNI)
  #MESSAGE(STATUS " JAVA dans ${JAVA_JVM_LIBRARY_DIR} et ${JNI_INCLUDE_DIRS}")

  #INCLUDE_DIRECTORIES(${JNI_INCLUDE_DIRS})
  #INCLUDE_DIRECTORIES(${JAVA_INCLUDE_PATH})

  #LINK_DIRECTORIES(${JNI_LIBRARIES})
ENDIF(MINGW)

#SET(EXCLUDE Unittest)
#SET(EXCLUDE_PATTERNS */*Unittest*/* )

INCLUDE(${PROJECT_SOURCE_DIR}/config/ProjectDoc.cmake)

INCLUDE(CTest)
INCLUDE(${PROJECT_SOURCE_DIR}/config/CTestConfig.cmake)

#ENABLE_TESTING(true)

#SET(CTEST_BINARY_DIRECTORY "${PROJECT_INSTALL_DIR}/bin")
#SET(CTEST_SOURCE_DIRECTORY "${CMAKE_SOURCE_DIR}/src/test/cpp")
##SET(CTEST_SOURCE_DIRECTORY "${PROJECT_SOURCE_DIR}/src/test/cpp")
## valgrind
#FIND_PROGRAM(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
#use ctest -T memcheck
INCLUDE(Dart)
#CONFIGURE_FILE(${PROJECT_BINARY_DIR}/DartConfiguration.tcl ${CMAKE_BINARY_DIR}/src/DartConfiguration.tcl)
#CONFIGURE_FILE("${PROJECT_BINARY_DIR}/DartConfiguration.tcl" "${CMAKE_BINARY_DIR}/DartConfiguration.tcl" )

#IF(CMAKE_COMPILER_IS_GNUCXX AND NOT BUILD_SHARED_LIBS)
#  SET(CMAKE_CXX_FLAGS "-fprofile-arcs -ftest-coverage")
#ENDIF(CMAKE_COMPILER_IS_GNUCXX AND NOT BUILD_SHARED_LIBS)

INCLUDE(InstallRequiredSystemLibraries)

SET(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
SET(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_MAJOR_VERSION})
SET(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_MINOR_VERSION})
SET(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_PATH_VERSION})

IF(WIN32 AND NOT UNIX)
  SET(CPACK_NSIS_MODIFY_PATH ON)
ELSE(WIN32 AND NOT UNIX)
  SET(CPACK_STRIP_FILES "")
  SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF(WIN32 AND NOT UNIX)
#SET(CPACK_PACKAGE_EXECUTABLES "Tools" "Tools")

INCLUDE(CPack)
