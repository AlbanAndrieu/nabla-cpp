@ECHO OFF
SETLOCAL ENABLEEXTENSIONS

SET /A ERROR_HELP_SCREEN=1
SET /A ERROR_FILE_NOT_FOUND=2
SET /A ERROR_FILE_READ_ONLY=4
SET /A ERROR_UNKNOWN=8

set project_dir=%CD%
set SCONS_MSCOMMON_DEBUG=-

echo "JAVA_HOME : %JAVA_HOME%"
call java -version
call scons --version
call gcc --version
REM call perl -V

echo "==============="
echo "BUILD"
call date /T && ECHO date succeeded!
call time /T
cd %project_dir%\ || ECHO command return code %ERRORLEVEL% 
echo "cd %project_dir%\"
echo "call scons %SCONS_OPTS%"
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
  exit 1 
) 

if not exist %project_dir%\install\winnt\debug\bin\run_app.exe ( 
  echo "Build failure: install\winnt\debug\bin\run_app.exe not found."
  exit 1 
) 

echo "==============="
cd %project_dir%\install\winnt || EXIT /B 1
del ..\winnt.zip
"C:\Program Files\7-Zip\7z" a -r ..\winnt.zip -xr!*.pdb *

echo "==============="
cd %WORKSPACE% || EXIT /B 1
echo NABLA #%BUILD_NUMBER%-sha1:%GIT_COMMIT:~0,6% > NABLA_WINDOWS_VERSION.TXT || EXIT /B 1

exit 0
