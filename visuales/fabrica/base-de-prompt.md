# Base de prompt y protocolo de video

## El protocolo, en corto

Los visuales son de dos clases: los **procedurales**, que el motor dibuja en vivo y ya van al golpe, y los **videos**, que hay que encajar. Para que cualquier video encaje solo, en cualquier canción, todos se piden igual y traen cuatro señales:

| Señal | Qué es | Quién la lee |
|---|---|---|
| **Rejilla de 120 BPM** | Un compás cada 2 s, bloques de 2 s en el prompt, tomas de 8 s = 4 compases | El motor lo lleva al BPM real de la canción (95, 100, 128…) |
| **Testigo** | Un puntito abajo a la derecha que destella en cada tiempo | El motor marca un golpe en cada destello y lo tapa en el show |
| **Luz del momentum** | El instante más luminoso del video es el que cae en el 1 (en una subida, el blanco final) | El motor pone ahí el momentum |
| **Nombre del archivo** | `rol_mood_idea_120bpm_4c_m4s.mp4`: rol, BPM, compases y el segundo del momentum (`m4s`) | El motor lo coloca en su sección, lo amarra y busca la luz cerca de ese segundo |

El **generador** está en el motor (grupo *Prompt para video*): rol + mood + qué se ve → el prompt y el nombre. Para una canción entera, el [Lector de pistas](lector-de-pistas.html) lee el audio y arma la lista de una vez, con los roles que tiene la canción y la subida en las tomas que pida su largo. Los colores salen de la paleta del mood, con palabras, y si no escribes nada usa la escena del mood (el humo a contraluz, la catedral, las hélices de puntos…).

Al **cargar** un video con ese nombre, el motor ya sabe dónde está el momentum y lo afina solo con la luz: no hay que abrir *Golpes*. Si el generador no respetó el testigo, el momentum se queda donde dice el nombre y el tempo a 120, que suele bastar.

Qué hace el generador con cada rol (toma de 8 s):

| Rol | Estructura | Momentum (`m`) | Nombre |
|---|---|---|---|
| Intro | Aparece de la oscuridad y vuelve | 0 s | `intro_…_120bpm_4c_m0s` |
| Groove | Movimiento constante, sin clímax | 0 s | `groove_…_120bpm_4c_m0s` |
| Break | Casi quieto, el centro vacío | 0 s | `break_…_120bpm_4c_m0s` |
| Subida | Acelera y termina en blanco | 8 s (el blanco final) | `subida_…_120bpm_4c_m8s` |
| Coro | 8, 4 o 0 tiempos de previos, golpe de luz y energía sostenida | 4, 2 o 0 s | `coro_…_120bpm_2c_m4s` |

Una subida de 8 compases o más sale mejor en varias tomas seguidas (una por cada 4 compases, hasta 4), cada una desde el último fotograma de la anterior y con el blanco solo al final de la última. Unidas, el nombre lleva el total: `subida_…_120bpm_8c_m16s`. El Lector de pistas las escribe ya repartidas.

Si unes tomas o pasas el video por `conformar.sh`, conserva el final del nombre (`_120bpm_…_m…s`) o vuelve a marcar el momentum en *Golpes*.

## La base, paso a paso

Lo que va en **todos** los prompts de video, para que después el motor pueda encajar el clip solo. Se pega la base y debajo los bloques del rol (los de [`roles.md`](roles.md)).

Lleva dos ayudas:

| Ayuda | Para qué | Qué hace el motor con ella |
|---|---|---|
| **El testigo**: un puntito diminuto en la esquina de abajo a la derecha que destella en cada tiempo | Contar el ritmo del video, a ojo o automáticamente | **Detectar por la luz** (en *Golpes*) encuentra la esquina, marca un golpe en cada destello y la tapa con negro en el show |
| **La luz del momentum**: el momento más emocionante es también el más luminoso | Encontrar el momentum sin buscarlo cuadro a cuadro | **Detectar por la luz** lo pone en el golpe de luz más fuerte (en una subida, en el blanco final) |

Pide siempre **120 BPM**: dos destellos por segundo, un compás cada 2 s y una toma de 8 s son 4 compases justos. El motor lo lleva luego al BPM real de la canción.

## La base

```
Ultra wide 2:1 cinematic shot, pure black background, no text, no logos, no camera cuts.
RHYTHM MARKER: a tiny white dot in the bottom-right corner, right at the edge, flashes
briefly twice per second (on every beat at 120 BPM) and stays dark between flashes.
It never moves, it is the only thing in that corner, and nothing else flashes like it.
```

Y una línea de luz según el rol:

| Rol | Línea de luz |
|---|---|
| Intro, groove, break | `Steady light level all the way through: no sudden flashes.` (el único destello es el testigo) |
| Subida | `The light grows until the very last frame is pure blinding white: the brightest moment of the video.` |
| Coro | `At 00:04 a sudden burst of blinding white light floods the frame: the brightest moment of the video. Low light before it.` |

## Ejemplo: coro con 8 tiempos de previos

Los 4 primeros segundos son los previos (8 tiempos a 120 BPM), el momentum cae en el segundo 4 y los 4 últimos sostienen la energía. En el motor, con drop automático, el clip arranca 8 tiempos antes del drop y el golpe de luz cae justo en el drop.

```
Ultra wide 2:1 cinematic shot, pure black background, no text, no logos, no camera cuts.
RHYTHM MARKER: a tiny white dot in the bottom-right corner, right at the edge, flashes
briefly twice per second (on every beat at 120 BPM) and stays dark between flashes.
It never moves, it is the only thing in that corner, and nothing else flashes like it.
A colossal faceless nun silhouette in a ruined gothic nave, lit only by candles.
[00:00-00:04] Low light, the camera slowly pushes in, embers rising, tension building.
[00:04-00:05] MOMENTUM: a sudden burst of blinding white light floods the frame behind
the figure, the brightest moment of the video, embers exploding outward.
[00:05-00:08] The light settles into a strong golden glow, slow orbit around the figure.
```

Después, en el motor: *Golpes* → **Detectar por la luz**. Si el testigo salió bien, marca los 16 golpes y elige tempo fijo; si no, al menos encuentra el momentum, y basta marcar otro golpe a mano.

## Lo que hay que saber

- **El testigo es una petición, no una garantía.** Los generadores lo siguen más o menos: a veces lo olvidan, lo mueven o destellan a destiempo. Si sale mal, la luz del momentum sigue sirviendo y los golpes se marcan a mano.
- **Que no se vea en el show.** El motor tapa con negro la esquina del testigo (un 10 % del ancho por un 14 % del alto) y `conformar.sh --tapar id` hace lo mismo en el archivo. Por eso va pegado al borde y sin nada alrededor.
- **Un solo destello por tiempo.** Si la escena tiene luces que parpadean (estrobos, rayos), pide que no lo hagan en esa esquina, o el detector las confundirá con el testigo.
- **Nuestros propios clips no lo necesitan.** Lo que sale de [Remotion](remotion/) ya va exacto al cuadro.
