#!/bin/bash
#set -xv

# for https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md
sudo apt-get install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3
sudo apt-get install libevent-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev
sudo apt install libsqlite3-dev
sudo apt install libminiupnpc-dev libnatpmp-dev
sudo apt-get install libzmq3-dev
sudo apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools
sudo apt-get install libqrencode-dev
sudo apt-get install libdb-dev libdb++-dev
sudo apt install pax-utils

# undefined reference to `__ubsan_handle_type_mismatch_v1'
sudo apt-get install libubsan0

./contrib/install_db4.sh `pwd`

#./configure --with-incompatible-bdb
export BDB_PREFIX='/workspace/users/albandrieu30/bitcoin/db4'
#./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"  CXX=clang++ CC=clang --enable-fuzz --with-sanitizers=fuzzer,address,undefined
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"  CXX=clang++ CC=clang --with-sanitizers=address,undefined
#--with-sanitizers=fuzzer-no-link,address,undefined

make -s j8
sudo make install
#ls -lrta /usr/local/lib
#ls -lrta /usr/local/bin

#libtool: install: /usr/bin/install -c bitcoind /usr/local/bin/bitcoind

scanelf -e src/bitcoind

#/usr/bin/llvm-symbolizer -> ../lib/llvm-10/bin/llvm-symbolizer
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
bitcoin-qt

exit 0
