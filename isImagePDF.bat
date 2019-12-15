@echo off
:: isImagePDF
:: a tool to check whether a pDF contains only images
:: Author: Alberto Buffolino

:: for internal !errorlevel! check in if (see below)
setlocal enabledelayedexpansion
:: return codes are:
:: 0: PDF has no text;
:: 1: PDF could contain same text in each page (a watermark or similar);
:: 2: PDF has a reasonable amount  of text;
:: 3: something went wrong.
set returncode=3
:: verify requirements
pdftotext -v>nul 2>nul
if %errorlevel% equ 9009 goto :alert1
pdfinfo -v>nul 2>nul
if %errorlevel% equ 9009 goto :alert1

:main:
:: extract whole text
pdftotext -raw -nopgbrk "%~dpnx1" "%tmp%\%~n1.txt"
if %errorlevel% equ 1 goto :alert2
if %errorlevel% equ 3 goto :alert3
set src="%~dpf1"
:: move to temp, the working directory
pushd %tmp%
:: start checks in a separate call (for args facilities)
call :check "%~n1.txt" %src%
:: delete previously generated txt
del "%~n1.txt" /q
:: restore starting directory
popd
:: return code set after call
exit /b %returncode%

:check:
:check1:
:: check if PDF has text
rem echo check1
:: check size of passed text file
if %~z1 equ 0 (
 echo Images-only PDF
	set returncode=0
	goto :eof
)
:: check to return if we are in sub-check2
if "%~2" == "check2" goto :eof

:check2:
:: check if text is the same for two random pages
rem echo check2
:: get PDF pages amount
set pages=0
for /f "usebackq tokens=2 delims= " %%a in (`pdfinfo "%~dpf2" ^| find "Pages: "`) do (set pages=%%a)
:: jump to check3 if we have less than 2 pages
if %pages% lss 2 (
	goto :check3
) else (
	rem :: "::" does strange errors here, use rem as prefix
	rem :: subcheck to exclude some PDF
	rem :: where only first page has text
	rem :: extracting text from 2nd to last page
	rem echo sub-check2
	pdftotext -f 2 -raw -nopgbrk  "%~dpf2" f0.txt
	call :check1 f0.txt "check2"
	del f0.txt /q
	rem :: if check1 says PDF has no text, terminate
	if !returncode! equ 0 goto :eof
)
:: give it up after 5 attempts
set loop=0
:check2loop:
set /a loop=%loop%+1
if %loop% gtr 5 goto :check3
rem echo check2loop
:: set random pages (or 1 and 2)
if %pages% equ 2 (
	rem echo We have 2 pages
	set page1=1
	set page2=2
) else (
	rem echo We have %pages% pages
	set /a page1=%random%*%pages%/32768+1
	set /a page2=%random%*%pages%/32768+1
)
if %page1% equ %page2% (
 rem echo Random pages are the same, retrying...
 goto :check2loop
 goto :eof
)
:: extract text of page %page1%
pdftotext -f %page1% -l %page1% -raw -nopgbrk "%~dpf2" f1.txt
:: if we have no text and more than 2 pages, do a new attempt
for %%e in (f1.txt) do (if %%~ze equ 0 if %pages% neq 2 goto :check2loop)
:: same for 2nd page %page2%
pdftotext -f %page2% -l %page2% -raw -nopgbrk "%~dpf2" f2.txt
for %%e in (f2.txt) do (if %%~ze equ 0 if %pages% neq 2 goto :check2loop)
echo Comparing page %page1% and %page2%
start /b /w fc f1.txt f2.txt>nul 2>nul
:: fc returns 0 if files are identical
if %errorlevel% equ 0 (
	echo PDF has some watermark 
	del f1.txt /q
	del f2.txt /q
	set returncode=1
) else (
	del f1.txt /q
	del f2.txt /q
	goto :check3
)
goto :eof

:check3:
:: simply echo text file size and set return code
rem echo check3
echo Derived TXT has size of %~z1 bytes
set returncode=2
goto :eof

:alert1:
echo Please get pdftotext and pdfinfo.
echo If you use Chocolatey, simple run:
echo choco install pdftk
exit /b %returncode%

:alert2:
echo Please specify a PDF file.
exit /b %returncode%

:alert3:
echo Try to unlock PDF with Calibre, unlockpdf.com or similar solutions.
exit /b %returncode%
