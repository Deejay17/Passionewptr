#!/usr/bin/env bash
# conformar.sh
#
# Convierte cualquier video (IA, 3D, grabado) en un loop exacto para el Motor Visual PR:
# lo recorta a N compases de un BPM (o lo estira si se queda corto), funde el final con el
# principio para que el empalme no se note, lo pasa a H.264 y le pone el BPM en el nombre.
#
# Con --entero no recorta nada: estira o encoge la toma completa hasta que dure N compases
# exactos. Es lo que necesitan las subidas y los coros, cuyo guion va compás a compás.
#
# Con --rol se dice para qué momento del set es el video y el script hace lo que toca:
#   intro, groove, break   toma entera, empalme fundido de 1 tiempo (loops que se repiten)
#   subida (o precoro)     toma entera, sin empalme: una sola pasada que acaba en el drop
#   coro (o drop)          toma entera, corte seco: vuelve a su impacto cada N compases
# y pone el rol delante del nombre (coro_sacro_128bpm_8c.mp4) para que el motor lo reconozca.
#
# Uso:
#   bash conformar.sh ENTRADA BPM COMPASES [opciones]
#
# Opciones:
#   --desde SEGUNDOS    dónde empieza el trozo que se usa (por defecto 0)
#   --fundido TIEMPOS   largo del fundido del empalme, en tiempos (por defecto 1; 0 = corte seco)
#   --nombre NOMBRE     nombre base del archivo de salida (por defecto, el de la entrada)
#   --salida CARPETA    dónde dejar el resultado (por defecto, la carpeta de la entrada)
#   --tam ANCHOxALTO    tamaño de salida (por defecto 1920x1080; recorta para llenar, sin bandas)
#   --fps N             cuadros por segundo (por defecto 30)
#   --mbps N            bitrate fijo en Mbps (por defecto, calidad constante CRF 18)
#   --perfil NOMBRE     psicoroom = 2048x1024 a 60 fps y 40 Mbps (pantalla 6×3 m, 2:1)
#                       master4k  = 3840x1920 a 60 fps y 80 Mbps
#   --hap               además del MP4, un .mov en HAP Q para Resolume (si tu ffmpeg lo trae)
#   --entero            usa la toma entera: la estira o la encoge a N compases, sin recortar ni fundir
#   --luego TOMA        pega otra toma a continuación antes de conformar (se puede repetir)
#   --rol ROL           intro, groove, break, subida (precoro) o coro (drop); ver arriba
#
# Ejemplos:
#   bash conformar.sh humo.mov 128 8 --nombre break_humo
#   → break_humo_128bpm_8c.mp4   (8 compases a 128 BPM = 15 s exactos, empalme invisible)
#   bash conformar.sh toma1.mp4 128 8 --rol subida --luego toma2.mp4 --nombre sacro
#   → subida_sacro_128bpm_8c.mp4 (las dos tomas de 8 s encajadas en 15 s; el motor la usa como Subida)
#
# Pensado para macOS (bash 3.2 + herramientas BSD); también funciona en Linux.
# Requiere ffmpeg y ffprobe (en Mac: brew install ffmpeg).

set -Eeuo pipefail

error() { printf 'Error: %s\n' "$*" >&2; exit 1; }
calc() { awk "BEGIN{printf \"%.6f\", ($1)}"; }   # entre paréntesis: en awk, «>» suelto sería una redirección
es_numero() { printf '%s' "$1" | grep -Eq '^[0-9]+([.][0-9]+)?$'; }

ayuda() { awk 'NR==1{next} /^#/{print;next} {exit}' "$0"; }   # el bloque de comentarios de arriba

case "${1:-}" in -h|--help) ayuda; exit 0 ;; esac
[ $# -ge 3 ] || { ayuda >&2; exit 2; }

ENTRADA="$1"; BPM="$2"; COMPASES="$3"; shift 3
DESDE=0; FUNDIDO=1; FUNDIDO_DADO=0; NOMBRE=""; SALIDA=""; TAM="1920x1080"; FPS=30; MBPS=""; HAP=0; ENTERO=0; ROL=""
TOMAS=("$ENTRADA")
while [ $# -gt 0 ]; do
  case "$1" in
    --entero) ENTERO=1; shift ;;
    --rol)
      case "${2:-}" in
        intro|groove|break|subida|coro) ROL="$2" ;;
        precoro) ROL="subida" ;;
        drop) ROL="coro" ;;
        *) error "rol desconocido: ${2:-} (hay intro, groove, break, subida o precoro, coro o drop)" ;;
      esac
      shift 2 ;;
    --luego) [ -n "${2:-}" ] || error "--luego necesita el archivo de la toma"; TOMAS+=("$2"); shift 2 ;;
    --desde) DESDE="${2:-}"; shift 2 ;;
    --fundido) FUNDIDO="${2:-}"; FUNDIDO_DADO=1; shift 2 ;;
    --nombre) NOMBRE="${2:-}"; shift 2 ;;
    --salida) SALIDA="${2:-}"; shift 2 ;;
    --tam) TAM="${2:-}"; shift 2 ;;
    --fps) FPS="${2:-}"; shift 2 ;;
    --mbps) MBPS="${2:-}"; shift 2 ;;
    --hap) HAP=1; shift ;;
    --perfil)
      case "${2:-}" in
        psicoroom) TAM="2048x1024"; FPS=60; MBPS=40 ;;
        master4k) TAM="3840x1920"; FPS=60; MBPS=80 ;;
        *) error "perfil desconocido: ${2:-} (hay psicoroom y master4k)" ;;
      esac
      shift 2 ;;
    *) error "opción desconocida: $1 (usa --help)" ;;
  esac
done

command -v ffmpeg >/dev/null 2>&1 || error "falta ffmpeg (en Mac: brew install ffmpeg)"
command -v ffprobe >/dev/null 2>&1 || error "falta ffprobe (viene con ffmpeg)"
for T in "${TOMAS[@]}"; do [ -f "$T" ] || error "no encuentro el archivo: $T"; done
es_numero "$BPM" || error "el BPM tiene que ser un número, por ejemplo 128"
es_numero "$COMPASES" || error "los compases tienen que ser un número, por ejemplo 8"
es_numero "$DESDE" || error "--desde tiene que ser un número de segundos"
es_numero "$FUNDIDO" || error "--fundido tiene que ser un número de tiempos"
es_numero "$FPS" || error "--fps tiene que ser un número"
[ -z "$MBPS" ] || es_numero "$MBPS" || error "--mbps tiene que ser un número"
if [ "$HAP" = "1" ]; then
  CODIFICADORES=$(ffmpeg -hide_banner -encoders 2>/dev/null || true)   # sin tubería: con pipefail, grep -q la rompería
  case "$CODIFICADORES" in
    *" hap "*) ;;
    *) error "tu ffmpeg no trae el codificador HAP; quita --hap o convierte el MP4 a DXV3 con Resolume Alley" ;;
  esac
fi
printf '%s' "$TAM" | grep -Eq '^[0-9]+x[0-9]+$' || error "--tam tiene que ser ANCHOxALTO, por ejemplo 1920x1080"
[ "$(calc "$BPM >= 60 && $BPM <= 200")" = "1.000000" ] || error "el BPM tiene que estar entre 60 y 200"
[ "$(calc "$COMPASES >= 1")" = "1.000000" ] || error "como mínimo, 1 compás"
ANCHO="${TAM%x*}"; ALTO="${TAM#*x}"

# lo que decide el rol (un --fundido escrito a mano manda sobre él)
if [ -n "$ROL" ]; then ENTERO=1; fi
if [ "$FUNDIDO_DADO" = "0" ]; then
  case "$ROL" in
    intro|groove|break) FUNDIDO=1 ;;             # loops: el final se funde con el principio
    subida|coro) FUNDIDO=0 ;;                     # una pasada, o un loop que vuelve a su impacto
    *) if [ "$ENTERO" = "1" ]; then FUNDIDO=0; fi ;;
  esac
fi

# tiempos de la rejilla
LARGO=$(calc "$COMPASES * 240 / $BPM")          # duración del loop
FUND=$(calc "$FUNDIDO * 60 / $BPM")             # duración del fundido del empalme
NECESITA=$(calc "$LARGO + $FUND")
CUADROS=$(awk "BEGIN{printf \"%d\", $LARGO * $FPS + 0.5}")
EXACTO=$(awk "BEGIN{d=$LARGO*$FPS-int($LARGO*$FPS+0.5); if(d<0)d=-d; print (d<0.001)?1:0}")

duracion() {
  local d
  d=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$1" 2>/dev/null || true)
  es_numero "${d:-x}" || d=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=nw=1:nk=1 "$1" 2>/dev/null || true)
  es_numero "${d:-x}" || error "no pude leer la duración de $1 (¿es un video?)"
  printf '%s' "$d"
}
DUR=0
for T in "${TOMAS[@]}"; do DUR=$(calc "$DUR + $(duracion "$T")"); done
DISP=$(calc "$DUR - $DESDE")
[ "$(calc "$DISP > 0.1")" = "1.000000" ] || error "--desde $DESDE queda fuera del video (dura $DUR s)"

if [ "$ENTERO" = "1" ]; then
  # la toma entera pasa a durar N compases (más el fundido, si lo hay): lo que el guion
  # pone al 50 % cae a mitad de los compases
  ESTIRA=$(calc "$NECESITA / $DISP")
else
  # si el trozo disponible no alcanza, se estira (cámara lenta) hasta cubrir el loop y el fundido
  ESTIRA=$(calc "($NECESITA > $DISP) ? $NECESITA / $DISP : 1")
fi

# nombre de salida: base_128bpm_8c.mp4 (el motor lee el BPM del nombre)
if [ -z "$NOMBRE" ]; then NOMBRE=$(basename "$ENTRADA"); NOMBRE="${NOMBRE%.*}"; fi
if [ -n "$ROL" ]; then
  case "$ROL" in   # las mismas palabras con las que el motor reconoce cada sección
    subida) PALABRAS_ROL='subida|build|riser|pre-?coro|pre-?chorus' ;;
    coro) PALABRAS_ROL='coro|drop|chorus|estribillo' ;;
    *) PALABRAS_ROL="$ROL" ;;
  esac
  printf '%s' "$NOMBRE" | grep -Eiq "$PALABRAS_ROL" || NOMBRE="${ROL}_${NOMBRE}"
fi
[ -n "$SALIDA" ] || SALIDA=$(dirname "$ENTRADA")
mkdir -p "$SALIDA"
BPM_TXT=$(awk "BEGIN{printf \"%g\", $BPM}")
COMP_TXT=$(awk "BEGIN{printf \"%g\", $COMPASES}")
DESTINO="$SALIDA/${NOMBRE}_${BPM_TXT}bpm_${COMP_TXT}c.mp4"

# al estirar, los cuadros intermedios se interpolan (si no, la cámara lenta repite cuadros y va a saltos)
if [ "$(calc "$ESTIRA > 1.0005")" = "1.000000" ]; then RITMO="minterpolate=fps=$FPS:mi_mode=blend"; else RITMO="fps=$FPS"; fi
ENCUADRE="scale=$ANCHO:$ALTO:force_original_aspect_ratio=increase,crop=$ANCHO:$ALTO,setsar=1"
ORIGEN="[0:v]"; PREVIO=""
if [ ${#TOMAS[@]} -gt 1 ]; then
  # varias tomas: se igualan de tamaño y se pegan una detrás de otra antes de conformar
  ETIQ=""
  for i in "${!TOMAS[@]}"; do PREVIO="$PREVIO[$i:v]$ENCUADRE,format=yuv420p,settb=AVTB,setpts=PTS-STARTPTS[t$i];"; ETIQ="$ETIQ[t$i]"; done
  PREVIO="$PREVIO${ETIQ}concat=n=${#TOMAS[@]}:v=1:a=0[unidas];"
  ORIGEN="[unidas]"
fi
BASE="$PREVIO${ORIGEN}trim=start=$DESDE,setpts=(PTS-STARTPTS)*$ESTIRA,$RITMO,$ENCUADRE"
if [ "$(calc "$FUND > 0")" = "1.000000" ]; then
  # el primer tramo del loop es una mezcla: empieza siendo lo que viene justo después del final
  # y termina siendo el principio, así el último cuadro empalma con el primero sin salto
  FILTRO="$BASE,split=3[a][b][c];\
[a]trim=start=$LARGO:end=$NECESITA,setpts=PTS-STARTPTS[cola];\
[b]trim=start=0:end=$FUND,setpts=PTS-STARTPTS[cabeza];\
[cola][cabeza]blend=all_expr='A*(1-T/$FUND)+B*(T/$FUND)'[union];\
[c]trim=start=$FUND:end=$LARGO,setpts=PTS-STARTPTS[resto];\
[union][resto]concat=n=2:v=1:a=0,format=yuv420p[v]"
else
  FILTRO="$BASE,trim=end=$LARGO,setpts=PTS-STARTPTS,format=yuv420p[v]"
fi

if [ ${#TOMAS[@]} -gt 1 ]; then printf 'Entrada:  %s tomas seguidas (%.2f s en total)\n' "${#TOMAS[@]}" "$DUR"
else printf 'Entrada:  %s (%.2f s)\n' "$ENTRADA" "$DUR"; fi
printf '%s %s compases a %s BPM = %.3f s = %s cuadros a %s fps\n' "$([ "$ENTERO" = "1" ] && printf 'Entero:  ' || printf 'Loop:    ')" "$COMP_TXT" "$BPM_TXT" "$LARGO" "$CUADROS" "$FPS"
case "$ROL" in
  intro|groove|break) printf 'Rol:      %s · loop con empalme %s\n' "$ROL" "$([ "$(calc "$FUND > 0")" = "1.000000" ] && printf 'fundido' || printf 'seco')" ;;
  subida) printf 'Rol:      subida · una pasada; en el motor se estira a la subida y acaba en el drop\n' ;;
  coro) printf 'Rol:      coro · entra en el 1 del drop desde su primer cuadro y vuelve al impacto cada %s compases\n' "$COMP_TXT" ;;
esac
[ "$EXACTO" = "1" ] || printf 'Aviso:    a %s fps el loop no cae en un cuadro exacto (se redondea). Con 120 BPM o loops de 4 u 8 compases a 128 es exacto.\n' "$FPS"
if [ "$ENTERO" = "1" ]; then
  printf 'Encaje:   la toma de %.2f s pasa a %.2f s (×%.3f, %s)\n' "$DISP" "$NECESITA" "$ESTIRA" "$([ "$(calc "$ESTIRA > 1")" = "1.000000" ] && printf 'más lenta' || printf 'más rápida')"
  [ "$(calc "$ESTIRA > 1.6 || $ESTIRA < 0.6")" = "1.000000" ] && printf 'Aviso:    el cambio de velocidad es grande y se notará; mejor generar tomas que sumen cerca de %.1f s.\n' "$NECESITA"
else
  [ "$(calc "$ESTIRA > 1.0005")" = "1.000000" ] && printf 'Estirado: el trozo útil dura %.2f s; se ralentiza ×%.2f para cubrir el loop\n' "$DISP" "$ESTIRA"
fi
[ "$(calc "$ESTIRA > 3")" = "1.000000" ] && printf 'Aviso:    estirar más de ×3 suele verse a saltos; mejor un video más largo o menos compases.\n'

if [ -n "$MBPS" ]; then
  CALIDAD="-b:v ${MBPS}M -maxrate ${MBPS}M -bufsize $(awk "BEGIN{printf \"%d\", $MBPS*2}")M"
else
  CALIDAD="-crf 18"
fi
printf 'Salida:   %s a %s fps · %s\n' "$TAM" "$FPS" "$([ -n "$MBPS" ] && printf '%s Mbps' "$MBPS" || printf 'calidad constante')"

# shellcheck disable=SC2086
ENTRADAS=()
for T in "${TOMAS[@]}"; do ENTRADAS+=(-i "$T"); done
ffmpeg -hide_banner -loglevel error -y "${ENTRADAS[@]}" -filter_complex "$FILTRO" -map "[v]" -an \
  -frames:v "$CUADROS" -r "$FPS" -c:v libx264 -preset slow $CALIDAD -pix_fmt yuv420p -movflags +faststart "$DESTINO"
printf 'Listo:    %s\n' "$DESTINO"

if [ "$HAP" = "1" ]; then
  ffmpeg -hide_banner -loglevel error -y -i "$DESTINO" -an -c:v hap -format hap_q "${DESTINO%.mp4}.mov"
  printf 'Listo:    %s (HAP Q para Resolume)\n' "${DESTINO%.mp4}.mov"
fi
