## [![Nabla](http://albandrieu.com/nabla/index/assets/nabla/nabla-4.png)](https://github.com/AlbanAndrieu)  nabla-cpp

A project that contains cpp code sample

[![License](http://img.shields.io/:license-apache-blue.svg?style=flat-square)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![Gitter](https://badges.gitter.im/nabla-cpp/Lobby.svg)](https://gitter.im/nabla-cpp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Minimal java version](https://img.shields.io/badge/java-1.8-yellow.svg)](https://img.shields.io/badge/java-1.8-yellow.svg)
[![Jenkins build Status](http://albandrieu.com/jenkins/job/nabla-cpp-interview-microsoft-cmake/badge/icon)](http://albandrieu.com/jenkins/job/nabla-cpp-interview-microsoft-cmake/)

[![Travis Build Status](https://travis-ci.org/AlbanAndrieu/nabla-cpp.svg?branch=master)](https://travis-ci.org/AlbanAndrieu/nabla-cpp)
[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=MICROSOFT%3Amaster&metric=alert_status)](https://sonarcloud.io/dashboard/index/MICROSOFT%3Amaster)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/AlbanAndrieu/nabla-cpp.svg)](https://github.com/AlbanAndrieu/nabla-cpp/pulls)
[![Docker Pulls](https://img.shields.io/docker/pulls/nabla/jenkins-slave-ubuntu)](https://hub.docker.com/r/nabla/jenkins-slave-ubuntu)<br/>

## Table of contents

<!-- toc -->

- [How to run it](#how-to-run-it)
  * [Install tools](#install-tools)
  * [Install python dependencies](#install-python-dependencies)
  * [Build it](#build-it)
  * [Clean it](#clean-it)
  * [Wine](#wine)
  * [pre-commit](#pre-commit)
- [Quality tools](#quality-tools)
- [Eclipse](#eclipse)
- [Tools](#tools)
  * [npm-groovy-lint groovy formating for Jenkinsfile](#npm-groovy-lint-groovy-formating-for-jenkinsfile)
- [Update README.md](#update-readmemd)

<!-- tocstop -->

## How to run it

### Install tools

```bash
./install.sh
```

See also install.sh

#### Linux or OS X

- Some Python packages: pip install conan termcolor distro pywin32

#### Windows

- [pywin32](http://sourceforge.net/projects/pywin32/) : path conversions (PyInstaller [issue](https://github.com/pyinstaller/pyinstaller/issues/1282); Windows only)
- Microsoft Visual C++ 2010 Redistributable Package (https://www.microsoft.com/en-US/download/details.aspx?id=5555)
- Microsoft Visual C++ Compiler for Python 2.7 (https://www.microsoft.com/en-us/download/details.aspx?id=44266): for pylzma

```
c:\Python27[-x64]\python.exe -m pip install --upgrade pip
pip.exe install colorama conan termcolor distro pywin32 setuptools==19.2 pyinstaller==2.1
```


### Install python dependencies

```bash
#sudo pip2.7 freeze > requirements-current-2.7.txt
sudo pip2.7 install -r requirements-current-2.7.txt

#sudo pip3.8 freeze > requirements-current-3.8.txt
sudo pip3.8 install -r requirements-current-3.8.txt
```

See also build.sh for scons AND sample/build-linux/build.sh for cmake

### Build it

```bash
export SCONS="/usr/bin/python3.6 /opt/ansible/env36/bin/scons"
./build.sh
#python3 /usr/bin/scons --cache-disable opt=True gcc_version=9.2.1 color=True use_cpp11=True
```

### Clean it

```bash
scons --clean
```

See also clean.sh

Your components should be available

You can convert a rpm to a deb with alien

```bash
sudo apt-get install alien
```

### Wine

See https://doc.ubuntu-fr.org/wine_trucs_et_astuces


```bash
# For 32 bits do first
export WINEARCH="win32"
# Start the program
WINEDEBUG=-all target/bin/x86Linux/run_app.exe
# shows dynamically linked libraries
ldd target/bin/x86Linux/run_app.exe
# shows the symbols in the file.
nm target/bin/x86Linux/run_app.exe
#convert PE32+ to ELF
strip -O elf32-i386 -o myprogram.elf -N xxxxxxx target/bin/x86Linux/run_app.exe
readelf -a -W  myprogram.elf
i686-w64-mingw32-objdump -h myprogram.elf

# See https://wiki.winehq.org/Wine_Developer%27s_Guide/Debugging_Wine
WINEDEBUG=+relay,-debug wine target/bin/x86Linux/run_app.exe
WINEDEBUG=+relay wine target/bin/x86Linux/run_app.exe 2>&1 | less -i
winedbg target/bin/x86Linux/run_app.exe

```


```bash
ldconfig -v | grep libstdc
g++ -print-file-name=libstdc++.a

file /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.22
#readelf -a -W /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.22
readelf -a -W target/lib/x86Linux/debug64/shared/libmain_library.so
```

### pre-commit

See [pre-commit](http://pre-commit.com/)
Run `pre-commit install`

First time run `cp hooks/hooks/* .git/hooks/`
or `git clone git@github.com:AlbanAndrieu/nabla-hooks.git hooks && rm -Rf ./.git/hooks && ln -s ../hooks/hooks ./.git/hooks`

Run `pre-commit run --all-files`

Run `SKIP=ansible-lint git commit -am 'Add key'`
Run `git commit -am 'Add key' --no-verify`

## Quality tools

See [pre-commit](http://pre-commit.com/)
Run `pre-commit install`

Run `pre-commit run --all-files`

```bash
pylint --rcfile=.pylintrc SConstruct
pylint --rcfile=.pylintrc *.py
```

## Eclipse

File -> Import -> Existing code as Makefile project
```
sample/build-linux/
```

## Tools

See [tools](https://linuxfr.org/users/oliver_h/journaux/moi-expert-c-j-abandonne-le-cxx)

### npm-groovy-lint groovy formating for Jenkinsfile

Tested with nodejs 12 and 16 on ubuntu 20 and 21 (not working with nodejs 11 and 16)

```bash
npm install -g npm-groovy-lint@8.2.0
npm-groovy-lint --format
ls -lrta .groovylintrc.json
```

## Update README.md


  * [github-markdown-toc](https://github.com/jonschlinkert/markdown-toc)
  * With [github-markdown-toc](https://github.com/Lucas-C/pre-commit-hooks-nodejs)

```bash
npm install --save markdown-toc
markdown-toc README.md
markdown-toc CHANGELOG.md  -i
```

```bash
pre-commit install
git add README.md
pre-commit run markdown-toc
```
