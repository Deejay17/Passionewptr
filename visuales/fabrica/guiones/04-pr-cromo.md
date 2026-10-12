# Guion de loop: Logo PR en cromo negro

| | |
|---|---|
| Archivo final | `tema_pr_cromo_120bpm_8c.mp4` |
| BPM de producción | 120 (8 compases = 16 s; un tiempo = 30 cuadros exactos a 60 fps) |
| Compases | 8 |
| Tipo | Loop (o tema de entrada del set) |
| Sección / mood | Intro y drop · **Sacro** o **Perreo** |
| Formato | 2048 × 1024 (master 3840 × 1920), 60 fps, sin audio |
| Paleta | Fondo `#000000` · cromo negro · luz blanca fría |
| Ruta | **3D por script** (Blender), con el vector oficial del logo |

## La idea en una frase

El símbolo PR como objeto real: metal oscuro flotando en la niebla, vivo con la percusión.

## Qué se ve

El logo extruido en 3D, **cromo negro** con bordes biselados que atrapan la luz, flotando en el centro. Niebla volumétrica baja. Un único haz cenital. La **onda de kick** del logo se ilumina como un neón blanco que recorre la onda en cada golpe. Sin fondo: negro absoluto.

## Rejilla

| Compás | Qué pasa | En el tiempo |
|---|---|---|
| 1–2 | El logo gira despacio (−15° → 0°), reflejos que barren el metal | La onda se enciende en cada negra |
| 3–4 | Cámara se acerca; la niebla sube | Destello en el filo del bisel en el 1 |
| 5–6 | Encuadre frontal; un haz de luz recorre los trazos de izquierda a derecha | La onda en corcheas |
| 7–8 | Vuelve al giro y encuadre del compás 1 | Para el empalme |

## Cómo se hace

- Importar el SVG oficial en Blender, extruir 4–6 mm a escala y biselar 0,5 mm.
- Material: metálico 1, rugosidad 0,15, color casi negro; un entorno HDRI de estudio oscuro para los reflejos.
- Animación con fotogramas clave en múltiplos de 30 cuadros (un tiempo a 120 BPM), así el loop es exacto sin conformar.
- Render a 60 fps, 2048 × 1024 (o 3840 × 1920 para el master), en una GPU en la nube.
- Mientras llega el vector, el motor ya tiene un **acabado cromo** para el logo en vivo (Capas → Acabado del logo).

## Conformar

No hace falta si el render ya mide 8 compases exactos; para la copia de Resolume:

```bash
bash conformar.sh render_pr.mp4 120 8 --perfil psicoroom --hap --fundido 0 --nombre tema_pr_cromo
```
