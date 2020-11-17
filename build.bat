@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

SET /A ERROR_HELP_SCREEN=1
SET /A ERROR_FILE_NOT_FOUND=2
SET /A ERROR_FILE_READ_ONLY=4
SET /A ERROR_UNKNOWN=8

set project_dir=%CD%
set SCONS_MSCOMMON_DEBUG=-

set PATH=C:\tools\msys64\mingw32\bin;C:\tools\msys64\usr\bin;%PATH%

echo "JAVA_HOME : %JAVA_HOME%"

call where bash
call where cl

call java -version
call scons --version
call gcc --version
REM call clang --version
call i686-w64-mingw32-g++ --version
REM call perl -V
call python --version
REM call cl /?

REM Get scons from http://fr1cslfrbm0059.misys.global.ad/download/scons/scons-2.4.1.zip and copy it to C:\Python27\scons-2.4.1
REM call C:\Python27\python.exe C:\Python27\scons-2.4.1\setup.py install
REM call C:\Python27\scons-2.4.1.bat --version
REM call C:\Python27\Scripts\pip2.7.exe install pywin32==228

call conan install sample\microsoft  --build boost -g scons -if .\sample\build-x86_64

echo "==============="
echo "BUILD"
call date /T && ECHO date succeeded!
call time /T
cd %project_dir%\ || ECHO command return code %ERRORLEVEL%
echo "cd %project_dir%\"

REM /c/Python38/python.exe /c/Python38/Scripts/scons.exe
echo "call C:\Python38\python.exe C:\Python38\Scripts\scons.exe %SCONS_OPTS%"
REM call scons %SCONS_OPTS% || EXIT /B 1
call scons %SCONS_OPTS%
IF %ERRORLEVEL% NEQ 0 (
  ECHO do something here to address the error %ERRORLEVEL%
  REM EXIT 2
)

call date /T
call time /T

if not exist %project_dir%\install\winnt\debug\bin\run_tests.exe (
  echo "Build failure: install\winnt\debug\bin\run_tests.exe not found."
  REM exit 1
)

if not exist %project_dir%\install\winnt\debug\bin\run_app.exe (
  echo "Build failure: install\winnt\debug\bin\run_app.exe not found."
  REM exit 1
)

pause

echo "==============="
cd %project_dir%\install\winnt || EXIT /B 1
del ..\winnt.zip
"C:\Program Files\7-Zip\7z" a -r ..\winnt.zip -xr!*.pdb *

echo "==============="
cd %WORKSPACE% || EXIT /B 1
echo NABLA #%BUILD_NUMBER%-sha1:%GIT_COMMIT:~0,6% > NABLA_WINDOWS_VERSION.TXT || EXIT /B 1

echo "==============="
echo "scons use_mingw=False use_cpp11=False use_pthread=False"

echo "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2019\Visual Studio Tools"
echo "C:\VS\2019\BuildTools"

pause

echo ELVL: !ERRORLEVEL!
IF NOT !ERRORLEVEL! == 0 (
 ECHO ABORT: !ERRORLEVEL!
 exit /b !ERRORLEVEL!
) ELSE (
 ECHO PROCEED: !ERRORLEVEL!
)

REM exit 0
