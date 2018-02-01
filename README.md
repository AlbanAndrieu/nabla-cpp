# nabla-cpp
A project that contains cpp code sample

[![Build Status](http://home.nabla.mobi:8380/jenkins/job/nabla-cpp-interview-microsoft-cmake/badge/icon)](http://home.nabla.mobi:8380/jenkins/job/nabla-cpp-interview-microsoft-cmake/)

## How to run it

### Install python dependencies

```
sudo apt-get install scons scons-doc
sudo pip install -r requirements.txt
```

### Run it

```
scons
#scons --cache-disable opt=True gcc_version=5.4.0 color=True 
```

### Clean it

```
scons --clean
```

Your components should be available

You can convert a rpm to a deb with alien
```
sudo apt-get install alien
```

```
ldd target/bin/x86Linux/run_app

ldconfig -v | grep libstdc

file /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.22
#readelf -a -W /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.22
readelf -a -W target/lib/x86Linux/debug64/shared/libmain_library.so
```
