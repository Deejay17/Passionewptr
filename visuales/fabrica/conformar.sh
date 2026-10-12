#!/usr/bin/env bash
# conformar.sh
#
# Convierte cualquier video (IA, 3D, grabado) en un loop exacto para el Motor Visual PR:
# lo recorta a N compases de un BPM (o lo estira si se queda corto), funde el final con el
# principio para que el empalme no se note, lo pasa a H.264 y le pone el BPM en el nombre.
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
#
# Ejemplo:
#   bash conformar.sh humo.mov 128 8 --nombre break_humo
#   → break_humo_128bpm_8c.mp4   (8 compases a 128 BPM = 15 s exactos, empalme invisible)
#
# Pensado para macOS (bash 3.2 + herramientas BSD); también funciona en Linux.
# Requiere ffmpeg y ffprobe (en Mac: brew install ffmpeg).

set -Eeuo pipefail

error() { printf 'Error: %s\n' "$*" >&2; exit 1; }
calc() { awk "BEGIN{printf \"%.6f\", ($1)}"; }   # entre paréntesis: en awk, «>» suelto sería una redirección
es_numero() { printf '%s' "$1" | grep -Eq '^[0-9]+([.][0-9]+)?$'; }

case "${1:-}" in -h|--help) sed -n '2,28p' "$0"; exit 0 ;; esac
[ $# -ge 3 ] || { sed -n '2,28p' "$0" >&2; exit 2; }

ENTRADA="$1"; BPM="$2"; COMPASES="$3"; shift 3
DESDE=0; FUNDIDO=1; NOMBRE=""; SALIDA=""; TAM="1920x1080"; FPS=30; MBPS=""; HAP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --desde) DESDE="${2:-}"; shift 2 ;;
    --fundido) FUNDIDO="${2:-}"; shift 2 ;;
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
[ -f "$ENTRADA" ] || error "no encuentro el archivo: $ENTRADA"
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

# tiempos de la rejilla
LARGO=$(calc "$COMPASES * 240 / $BPM")          # duración del loop
FUND=$(calc "$FUNDIDO * 60 / $BPM")             # duración del fundido del empalme
NECESITA=$(calc "$LARGO + $FUND")
CUADROS=$(awk "BEGIN{printf \"%d\", $LARGO * $FPS + 0.5}")
EXACTO=$(awk "BEGIN{d=$LARGO*$FPS-int($LARGO*$FPS+0.5); if(d<0)d=-d; print (d<0.001)?1:0}")

DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$ENTRADA" 2>/dev/null || true)
es_numero "${DUR:-x}" || DUR=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=nw=1:nk=1 "$ENTRADA" 2>/dev/null || true)
es_numero "${DUR:-x}" || error "no pude leer la duración de $ENTRADA (¿es un video?)"
DISP=$(calc "$DUR - $DESDE")
[ "$(calc "$DISP > 0.1")" = "1.000000" ] || error "--desde $DESDE queda fuera del video (dura $DUR s)"

# si el trozo disponible no alcanza, se estira (cámara lenta) hasta cubrir el loop y el fundido
ESTIRA=$(calc "($NECESITA > $DISP) ? $NECESITA / $DISP : 1")

# nombre de salida: base_128bpm_8c.mp4 (el motor lee el BPM del nombre)
if [ -z "$NOMBRE" ]; then NOMBRE=$(basename "$ENTRADA"); NOMBRE="${NOMBRE%.*}"; fi
[ -n "$SALIDA" ] || SALIDA=$(dirname "$ENTRADA")
mkdir -p "$SALIDA"
BPM_TXT=$(awk "BEGIN{printf \"%g\", $BPM}")
COMP_TXT=$(awk "BEGIN{printf \"%g\", $COMPASES}")
DESTINO="$SALIDA/${NOMBRE}_${BPM_TXT}bpm_${COMP_TXT}c.mp4"

# al estirar, los cuadros intermedios se interpolan (si no, la cámara lenta repite cuadros y va a saltos)
if [ "$(calc "$ESTIRA > 1.0005")" = "1.000000" ]; then RITMO="minterpolate=fps=$FPS:mi_mode=blend"; else RITMO="fps=$FPS"; fi
BASE="[0:v]trim=start=$DESDE,setpts=(PTS-STARTPTS)*$ESTIRA,$RITMO,scale=$ANCHO:$ALTO:force_original_aspect_ratio=increase,crop=$ANCHO:$ALTO,setsar=1"
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

printf 'Entrada:  %s (%.2f s)\n' "$ENTRADA" "$DUR"
printf 'Loop:     %s compases a %s BPM = %.3f s = %s cuadros a %s fps\n' "$COMP_TXT" "$BPM_TXT" "$LARGO" "$CUADROS" "$FPS"
[ "$EXACTO" = "1" ] || printf 'Aviso:    a %s fps el loop no cae en un cuadro exacto (se redondea). Con 120 BPM o loops de 4 u 8 compases a 128 es exacto.\n' "$FPS"
[ "$(calc "$ESTIRA > 1.0005")" = "1.000000" ] && printf 'Estirado: el trozo útil dura %.2f s; se ralentiza ×%.2f para cubrir el loop\n' "$DISP" "$ESTIRA"
[ "$(calc "$ESTIRA > 3")" = "1.000000" ] && printf 'Aviso:    estirar más de ×3 suele verse a saltos; mejor un video más largo o menos compases.\n'

if [ -n "$MBPS" ]; then
  CALIDAD="-b:v ${MBPS}M -maxrate ${MBPS}M -bufsize $(awk "BEGIN{printf \"%d\", $MBPS*2}")M"
else
  CALIDAD="-crf 18"
fi
printf 'Salida:   %s a %s fps · %s\n' "$TAM" "$FPS" "$([ -n "$MBPS" ] && printf '%s Mbps' "$MBPS" || printf 'calidad constante')"

# shellcheck disable=SC2086
ffmpeg -hide_banner -loglevel error -y -i "$ENTRADA" -filter_complex "$FILTRO" -map "[v]" -an \
  -frames:v "$CUADROS" -r "$FPS" -c:v libx264 -preset slow $CALIDAD -pix_fmt yuv420p -movflags +faststart "$DESTINO"
printf 'Listo:    %s\n' "$DESTINO"

if [ "$HAP" = "1" ]; then
  ffmpeg -hide_banner -loglevel error -y -i "$DESTINO" -an -c:v hap -format hap_q "${DESTINO%.mp4}.mov"
  printf 'Listo:    %s (HAP Q para Resolume)\n' "${DESTINO%.mp4}.mov"
fi
