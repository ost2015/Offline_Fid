@echo off

REM if %1="" goto blank
for /R %1 %%a in (*.txt) do ( 
	..\x64\Debug\Offline_Fid.exe %%~dpa\ > %%~dpa\temp_%%~na.csv 
)

echo finished running. creating log files...

for /R %1 %%a in (*.txt) do (
mkdir ..\Results\%%~na\
	for /f skip^=5^ usebackq^ delims^=^ eol^= %%b in (%%~dpa\temp_%%~na.csv) do ( 
		echo %%b >> ..\Results\%%~na\OF_log.csv
	)
	
	del /q %%~dpa\temp_%%~na.csv
)
exit /b 1
:blank

for /R %CD% %%a in (*.txt) do ( 
	..\x64\Debug\Offline_Fid.exe %%~dpa\ > %%~dpa\temp_%%~na.csv 
)

echo finished running. creating log files...

for /R %CD% %%a in (*.txt) do (
	for /f skip^=5^ usebackq^ delims^=^ eol^= %%b in (%%~dpa\temp_%%~na.csv) do ( 
		mkdir ..\Results\%%~na\
		echo %%b >> ..\Results\%%~na\OF_log.csv
	)
	
	del /q %%~dpa\temp_%%~na.csv
)