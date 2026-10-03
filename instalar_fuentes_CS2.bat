@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

rem ============================================================
rem  Instalador de fuentes para CS2 (Windows)
rem  1) Detecta la carpeta del juego en Steam (o la pide)
rem  2) Crea "Copia seguridad NO BORRAR" con fonts y conf.d
rem  3) Menu: 1 = Cambiar fuente, 2 = Volver al estado original
rem ============================================================

set "SCRIPT_DIR=%~dp0"
set "FUENTES_DIR=%SCRIPT_DIR%Fuentes"
set "PLANTILLA_FONTS=%SCRIPT_DIR%fonts.conf"
set "PLANTILLA_REPL=%SCRIPT_DIR%42-repl-global.conf"
set "BACKUP_BASE=%SCRIPT_DIR%Copia seguridad NO BORRAR"
set "BACKUP_FONTS=%BACKUP_BASE%\fonts"
set "BACKUP_CONFD=%BACKUP_BASE%\conf.d"

set "GAME_DIR="
set "FONTS_DIR="
set "CONFD_DIR="

rem Alias sin parentesis: %ProgramFiles(x86)% NO puede usarse dentro de bloques (...)
rem porque su ")" cierra el bloque antes de tiempo y el script se autocierra.
set "PF86=%ProgramFiles(x86)%"
set "PF64=%ProgramFiles%"

:LANG_SEL
echo Elige idioma / Choose language:
echo   1) Espanol
echo   2) English
set "LANG_OP="
set /p "LANG_OP=Elige (1/2) [1]: "
if "!LANG_OP!"=="" set "LANG_OP=1"
if "!LANG_OP!"=="2" goto :LANG_EN
if /I "!LANG_OP!"=="en" goto :LANG_EN
if /I "!LANG_OP!"=="english" goto :LANG_EN
goto :LANG_ES
:LANG_EN
set "LANG=EN"
set "M_TITLEWIN=CS2 font installer"
set "M_TITLE=CS2 font installer (Windows)"
set "M_NOGAME=Game folder not found in the default Steam location."
set "M_CHECKEDREG=Checked the Steam registry and:"
set "M_FOUND=Game found at:"
set "P_ASKPATH=Enter the 'Counter-Strike Global Offensive' path (e.g.: C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive): "
set "M_ERR_A=ERROR: "
set "M_ERR_B= does not contain"
set "M_RETRY=Try again."
set "M_FONTSFOLDER=fonts folder:"
set "M_CONFDFOLDER=conf.d folder:"
set "M_NOTPL_F=ERROR: 'fonts.conf' not found next to the script."
set "M_EXPECTED=Expected at:"
set "M_NOTPL_R=ERROR: '42-repl-global.conf' not found next to the script."
set "M_MAKINGBK=Creating backup in 'Copia seguridad NO BORRAR'..."
set "M_BKDONE=Backup created."
set "M_BKKEPT=Backup already exists, keeping it (it will not be overwritten)."
set "M_OPT1=  1) Change font"
set "M_OPT2=  2) Restore original state"
set "M_OPT3=  3) Exit"
set "P_ASKOPT=Choose an option (1/2/3): "
set "M_INVALID=Invalid option."
set "M_NOFUENTES=ERROR: 'Fuentes' folder not found next to the script."
set "M_OTFTAG=[OTF: must be converted to .ttf first]"
set "M_INCOMPAT=options with an unsupported extension (skipped):"
set "M_NOTTF=ERROR: no .ttf files in the 'Fuentes' folder."
set "M_ONLYTTF=Only .ttf fonts can be installed (convert .otf files first)."
set "M_GOBACK=  0) Go back"
set "P_ASKNUM=Choose the font number to install (0 = go back): "
set "M_RANGE=Invalid option. Enter a number between 0 and"
set "M_OTFMSG_PRE=The font '"
set "M_OTFMSG_MID=' is in .otf format. It must be converted to .ttf to use it."
set "M_OTF1=  1) Convert online (opens the browser)"
set "M_OTF2=  2) Convert locally and apply it directly (an additional component may be installed)"
set "M_OTF3=  3) Go back"
set "P_ASKOTF=Choose (1/2/3): "
set "M_WEBOPEN=Opening the conversion website:"
set "M_WEBHINT=Once you have the .ttf, put it in the 'Fuentes' folder and select it again."
set "M_NEEDFF=Local conversion needs the free FontForge component, which is not installed yet."
set "P_ASKFF=Do you want to install it now with winget? (y/n): "
set "M_USEWEB=OK. You can use the online option."
set "M_NOWINGET_A='winget' not found. Install FontForge manually from its official website"
set "M_NOWINGET_B=(fontforge.org) and try again."
set "M_INSTALLINGFF=Installing FontForge (this may take a few minutes)..."
set "M_FFNF_A=FontForge not found after installing. Close this window, open"
set "M_FFNF_B=a new one and try again, or install it manually from fontforge.org."
set "M_FFOK=FontForge installed successfully."
set "M_CONV_PRE=Converting '"
set "M_CONV_POST=' to .ttf locally..."
set "M_CONVERR=ERROR: FontForge could not convert the file."
set "M_NOGEN=ERROR: no .ttf file was generated."
set "M_CONVOK_PRE=Converted and saved to 'Fuentes\"
set "M_CONVOK_POST=Applying it now..."
set "M_INST_PRE=Installing '"
set "M_INST_MID=' (internal name: '"
set "M_INST_POST=')..."
set "M_ERRCOPYF=ERROR copying the font to the game."
set "M_ERRCOPYCONF=ERROR copying fonts.conf to the game."
set "M_ERRMODCONF=ERROR modifying fonts.conf."
set "M_ERRCOPYREPL=ERROR copying 42-repl-global.conf to the game."
set "M_ERRMODREPL=ERROR modifying 42-repl-global.conf."
set "M_FINAL=Final contents of the game fonts folder:"
set "M_INSTDONE_PRE=Font '"
set "M_INSTDONE_POST=' installed successfully."
set "M_NOBKF=ERROR: backup folder 'Copia seguridad NO BORRAR\fonts' not found."
set "M_NOBKC=ERROR: backup folder 'Copia seguridad NO BORRAR\conf.d' not found."
set "M_RESTORING=Restoring original state from the backup..."
set "M_RESTORED=Restore completed."
set "M_FCONTENT=Contents of the game fonts folder:"
set "M_BYE=Exiting."
goto :LANG_OK
:LANG_ES
set "LANG=ES"
set "M_TITLEWIN=Instalador de fuentes para CS2"
set "M_TITLE=Instalador de fuentes para CS2 (Windows)"
set "M_NOGAME=No se encontro la carpeta del juego en la ubicacion por defecto de Steam."
set "M_CHECKEDREG=Se ha comprobado el registro de Steam y:"
set "M_FOUND=Juego encontrado en:"
set "P_ASKPATH=Introduce la ruta de 'Counter-Strike Global Offensive' (ej: C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive): "
set "M_ERR_A=ERROR: en "
set "M_ERR_B= no se encuentra"
set "M_RETRY=Prueba de nuevo."
set "M_FONTSFOLDER=Carpeta fonts:"
set "M_CONFDFOLDER=Carpeta conf.d:"
set "M_NOTPL_F=ERROR: no se encuentra 'fonts.conf' junto al script."
set "M_EXPECTED=Se esperaba en:"
set "M_NOTPL_R=ERROR: no se encuentra '42-repl-global.conf' junto al script."
set "M_MAKINGBK=Creando copia de seguridad en 'Copia seguridad NO BORRAR'..."
set "M_BKDONE=Copia de seguridad creada."
set "M_BKKEPT=Copia de seguridad ya existente, se conserva (no se sobrescribe)."
set "M_OPT1=  1) Cambiar fuente"
set "M_OPT2=  2) Volver al estado original"
set "M_OPT3=  3) Salir"
set "P_ASKOPT=Elige una opcion (1/2/3): "
set "M_INVALID=Opcion no valida."
set "M_NOFUENTES=ERROR: no existe la carpeta 'Fuentes' junto al script."
set "M_OTFTAG=[OTF: hay que convertirla a .ttf primero]"
set "M_INCOMPAT=opciones con una extension no compatible (se omiten):"
set "M_NOTTF=ERROR: no hay archivos .ttf en la carpeta 'Fuentes'."
set "M_ONLYTTF=Solo se pueden instalar fuentes .ttf (las .otf hay que convertirlas antes)."
set "M_GOBACK=  0) Volver atras"
set "P_ASKNUM=Elige el numero de fuente a instalar (0 = volver): "
set "M_RANGE=Opcion no valida. Introduce un numero entre 0 y"
set "M_OTFMSG_PRE=La fuente '"
set "M_OTFMSG_MID=' esta en formato .otf. Para usarla hay que pasarla a .ttf."
set "M_OTF1=  1) Convertir en la web (se abre el navegador)"
set "M_OTF2=  2) Convertir en local y aplicarla directamente (puede que se instale algun complemento necesario)"
set "M_OTF3=  3) Volver atras"
set "P_ASKOTF=Elige (1/2/3): "
set "M_WEBOPEN=Te abrimos la web para convertirla:"
set "M_WEBHINT=Cuando tengas el .ttf, metelo en la carpeta 'Fuentes' y vuelve a elegirlo."
set "M_NEEDFF=La conversion en local necesita el complemento gratuito FontForge, que aun no esta instalado."
set "P_ASKFF=Deseas instalarlo ahora con winget? (s/n): "
set "M_USEWEB=De acuerdo. Puedes usar la opcion de la web."
set "M_NOWINGET_A=No se encontro 'winget'. Instala FontForge a mano desde su web oficial"
set "M_NOWINGET_B=(fontforge.org) y vuelve a intentarlo."
set "M_INSTALLINGFF=Instalando FontForge (puede tardar unos minutos)..."
set "M_FFNF_A=No se encontro FontForge tras instalarlo. Cierra esta ventana, abre"
set "M_FFNF_B=otra y vuelve a intentarlo, o instalalo a mano desde fontforge.org."
set "M_FFOK=FontForge instalado correctamente."
set "M_CONV_PRE=Convirtiendo '"
set "M_CONV_POST=' a .ttf en local..."
set "M_CONVERR=ERROR: FontForge no pudo convertir el archivo."
set "M_NOGEN=ERROR: no se genero el archivo .ttf."
set "M_CONVOK_PRE=Convertida y guardada en 'Fuentes\"
set "M_CONVOK_POST=Se aplica directamente..."
set "M_INST_PRE=Instalando '"
set "M_INST_MID=' (nombre interno: '"
set "M_INST_POST=')..."
set "M_ERRCOPYF=ERROR al copiar la fuente al juego."
set "M_ERRCOPYCONF=ERROR al copiar fonts.conf al juego."
set "M_ERRMODCONF=ERROR al modificar fonts.conf."
set "M_ERRCOPYREPL=ERROR al copiar 42-repl-global.conf al juego."
set "M_ERRMODREPL=ERROR al modificar 42-repl-global.conf."
set "M_FINAL=Contenido final de fonts del juego:"
set "M_INSTDONE_PRE=Fuente '"
set "M_INSTDONE_POST=' instalada correctamente."
set "M_NOBKF=ERROR: no existe la copia de seguridad 'Copia seguridad NO BORRAR\fonts'."
set "M_NOBKC=ERROR: no existe la copia de seguridad 'Copia seguridad NO BORRAR\conf.d'."
set "M_RESTORING=Restaurando estado original desde la copia de seguridad..."
set "M_RESTORED=Restauracion completada."
set "M_FCONTENT=Contenido de fonts del juego:"
set "M_BYE=Saliendo."
:LANG_OK
title !M_TITLEWIN!

echo ==============================================
echo   !M_TITLE!
echo ==============================================
echo.

rem ---- 1) Intentar detectar Steam via registro ----
set "STEAM_PATH="
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM_PATH=%%B"
if defined STEAM_PATH (
    set "STEAM_PATH=!STEAM_PATH:/=\!"
    if exist "!STEAM_PATH!\steamapps\common\Counter-Strike Global Offensive\game\csgo\panorama\fonts" (
        if exist "!STEAM_PATH!\steamapps\common\Counter-Strike Global Offensive\game\core\panorama\fonts\conf.d" (
            set "GAME_DIR=!STEAM_PATH!\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)

rem ---- 2) Rutas por defecto ----
if not defined GAME_DIR (
    if exist "%PF86%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\panorama\fonts" (
        if exist "%PF86%\Steam\steamapps\common\Counter-Strike Global Offensive\game\core\panorama\fonts\conf.d" (
            set "GAME_DIR=%PF86%\Steam\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)
if not defined GAME_DIR (
    if exist "%PF64%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\panorama\fonts" (
        if exist "%PF64%\Steam\steamapps\common\Counter-Strike Global Offensive\game\core\panorama\fonts\conf.d" (
            set "GAME_DIR=%PF64%\Steam\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)
if not defined GAME_DIR (
    if exist "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\panorama\fonts" (
        if exist "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\core\panorama\fonts\conf.d" (
            set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)
if not defined GAME_DIR (
    if exist "C:\Program Files\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\panorama\fonts" (
        if exist "C:\Program Files\Steam\steamapps\common\Counter-Strike Global Offensive\game\core\panorama\fonts\conf.d" (
            set "GAME_DIR=C:\Program Files\Steam\steamapps\common\Counter-Strike Global Offensive"
        )
    )
)

rem ---- 3) Si no se encontro, pedirla al usuario ----
if not defined GAME_DIR (
    echo !M_NOGAME!
    echo !M_CHECKEDREG!
    echo   - !PF86!\Steam\steamapps\common\Counter-Strike Global Offensive
    echo   - !PF64!\Steam\steamapps\common\Counter-Strike Global Offensive
    echo.
    goto :PEDIR_RUTA
) else (
    echo !M_FOUND!
    echo   !GAME_DIR!
    goto :RUTA_OK
)

:PEDIR_RUTA
set "GAME_DIR="
set /p "GAME_DIR=!P_ASKPATH!"
rem Quitar comillas envolventes
set "GAME_DIR=!GAME_DIR:"=!"
rem Quitar barra final si la hay
if "!GAME_DIR:~-1!"=="\" set "GAME_DIR=!GAME_DIR:~0,-1!"
if not exist "!GAME_DIR!\game\csgo\panorama\fonts" (
    echo !M_ERR_A!"!GAME_DIR!"!M_ERR_B! game\csgo\panorama\fonts
    echo !M_RETRY!
    goto :PEDIR_RUTA
)
if not exist "!GAME_DIR!\game\core\panorama\fonts\conf.d" (
    echo !M_ERR_A!"!GAME_DIR!"!M_ERR_B! game\core\panorama\fonts\conf.d
    echo !M_RETRY!
    goto :PEDIR_RUTA
)

:RUTA_OK
set "FONTS_DIR=!GAME_DIR!\game\csgo\panorama\fonts"
set "CONFD_DIR=!GAME_DIR!\game\core\panorama\fonts\conf.d"
echo.
echo !M_FONTSFOLDER! !FONTS_DIR!
echo !M_CONFDFOLDER! !CONFD_DIR!
echo.

rem ---- Comprobar plantillas junto al script ----
if not exist "%PLANTILLA_FONTS%" (
    echo !M_NOTPL_F!
    echo !M_EXPECTED! !PLANTILLA_FONTS!
    pause
    exit /b 1
)
if not exist "%PLANTILLA_REPL%" (
    echo !M_NOTPL_R!
    echo !M_EXPECTED! !PLANTILLA_REPL!
    pause
    exit /b 1
)

rem ---- Copia de seguridad (solo si no existe o esta vacia) ----
set "HACER_BACKUP=0"
if not exist "%BACKUP_FONTS%" set "HACER_BACKUP=1"
if not exist "%BACKUP_CONFD%" set "HACER_BACKUP=1"
if "%HACER_BACKUP%"=="0" (
    dir /b /a "%BACKUP_FONTS%" 2>nul | findstr /r "." >nul || set "HACER_BACKUP=1"
)
if "%HACER_BACKUP%"=="0" (
    dir /b /a "%BACKUP_CONFD%" 2>nul | findstr /r "." >nul || set "HACER_BACKUP=1"
)
if "%HACER_BACKUP%"=="1" (
    echo !M_MAKINGBK!
    if not exist "%BACKUP_FONTS%" mkdir "%BACKUP_FONTS%"
    if not exist "%BACKUP_CONFD%" mkdir "%BACKUP_CONFD%"
    xcopy "!FONTS_DIR!" "%BACKUP_FONTS%\" /E /I /H /Y >nul
    xcopy "!CONFD_DIR!" "%BACKUP_CONFD%\" /E /I /H /Y >nul
    echo !M_BKDONE!
) else (
    echo !M_BKKEPT!
)
echo.

:MENU
echo ---------- MENU ----------
echo !M_OPT1!
echo !M_OPT2!
echo !M_OPT3!
echo --------------------------
set "OPCION="
set /p "OPCION=!P_ASKOPT!"
if "%OPCION%"=="1" goto :CAMBIAR
if "%OPCION%"=="2" goto :RESTAURAR
if "%OPCION%"=="3" goto :FIN
echo !M_INVALID!
echo.
goto :MENU

:CAMBIAR
if not exist "%FUENTES_DIR%" (
    echo !M_NOFUENTES!
    echo.
    goto :MENU
)
set COUNT=0
for %%F in ("%FUENTES_DIR%\*.ttf") do (
    if exist "%%F" (
        set /A COUNT+=1
        set "FONT_!COUNT!=%%F"
        set "FONTTYPE_!COUNT!=TTF"
        echo   !COUNT!^) %%~nxF
    )
)
for %%F in ("%FUENTES_DIR%\*.otf") do (
    if exist "%%F" (
        set /A COUNT+=1
        set "FONT_!COUNT!=%%F"
        set "FONTTYPE_!COUNT!=OTF"
        echo   !COUNT!^) %%~nxF  !M_OTFTAG!
    )
)
rem Contar archivos con extension no compatible (ni .ttf ni .otf)
set INCOMP=0
if exist "%FUENTES_DIR%\*" (
    set TOTAL=0
    for %%F in ("%FUENTES_DIR%\*") do if exist "%%F" if not exist "%%F\" set /A TOTAL+=1
    set /A INCOMP=TOTAL-COUNT
)
if !INCOMP! GTR 0 (
    echo   !INCOMP! !M_INCOMPAT!
    for %%F in ("%FUENTES_DIR%\*") do (
        if exist "%%F" if not exist "%%F\" (
            set "EXT=%%~xF"
            if /I not "!EXT!"==".ttf" if /I not "!EXT!"==".otf" echo       - %%~nxF
        )
    )
)
if "!COUNT!"=="0" (
    echo !M_NOTTF!
    echo !M_ONLYTTF!
    echo.
    goto :MENU
)
echo !M_GOBACK!
set "NUM="
set /p "NUM=!P_ASKNUM!"
if "!NUM!"=="" (
    echo !M_INVALID!
    echo.
    goto :CAMBIAR
)
if "!NUM!"=="0" goto :MENU
rem Validar que sea numerico (solo digitos) con findstr
echo !NUM!| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo !M_RANGE! !COUNT!.
    echo.
    goto :CAMBIAR
)
if !NUM! LSS 1 (
    echo !M_RANGE! !COUNT!.
    echo.
    goto :CAMBIAR
)
if !NUM! GTR !COUNT! (
    echo !M_RANGE! !COUNT!.
    echo.
    goto :CAMBIAR
)
set "SELECTED_PATH=!FONT_%NUM%!"
set "SELTYPE=!FONTTYPE_%NUM%!"
if "!SELTYPE!"=="OTF" (
    for %%X in ("!SELECTED_PATH!") do set "OTFNAME=%%~nxX"
    goto :OTF_MENU
)
:INSTALAR_TTF
set "FONTFILE="
set "FONTNAME="
for %%X in ("!SELECTED_PATH!") do (
    set "FONTFILE=%%~nxX"
    set "FONTNAME=%%~nX"
)
echo.
echo !M_INST_PRE!!FONTFILE!!M_INST_MID!!FONTNAME!!M_INST_POST!

rem 1) Vaciar fonts del juego y copiar fuente + fonts.conf
del /Q "!FONTS_DIR!\*" 2>nul
for /D %%D in ("!FONTS_DIR!\*") do rd /S /Q "%%D" 2>nul
copy /Y "!SELECTED_PATH!" "!FONTS_DIR!\" >nul
if errorlevel 1 (
    echo !M_ERRCOPYF!
    echo.
    goto :MENU
)
copy /Y "%PLANTILLA_FONTS%" "!FONTS_DIR!\fonts.conf" >nul
if errorlevel 1 (
    echo !M_ERRCOPYCONF!
    echo.
    goto :MENU
)

rem Modificar fonts.conf: FONTFILENAME primero, luego FONTNAME
rem (FONTFILENAME contiene FONTNAME como subcadena, el orden importa)
set "FONTS_CONF_PATH=!FONTS_DIR!\fonts.conf"
set "REPL_FONTNAME=!FONTNAME!"
set "REPL_FONTFILE=!FONTFILE!"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f=$env:FONTS_CONF_PATH; $c=Get-Content -Raw -Encoding UTF8 $f; $c=$c.Replace('FONTFILENAME',$env:REPL_FONTFILE).Replace('FONTNAME',$env:REPL_FONTNAME); Set-Content -Encoding UTF8 $f $c"
if errorlevel 1 (
    echo !M_ERRMODCONF!
    echo.
    goto :MENU
)

rem 2) Sustituir 42-repl-global.conf en conf.d (conservar el resto de archivos)
del "!CONFD_DIR!\42-repl-global.conf" 2>nul
copy /Y "%PLANTILLA_REPL%" "!CONFD_DIR!\42-repl-global.conf" >nul
if errorlevel 1 (
    echo !M_ERRCOPYREPL!
    echo.
    goto :MENU
)
set "REPL_CONF_PATH=!CONFD_DIR!\42-repl-global.conf"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f=$env:REPL_CONF_PATH; $c=Get-Content -Raw -Encoding UTF8 $f; $c=$c.Replace('FONTNAME',$env:REPL_FONTNAME); Set-Content -Encoding UTF8 $f $c"
if errorlevel 1 (
    echo !M_ERRMODREPL!
    echo.
    goto :MENU
)

echo.
echo !M_FINAL!
dir /b "!FONTS_DIR!"
echo.
echo !M_INSTDONE_PRE!!FONTNAME!!M_INSTDONE_POST!
echo.
goto :MENU

:OTF_MENU
echo.
echo !M_OTFMSG_PRE!!OTFNAME!!M_OTFMSG_MID!
echo !M_OTF1!
echo !M_OTF2!
echo !M_OTF3!
set "OTFOP="
set /p "OTFOP=!P_ASKOTF!"
if "%OTFOP%"=="1" (
    echo !M_WEBOPEN!
    echo   https://convertio.co/es/otf-ttf/
    start "" "https://convertio.co/es/otf-ttf/"
    echo !M_WEBHINT!
    echo.
    goto :MENU
)
if "%OTFOP%"=="2" goto :CONVERTIR_LOCAL
if "%OTFOP%"=="3" goto :CAMBIAR
echo !M_INVALID!
echo.
goto :OTF_MENU

:CONVERTIR_LOCAL
call :LOCALIZAR_FONTFORGE
if defined FF_EXE goto :CONVERTIR_AHORA
echo.
echo !M_NEEDFF!
set "INSTFF="
set /p "INSTFF=!P_ASKFF!"
set "FFYES=0"
if /I "!INSTFF:~0,1!"=="s" set "FFYES=1"
if /I "!INSTFF:~0,1!"=="y" set "FFYES=1"
if "!FFYES!"=="0" (
    echo !M_USEWEB!
    echo.
    goto :CAMBIAR
)
where winget >nul 2>&1
if errorlevel 1 (
    echo !M_NOWINGET_A!
    echo !M_NOWINGET_B!
    echo.
    goto :CAMBIAR
)
echo !M_INSTALLINGFF!
winget install -e --id FontForge.FontForge --accept-source-agreements --accept-package-agreements
rem Recargar el PATH de esta sesion por si el instalador lo amplio
set "SYS_P="
set "USR_P="
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_P=%%B"
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_P=%%B"
if defined SYS_P call set "PATH=%SYS_P%;%USR_P%"
call :LOCALIZAR_FONTFORGE
if defined FF_EXE (
    echo !M_FFOK!
    goto :CONVERTIR_AHORA
)
echo !M_FFNF_A!
echo !M_FFNF_B!
echo.
pause
goto :CAMBIAR
:CONVERTIR_AHORA
for %%X in ("!SELECTED_PATH!") do set "OTFBASE=%%~nX"
set "CONV_TTF=%FUENTES_DIR%\!OTFBASE!.ttf"
echo !M_CONV_PRE!!OTFNAME!!M_CONV_POST!
"%FF_EXE%" -lang=ff -c "Open($1); Generate($2)" "!SELECTED_PATH!" "!CONV_TTF!"
if errorlevel 1 (
    echo !M_CONVERR!
    del "!CONV_TTF!" 2>nul
    echo.
    goto :CAMBIAR
)
if not exist "!CONV_TTF!" (
    echo !M_NOGEN!
    echo.
    goto :CAMBIAR
)
echo !M_CONVOK_PRE!!OTFBASE!.ttf'. !M_CONVOK_POST!
set "SELECTED_PATH=!CONV_TTF!"
goto :INSTALAR_TTF

:LOCALIZAR_FONTFORGE
rem Busca fontforge.exe y deja su ruta completa en FF_EXE (vacia si no lo encuentra).
set "FF_EXE="
for /f "delims=" %%F in ('where fontforge 2^>nul') do set "FF_EXE=%%F"
if defined FF_EXE goto :FF_LOCALIZADO
if exist "!PF64!\FontForgeBuilds\bin\fontforge.exe" set "FF_EXE=!PF64!\FontForgeBuilds\bin\fontforge.exe"
if defined FF_EXE goto :FF_LOCALIZADO
if exist "!PF86!\FontForgeBuilds\bin\fontforge.exe" set "FF_EXE=!PF86!\FontForgeBuilds\bin\fontforge.exe"
if defined FF_EXE goto :FF_LOCALIZADO
for /D %%D in ("!PF64!\FontForge*") do if exist "%%D\bin\fontforge.exe" set "FF_EXE=%%D\bin\fontforge.exe"
if defined FF_EXE goto :FF_LOCALIZADO
for /D %%D in ("!PF86!\FontForge*") do if exist "%%D\bin\fontforge.exe" set "FF_EXE=%%D\bin\fontforge.exe"
if defined FF_EXE goto :FF_LOCALIZADO
for /D %%D in ("%LocalAppData%\Programs\FontForge*") do if exist "%%D\bin\fontforge.exe" set "FF_EXE=%%D\bin\fontforge.exe"
:FF_LOCALIZADO
exit /b 0

:RESTAURAR
if not exist "%BACKUP_FONTS%" (
    echo !M_NOBKF!
    echo.
    goto :MENU
)
if not exist "%BACKUP_CONFD%" (
    echo !M_NOBKC!
    echo.
    goto :MENU
)
echo !M_RESTORING!
del /Q "!FONTS_DIR!\*" 2>nul
for /D %%D in ("!FONTS_DIR!\*") do rd /S /Q "%%D" 2>nul
xcopy "%BACKUP_FONTS%" "!FONTS_DIR!\" /E /I /H /Y >nul
del /Q "!CONFD_DIR!\*" 2>nul
for /D %%D in ("!CONFD_DIR!\*") do rd /S /Q "%%D" 2>nul
xcopy "%BACKUP_CONFD%" "!CONFD_DIR!\" /E /I /H /Y >nul
echo !M_RESTORED!
echo.
echo !M_FCONTENT!
dir /b "!FONTS_DIR!"
echo.
goto :MENU

:FIN
echo !M_BYE!
pause
endlocal
exit /b 0
