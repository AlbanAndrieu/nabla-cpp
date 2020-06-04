# nabla-cpp
A project that contains cpp code sample

[![License](http://img.shields.io/:license-apache-blue.svg?style=flat-square)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![Gitter](https://badges.gitter.im/nabla-cpp/Lobby.svg)](https://gitter.im/nabla-cpp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Minimal java version](https://img.shields.io/badge/java-1.8-yellow.svg)](https://img.shields.io/badge/java-1.8-yellow.svg)

[![Jenkins build Status](http://albandrieu.com:8686/job/nabla-cpp-interview-microsoft-cmake/badge/icon)](http://albandrieu.com:8686/job/nabla-cpp-interview-microsoft-cmake/)
[![Travis Build Status](https://travis-ci.org/AlbanAndrieu/nabla-cpp.svg?branch=master)](https://travis-ci.org/AlbanAndrieu/nabla-cpp)
[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=MICROSOFT%3Amaster&metric=alert_status)](https://sonarcloud.io/dashboard/index/MICROSOFT%3Amaster)

## How to run it

### Install tools

```
./install.sh
```

See also install.sh

### Install python dependencies

```
#sudo pip2.7 freeze > requirements-current-2.7.txt
sudo pip2.7 install -r requirements-current-2.7.txt

#sudo pip3.7 freeze > requirements-current-3.7.txt
sudo pip3.7 install -r requirements-current-3.7.txt
```

See also build.sh for scons AND sample/build-linux/build.sh for cmake

### Build it

```
export SCONS="/usr/bin/python3.6 /opt/ansible/env36/bin/scons"
./build.sh
#python3 /usr/bin/scons --cache-disable opt=True gcc_version=9.2.1 color=True use_cpp11=True
```

### Clean it

```
scons --clean
```

See also clean.sh

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

## Quality tools

See [pre-commit](http://pre-commit.com/)
Run `pre-commit install`

Run `pre-commit run --all-files`

```
pylint --rcfile=.pylintrc SConstruct
pylint --rcfile=.pylintrc *.py
```

## Eclipse

File -> Import -> Existing code as Makefile project
```
sample/build-linux/
```
