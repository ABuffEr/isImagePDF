@echo off
setlocal enabledelayedexpansion
md OCRReady
md Watermarked
md Textual
md Problematic
for %%f in (*.pdf) do (
	echo %%f
	call isImagePDF "%%f"
	if !errorlevel! equ 0 move "%%f" OCRReady\
	if !errorlevel! equ 1 move "%%f" Watermarked\
	if !errorlevel! equ 2 move "%%f" Textual\
	if !errorlevel! equ 3 move "%%f" Problematic\
)
