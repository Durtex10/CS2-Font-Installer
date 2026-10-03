# 🎮 Instalador de Fuentes para CS2

> 🌍 **[English version below / Versión en inglés abajo](#-english-version)**

Cambia la fuente de la interfaz de **Counter-Strike 2** con un par de clics, y vuelve al estado original cuando quieras. Funciona en **Windows** y en **Linux**.

> Desarrollado por **Durtex10**.

---

## ✨ ¿Qué hace?

1. 🔍 **Detecta automáticamente** la carpeta del juego en su ubicación por defecto de Steam. Si no la encuentra, te pide que se la indiques.
2. 💾 **Crea una copia de seguridad** de tus archivos originales (solo la primera vez, nunca se sobrescribe).
3. 🔤 **Instala la fuente que elijas** de la carpeta `Fuentes`.
4. ♻️ **Restaura todo** al estado original con la opción 2.

---

## 📁 Contenido del proyecto

| Archivo / Carpeta | Descripción |
|---|---|
| `instalar_fuentes_CS2.bat` | Instalador para **Windows** (doble clic). |
| `instalar_fuentes_CS2.sh` | Instalador para **Linux** (desde terminal). |
| `Instalar fuentes CS2.desktop` | Acceso directo para abrir el instalador en Linux con doble clic. |
| `fonts.conf` | Plantilla que se adapta a tu fuente (`FONTNAME` / `FONTFILENAME`). |
| `42-repl-global.conf` | Plantilla de reemplazos globales (`FONTNAME`). |
| `Fuentes/` | Mete aquí tus fuentes en **.ttf**. |
| `Copia seguridad NO BORRAR/` | Se genera sola con tus archivos originales. **No la borres.** |

---

## ✅ Requisitos

- **Windows:** Windows 10/11 con PowerShell (viene de serie).
- **Linux:** `bash` (cualquiera moderno). Para abrir enlaces: `xdg-open` (opcional).
- El juego instalado desde **Steam** (o saber su ruta a mano).
- Fuentes en formato **.ttf** dentro de la carpeta `Fuentes/`.

---

## 🚀 Uso en Windows

1. Descarga o clona este repositorio **manteniendo todos los archivos juntos**.
2. Mete tus fuentes `.ttf` en la carpeta `Fuentes/`.
3. Haz **doble clic** en `instalar_fuentes_CS2.bat`.
   - Si la ventana se cierra sola, abre `cmd` en la carpeta y ejecútalo desde ahí para ver el mensaje.
4. Primero elige el idioma (`1` Español, `2` English) y luego una opción del menú:
   - `1` Cambiar fuente.
   - `2` Volver al estado original.
   - `3` Salir.

## 🐧 Uso en Linux

1. Descarga o clona este repositorio **manteniendo todos los archivos juntos**.
2. Mete tus fuentes `.ttf` en la carpeta `Fuentes/`.
3. Abre un terminal en la carpeta y ejecuta:

   ```bash
   bash instalar_fuentes_CS2.sh
   ```

   Lo primero te pregunta el idioma (`1` Español, `2` English).

   > ⚠️ No abras el `.sh` con doble clic directamente: el gestor de archivos lo abre como texto o sin terminal y el menú no se muestra. Usa el terminal o el archivo `Instalar fuentes CS2.desktop` (clic derecho → *Permitir ejecución* la primera vez).

---

## 🔤 Cómo funciona la opción 1 (Cambiar fuente)

1. Muestra las fuentes `.ttf` disponibles en `Fuentes/` y te pide elegir una (con `0` vuelves atrás al menú principal).
2. Vacía la carpeta de fuentes del juego:
   - Linux: `…/Counter-Strike Global Offensive/game/csgo/panorama/fonts/`
   - Windows: su equivalente dentro de `steamapps\common\Counter-Strike Global Offensive`.
3. Copia tu fuente elegida y el `fonts.conf` de la plantilla.
4. Adapta el `fonts.conf` a tu fuente:
   - Cada `FONTNAME` → nombre de la fuente **sin** extensión (p. ej. `Bounce-Dash`).
   - Cada `FONTFILENAME` → nombre del archivo **con** extensión (p. ej. `Bounce-Dash.ttf`).
5. En la carpeta `conf.d` (`…/game/core/panorama/fonts/conf.d/`) sustituye el `42-repl-global.conf` por el de la plantilla (conservando el resto de archivos) y reemplaza sus `FONTNAME` igual que antes.

Al terminar, en `fonts` quedan exactamente **tu fuente + el `fonts.conf` adaptado**, y en `conf.d`, los archivos originales más el **`42-repl-global.conf` adaptado**.

## ♻️ Cómo funciona la opción 2 (Volver al estado original)

Vacía las carpetas `fonts` y `conf.d` del juego y restaura el contenido de **`Copia seguridad NO BORRAR`**. Listo, como si nada hubiera pasado.

---

## ⚠️ Notas sobre formatos

- Solo se instalan fuentes **.ttf**.
- Si eliges un archivo **.otf**, el instalador te da dos opciones:
  1. **Convertir en la web:** abre <https://convertio.co/es/otf-ttf/> para que la conviertas. Después mete el `.ttf` resultante en `Fuentes/` y repite la opción 1.
  2. **Convertir en local y aplicarla directamente:** el instalador la convierte y la instala del tirón (además la guarda en `Fuentes/` para la próxima). Ten en cuenta que **puede que se instale algún complemento necesario** para la conversión: en Linux es **FontForge** (se instala con el gestor de paquetes si aceptas) y en Windows también (vía `winget` si está disponible).
- Los archivos con cualquier otra extensión se ignoran, y el instalador te muestra cuántos hay: `X opciones con una extension no compatible`.

---

## 🧰 Solución de problemas

| Problema | Solución |
|---|---|
| No encuentra el juego | Escribe la ruta completa a `Counter-Strike Global Offensive` cuando te la pida (p. ej. otra biblioteca de Steam en disco `D:`). |
| En Linux no se ve el menú | Ejecútalo desde un terminal con `bash instalar_fuentes_CS2.sh`. |
| Permiso denegado en Linux | `chmod +x instalar_fuentes_CS2.sh` y reintenta. |
| Steam actualiza y la fuente desaparece | Normal: las actualizaciones pueden restaurar los archivos del juego. Repite la opción 1. |
| Quiero empezar de cero la copia | Borra `Copia seguridad NO BORRAR` y el instalador la regenerará con el estado actual del juego. |
| La conversión local falla | Instala **FontForge** a mano (Linux: con tu gestor de paquetes; Windows: desde fontforge.org o con `winget install FontForge.FontForge`) y reintenta. |

---

## 👤 Autor

Desarrollado por **Durtex10**.

---

## 🌍 English version

### 🎮 CS2 Font Installer

Change the **Counter-Strike 2** interface font in a couple of clicks, and go back to the original state whenever you want. Works on **Windows** and **Linux**.

> Developed by **Durtex10**.

### ✨ What does it do?

1. 🔍 **Auto-detects** the game folder in its default Steam location. If it can't find it, it asks you for the path.
2. 💾 **Creates a backup** of your original files (only the first time, never overwritten).
3. 🔤 **Installs the font you choose** from the `Fuentes/` folder.
4. ♻️ **Restores everything** to the original state with option 2.

The installer asks you first whether you want **Español or English**.

### 📁 Project contents

| File / Folder | Description |
|---|---|
| `instalar_fuentes_CS2.bat` | Installer for **Windows** (double click). |
| `instalar_fuentes_CS2.sh` | Installer for **Linux** (from the terminal). |
| `Instalar fuentes CS2.desktop` | Shortcut to open the installer on Linux with a double click. |
| `fonts.conf` | Template adapted to your font (`FONTNAME` / `FONTFILENAME`). |
| `42-repl-global.conf` | Global replacement template (`FONTNAME`). |
| `Fuentes/` | Put your **.ttf** fonts here. |
| `Copia seguridad NO BORRAR/` | Generated automatically with your original files. **Do not delete it.** |

### ✅ Requirements

- **Windows:** Windows 10/11 with PowerShell (built in).
- **Linux:** `bash` (any modern one). To open links: `xdg-open` (optional).
- The game installed from **Steam** (or know its path).
- Fonts in **.ttf** format inside the `Fuentes/` folder.

### 🚀 Use on Windows

1. Download or clone this repo **keeping all files together**.
2. Put your `.ttf` fonts in the `Fuentes/` folder.
3. **Double click** `instalar_fuentes_CS2.bat`.
4. First choose the language (`1` Español, `2` English), then pick a menu option:
   - `1` Change font.
   - `2` Restore original state.
   - `3` Exit.

### 🐧 Use on Linux

1. Download or clone this repo **keeping all files together**.
2. Put your `.ttf` fonts in the `Fuentes/` folder.
3. Open a terminal in the folder and run:

   ```bash
   bash instalar_fuentes_CS2.sh
   ```

   > ⚠️ Don't open the `.sh` with a double click: the file manager opens it as text or without a terminal and the menu won't show. Use the terminal or the `Instalar fuentes CS2.desktop` file (right click → *Allow execution* the first time).

### 🔤 How option 1 works (Change font)

1. It shows the `.ttf` fonts in `Fuentes/` and asks you to pick one (`0` goes back to the main menu).
2. It empties the game fonts folder and copies your font plus the template `fonts.conf`.
3. It adapts `fonts.conf`: every `FONTNAME` → font name **without** extension (e.g. `Bounce-Dash`), every `FONTFILENAME` → file name **with** extension (e.g. `Bounce-Dash.ttf`).
4. In `conf.d` it replaces `42-repl-global.conf` with the template one (keeping the other files) and replaces its `FONTNAME` entries the same way.

### ♻️ How option 2 works (Restore original state)

It empties the game `fonts` and `conf.d` folders and restores the contents of **`Copia seguridad NO BORRAR`**.

### ⚠️ Format notes

- Only **.ttf** fonts are installed.
- If you pick an **.otf** file, you get two choices:
  1. **Convert online:** opens <https://convertio.co/es/otf-ttf/>. Then put the resulting `.ttf` in `Fuentes/` and pick it again.
  2. **Convert locally and apply directly:** converts and installs it in one go (also saved to `Fuentes/`). Note that **an additional component may be installed**: **FontForge** on Linux (via the package manager if you accept) and on Windows too (via `winget` if available).
- Files with any other extension are skipped, and the installer tells you how many: `X options with an unsupported extension`.

### 🧰 Troubleshooting

| Problem | Solution |
|---|---|
| It can't find the game | Type the full path to `Counter-Strike Global Offensive` when asked (e.g. another Steam library on drive `D:`). |
| No menu shows on Linux | Run it from a terminal with `bash instalar_fuentes_CS2.sh`. |
| Permission denied on Linux | `chmod +x instalar_fuentes_CS2.sh` and retry. |
| Steam updates and the font is gone | Normal: updates may restore the game files. Repeat option 1. |
| Local conversion fails | Install **FontForge** manually (Linux: with your package manager; Windows: from fontforge.org or `winget install FontForge.FontForge`) and retry. |
