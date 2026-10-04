@echo off
setlocal enabledelayedexpansion
title RTX 50-Series (Blackwell) NVENC Mezzanine Transcoder

:: Verify FFmpeg exists in system PATH
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] FFmpeg was not detected in your system PATH!
    echo Please install FFmpeg and add the 'bin' folder to your Environment Variables.
    echo.
    pause
    exit /b
)

:: Verify user passed files by drag-and-drop
if "%~1"=="" (
    echo ======================================================================
    echo   RTX 50-Series (Blackwell) NVENC Mezzanine Transcoder
    echo ======================================================================
    echo.
    echo [NO INPUT DETECTED]
    echo To use this script, select one or more video files in File Explorer
    echo and drag-and-drop them directly onto this .bat file.
    echo.
    pause
    exit /b
)

:: ==============================================================================
:: INTERACTIVE USER CONFIGURATION MENU
:: ==============================================================================
cls
echo ======================================================================
echo   RTX 50-SERIES NVENC TRANSCODER CONFIGURATION
echo ======================================================================
echo.

:: 1. CHROMA SUBSAMPLING SELECTION
echo [1] Choose Chroma Subsampling:
echo     1. 4:2:2 (ProRes/Mezzanine Intermediate - Ideal for 4K/8K Editing)
echo     2. 4:2:0 (Maximum Compatibility - Web, YouTube, Smaller File Size)
echo     3. 4:4:4 (Full Chroma - Screen Captures, VFX, CGI, Fine Graphics)
set /p CHROMA_CHOICE="Enter 1, 2, or 3 (Default: 1): "
if "%CHROMA_CHOICE%"=="2" (
    set "PIX_FMT=p010le"
    set "PROFILE_FLAG=-profile:v main10"
    set "CHROMA_TAG=420"
) else if "%CHROMA_CHOICE%"=="3" (
    set "PIX_FMT=yuv444p16le"
    set "PROFILE_FLAG=-profile:v rext"
    set "CHROMA_TAG=444"
) else (
    set "PIX_FMT=p210le"
    set "PROFILE_FLAG=-profile:v rext"
    set "CHROMA_TAG=422"
)
echo Selected: %CHROMA_TAG%
echo.

:: 2. CONTENT TYPE SELECTION (PEOPLE VS MECHANICAL)
echo [2] Choose Subject / Scene Type:
echo     1. People / Interviews / Cinematic (Smooth skin tones, prevents face blotches)
echo     2. Mechanical / High Detail / Aviation (Sharp edges, rivets, fine textures)
set /p SCENE_CHOICE="Enter 1 or 2 (Default: 1): "
if "%SCENE_CHOICE%"=="2" (
    set "AQ_FLAGS=-spatial_aq 1 -temporal_aq 1 -aq-strength 8"
    set "SCENE_TAG=Action"
) else (
    set "AQ_FLAGS=-spatial_aq 1 -temporal_aq 1 -aq-strength 5"
    set "SCENE_TAG=Cinematic"
)
echo Selected: %SCENE_TAG%
echo.

:: 3. QUALITY / COMPRESSION TIER
echo [3] Choose Visual Quality / File Size Tier:
echo     1. Master Grade (QP 15 - Visually lossless, larger files, optimal for punch-in)
echo     2. Balanced Quality (QP 18 - Excellent retention, ~40%% smaller files)
echo     3. Delivery / Archival (QP 22 - Smallest footprint, great for client review/web)
set /p QP_CHOICE="Enter 1, 2, or 3 (Default: 1): "
if "%QP_CHOICE%"=="2" (
    set "QP_VAL=18"
) else if "%QP_CHOICE%"=="3" (
    set "QP_VAL=22"
) else (
    set "QP_VAL=15"
)
echo Selected QP: %QP_VAL%
echo.

echo ======================================================================
echo Ready to process! Press any key to begin transcoding...
echo ======================================================================
pause >nul

:: ==============================================================================
:: BATCH TRANSCODE EXECUTION LOOP
:: ==============================================================================
:process_loop
if "%~1"=="" goto finish

set "INPUT_FILE=%~1"
set "FILE_DIR=%~dp1"
set "FILE_NAME=%~n1"

echo.
echo ----------------------------------------------------------------------
echo Processing: "%FILE_NAME%"
echo Mode: 10-bit %CHROMA_TAG% | QP: %QP_VAL% | Scene: %SCENE_TAG%
echo ----------------------------------------------------------------------

ffmpeg -hide_banner -hwaccel cuda -i "%INPUT_FILE%" ^
  -c:v hevc_nvenc -preset p7 -tune hq %PROFILE_FLAG% -pix_fmt %PIX_FMT% ^
  -rc constqp -qp %QP_VAL% %AQ_FLAGS% ^
  -c:a copy ^
  "%FILE_DIR%%FILE_NAME%_%CHROMA_TAG%_Master.mov"

shift
goto process_loop

:finish
echo.
echo ======================================================================
echo   Batch complete! All files transcoded successfully.
echo ======================================================================
pause
exit /b