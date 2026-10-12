# Motor Visual PR

Motor de visuales en vivo para sets DJ, hecho a medida del logo **PR**. Funciona sin instalar nada y sin internet: es un único archivo, `motor-visual-pr.html`, que se abre en Chrome.

La idea es que la narrativa del set ya venga programada, en lugar de montarla clip a clip como en Resolume:

| Sección | Qué hace la imagen |
|---|---|
| **Intro** | El logo se dibuja trazo a trazo durante 4 compases; de fondo, la onda de kick suave |
| **Groove** | Color base. El logo late con cada kick (su onda se "dispara"); barras y diagonales cambian cada 8 compases |
| **Break** | Colores fríos y desaturados, trazos que flotan y se separan, estelas largas, sin pulso |
| **Subida** | La tensión sube sola durante N compases: color hacia el de tensión, trazos que se abren y vibran, redoble visual que acelera (negras → corcheas → semicorcheas), strobe en la segunda mitad y blackout en el último tiempo |
| **Drop** | Golpe de flash, color de acento, trazos apretados, onda de kick en espejo. Dura 16 compases y vuelve solo al groove |

Son dos capas, como pediste: **1 · Fondo** (tus clips de video, o el fondo generativo con barras, diagonales con los ángulos del logo y onda de kick) y **2 · Logo PR**.

## Uso rápido

1. Abre `motor-visual-pr.html` en **Chrome** (Safari no tiene Web MIDI).
2. Pulsa **Abrir ventana de salida**, arrástrala al proyector, haz clic en ella y pulsa `Enter`. La ventana principal queda como monitor y control.
3. Durante el set solo necesitas las teclas `1`–`5` (secciones) y `Espacio` (marcar el 1).

| Tecla | Acción |
|---|---|
| `1` – `5` | Intro, Groove, Break, Subida, Drop (entran en el siguiente tiempo) |
| `Espacio` | Marcar el 1 del compás (alinea las frases) |
| `T` | Tap tempo (empieza a tocar en el 1) |
| `F` / `B` / `S` | Flash / Blackout / Strobe mientras mantienes la tecla |
| `↑` `↓` | Tensión manual |
| `C` | Siguiente clip |
| `A` | Modo auto |
| `Enter` | Pantalla completa |

## Clips de video

- Pulsa **Elegir carpeta** (o **Añadir clips**, o arrástralos sobre la página). Hay que volver a cargarlos cada vez que abres el motor.
- Si el nombre del archivo incluye `intro`, `groove`, `break`, `subida` (o `build`) o `drop`, el clip solo se usa en esa sección. Si no, vale para todas. También se cambia a mano con los botones I G B S D de cada clip.
- Los cortes caen siempre en el compás: cada 4, 8 o 16 compases (eliges tú). En la subida se aceleran solos (cada 2 compases y luego cada compás) y el drop siempre corta a un clip nuevo. Cada corte arranca en un punto al azar del clip para que no se repita igual.
- El clip siguiente queda preparado antes del corte. En la subida se deja listo el del drop, así el corte del drop es inmediato y sin cuadros negros.
- **Teñir con la paleta** pasa el clip a blanco y negro y lo colorea con el color de la sección (base, tensión o acento). Así cualquier material mantiene tu identidad.
- **Velocidad según la sección**: el clip va más lento en el break, se acelera con la tensión de la subida y un poco más rápido en el drop.
- El kick abre el brillo del clip, y el logo lleva un contorno oscuro para leerse sobre cualquier imagen.

**Formatos**: Chrome reproduce MP4 (H.264) y WebM. Los códecs de VJ como HAP o DXV no funcionan en el navegador. Para convertir una carpeta con ffmpeg:

```bash
for f in *.mov; do ffmpeg -i "$f" -c:v libx264 -crf 18 -pix_fmt yuv420p -an "${f%.*}.mp4"; done
```

## Sincronizar con Traktor (Mac)

Los nombres exactos de los menús pueden variar un poco según tu versión de Traktor.

**Tempo por MIDI clock**
1. En *Configuración de Audio MIDI* → *Ventana* → *Mostrar estudio MIDI*, abre **IAC Driver** y marca *El dispositivo está conectado*.
2. En Traktor: *Preferences → Controller Manager → Add… → Generic MIDI*, con **Out-Port: IAC Driver Bus 1**.
3. En *Preferences → MIDI Clock* activa el envío de MIDI Clock y enciéndelo en el panel Master Clock.
4. En el motor: *Tempo y sincronía → MIDI clock de Traktor* y acepta el permiso de MIDI. El indicador pasa a verde.
5. Pulsa `Espacio` en un 1 para alinear los compases.

**Audio (para que el logo lata con el kick real y para el modo auto)**
- Mismo Mac: instala **BlackHole 2ch**, crea un *Dispositivo agregado* con tu controladora y BlackHole, y manda el Master de Traktor también a los canales de BlackHole. En el motor elige *Audio → Entrada de audio → BlackHole*.
- Mixer externo: lleva la salida REC o Booth a la entrada de una interfaz de audio y elígela aquí.

**Controles MIDI**: en el grupo *MIDI*, pulsa **Aprender** junto a una acción y mueve un control. Si mapeas la misma perilla al filtro de Traktor y a **Tensión**, el audio y la imagen suben juntos.

## Modo auto (experimental)

Con audio conectado, el motor detecta las secciones por su cuenta:
- **Break**: el bajo desaparece durante un compás.
- **Subida**: en el break, los agudos crecen (redobles, ruido que sube).
- **Drop**: el bajo vuelve con fuerza. Entra en el mismo instante, sin esperar al tiempo.

Puedes pulsar secciones a mano en cualquier momento. Probado con una pista sintética a 126 BPM: detecta el break unos 2 s después de empezar, la subida unos 0,3 s después y el drop en menos de 0,1 s. Los cortes de bajo en las mezclas (EQ) pueden provocar breaks falsos; en esos casos vuelve con `2`.

## Cómo modificarlo

Todo está en `motor-visual-pr.html`, en bloques comentados:

| Quieres cambiar… | Busca |
|---|---|
| Colores y paletas | `PALETAS` |
| Cómo se ve cada sección (color, estela, apertura de trazos, velocidad) | `function objetivos` |
| Cuánto dura el drop | `DROP_COMPASES` |
| Qué patrón de fondo usa cada sección | `function patrones` |
| La forma del logo | `LOGO` (coordenadas sobre la imagen original; se cambiará por el vector) |
| Cuándo cortan los clips | `function tocaCorte` |
| El tinte de los clips | `function dibujarClip` |
| La forma de la onda de kick | `function envKick` |
| Sensibilidad del modo auto | `function autoNarrativa` |

Los ajustes (paleta, capas, BPM, mapeo MIDI) se guardan en el navegador.

**Seguridad**: *Strobe seguro* viene activado y limita los destellos a 3 por segundo como máximo (por encima de esa frecuencia hay riesgo para personas con fotosensibilidad). Si lo desactivas, avisa al público.
