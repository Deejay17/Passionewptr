# Motor Visual PR

Motor de visuales en vivo para sets DJ, hecho a medida del logo **PR**. Es la pieza visual de [PRotocolive](../PROTOCOLIVE.md). Funciona sin instalar nada y sin internet: es un único archivo, `motor-visual-pr.html`, que se abre en Chrome.

La idea es que la narrativa del set ya venga programada, en lugar de montarla clip a clip como en Resolume:

| Sección | Qué hace la imagen |
|---|---|
| **Intro** | El logo se dibuja trazo a trazo durante 4 compases sobre un campo de partículas |
| **Groove** | Color base. El logo late con cada kick (su onda se "dispara"); el fondo pasa por barras, haces de luz y diagonales cada 8 compases |
| **Break** | Colores fríos y desaturados, trazos que flotan y se separan, partículas con estelas largas, sin pulso |
| **Subida** | La tensión sube sola durante N compases: color hacia el de tensión, trazos que se abren y vibran, haces que barren cada vez más rápido, redoble visual que acelera (negras → corcheas → semicorcheas), strobe en la segunda mitad y blackout en el último tiempo |
| **Drop** | Golpe de flash y la pantalla entera del color de acento con el logo en silueta negra (4 compases), luego onda de kick en espejo y barras. Dura 16 compases y vuelve solo al groove |

Son dos capas, como pediste:
- **1 · Fondo**: tus clips de video o el fondo generativo (barras, diagonales con los ángulos del logo, onda de kick, partículas, haces de luz, lavado de color). Se puede partir en **paneles LED** verticales: una imagen que cruza todos, la misma repetida o en espejo.
- **2 · Logo y texto**: el logo PR, un texto con letras muy espaciadas (nombre del evento, fecha) o los dos. El aire entre letras se abre con la tensión, igual que los trazos del logo.

## Moods

Un **mood** es el look completo: paleta, qué fondo sale en cada sección y paneles. Las secciones cuentan la historia dentro de cada tema; el mood cambia entre temas o entre partes de la noche (warm-up, peak time, cierre).

| Mood | Look |
|---|---|
| **Líneas** | El primer motor: trazos, barras y diagonales con los ángulos del logo, en ultravioleta |
| **Escenario** | Partículas, haces de luz y la pantalla roja con el logo en silueta en el drop. Paleta **Arena**, sacada de las referencias: azul en el groove y los breaks, blanco frío en la tensión, rojo en el drop |
| **Pared LED** | El escenario partido en 12 columnas, como una pared de pantallas |
| **Sacro** | Oro de vela sobre negro absoluto, haces cenitales y brasas; logo en cromo. Momentos pop y vocales |
| **Bio-Hazard** | Verde mutágeno, códigos de alarma que corren y franjas de peligro rojas en el drop. Drops pesados |
| **Perreo** | Blanco y negro brutal, frases en tipografía de brocha y estrobo; logo en cromo |

Sacro, Bio-Hazard y Perreo son los bloques del show de Halloween y mantienen el **fondo negro absoluto** para que respiren las luces y los láseres.

- Se cambia con `M` (o con los botones bajo las secciones) y entra en el siguiente tiempo.
- Cada mood recuerda tus cambios de paleta y paneles. **Restablecer el mood actual** vuelve al original.
- Opción **Pasar al siguiente mood en cada drop**, para que cada drop estrene look.
- Para crear un mood nuevo se añade una entrada en `MOODS` dentro del HTML.

## Uso rápido

1. Abre `motor-visual-pr.html` en **Chrome** (Safari no tiene Web MIDI).
2. Pulsa **Abrir ventana de salida**, arrástrala al proyector, haz clic en ella y pulsa `Enter`. La ventana principal queda como monitor y control; con **Pantalla completa** (arriba a la derecha, o `Mayús` + `Enter`) la interfaz entera ocupa la pantalla del portátil, como una mesa de control.
3. Durante el set solo necesitas las teclas `1`–`5` (secciones) y `Espacio` (marcar el 1).

| Tecla | Acción |
|---|---|
| `1` – `5` | Intro, Groove, Break, Subida, Drop (entran en el siguiente tiempo) |
| `Espacio` | Marcar el 1 del compás (alinea las frases) |
| `T` | Tap tempo (empieza a tocar en el 1) |
| `F` / `B` / `S` / `I` / `G` | Flash / Blackout / Strobe / Invert / Glitch mientras mantienes la tecla |
| `↑` `↓` | Tensión manual |
| `C` | Siguiente loop |
| `L` | Lanzar el siguiente tema en el 1 |
| `K` | Parar el tema |
| `M` | Siguiente mood |
| `P` | Frase de impacto |
| `O` | Logo visible o apagado |
| `X` | Capa 2: logo, texto o ambos |
| `A` | Modo auto |
| `Enter` | Pantalla completa de la salida |
| `Mayús` + `Enter` | Toda la interfaz a pantalla completa (modo cabina) |

## Momentos de impacto

- **Frases** (`P`): tipografía monumental condensada de lado a lado (de brocha en Perreo). Una palabra por tiempo o la frase entera durante un compás; entra en el siguiente tiempo y apaga el fondo mientras dura. Se escriben en *Frases de impacto*, una por línea, y se puede lanzar una en cada drop.
- **Whiteout en el drop**: golpe corto, 1 tiempo o 1 compás de blanco total (para el CO2).
- **Silueta**: sobre el blanco (whiteout, flash o strobe), el logo o la frase quedan en negro.
- **Zona segura**: las frases no se salen de la franja central del 50 % de alto; en el monitor se marca con dos líneas.
- **Tipografía propia** (por ejemplo Pirulen): *Frases de impacto → Cargar tipografía* (o arrastrar el archivo TTF, OTF, WOFF o WOFF2 a la página). Se usa en las frases y en el texto de la capa 2, y se recuerda en ese navegador. El archivo no se sube al repositorio: revisa que tu licencia cubra su uso en el show.

## Efectos de tensión

- **Blur**: crece con la tensión (la subida o la perilla manual), respira con cada tiempo y se limpia de golpe en el drop.
- **Glitch**: con el redoble de la subida salen golpes cortos de aberración de color y franjas corridas, cada vez más seguidos. También a mano, manteniendo `G`.
- Si mapeas la perilla del filtro de Traktor a **Tensión**, el filtro mueve también el blur y el glitch.
- Se activan o quitan en *Narrativa*. La cabecera muestra los **cuadros por segundo** de la salida: en verde a 55 o más. Si en tu ordenador bajan con el blur, desactívalo ahí.

## Logo

- **Trazado PR**: el logo redibujado trazo a trazo, con su onda de kick animada.
- **SVG**: *Cargar logo SVG* (o arrastrarlo a la página) usa cualquier vector, con grosor ajustable, el color de la sección, kick y tensión. Se recuerda para la próxima vez. Pensado para el vector oficial.
- **Acabado cromo negro**: reflejos metálicos que giran y destellan con el kick. Cada mood recuerda su acabado.

## Pantalla 2:1

En *Salida → Formato de la pantalla* elige **2:1 · pantalla de 6 × 3 m**: el monitor pasa a 2:1 y la salida dibuja la zona 2:1 dentro de la ventana (centrada o arriba a la izquierda, según cómo la mapee el procesador LED).

## Clips de video

Pulsa **Elegir carpeta** (o **Añadir clips**, o arrástralos sobre la página). Hay que volver a cargarlos cada vez que abres el motor; el BPM, el tipo y las secciones de cada clip sí se recuerdan por nombre.

Hay tres tipos de clip:
- **Loop**: corto, rota por sección y corta al compás. Es el relleno.
- **Tema**: un video largo hecho para una canción. Se lanza en el 1, suena entero sin cortes y al terminar vuelve el relleno. Los videos de más de 30 s, o con `tema` en el nombre, entran como tema.
- **Subida**: un video hecho para la subida. La recorre entera y su último cuadro cae justo en el drop. Entran así los que llevan `subida`, `build` o `riser` en el nombre.

### Subidas que terminan en el drop

Un clip de tipo Subida se reparte a lo largo de los compases de la subida (4, 8 o 16) a cualquier BPM: lo que pasa a la mitad del video pasa a la mitad de la subida. Mientras suena no hay cortes, y por encima siguen el blur, el glitch del redoble, el strobe y el blackout del último tiempo. En el drop entra el clip del coro desde su primer cuadro, sin retraso. En las pruebas, el video se mantuvo a 10–20 ms de su sitio de media y el coro entró en su primer cuadro en el 1 del drop.

Si hay varios clips de subida, se turnan. Para que el video no vaya a cámara lenta, conviene que dure lo mismo que la subida: [`fabrica/subida-y-coro.md`](fabrica/subida-y-coro.md) explica cómo escribir el prompt por compases y cómo encajarlo con `conformar.sh --entero`.

### Temas sincronizados

Si el clip tiene **BPM** (escrito en la lista o en el nombre, como `tema_intro_128bpm.mp4`), queda amarrado a la sesión:
- Su velocidad sigue al tempo: un video hecho a 128 en una sesión a 124 va al 96,9 %, y si el DJ sube el pitch, el video sube con él.
- Su posición sigue a la rejilla de compases y se corrige sola. En las pruebas, el desfase se mantuvo entre 2 y 15 ms, menos de medio cuadro de video.

Para lanzarlo en el momento justo:
1. Al oír el **primer tiempo del tema**, pulsa `Espacio` (marca el 1).
2. Pulsa `L` cuando quieras durante los 8 compases siguientes: el video entra ya, alineado a ese 1 (si pasaron 3 segundos, entra 3 segundos adentro).
3. Si no marcaste el 1, `L` lo hace entrar en el próximo 1.
4. Si quedó corrido, **−1 compás** / **+1 compás** lo corrige en vivo.

### Marcar los golpes de un video (el warp)

Un video hecho con IA casi nunca tiene su primer golpe en el primer cuadro, ni sus golpes a un tempo exacto. Con el botón **Golpes** de cada clip se le dice dónde caen, como la rejilla de Traktor o los marcadores de warp de Ableton:

1. Busca el cuadro del primer golpe fuerte (clic en la línea de tiempo y `←` `→` cuadro a cuadro) y pulsa **Aquí cae el golpe 1**. Es el que abre la secuencia: lo que va antes son los **previos**.
2. Ve a otro golpe claro más adelante, escribe su número (el 9 es el 1 del compás 3; al lado se ve en compás y tiempo) y pulsa **Marcar este golpe**. Con dos marcas el motor ya sabe a qué tempo va el video y pone su BPM solo.
3. Si el video acelera o frena, marca más golpes: entre cada dos marcas el motor estira o encoge ese tramo para que todos caigan en los golpes de la música.
4. **Reproducir con clic** suena un clic en cada golpe del video (más agudo en el 1 de cada compás) para comprobar que encaja.

Qué hace el motor con las marcas:

| Tipo | Con marcas |
|---|---|
| Loop | Al empezar su sección entra en el golpe 1 (el impacto del coro cae en el 1) y repite los compases enteros que hay desde ahí |
| Tema | El golpe 1 cae en el 1 que marcaste o en el próximo, y los previos suenan antes, de modo que la entrada se oye completa |
| Subida | El golpe 1 cae al empezar la subida y la última marca, justo en el drop |

En las pruebas, un video con tres marcas a tempos distintos se mantuvo a 4 ms de media de su sitio, y un tema con 3 tiempos de previos arrancó 3 tiempos antes del 1 y llegó al 1 en su cuadro. Las marcas se recuerdan por nombre de archivo. El editor da además la línea de `conformar.sh --marcas` para que el archivo ya salga con ese warp (para Resolume o de respaldo).

### El logo sobre los videos

Cada clip decide qué hace el logo encima: **encima**, **en la esquina** (pequeño, abajo a la derecha) u **oculto**. Los temas y las subidas, que son tus videos grandes, vienen con el logo oculto y los loops con el logo encima. El cambio se hace con un fundido suave y se recuerda por nombre de archivo. En los whiteouts el logo vuelve a aparecer en silueta. La tecla `O` apaga o enciende el logo al instante.

### Loops

- Si el nombre del archivo incluye `intro`, `groove`, `break` o `drop` (también `coro` o `chorus`), el clip solo se usa en esa sección. Si no, vale para todas. También se cambia a mano con los botones I G B S D de cada clip. Un archivo con `subida` en el nombre entra como tipo Subida; si lo quieres como loop que rota en la subida, cámbialo a Loop.
- Los cortes caen siempre en el compás: cada 4, 8 o 16 compases (eliges tú). En la subida se aceleran solos (cada 2 compases y luego cada compás) si no hay un clip de tipo Subida, y el drop siempre corta a un clip nuevo.
- Al empezar una sección el clip entra desde su primer cuadro (ahí va el impacto del coro); los cortes dentro de la sección entran en un compás al azar para que no se repita igual.
- El clip siguiente queda preparado antes del corte. En la subida se deja listo el del drop, así el corte del drop es inmediato y sin cuadros negros.
- **Teñir con la paleta** pasa el clip a blanco y negro y lo colorea con el color de la sección (base, tensión o acento). Así cualquier material mantiene tu identidad.
- **Velocidad según la sección**: el clip va más lento en el break, se acelera con la tensión de la subida y un poco más rápido en el drop.
- El kick abre el brillo del clip, y el logo lleva un contorno oscuro para leerse sobre cualquier imagen.

**Formatos**: Chrome reproduce MP4 (H.264) y WebM. Los códecs de VJ como HAP o DXV no funcionan en el navegador. Para convertir una carpeta con ffmpeg:

```bash
for f in *.mov; do ffmpeg -i "$f" -c:v libx264 -crf 18 -pix_fmt yuv420p -an "${f%.*}.mp4"; done
```

## Cómo producir los videos para que vayan sincronizados

La guía completa, el script `conformar.sh` y los guiones del show están en [`fabrica/`](fabrica/README.md). Cada video se hace para un rol (intro, groove, break, subida o coro) que va en su nombre y el motor lo coloca solo: [`fabrica/roles.md`](fabrica/roles.md).

- **Elige un BPM de producción** y ponlo en el nombre: `tema_nombre_128bpm.mp4`. El motor ajusta la velocidad al BPM real de la sesión.
- **Que dure compases enteros**: a 128 BPM, 1 compás = 1,875 s y **1 minuto = 32 compases exactos**. A 120 BPM, 1 compás = 2 s.
- **Marca la rejilla en el editor** (After Effects, Premiere, DaVinci): un marcador por compás y la estructura de la canción encima (intro, subida, drop). Si el drop del video cae en el compás 17, caerá en el compás 17 del tema.
- Para cortes exactos al cuadro: a **120 BPM y 30 fps** un tiempo son 15 cuadros justos; a **125 BPM y 25 fps**, 12 cuadros.
- El primer cuadro del video es el **1** del compás 1.
- Exporta en **MP4 H.264**, 1080p, sin audio. Los loops, de 4, 8 o 16 compases.

## Sincronizar con Traktor (Mac)

Los nombres exactos de los menús pueden variar un poco según tu versión de Traktor.

**Qué puede mandar Traktor al motor**
- **Tempo** (MIDI clock): el BPM y el arranque o parada.
- **Eventos** (Controller Manager → Generic MIDI → *Add Out*): el estado de Play de cada deck y de los hotcues, entre otros. Se pueden mapear en el grupo *MIDI* a *Lanzar tema*, *Marcar el 1* o *Drop*: por ejemplo, el hotcue del drop dispara el drop visual.
- **Audio**: para el kick y el modo auto.
- **No manda** qué canción suena ni en qué punto de la canción va. Por eso el 1 lo marca una persona (`Espacio`) o un hotcue.
- Sin MIDI también funciona: alguien en el ordenador con tap tempo, `Espacio`, `L` y las teclas `1`–`5`.

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
| Los moods (looks completos) | `MOODS` |
| Colores y paletas | `PALETAS` |
| Cómo se ve cada sección (color, estela, apertura de trazos, velocidad) | `function objetivos` |
| Cuánto dura el drop | `DROP_COMPASES` |
| Qué fondo usa cada sección | `fondos` de cada mood en `MOODS` |
| La forma del logo | `LOGO` (coordenadas sobre la imagen original; se cambiará por el vector) |
| Cuándo cortan los clips | `function tocaCorte` |
| El tinte de los clips | `function dibujarClip` |
| Cómo se amarra un clip al tempo | `function amarrar` |
| Cómo recorre la subida un clip de subida | `function amarrarSubida` |
| Los golpes de un clip (el warp) | `function tDeGolpe` y, para el editor, `function abrirGolpes` |
| Cuándo entra un tema | `function lanzarTema` |
| Partículas, haces y lavado | `function dibujarParticulas`, `dibujarHaces`, `dibujarLavado` |
| Los paneles LED | `function componerPaneles` |
| El texto espaciado | `function dibujarTexto` |
| Las frases de impacto | `function lanzarFrase`, `textoFrase` |
| El logo SVG y el cromo | `function leerSvg`, `dibujarLogoSvg`, `gradCromo` |
| Códigos y franjas de alarma | `function dibujarCodigos`, `dibujarAlarma` |
| La forma de la onda de kick | `function envKick` |
| Sensibilidad del modo auto | `function autoNarrativa` |

Los ajustes (paleta, capas, BPM, mapeo MIDI) se guardan en el navegador.

**Seguridad**: *Strobe seguro* viene activado y limita los destellos a 3 por segundo como máximo (por encima de esa frecuencia hay riesgo para personas con fotosensibilidad). Si lo desactivas, avisa al público.
