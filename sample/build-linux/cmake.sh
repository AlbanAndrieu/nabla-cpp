
#rm CMakeCache.txt

#-DCMAKE_COLOR_MAKEFILE=0FF
#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_INSTALL_PREFIX=/target/install/${ARCH}/debug

cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DECLIPSE_CDT4_GENERATE_SOURCE_PROJECT=TRUE ../microsoft
