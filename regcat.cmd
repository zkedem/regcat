@echo off
setlocal ENABLEDELAYEDEXPANSION
set filename=CON
set "regfilelist=^ "
set "needsusage="
if "%1" == "" set "needsusage=1"
if "%1" == "/?" set "needsusage=1"
if %needsusage% EQU 1 (
	echo Concatenates Windows Registry files to a single file. 1>&2
	echo. 1>&2
	echo %0 file1.reg file2.reg ... [/O:filename] 1>&2
	echo. 1>&2
	echo     file1.reg    An input file. 1>&2
	echo     /O:filename  Output to filename. 1>&2
	goto :EOF
)
for %%a in (%*) do (
	set "argument=%%a"
	if not !argument:/O:^=! == !argument! (
		set "filename=!argument:/O:=!"
	) else (
		set "regfilelist=!regfilelist!!argument!^ "
	)
)
echo Windows Registry Editor Version 5.00 > %filename%
type%regfilelist% 2>NUL | findstr /R /V /C:"^Windows Registry Editor Version 5\.00$" >> %filename%
endlocal