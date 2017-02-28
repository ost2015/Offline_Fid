@echo off

REM if %1="" goto blank
for /R %1 %%a in (*.txt) do ( 
	echo runs %%~na 
	..\x64\Debug\Offline_Fid.exe %%~dpa\ 
)

echo finished running. creating log files...
pause
for /R %1 %%a in (*.txt) do (
mkdir ..\Results\%%~na\
	move %%~dpa\log.csv ..\Results\%%~na\OF_log.csv 
)
exit /b 1
REM :blank

REM for /R %CD% %%a in (*.txt) do ( 
	REM ..\x64\Debug\Offline_Fid.exe %%~dpa\ > %%~dpa\temp_%%~na.csv 
REM )

REM echo finished running. creating log files...

REM for /R %CD% %%a in (*.txt) do (
	REM for /f skip^=5^ usebackq^ delims^=^ eol^= %%b in (%%~dpa\temp_%%~na.csv) do ( 
		REM mkdir ..\Results\%%~na\
		REM echo %%b >> ..\Results\%%~na\OF_log.csv
	REM )
	
	REM del /q %%~dpa\temp_%%~na.csv
REM )