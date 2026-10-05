@echo off
setlocal DisableDelayedExpansion
title ProRes to HEVC Broadcast 422 - v1.1

:: Set Configuration File Location
set "CONFIG_FILE=%~dp0.hevc_last_settings.ini"

:: 1. System Check: Verify Local or System FFmpeg
if exist "%~dp0ffmpeg.exe" (
    set "FFMPEG_CMD=%~dp0ffmpeg.exe"
) else (
    where ffmpeg >nul 2>nul
    if %errorlevel% equ 0 (
        set "FFMPEG_CMD=ffmpeg"
    ) else (
        echo.
        echo ======================================================================
        echo [ERROR] FFmpeg was NOT found!
        echo ======================================================================
        echo Could not find "ffmpeg.exe" next to this script or in Windows PATH.
        echo.
        pause
        exit /b
    )
)

:: 2. Check Input Files
if "%~1"=="" (
    echo.
    echo ======================================================================
    echo   ProRes to HEVC Broadcast 422 - v1.1
    echo ======================================================================
    echo.
    echo [NO FILES DETECTED]
    echo Drag and drop one or more video files directly onto this batch file.
    echo.
    pause
    exit /b
)

:: 3. Check for Saved Settings
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
        set "CFG_%%A=%%B"
    )
    goto prompt_reuse
)
goto manual_menu

:prompt_reuse
cls
echo ======================================================================
echo   ProRes to HEVC Broadcast 422 - v1.1
echo ======================================================================
echo.
echo [PREVIOUS CONFIGURATION DETECTED]
echo   - Chroma Subsampling : %CFG_LABEL_CHROMA%
echo   - Scene Tuning       : %CFG_LABEL_SCENE%
echo   - Quality Target     : %CFG_LABEL_QP%
echo   - Container Format   : %CFG_LABEL_CONTAINER%
echo   - Output Destination : %CFG_LABEL_DEST%
echo.
echo ----------------------------------------------------------------------
echo   Press [ENTER] to reuse these settings
echo   - OR -
echo   Type [N] and press Enter to choose new settings
echo ----------------------------------------------------------------------
set /p REUSE_CHOICE="Selection [Default: Reuse]: "
if /i "%REUSE_CHOICE%"=="N" goto manual_menu

:: Apply cached variables
set "PIX_FMT=%CFG_PIX_FMT%"
set "PROFILE_FLAG=%CFG_PROFILE_FLAG%"
set "CHROMA_TAG=%CFG_CHROMA_TAG%"
set "AQ_FLAGS=%CFG_AQ_FLAGS%"
set "SCENE_TAG=%CFG_SCENE_TAG%"
set "QP_VAL=%CFG_QP_VAL%"
set "OUT_EXT=%CFG_OUT_EXT%"
set "AUDIO_FLAG=%CFG_AUDIO_FLAG%"
set "DATA_MAP=%CFG_DATA_MAP%"
set "DEST_MODE=%CFG_DEST_MODE%"
goto confirm_run

:manual_menu
cls
echo ======================================================================
echo   ProRes to HEVC Broadcast 422 - v1.1 Configuration
echo ======================================================================
echo.

echo [1] Choose Chroma Subsampling:
echo     1. 4:2:2 (Broadcast Intermediate and NLE Master - Recommended)
echo     2. 4:2:0 (Web Delivery, YouTube, Minimum File Size)
echo     3. 4:4:4 (Full Chroma - Screen Capture, VFX, Graphics)
set /p CHROMA_CHOICE="Enter 1, 2, or 3 (Default: 1): "
if "%CHROMA_CHOICE%"=="2" (
    set "PIX_FMT=p010le"
    set "PROFILE_FLAG=-profile:v main10"
    set "CHROMA_TAG=420"
    set "LABEL_CHROMA=4:2:0 (Web Delivery / main10)"
) else if "%CHROMA_CHOICE%"=="3" (
    set "PIX_FMT=yuv444p16le"
    set "PROFILE_FLAG=-profile:v rext"
    set "CHROMA_TAG=444"
    set "LABEL_CHROMA=4:4:4 (Full Chroma / rext)"
) else (
    set "PIX_FMT=p210le"
    set "PROFILE_FLAG=-profile:v rext"
    set "CHROMA_TAG=422"
    set "LABEL_CHROMA=4:2:2 (Broadcast Master / rext)"
)
echo.

echo [2] Choose Scene Type:
echo     1. People / Interviews (Smoother skin tones, no macroblocking)
echo     2. Action / Aviation / High Detail (Preserves rivets, fine textures)
set /p SCENE_CHOICE="Enter 1 or 2 (Default: 1): "
if "%SCENE_CHOICE%"=="2" (
    set "AQ_FLAGS=-spatial_aq 1 -temporal_aq 1"
    set "SCENE_TAG=Action"
    set "LABEL_SCENE=Action / Aviation (Spatial AQ On)"
) else (
    set "AQ_FLAGS=-spatial_aq 0 -temporal_aq 1"
    set "SCENE_TAG=Cinematic"
    set "LABEL_SCENE=People / Interviews (Smooth Skin)"
)
echo.

echo [3] Choose Quality Target:
echo     1. Master Grade (QP 15 - Visually lossless archive)
echo     2. Balanced (QP 18 - Excellent balance of quality and storage)
echo     3. Delivery (QP 22 - Smallest footprint for client review)
set /p QP_CHOICE="Enter 1, 2, or 3 (Default: 1): "
if "%QP_CHOICE%"=="2" (
    set "QP_VAL=18"
    set "LABEL_QP=Balanced (QP 18)"
) else if "%QP_CHOICE%"=="3" (
    set "QP_VAL=22"
    set "LABEL_QP=Delivery (QP 22)"
) else (
    set "QP_VAL=15"
    set "LABEL_QP=Master Grade (QP 15)"
)
echo.

echo [4] Choose Output Container Format:
echo     * TIP: For project archiving and timeline relinking in Premiere or
echo       Resolve, keep the container identical to the original (usually MOV).
echo     ----------------------------------------------------------------------
echo     1. MOV (Copies lossless uncompressed PCM audio and timecode tracks)
echo     2. MP4 (Encodes to AAC audio - Best for web and mobile devices)
set /p EXT_CHOICE="Enter 1 or 2 (Default: 1): "
if "%EXT_CHOICE%"=="2" (
    set "OUT_EXT=mp4"
    set "AUDIO_FLAG=-c:a aac -b:a 320k"
    set "DATA_MAP="
    set "LABEL_CONTAINER=.MP4 (AAC Audio)"
) else (
    set "OUT_EXT=mov"
    set "AUDIO_FLAG=-c:a copy"
    set "DATA_MAP=-map 0:d?"
    set "LABEL_CONTAINER=.MOV (PCM Lossless Copy)"
)
echo.

echo [5] Choose File Naming and Output Strategy:
echo     1. Clean Archive for NLE Relinking (Recommended)
echo        - Keeps the EXACT same filename.
echo        - Writes to an "_Archived" subfolder.
echo        - Enables 1-click batch relinking in Premiere and DaVinci Resolve.
echo.
echo     2. Standalone Export (Side-by-Side)
echo        - Saves in the source folder alongside the original file.
echo        - Appends "_Master" to the filename to avoid collisions.
set /p DEST_CHOICE="Enter 1 or 2 (Default: 1): "
if "%DEST_CHOICE%"=="2" (
    set "DEST_MODE=STANDALONE"
    set "LABEL_DEST=Same folder with _Master suffix"
) else (
    set "DEST_MODE=ARCHIVE"
    set "LABEL_DEST=_Archived subfolder with exact original filename"
)

:: Save settings to .ini cache
(
    echo PIX_FMT=%PIX_FMT%
    echo PROFILE_FLAG=%PROFILE_FLAG%
    echo CHROMA_TAG=%CHROMA_TAG%
    echo AQ_FLAGS=%AQ_FLAGS%
    echo SCENE_TAG=%SCENE_TAG%
    echo QP_VAL=%QP_VAL%
    echo OUT_EXT=%OUT_EXT%
    echo AUDIO_FLAG=%AUDIO_FLAG%
    echo DATA_MAP=%DATA_MAP%
    echo DEST_MODE=%DEST_MODE%
    echo LABEL_CHROMA=%LABEL_CHROMA%
    echo LABEL_SCENE=%LABEL_SCENE%
    echo LABEL_QP=%LABEL_QP%
    echo LABEL_CONTAINER=%LABEL_CONTAINER%
    echo LABEL_DEST=%LABEL_DEST%
) > "%CONFIG_FILE%"

:confirm_run
echo.
echo ======================================================================
echo Ready to transcode. Press any key to begin...
echo ======================================================================
pause >nul

:: 4. Processing Loop
:process_loop
if "%~1"=="" goto finish

set "INPUT_FILE=%~1"
set "FILE_DIR=%~dp1"
set "FILE_NAME=%~n1"

if "%DEST_MODE%"=="ARCHIVE" (
    if not exist "%FILE_DIR%_Archived" mkdir "%FILE_DIR%_Archived"
    set "OUTPUT_FILE=%FILE_DIR%_Archived\%FILE_NAME%.%OUT_EXT%"
) else (
    set "OUTPUT_FILE=%FILE_DIR%%FILE_NAME%_%CHROMA_TAG%_Master.%OUT_EXT%"
)

echo.
echo ----------------------------------------------------------------------
echo Source : "%FILE_NAME%"
echo Target : "%OUTPUT_FILE%"
echo Config : 10-bit %CHROMA_TAG% - %SCENE_TAG% - QP %QP_VAL%
echo ----------------------------------------------------------------------

"%FFMPEG_CMD%" -hide_banner -hwaccel cuda -i "%INPUT_FILE%" ^
  -map 0:v:0 -map 0:a? %DATA_MAP% -map_metadata 0 ^
  -c:v hevc_nvenc -preset p7 -tune hq %PROFILE_FLAG% -pix_fmt %PIX_FMT% ^
  -rc constqp -qp %QP_VAL% %AQ_FLAGS% ^
  -tag:v hvc1 %AUDIO_FLAG% "%OUTPUT_FILE%"

if %errorlevel% neq 0 (
    echo.
    echo ======================================================================
    echo [ERROR] FFmpeg encountered an issue on this file.
    echo ======================================================================
    pause
)

shift
goto process_loop

:finish
echo.
echo ======================================================================
echo   Batch complete! All files processed successfully.
echo ======================================================================
pause
exit /b