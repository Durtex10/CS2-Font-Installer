#!/bin/bash
# Instalador de fuentes para CS2 (Linux)
# 1) Detecta la carpeta del juego en Steam (o la pide)
# 2) Crea "Copia seguridad NO BORRAR" con fonts y conf.d si no existe
# 3) Menu: 1 = Cambiar fuente, 2 = Volver al estado original

set -o pipefail

# Si se lanza con doble clic (sin terminal), reabrir en un emulador de terminal.
# No se activa si la entrada viene por tuberia con datos (automatizacion/pruebas),
# ni si no hay sesion grafica (entorno headless/SSH sin X).
tiene_tty_control() { { exec 3<>/dev/tty; } 2>/dev/null && { exec 3>&- 2>/dev/null || true; return 0; }; return 1; }
if [[ -z "${CS2_FUENTES_RELANZADO:-}" && ! -t 0 ]]; then
    TIENE_DATOS_STDIN=0
    if read -t 0 <&0 2>/dev/null; then TIENE_DATOS_STDIN=1; fi
    TIENE_GRAFICO=0
    [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] && TIENE_GRAFICO=1
    if [[ "$TIENE_DATOS_STDIN" == "0" ]] && ! tiene_tty_control; then
        if [[ "$TIENE_GRAFICO" == "1" ]]; then
            export CS2_FUENTES_RELANZADO=1
            ABS_SCRIPT="$(realpath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || printf '%s' "$0")"
            RELANZADO=0
            if command -v konsole >/dev/null 2>&1; then
                konsole -e bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v gnome-terminal >/dev/null 2>&1; then
                gnome-terminal -- bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v xfce4-terminal >/dev/null 2>&1; then
                xfce4-terminal -x bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v mate-terminal >/dev/null 2>&1; then
                mate-terminal -x bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v lxterminal >/dev/null 2>&1; then
                lxterminal -e bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v alacritty >/dev/null 2>&1; then
                alacritty -e bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v kitty >/dev/null 2>&1; then
                kitty bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v xterm >/dev/null 2>&1; then
                xterm -e bash "$ABS_SCRIPT" && RELANZADO=1
            elif command -v x-terminal-emulator >/dev/null 2>&1; then
                x-terminal-emulator -e bash "$ABS_SCRIPT" && RELANZADO=1
            fi
            if [[ "$RELANZADO" == "1" ]]; then
                exit 0
            fi
            # No se pudo abrir terminal: avisar por via grafica si es posible
            MSG="No se pudo abrir un terminal para el instalador de fuentes CS2. Abre un terminal y ejecuta: bash \"$ABS_SCRIPT\""
            if command -v zenity >/dev/null 2>&1; then
                zenity --error --text="$MSG" 2>/dev/null
            elif command -v kdialog >/dev/null 2>&1; then
                kdialog --error "$MSG" 2>/dev/null
            elif command -v xmessage >/dev/null 2>&1; then
                xmessage "$MSG" 2>/dev/null
            elif command -v notify-send >/dev/null 2>&1; then
                notify-send "Instalador fuentes CS2" "$MSG" 2>/dev/null
            else
                echo "$MSG" >&2
            fi
            exit 1
        fi
        # Sin grafico y sin terminal (p. ej. CI): seguir con el stdin actual.
        # Los read con EOF salen de forma limpia gracias al manejo de EOF de abajo.
    fi
fi

pausa_salir() {
    # Pausa para que la ventana no se cierre antes de leer el error
    read -rp "$M_PAUSE_EXIT" _ </dev/tty 2>/dev/null \
        || read -rp "$M_PAUSE_EXIT" _ 2>/dev/null || true
}

# --- Idioma / Language: lo primero que se pregunta ---
echo "Elige idioma / Choose language:"
echo "  1) Español"
echo "  2) English"
if ! read -r -p "Elige (1/2) [1]: " LANG_OP; then
    echo ""
    LANG_OP="1"
fi
case "$LANG_OP" in
    2|en|EN|english|English|ENGLISH) LANG="EN" ;;
    *) LANG="ES" ;;
esac

if [[ "$LANG" == "EN" ]]; then
    M_TITLE="CS2 font installer (Linux)"
    M_NOGAME="Game folder not found in the default Steam location."
    M_CHECKED="Checked locations:"
    M_FLATPAK="  (Flatpak/Snap and libraryfolders.vdf if present)"
    P_ASKPATH="Enter the 'Counter-Strike Global Offensive' path (e.g.: /path/to/Counter-Strike Global Offensive): "
    M_EOF_EXIT="Input ended. Exiting."
    F_BADPATH="ERROR: '%s' does not contain game/csgo/panorama/fonts and game/core/panorama/fonts/conf.d"
    M_RETRY="Try again (or press Ctrl+C to exit)."
    M_FOUND="Game found at:"
    M_FONTSFOLDER="fonts folder:"
    M_CONFDFOLDER="conf.d folder:"
    F_NOTPL_FONTS="ERROR: 'fonts.conf' not found next to the script (%s)."
    F_NOTPL_REPL="ERROR: '42-repl-global.conf' not found next to the script (%s)."
    M_MAKINGBK="Creating backup in 'Copia seguridad NO BORRAR'..."
    M_BKDONE="Backup created."
    M_BKKEPT="Backup already exists, keeping it (it will not be overwritten)."
    M_PAUSE_EXIT="Press Enter to exit... "
    M_NOFUENTESDIR="ERROR: 'Fuentes' folder not found next to the script."
    F_INCOMP_TOP="%s options with an unsupported extension:"
    M_NOTTF="ERROR: no .ttf files in the 'Fuentes' folder."
    M_ONLYTTF="Only .ttf fonts can be installed (convert .otf files first)."
    M_AVAIL="Available fonts:"
    F_OTF_ITEM='  %d) %s  [OTF: must be converted to .ttf first]\n'
    F_INCOMP_LIST="  %s options with an unsupported extension (skipped):"
    M_GOBACK="  0) Go back"
    P_ASKNUM="Choose the font number to install (0 = go back): "
    M_EOF_MENU="Input ended. Returning to the menu."
    F_RANGE="Invalid option. Enter a number between 0 and %s."
    F_OTFMSG="The font '%s' is in .otf format. It must be converted to .ttf to use it."
    M_OTF1="  1) Convert online (opens the browser)"
    M_OTF2="  2) Convert locally and apply it directly (an additional component may be installed)"
    M_OTF3="  3) Go back"
    P_ASKOTF="Choose (1/2/3): "
    M_WEBOPEN="Opening the conversion website:"
    M_WEBHINT="Once you have the .ttf, put it in the 'Fuentes' folder and select it again."
    M_MANUALURL="Open this website manually: "
    M_NEEDFF="Local conversion needs the free FontForge component, which is not installed yet."
    P_ASKFF="Do you want to install it now? (y/n): "
    M_NOSUDO="No 'sudo' on this system. Install FontForge manually"
    M_NOSUDO2="(e.g. with your distro's software manager) and try again."
    M_NOPM="Package manager not recognized. Install FontForge manually and try again."
    M_FFOK="FontForge installed successfully."
    M_FFFAIL="FontForge could not be installed. Try the online option."
    F_CONVERTING="Converting '%s' to .ttf locally..."
    M_CONVERR="ERROR: FontForge could not convert the file."
    M_NOGEN="ERROR: no .ttf file was generated."
    F_CONVOK="Converted and saved to 'Fuentes/%s'."
    F_INSTALLING="Installing '%s' (internal name: '%s')..."
    M_FINAL="Final contents of the game fonts folder:"
    F_INSTDONE="Font '%s' installed successfully."
    M_NOBK="ERROR: backup folder 'Copia seguridad NO BORRAR' not found."
    M_RESTORING="Restoring original state from the backup..."
    M_RESTORED="Restore completed."
    M_FCONTENT="Contents of the game fonts folder:"
    M_OPT1="  1) Change font"
    M_OPT2="  2) Restore original state"
    M_OPT3="  3) Exit"
    P_ASKOPT="Choose an option (1/2/3): "
    M_INVALID="Invalid option."
    M_BYE="Exiting."
else
    M_TITLE="Instalador de fuentes para CS2 (Linux)"
    M_NOGAME="No se encontro la carpeta del juego en la ubicacion por defecto de Steam."
    M_CHECKED="Ubicaciones comprobadas:"
    M_FLATPAK="  (Flatpak/Snap y libraryfolders.vdf si existen)"
    P_ASKPATH="Introduce la ruta de 'Counter-Strike Global Offensive' (ej: /ruta/a/Counter-Strike Global Offensive): "
    M_EOF_EXIT="Entrada terminada. Saliendo."
    F_BADPATH="ERROR: en '%s' no se encuentran game/csgo/panorama/fonts y game/core/panorama/fonts/conf.d"
    M_RETRY="Prueba de nuevo (o pulsa Ctrl+C para salir)."
    M_FOUND="Juego encontrado en:"
    M_FONTSFOLDER="Carpeta fonts:"
    M_CONFDFOLDER="Carpeta conf.d:"
    F_NOTPL_FONTS="ERROR: no se encuentra 'fonts.conf' junto al script (%s)."
    F_NOTPL_REPL="ERROR: no se encuentra '42-repl-global.conf' junto al script (%s)."
    M_MAKINGBK="Creando copia de seguridad en 'Copia seguridad NO BORRAR'..."
    M_BKDONE="Copia de seguridad creada."
    M_BKKEPT="Copia de seguridad ya existente, se conserva (no se sobrescribe)."
    M_PAUSE_EXIT="Pulsa Enter para salir... "
    M_NOFUENTESDIR="ERROR: no existe la carpeta 'Fuentes' junto al script."
    F_INCOMP_TOP="%s opciones con una extension no compatible:"
    M_NOTTF="ERROR: no hay archivos .ttf en la carpeta 'Fuentes'."
    M_ONLYTTF="Solo se pueden instalar fuentes .ttf (las .otf hay que convertirlas antes)."
    M_AVAIL="Fuentes disponibles:"
    F_OTF_ITEM='  %d) %s  [OTF: hay que convertirla a .ttf primero]\n'
    F_INCOMP_LIST="  %s opciones con una extension no compatible (se omiten):"
    M_GOBACK="  0) Volver atras"
    P_ASKNUM="Elige el numero de fuente a instalar (0 = volver): "
    M_EOF_MENU="Entrada terminada. Volviendo al menu."
    F_RANGE="Opcion no valida. Introduce un numero entre 0 y %s."
    F_OTFMSG="La fuente '%s' esta en formato .otf. Para usarla hay que pasarla a .ttf."
    M_OTF1="  1) Convertir en la web (se abre el navegador)"
    M_OTF2="  2) Convertir en local y aplicarla directamente (puede que se instale algun complemento necesario)"
    M_OTF3="  3) Volver atras"
    P_ASKOTF="Elige (1/2/3): "
    M_WEBOPEN="Te abrimos la web para convertirla:"
    M_WEBHINT="Cuando tengas el .ttf, metelo en la carpeta 'Fuentes' y vuelve a elegirlo."
    M_MANUALURL="Abre manualmente esta web: "
    M_NEEDFF="La conversion en local necesita el complemento gratuito FontForge, que aun no esta instalado."
    P_ASKFF="¿Quieres instalarlo ahora? (s/n): "
    M_NOSUDO="No hay 'sudo' en este sistema. Instala FontForge a mano"
    M_NOSUDO2="(p. ej. con el gestor de software de tu distro) y vuelve a intentarlo."
    M_NOPM="No se reconoce el gestor de paquetes. Instala FontForge a mano y vuelve a intentarlo."
    M_FFOK="FontForge instalado correctamente."
    M_FFFAIL="No se pudo instalar FontForge. Prueba con la opcion de la web."
    F_CONVERTING="Convirtiendo '%s' a .ttf en local..."
    M_CONVERR="ERROR: FontForge no pudo convertir el archivo."
    M_NOGEN="ERROR: no se genero el archivo .ttf."
    F_CONVOK="Convertida y guardada en 'Fuentes/%s'."
    F_INSTALLING="Instalando '%s' (nombre interno: '%s')..."
    M_FINAL="Contenido final de fonts del juego:"
    F_INSTDONE="Fuente '%s' instalada correctamente."
    M_NOBK="ERROR: no existe la copia de seguridad 'Copia seguridad NO BORRAR'."
    M_RESTORING="Restaurando estado original desde la copia de seguridad..."
    M_RESTORED="Restauracion completada."
    M_FCONTENT="Contenido de fonts del juego:"
    M_OPT1="  1) Cambiar fuente"
    M_OPT2="  2) Volver al estado original"
    M_OPT3="  3) Salir"
    P_ASKOPT="Elige una opcion (1/2/3): "
    M_INVALID="Opcion no valida."
    M_BYE="Saliendo."
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FUENTES_DIR="$SCRIPT_DIR/Fuentes"
PLANTILLA_FONTS_CONF="$SCRIPT_DIR/fonts.conf"
PLANTILLA_REPL="$SCRIPT_DIR/42-repl-global.conf"
BACKUP_BASE="$SCRIPT_DIR/Copia seguridad NO BORRAR"
BACKUP_FONTS="$BACKUP_BASE/fonts"
BACKUP_CONFD="$BACKUP_BASE/conf.d"

GAME_DIR=""
FONTS_DIR=""
CONFD_DIR=""

expand_path() {
    local p="$1"
    # quitar comillas envolventes si las hay
    p="${p%\"}"; p="${p#\"}"
    p="${p%\'}"; p="${p#\'}"
    # expandir ~ inicial
    if [[ "$p" == "~"* ]]; then
        p="$HOME${p:1}"
    fi
    printf '%s' "$p"
}

candidata_valida() {
    local c="$1"
    [[ -n "$c" && -d "$c/game/csgo/panorama/fonts" && -d "$c/game/core/panorama/fonts/conf.d" ]]
}

buscar_en_libraryfolders() {
    local vdf="$1"
    [[ -f "$vdf" ]] || return 1
    # Extrae valores de "path" del vdf (soporta librerias extra de Steam)
    grep -oiE '"path"[[:space:]]*"[^"]+"' "$vdf" 2>/dev/null \
        | sed -E 's/.*"[^"]*"[[:space:]]*"([^"]+)".*/\1/' \
        | sed 's/\\\\/\//g' | while IFS= read -r lib; do
        # expandir \\u escapes basicos y limpiar
        lib="$(printf '%b' "${lib//\\/\\\\}" 2>/dev/null || printf '%s' "$lib")"
        for suf in \
            "$lib/steamapps/common/Counter-Strike Global Offensive" \
            "$lib/Steam/steamapps/common/Counter-Strike Global Offensive" \
            "$lib/SteamApps/common/Counter-Strike Global Offensive"; do
            if candidata_valida "$suf"; then
                printf '%s' "$suf"
                return 0
            fi
        done
    done
    return 1
}

detectar_juego() {
    local candidatos=(
        "$HOME/.local/share/Steam/steamapps/common/Counter-Strike Global Offensive"
        "$HOME/.steam/steam/steamapps/common/Counter-Strike Global Offensive"
        "$HOME/.steam/debian-installation/steamapps/common/Counter-Strike Global Offensive"
        "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/Counter-Strike Global Offensive"
        "$HOME/snap/steam/common/.local/share/Steam/steamapps/common/Counter-Strike Global Offensive"
    )
    local c
    for c in "${candidatos[@]}"; do
        if candidata_valida "$c"; then
            GAME_DIR="$c"
            return 0
        fi
    done
    # Buscar en libraryfolders.vdf de cada instalacion conocida
    local vdfs=(
        "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
        "$HOME/.steam/steam/steamapps/libraryfolders.vdf"
        "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"
    )
    local v encontrado
    for v in "${vdfs[@]}"; do
        encontrado="$(buscar_en_libraryfolders "$v")"
        if [[ -n "$encontrado" ]] && candidata_valida "$encontrado"; then
            GAME_DIR="$encontrado"
            return 0
        fi
    done
    return 1
}

echo "=============================================="
echo "  $M_TITLE"
echo "=============================================="
echo ""

if ! detectar_juego; then
    echo "$M_NOGAME"
    echo "$M_CHECKED"
    echo "  ~/.local/share/Steam/steamapps/common/Counter-Strike Global Offensive"
    echo "  ~/.steam/steam/steamapps/common/Counter-Strike Global Offensive"
    echo "$M_FLATPAK"
    echo ""
    while true; do
        if ! read -r -p "$P_ASKPATH" entrada; then
            echo ""
            echo "$M_EOF_EXIT"
            exit 0
        fi
        entrada="$(expand_path "$entrada")"
        # Si apunta directamente a .../game, subir un nivel
        if [[ -d "$entrada/game/csgo/panorama/fonts" ]]; then
            GAME_DIR="$entrada"
            break
        elif candidata_valida "$entrada"; then
            GAME_DIR="$entrada"
            break
        else
            printf "$F_BADPATH\n" "$entrada"
            echo "$M_RETRY"
        fi
    done
else
    echo "$M_FOUND"
    echo "  $GAME_DIR"
fi

FONTS_DIR="$GAME_DIR/game/csgo/panorama/fonts"
CONFD_DIR="$GAME_DIR/game/core/panorama/fonts/conf.d"
echo ""
echo "$M_FONTSFOLDER $FONTS_DIR"
echo "$M_CONFDFOLDER $CONFD_DIR"
echo ""

# --- Comprobar plantillas junto al script ---
if [[ ! -f "$PLANTILLA_FONTS_CONF" ]]; then
    printf "$F_NOTPL_FONTS\n" "$PLANTILLA_FONTS_CONF"
    pausa_salir
    exit 1
fi
if [[ ! -f "$PLANTILLA_REPL" ]]; then
    printf "$F_NOTPL_REPL\n" "$PLANTILLA_REPL"
    pausa_salir
    exit 1
fi

# --- Copia de seguridad (solo si no existe) ---
hacer_backup() {
    echo "$M_MAKINGBK"
    mkdir -p "$BACKUP_FONTS" "$BACKUP_CONFD"
    cp -a "$FONTS_DIR/." "$BACKUP_FONTS/"
    cp -a "$CONFD_DIR/." "$BACKUP_CONFD/"
    echo "$M_BKDONE"
}

if [[ ! -d "$BACKUP_FONTS" || ! -d "$BACKUP_CONFD" ]] \
    || [[ -z "$(ls -A "$BACKUP_FONTS" 2>/dev/null)" ]] \
    || [[ -z "$(ls -A "$BACKUP_CONFD" 2>/dev/null)" ]]; then
    hacer_backup
else
    echo "$M_BKKEPT"
fi
echo ""

# Escapa texto para usarlo como reemplazo en sed con delimitador |
escape_sed_replacement() {
    printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

abrir_url() {
    local url="$1"
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url" >/dev/null 2>&1 &
    elif command -v gio >/dev/null 2>&1; then
        gio open "$url" >/dev/null 2>&1 &
    elif command -v kde-open >/dev/null 2>&1; then
        kde-open "$url" >/dev/null 2>&1 &
    else
        echo "${M_MANUALURL}$url"
    fi
}

CONVERT_URL="https://convertio.co/es/otf-ttf/"

asegurar_fontforge() {
    # Devuelve 0 si FontForge esta disponible (lo instala si el usuario acepta).
    command -v fontforge >/dev/null 2>&1 && return 0
    echo "$M_NEEDFF"
    local r
    if ! read -r -p "$P_ASKFF" r; then
        echo ""
        return 1
    fi
    if [[ ! "$r" =~ ^[sSyY] ]]; then
        return 1
    fi
    local SUDO=""
    if [[ "$(id -u)" -ne 0 ]]; then
        if ! command -v sudo >/dev/null 2>&1; then
            echo "$M_NOSUDO"
            echo "$M_NOSUDO2"
            return 1
        fi
        SUDO="sudo"
    fi
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update && $SUDO apt-get install -y fontforge
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y fontforge
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -S --noconfirm fontforge
    elif command -v zypper >/dev/null 2>&1; then
        $SUDO zypper install -y fontforge
    else
        echo "$M_NOPM"
        return 1
    fi
    if command -v fontforge >/dev/null 2>&1; then
        echo "$M_FFOK"
        return 0
    fi
    echo "$M_FFFAIL"
    return 1
}

CONVERTIDO_TTF=""

convertir_otf_local() {
    # $1 = ruta del .otf. Genera el .ttf en Fuentes/ y lo deja en $CONVERTIDO_TTF.
    local origen="$1"
    local base
    base="$(basename "$origen")"
    CONVERTIDO_TTF="$FUENTES_DIR/${base%.*}.ttf"
    printf "$F_CONVERTING\n" "$base"
    if ! fontforge -lang=ff -c 'Open($1); Generate($2)' "$origen" "$CONVERTIDO_TTF" >/dev/null 2>&1; then
        echo "$M_CONVERR"
        rm -f "$CONVERTIDO_TTF"
        CONVERTIDO_TTF=""
        return 1
    fi
    if [[ ! -s "$CONVERTIDO_TTF" ]]; then
        echo "$M_NOGEN"
        rm -f "$CONVERTIDO_TTF"
        CONVERTIDO_TTF=""
        return 1
    fi
    printf "$F_CONVOK\n" "$(basename "$CONVERTIDO_TTF")"
    return 0
}

instalar_ttf() {
    # $1 = ruta del .ttf a instalar en el juego.
    local origen="$1"
    local fontfile
    fontfile="$(basename "$origen")"
    local fontname="${fontfile%.*}"

    echo ""
    printf "$F_INSTALLING\n" "$fontfile" "$fontname"

    # 1) Vaciar fonts del juego y copiar fuente + fonts.conf
    find "$FONTS_DIR" -mindepth 1 -delete
    cp -a "$origen" "$FONTS_DIR/$fontfile"
    cp -a "$PLANTILLA_FONTS_CONF" "$FONTS_DIR/fonts.conf"

    # IMPORTANTE: reemplazar FONTFILENAME antes que FONTNAME,
    # porque FONTFILENAME contiene FONTNAME como subcadena.
    local esc_name esc_file
    esc_name="$(escape_sed_replacement "$fontname")"
    esc_file="$(escape_sed_replacement "$fontfile")"
    sed -i "s|FONTFILENAME|${esc_file}|g; s|FONTNAME|${esc_name}|g" "$FONTS_DIR/fonts.conf"

    # 2) Sustituir 42-repl-global.conf en conf.d (conservar el resto de archivos)
    rm -f "$CONFD_DIR/42-repl-global.conf"
    cp -a "$PLANTILLA_REPL" "$CONFD_DIR/42-repl-global.conf"
    sed -i "s|FONTNAME|${esc_name}|g" "$CONFD_DIR/42-repl-global.conf"

    echo ""
    echo "$M_FINAL"
    ls -1 "$FONTS_DIR"
    echo ""
    printf "$F_INSTDONE\n" "$fontname"
}

cambiar_fuente() {
    if [[ ! -d "$FUENTES_DIR" ]]; then
        echo "$M_NOFUENTESDIR"
        return 1
    fi
    mapfile -d '' todos < <(find "$FUENTES_DIR" -maxdepth 1 -type f -print0 2>/dev/null | sort -z)
    local opciones=() tipos=() incompatibles=()
    local f base ext ext_low
    for f in "${todos[@]}"; do
        base="$(basename "$f")"
        if [[ "$base" == *.* ]]; then
            ext="${base##*.}"
            ext_low="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
        else
            ext_low=""
        fi
        case "$ext_low" in
            ttf) opciones+=("$f"); tipos+=("TTF") ;;
            otf) opciones+=("$f"); tipos+=("OTF") ;;
            *) incompatibles+=("$base") ;;
        esac
    done
    if [[ ${#opciones[@]} -eq 0 ]]; then
        if [[ ${#incompatibles[@]} -gt 0 ]]; then
            printf "$F_INCOMP_TOP\n" "${#incompatibles[@]}"
            printf '  - %s\n' "${incompatibles[@]}"
        fi
        echo "$M_NOTTF"
        echo "$M_ONLYTTF"
        return 1
    fi
    local num origen fontfile otfop
    local i
    while true; do
        echo "$M_AVAIL"
        for i in "${!opciones[@]}"; do
            base="$(basename "${opciones[$i]}")"
            if [[ "${tipos[$i]}" == "OTF" ]]; then
                printf "$F_OTF_ITEM" "$((i + 1))" "$base"
            else
                printf '  %d) %s\n' "$((i + 1))" "$base"
            fi
        done
        if [[ ${#incompatibles[@]} -gt 0 ]]; then
            printf "$F_INCOMP_LIST\n" "${#incompatibles[@]}"
            printf '    - %s\n' "${incompatibles[@]}"
        fi
        echo "$M_GOBACK"
        if ! read -r -p "$P_ASKNUM" num; then
            echo ""
            echo "$M_EOF_MENU"
            return 1
        fi
        if [[ "$num" == "0" ]]; then
            return 0
        fi
        if [[ ! "$num" =~ ^[0-9]+$ ]] || (( num < 1 || num > ${#opciones[@]} )); then
            printf "$F_RANGE\n" "${#opciones[@]}"
            continue
        fi
        origen="${opciones[$((num - 1))]}"
        fontfile="$(basename "$origen")"
        # Si es .otf: elegir entre web o conversion local
        if [[ "${tipos[$((num - 1))]}" == "OTF" ]]; then
            echo ""
            printf "$F_OTFMSG\n" "$fontfile"
            echo "$M_OTF1"
            echo "$M_OTF2"
            echo "$M_OTF3"
            if ! read -r -p "$P_ASKOTF" otfop; then
                echo ""
                echo "$M_EOF_MENU"
                return 1
            fi
            case "$otfop" in
                1)
                    echo "$M_WEBOPEN"
                    echo "  $CONVERT_URL"
                    abrir_url "$CONVERT_URL"
                    echo "$M_WEBHINT"
                    return 0
                    ;;
                2)
                    if asegurar_fontforge && convertir_otf_local "$origen"; then
                        instalar_ttf "$CONVERTIDO_TTF"
                        return 0
                    fi
                    continue
                    ;;
                3)
                    continue
                    ;;
                *)
                    echo "$M_INVALID"
                    continue
                    ;;
            esac
        fi
        instalar_ttf "$origen"
        return 0
    done
}

restaurar_original() {
    if [[ ! -d "$BACKUP_FONTS" || ! -d "$BACKUP_CONFD" ]]; then
        echo "$M_NOBK"
        return 1
    fi
    echo "$M_RESTORING"
    find "$FONTS_DIR" -mindepth 1 -delete
    cp -a "$BACKUP_FONTS/." "$FONTS_DIR/"
    find "$CONFD_DIR" -mindepth 1 -delete
    cp -a "$BACKUP_CONFD/." "$CONFD_DIR/"
    echo "$M_RESTORED"
    echo ""
    echo "$M_FCONTENT"
    ls -1 "$FONTS_DIR"
}

while true; do
    echo ""
    echo "---------- MENU ----------"
    echo "$M_OPT1"
    echo "$M_OPT2"
    echo "$M_OPT3"
    echo "--------------------------"
    if ! read -r -p "$P_ASKOPT" op; then
        echo ""
        echo "$M_EOF_EXIT"
        exit 0
    fi
    case "$op" in
        1) cambiar_fuente ;;
        2) restaurar_original ;;
        3)
            echo "$M_BYE"
            if [[ -n "${CS2_FUENTES_RELANZADO:-}" ]]; then
                pausa_salir
            fi
            exit 0
            ;;
        *) echo "$M_INVALID" ;;
    esac
done
